import { LightningElement, api, track, wire } from 'lwc';
import { resolve } from 'c/b2B2C_cmsResourceResolver';
import { getLabelForOriginalPrice, displayOriginalPrice } from 'c/b2b_cartUtils';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';
import { updateItemInCart, deleteItemFromCart } from 'commerce/cartApi';
import wishlistModal from "c/b2b_wishlistmodal";
import communityId from '@salesforce/community/Id';
import InstockLabel from '@salesforce/label/c.InstockLabel';
import BackOrder from '@salesforce/label/c.BackOrder';
import calculateDiscountOnItem from '@salesforce/apex/B2BCartController.calculateDiscountOnItem';
import AddToList from '@salesforce/label/c.AddToList';
import SKULabel from '@salesforce/label/c.SKULabel';
import item from '@salesforce/label/c.item';
import Delete from '@salesforce/label/c.Delete';
import Discount from '@salesforce/label/c.Discount';
import TotalPrice from '@salesforce/label/c.TotalPrice';
import contextApi from 'commerce/contextApi';
import B2B_Add_To_Cart_Success_Msg from '@salesforce/label/c.B2B_Add_To_Cart_Success_Msg';
import B2B_Success_Label from '@salesforce/label/c.B2B_Success_Label';
import B2B_Error_Msg_Label from '@salesforce/label/c.B2B_Error_Msg_Label';
import B2B_Cart_Wishlist_Msg from '@salesforce/label/c.B2B_Cart_Wishlist_Msg';
import B2B_Cart_Error_Msg from '@salesforce/label/c.B2B_Cart_Error_Msg';
import B2B_Cart_Quantity_Error_Msg from '@salesforce/label/c.B2B_Cart_Quantity_Error_Msg';
const QUANTITY_CHANGED_EVT = 'quantitychanged';
const discountedCartChangeMessage = 'You can not change the cart as the Discount has been applied. If you want to add a new product or change a quantity please clear the Cart and request a new Discount';
export default class B2c_cartitems extends NavigationMixin(LightningElement) {

    labels = {
        InstockLabel,
        BackOrder,
        AddToList,
        SKULabel,
        item,
        Delete,
        Discount,
        TotalPrice,
        B2B_Add_To_Cart_Success_Msg,
        B2B_Success_Label,
        B2B_Error_Msg_Label,
        B2B_Cart_Wishlist_Msg,
        B2B_Cart_Error_Msg,
        B2B_Cart_Quantity_Error_Msg
    }

    @api currencyCode;
    @api isDiscountApplied;
    effectiveAccountId;

    discountErrorModal = false;

    @api isCartDisabled = false;

    @wire(CurrentPageReference)
    pageRef;


    @api
    get cartItems() {
        return this._providedItems;
    }

    label = {
        discountedCartChangeMessage
    }

    set cartItems(items) {
        // handleCartItemsQty(items);
        this._providedItems = items;
        const generatedUrls = [];
        this._items = (items || []).map((item) => {
            console.log('***item. ' + JSON.stringify(item));
            const newItem = { ...item };
            newItem.productUrl = '';
            if(item.ProductDetails.sku =='ELP1YR' || item.ProductDetails.sku=='ELPRENEW'  || item.ProductDetails.sku=='TBHF'){
                newItem.hidequantity=true;
            }
            else{
                newItem.hidequantity=false;
            }
            if(item.ProductDetails.sku =='TBHF'){
                newItem.hidedelete=true;
            }
            else{
                newItem.hidedelete=false;
            }
            newItem.productImageUrl = resolve(
                //item.cartItem.productDetails.thumbnailImage.url
                item.ProductDetails.thumbnailImage.url
            );
            console.log('***itemss. ' + items);
            newItem.productImageAlternativeText =
                //item.cartItem.productDetails.thumbnailImage.alternateText || '';
                item.ProductDetails.thumbnailImage.title || '';

            const urlGenerated = this._canResolveUrls
                .then(() =>
                    this[NavigationMixin.GenerateUrl]({
                        type: 'standard__recordPage',
                        attributes: {
                            recordId: newItem.ProductDetails.productId,     //newItem.cartItem.productId, 
                            objectApiName: 'Product2',
                            actionName: 'view'
                        }
                    })
                )
                .then((url) => {
                    newItem.productUrl = url;
                });
            generatedUrls.push(urlGenerated);
               return newItem; 
        });

        Promise.all(generatedUrls).then(() => {
            this._items = Array.from(this._items);
        });
        
    }
    // handleCartItemsQty(items){}
    @track _items = [];
    _providedItems;
    _connectedResolver;
    _canResolveUrls = new Promise((resolved) => {
        this._connectedResolver = resolved;
    });

    @track quantityFieldValue;

    //minus = `${iconsImg}#minus`;
    //plus = `${iconsImg}#plus`;

    connectedCallback() {
        loadStyle(this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
        this._connectedResolver();

        const result = contextApi.getSessionContext();
        
        result.then((response) => {
            this.effectiveAccountId = response.effectiveAccountId;
        }).catch((error) => {
            console.log("getSessionContext result error");
            console.log(error);
        });
    }

    disconnectedCallback() {
        this._canResolveUrls = new Promise((resolved) => {
            this._connectedResolver = resolved;
        });
    }

    get displayItems() {
        return this._items.map((item) => {
            const newItem = { ...item };
            newItem.showNegotiatedPrice =
                this.showNegotiatedPrice &&
                (newItem.data.TotalPrice || '').length > 0;
            newItem.showOriginalPrice = displayOriginalPrice(
                this.showNegotiatedPrice,
                this.showOriginalPrice,
                newItem.data.TotalPrice,
                newItem.data.TotalListPrice
            );
            newItem.originalPriceLabel = newItem.data.currencyIsoCodeValue;/*this.currencyCode;getLabelForOriginalPrice(
                this.currencyCode,
                newItem.data.TotalListPrice
            );*/
            this.currencyCode = newItem.data.currencyIsoCodeValue;
            return newItem;
        });
    }

    get labels() {
        return {
            quantity: 'QTY',
            originalPriceCrossedOut: 'Original price (crossed out):'
        };
    }

    handleProductDetailNavigation(evt) {
        evt.preventDefault();
        const productId = evt.target.dataset.productid;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: productId,
                actionName: 'view'
            }
        });
    }

    handleDeleteCartItem(clickEvt) {
        const cartItemId = clickEvt.target.dataset.cartitemid;

        deleteItemFromCart(cartItemId).then((fulfilled) => {
            console.log("added product to cart" ,fulfilled);
            this.loading = false;
            this.template.querySelector('c-b2b-show-toast-message').showToast(this.labels.B2B_Add_To_Cart_Success_Msg,this.labels.B2B_Success_Label);
        }).catch(error => {
            console.log('error' ,error);
            this.loading = false;
            this.template.querySelector('c-b2b-show-toast-message').showToast(this.labels.B2B_Add_To_Cart_Success_Msg,this.labels.B2B_Error_Msg_Label);
        });
        // this.dispatchEvent(
        //     new CustomEvent(SINGLE_CART_ITEM_DELETE, {
        //         bubbles: true,
        //         composed: true,
        //         cancelable: false,
        //         detail: {
        //             cartItemId
        //         }
        //     })
        // );
    }

    handleQuantitySelectorBlur(blurEvent) {
        blurEvent.stopPropagation();
        const cartItemId = blurEvent.target.dataset.itemId;
        const quantity = blurEvent.target.value;
        if(quantity && quantity!= null && quantity!=''){
            this.dispatchEvent(
                new CustomEvent(QUANTITY_CHANGED_EVT, {
                    bubbles: true,
                    composed: true,
                    cancelable: false,
                    detail: {
                        cartItemId,
                        quantity
                    }
                })
            );
        }else{
            this.template.querySelector('c-b2b-show-toast-message').showToast(this.labels.B2B_Cart_Quantity_Error_Msg,this.labels.B2B_Error_Msg_Label);
        }

    }

    closeModal(){
        this.discountErrorModal = false;
    }

    handleOnlyNaturalkeyup(e) {
        if(e.target.value.length==1) {
            e.target.value=e.target.value.replace(/[^1-9]/g,'')
        } else {
            e.target.value=e.target.value.replace(/\D/g,'')
        }
    }

    handleOnlyNaturalAfterPaste(e) {
        if(e.target.value.length==1) {
            e.target.value=e.target.value.replace(/[^1-9]/g,'0')
        } else {
            e.target.value=e.target.value.replace(/\D/g,'')
        }
    }

    handleQuantitySelectorClick(clickEvent) {
        clickEvent.target.focus();
    }

    handleQuantityChange(quantity, cartItemId) {
        this.dispatchEvent(
            new CustomEvent(QUANTITY_CHANGED_EVT, {
                bubbles: true,
                composed: true,
                cancelable: false,
                detail: {
                    cartItemId,
                    quantity
                }
            })
        );
    }

    notifyCreateAndAddToList() {
        this.dispatchEvent(new CustomEvent('createandaddtolist'));
    }

    addQty(event){
        event.stopPropagation();
        if(this.isDiscountApplied) {
            this.discountErrorModal = true;
        } else {
            this.quantityFieldValue = parseInt(event.target.value) + 1;
            event.target.value = this.quantityFieldValue;
            const cartItemId = event.target.dataset.itemId;
            const quantity = this.quantityFieldValue;
            this.dispatchEvent(
                new CustomEvent(QUANTITY_CHANGED_EVT, {
                    bubbles: true,
                    composed: true,
                    cancelable: false,
                    detail: {
                        cartItemId,
                        quantity
                    }
                })
            );
            //this.updateCartItemFun(cartItemId,this.quantityFieldValue);
        }
    }

    subQuanity(event){
        event.stopPropagation();
        if(this.isDiscountApplied) {
            this.discountErrorModal = true;
        } else {
            if(parseInt(event.target.value) > 1){
                this.quantityFieldValue = parseInt(event.target.value) - 1;
                event.target.value = this.quantityFieldValue;
                const quantity = this.quantityFieldValue;
                const cartItemId = event.target.dataset.itemId;
                this.dispatchEvent(
                    new CustomEvent(QUANTITY_CHANGED_EVT, {
                        bubbles: true,
                        composed: true,
                        cancelable: false,
                        detail: {
                            cartItemId,
                            quantity
                        }
                    })
                );
                //this.updateCartItemFun(cartItemId,this.quantityFieldValue);
            }else{
                this.template.querySelector('c-b2b-show-toast-message').showToast(this.labels.B2B_Cart_Error_Msg,this.labels.B2B_Error_Msg_Label);
            }
        }
    }

    async updateCartItemFun(itemId, quant){
        await updateItemInCart(itemId,quant).then((fulfilled) => {
            console.log("added product to cart" ,fulfilled);
            this.calculateDiscount(fulfilled);
            //this.loading = false;
            //this.template.querySelector('c-b2b-show-toast-message').showToast('Your cart has been updated.','success');
        }).catch(error => {
            console.log('error' ,error);
            this.loading = false;
            this.template.querySelector('c-b2b-show-toast-message').showToast(this.labels.B2B_Add_To_Cart_Success_Msg,this.labels.B2B_Error_Msg_Label);
        });
    } 

    async calculateDiscount(input){
        console.log('calculateDiscount(fulfilled)--- ', input);
        let mapParams = {
            cartItemId : input.cartItemId
        }
        await calculateDiscountOnItem({
            mapParams: mapParams
        }).then((results) => {
            console.log('calculateDiscount results- ',results);
            this.loading = false;
            this.template.querySelector('c-b2b-show-toast-message').showToast(this.labels.B2B_Add_To_Cart_Success_Msg,this.labels.B2B_Success_Label);
        }).catch((error) => {
            console.log('calculateDiscount error');
            console.log(error);
            this.loading = false;
            this.template.querySelector('c-b2b-show-toast-message').showToast(this.labels.B2B_Add_To_Cart_Success_Msg,this.labels.B2B_Error_Msg_Label);
        });
    }

    /**
     * Handles a user request to add the product to a newly created wishlist.
     * On success, a success toast is shown to let the user know the product was added to a new list
     * If there is an error, an error toast is shown with a message explaining that the product could not be added to a new list
     *
     * Toast documentation: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_toast
     *
     * @private
     */
    showModal = false;
    wishlistproductId;

    async addToList(event) {
        console.log('event.target.dataset.productid: ',event.target.dataset.productid);
        this.wishlistproductId = event.target.dataset.productid;
        this.showModal = true;
    }
    handleModalClose(event){
        let result = event.detail;
        if(result){
            this.showModal = false;
            this.template.querySelector('c-b2b-show-toast-message').showToast(this.labels.B2B_Cart_Wishlist_Msg,this.labels.B2B_Success_Label);
        } else {
            this.showModal = false;
            console.log('Some error occured.');
            //this.template.querySelector('c-b2b-show-toast-message').showToast('Some error occured.','error');
        }
    }

    get resolvedEffectiveAccountId() {
        const effectiveAccountId = this.effectiveAccountId || '';
        let resolved = null;

        if (
            effectiveAccountId.length > 0 &&
            effectiveAccountId !== '000000000000000'
        ) {
            resolved = effectiveAccountId;
        }
        return resolved;
    }
}