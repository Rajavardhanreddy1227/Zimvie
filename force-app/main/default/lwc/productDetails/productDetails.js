import { LightningElement, wire, api } from 'lwc';
import {addItemToCart} from 'commerce/cartApi';
import communityId from '@salesforce/community/Id';
import getProduct from '@salesforce/apex/B2BGetInfo.getProduct';
import getCartSummary from '@salesforce/apex/B2BGetInfo.getCartSummary';
import checkProductIsInStock from '@salesforce/apex/B2BGetInfo.checkProductIsInStock';
import addToCart from '@salesforce/apex/B2BGetInfo.addToCart';
import createAndAddToList from '@salesforce/apex/B2BGetInfo.createAndAddToList';
import getProductPrice from '@salesforce/apex/B2BGetInfo.getProductPrice';
import calculateDiscountOnItem from '@salesforce/apex/B2BCartController.calculateDiscountOnItem';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import PorductDetailsAltText from '@salesforce/label/c.PorductDetailsAltText';
import ToastContainer from 'lightning/toastContainer';
import { resolve } from 'c/cmsResourceResolver';
import {
 publish,
 MessageContext
} from "lightning/messageService";
import cartChanged from "@salesforce/messageChannel/lightning__commerce_cartChanged";
import wishlistModal from "c/b2b_wishlistmodal";
import B2B_AddToCart_SpinnerMessage from '@salesforce/label/c.B2B_AddToCart_SpinnerMessage';
import B2B_CalculateDiscount_SpinnerMessage from '@salesforce/label/c.B2B_CalculateDiscount_SpinnerMessage';
import B2B_Add_To_Cart_Error_Msg from '@salesforce/label/c.B2B_Add_To_Cart_Error_Msg';
import B2B_Error_Msg_Label from '@salesforce/label/c.B2B_Error_Msg_Label';
import B2B_Success_Label from '@salesforce/label/c.B2B_Success_Label';
import B2B_Add_To_Cart_Success_Msg from '@salesforce/label/c.B2B_Add_To_Cart_Success_Msg';
import B2B_PDP_Wishlist_Msg from '@salesforce/label/c.B2B_PDP_Wishlist_Msg';
import B2B_Loading_Message from '@salesforce/label/c.B2B_Loading_Message';
/**
 * A detailed display of a product.
 * This outer component layer handles data retrieval and management, as well as projection for internal display components.
 */
export default class ProductDetails extends LightningElement {
    labels = {
        PorductDetailsAltText,
        B2B_CalculateDiscount_SpinnerMessage,
        B2B_AddToCart_SpinnerMessage,
        B2B_Loading_Message,
        B2B_Add_To_Cart_Error_Msg,
        B2B_Error_Msg_Label,
        B2B_Success_Label,
        B2B_Add_To_Cart_Success_Msg,
        B2B_PDP_Wishlist_Msg

    };
    messageState = B2B_Loading_Message;
    hideQuantity=false;
    hideAddToCart=false;
    hideSaveForLater=false;
    @wire(MessageContext)
    messageContext;


    /**
     * Gets the effective account - if any - of the user viewing the product.
     *
     * @type {string}
     */
    @api
    get effectiveAccountId() {
        return this._effectiveAccountId;
    }

    set effectiveAccountId(newId) {
        console.log('newId====');
        console.log(JSON.stringify(newId));
        this._effectiveAccountId = newId;
        //this.updateCartInformation();
    }
    
    get loaderEnabled(){
        return this.showLoader || this.prodDetails == undefined;
    }

    @api
    recordId;

    @api
    customDisplayFields;

    @api
    showFilterOptions;

    _selectedvariant;
    @api 
    get selectedvariant(){
        return _selectedvariant;
    }
    set selectedvariant(val){
        this._selectedvariant = val;
        console.log('selected variant===');
        console.log(JSON.stringify(val));
    }

    product;
    @api 
    get prodDetails(){
        return this.product;
    }
    set prodDetails(val){
        console.log('product from context : ');
        console.log(val);
        this.product = val;
    }

    cartSummary;


    @wire(checkProductIsInStock, {
        productId: '$recordId'
    })
    inStock;


    /*@wire(getProduct, {
        communityId: communityId,
        productId: '$recordId',
        effectiveAccountId: '$resolvedEffectiveAccountId'
    })
    product;*/


    @wire(getProductPrice, {
        communityId: communityId,
        productId: '$recordId',
        effectiveAccountId: '$resolvedEffectiveAccountId'
    })
    productPrice;

    /**
     * The connectedCallback() lifecycle hook fires when a component is inserted into the DOM.
     */
    connectedCallback() {
        console.log('Testing');
        console.log('this.effectiveAccountId-->'+this.effectiveAccountId);
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';

        //this.updateCartInformation();
    }

    /**
     * Gets the normalized effective account of the user.
     *
     * @type {string}
     * @readonly
     * @private
     */
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

    /**
     * Gets whether product information has been retrieved for display.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get hasProduct() {
        return this.prodDetails !== undefined;
    }

    /**
     * Gets the normalized, displayable product information for use by the display components.
     *
     * @readonly
     */
    get displayableProduct() {
        //console.log('fetched product');
        console.log('here prod details>>>'+JSON.stringify(this.prodDetails));
        if(this.prodDetails.fields.ProductCode=='ELP1YR' || this.prodDetails.fields.ProductCode=='ELPRENEW' || this.prodDetails.fields.ProductCode=='TBHF'){
            this.hideQuantity=true;
        }
        if(this.prodDetails.fields.ProductCode=='TBHF'){
            this.hideAddToCart=true;
            this.hideSaveForLater=true;
        }
        let media=[];
        if(!!this.prodDetails.mediaGroups){
            let attachments = this.prodDetails.mediaGroups.find(attach => attach.developerName == 'attachment');
            if(!!attachments){
                media=attachments.mediaItems;
            }
        }
        return {
            categoryPath: this.prodDetails.primaryProductCategoryPath.path.map(
                (category) => ({
                    id: category.id,
                    name: category.name
                })
            ),
            isVarParent: this.prodDetails.productClass !== 'Simple',
            variantions: this.prodDetails.variationInfo?.attributesToProductMappings,
            description: this.prodDetails.fields.Description,
            image: {
                alternativeText: this.prodDetails.defaultImage.alternativeText,
                url: resolve(this.prodDetails.defaultImage.url)
            },
            mediaItems:media,
            inStock: this.inStock.data === true,
            name: this.prodDetails.fields.Name,
            price: {
                currency: ((this.productPrice || {}).data || {})
                    .currencyIsoCode,
                negotiated: ((this.productPrice || {}).data || {}).unitPrice
            },
            sku: this.prodDetails.fields.StockKeepingUnit,
            customFields: Object.entries(
                this.prodDetails.fields || Object.create(null)
            )
                .filter(([key]) =>
                    (this.customDisplayFields || '').includes(key)
                )
                .map(([key, value]) => ({ name: key, value }))
        };
    }

    /**
     * Gets whether the cart is currently locked
     *
     * Returns true if the cart status is set to either processing or checkout (the two locked states)
     *
     * @readonly
     */
    get _isCartLocked() {
        const cartStatus = (this.cartSummary || {}).status;
        return cartStatus === 'Processing' || cartStatus === 'Checkout';
    }

    /**
     * Handles a user request to add the product to their active cart.
     * On success, a success toast is shown to let the user know the product was added to their cart
     * If there is an error, an error toast is shown with a message explaining that the product could not be added to the cart
     *
     * Toast documentation: https://developer.salesforce.com/docs/component-library/documentation/en/lwc/lwc.use_toast
     *
     * @private
     */
    showLoader = false;
    /*async addToCart(event) {
        let evtResponse = event.detail;
        this.showLoader = true;
        console.log('cart method called...');
        addToCart({
            communityId: communityId,
            productId: evtResponse.prodId != null ? evtResponse.prodId : this.recordId,
            quantity: event.detail.quantity,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then(() => {
                console.log('cart method success...');
                this.dispatchEvent(
                    new CustomEvent('cartchanged', {
                        bubbles: true,
                        composed: true
                    })
                );
                publish(this.messageContext, cartChanged);
                this.showLoader = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Your cart has been updated.',
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
                //alert('Your cart has been updated.');
            })
            .catch(() => {
                this.showLoader = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message:
                            '{0} could not be added to your cart at this time. Please try again later.',
                        messageData: [this.displayableProduct.name],
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
                //alert('This could not be added to your cart at this time. Please try again later.');
            });
    }*/
    addToCart(event) {
        let evtResponse = event.detail;
        this.messageState = B2B_AddToCart_SpinnerMessage;
        this.showLoader = true;
        let prodId = evtResponse.prodId != null ? evtResponse.prodId : this.recordId;
        addItemToCart(prodId,evtResponse.quantity).then((fulfilled) => {
                console.log("added product to cart" ,fulfilled);
                if(this.prodDetails.fields.Name.includes('Enrollment')){
                    console.log("added product is includes" ,this.prodDetails.fields.Name);
                }
                //this.calculateDiscount(fulfilled);
                this.showLoader = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.labels.B2B_Success_Label,
                        message:this.labels.B2B_Add_To_Cart_Success_Msg,
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
            }).catch(error => {
                console.log('error' ,error);
                this.showLoader = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message:
                            '{0} could not be added to your cart at this time. Please try again later.',
                        messageData: [this.displayableProduct.name],
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
            });

    }

    retryAttempt = 0;
    async retryApiCallout(inputVal){
        this.messageState = B2B_Loading_Message;
        this.retryAttempt = this.retryAttempt + 1;
        this.calculateDiscount(inputVal);
    }

    calculateDiscount(input){
        if(this.retryAttempt == 1){
            this.messageState = 'Please wait';
        }else{
            this.messageState = B2B_CalculateDiscount_SpinnerMessage;
        }
        console.log('calculateDiscount(fulfilled)--- ', input);
        let mapParams = {
            cartItemId : input.cartItemId
        }
        calculateDiscountOnItem({
            mapParams: mapParams
        }).then((results) => {
            console.log('calculateDiscount results- ',results);
            if(!results.isSuccess){
                if(this.retryAttempt < 2){
                    this.retryApiCallout(input);
                }else{
                    this.showLoader = false;
                    this.retryAttempt = 0;
                    console.log('there was some error in calculating discount--', results);
                }
            }else{
                this.showLoader = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.labels.B2B_Success_Label,
                        message:this.labels.B2B_Add_To_Cart_Success_Msg,
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
            }
        }).catch((error) => {
            console.log('calculateDiscount error');
            console.log(error);
            this.showLoader = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title:  this.labels.B2B_Error_Msg_Label,
                        message:this.labels.B2B_Add_To_Cart_Error_Msg,
                        messageData: [this.displayableProduct.name],
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
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
    wishlistproductId;
    showModal = false;
    async addToList(event) {
        console.log('event detail : ');
        console.log(event.detail);
        this.wishlistproductId = event.detail.prodId != null ? event.detail.prodId : this.recordId;
        this.showModal = true;
        /*const result = await wishlistModal.open({
            size: "small",
            communityId: communityId,
            ,
            effectiveAccountId: this.resolvedEffectiveAccountId
        });*/
    }
    handleModalClose(event){
        let result = event.detail;
        if(result){
            this.showModal = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.B2B_Success_Label,
                    message: this.labels.B2B_PDP_Wishlist_Msg,
                    variant: 'success',
                    mode: 'dismissable'
                })
            );
        } else {
            this.showModal = false;
            console.log('Some error occured.');
        }
        
        /*let listname = this.prodDetails.primaryProductCategoryPath.path[0]
            .name;
        createAndAddToList({
            communityId: communityId,
            productId: this.recordId,
            wishlistName: listname,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then(() => {
                this.dispatchEvent(new CustomEvent('createandaddtolist'));

                alert('Product added to list');
            })
            .catch(() => {

                alert('Product could not be added to a new list. Please make sure you have fewer than 10 lists or try again later');
            });*/
    }

    /**
     * Ensures cart information is up to date
     */
    updateCartInformation() {
        getCartSummary({
            communityId: communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then((result) => {
                this.cartSummary = result;
            })
            .catch((e) => {
                // Handle cart summary error properly
                // For this sample, we can just log the error
                console.log(e);
            });
    }
}