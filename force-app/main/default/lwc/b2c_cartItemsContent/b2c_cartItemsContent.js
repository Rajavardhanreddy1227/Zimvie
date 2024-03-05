import { LightningElement,api, wire, track } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
//import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import communityId from '@salesforce/community/Id';
import getCartItemsByCartId from '@salesforce/apex/B2BGetInfo.getCartItemsByCartId';
import getCartItems from '@salesforce/apex/RSM_CartController.getCartItemsLWR';
import deleteCartItem from '@salesforce/apex/RSM_CartController.deleteCartItem';
import getCategoryId from '@salesforce/apex/RSM_CartController.getCategoryId';
import { updateItemInCart, deleteCurrentCart } from 'commerce/cartApi';
import calculateDiscountOnItem from '@salesforce/apex/B2BCartController.calculateDiscountOnItem';
import LoadingCartItems from '@salesforce/label/c.LoadingCartItems';
import clearCartButton from '@salesforce/label/c.clearCartButton';
import SortBy from '@salesforce/label/c.SortBy';
import CartHeader from '@salesforce/label/c.CartHeader';
import EmptyCartHeaderLabel from '@salesforce/label/c.EmptyCartHeaderLabel';
import EmptyCartBodyLabel from '@salesforce/label/c.EmptyCartBodyLabel';
import ClosedCartLabel from '@salesforce/label/c.ClosedCartLabel';
import CreatedDateDesc from '@salesforce/label/c.CreatedDateDesc';
import CreatedDateAsc from '@salesforce/label/c.CreatedDateAsc';
import NameAsc from '@salesforce/label/c.NameAsc';
import NameDesc from '@salesforce/label/c.NameDesc';
import LightningConfirm from 'lightning/confirm';
import { CartSummaryAdapter } from "commerce/cartApi";
import getRMACartDetail from '@salesforce/apex/B2BCartController.getRMACartDetail';

import { fireEvent } from 'c/b2b_pubsub';
const CART_CHANGED_EVT = 'cartchanged';
const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';
const CLEAR_CART_EVT = 'clearcartclicked';
import calculateDiscountOnCart from '@salesforce/apex/B2BCartController.calculateDiscountOnCart';
import deleteCartShippingAndTax from '@salesforce/apex/B2BCartController.deleteCartShippingAndTax';
import getCartItemWithPricingDetailsApex from '@salesforce/apex/LWR_CartController.getCartItemWithPricingDetailsApex';
import B2B_AddToCart_SpinnerMessage from '@salesforce/label/c.B2B_AddToCart_SpinnerMessage';
import B2B_CalculateDiscount_SpinnerMessage from '@salesforce/label/c.B2B_CalculateDiscount_SpinnerMessage';
import B2B_Loading_Message from '@salesforce/label/c.B2B_Loading_Message';

export default class b2c_cartItemsContent extends NavigationMixin(LightningElement) {

    // labels = {
    //     B2B_CalculateDiscount_SpinnerMessage,
    //     B2B_AddToCart_SpinnerMessage,
    //     B2B_Loading_Message
    // };
    messageState = B2B_Loading_Message;

    @api recordId;
    cartItemsTemp;
    customLoader = false;
    isLoadOver = false;
    @api effectiveAccountId;
    

    _originalCartItems;
    @api 
    get originalCartItems(){
        return this._originalCartItems;
    }
    set originalCartItems(value){
        console.log('value12333---- ',value);
        if(value != undefined){
            if(JSON.parse(JSON.stringify(value)).length > 0){
                //this._cartItems = value;
                //this.spinnerValue = true;
                //if(this.cartItems.length <= 0){
                    this.customLoader = true;
                    this.cartItemsTemp = value;
                    //this.getCartItemWithPricingDetailsCart(value);
                    //this.calculateDiscountOnLoad(value);
                    this.deleteShippingAndTaxOnCart(value);
                //}
            }else{
                this.spinnerValue = false;
                //this.querySelector('c-b2b-show-toast-message').showToast('Cart is empty','warning');
            }
        }else{
            this.spinnerValue = false;
        }
    }
    cartId;
    isRMACart = false;
    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
    if(!data){
            return;
        }
    else if (data) {
            console.log("Checkout Cart--- ", data);
            console.log("Checkout ID---", data.cartId);
            this.cartId=data.cartId;
            if(this.cartId!=undefined){
            this.getCartDetail();
            }
        } else if (error) {
            console.error(error);
           //  alert('RMA Error');
        }
    }
    getCartDetail(){
        console.log('GetCartDetail--- ');
            let mapParams = {
                cartId : this.cartId
            }
                getRMACartDetail({
                mapParams: mapParams
            }).then((results) => {
                console.log('getRMACartDetail Cart results- ',results);
                this.isRMACart = results.IsRMACart;
            }).catch((error) => {
                console.log('getRMACartDetail Cart error');
                console.log(error);
            });
    }

    async deleteShippingAndTaxOnCart(val){
        if(val != undefined){       
            let input = JSON.parse(JSON.stringify(val));
            console.log('deleteShippingAndTaxOnCart input---- ',input);
            let inputMap = {};
            inputMap.originalCartItems = input;   
            await deleteCartShippingAndTax({
                'mapParams': inputMap
            }).then((result) => {
                console.log('deleteShippingAndTaxOnCart---- '+result);
                this.isLoadOver = true;
                this.calculateDiscountOnLoad(val);
            }).catch((error) => {
                this.spinnerValue = false;
                this.customLoader = false;
                console.log('deleteShippingAndTaxOnCart error '+JSON.stringify(error));
            });
        }
    }

    retryAttemptOnLoad = 0;
    async retryApiCalloutOnLoad(inputVal){
        this.messageState = B2B_Loading_Message;
        this.retryAttemptOnLoad = this.retryAttemptOnLoad + 1;
        this.calculateDiscountOnLoad(inputVal);
    }

    async calculateDiscountOnLoad(val){
        if(val != undefined){       
            if(this.retryAttemptOnLoad == 1){
                this.messageState = 'Please wait';
            }else{
                this.messageState = B2B_CalculateDiscount_SpinnerMessage;
            }
            let input = JSON.parse(JSON.stringify(val));
            console.log('calculateDiscountOnLoad input---- ',input);
            let inputMap = {};
            inputMap.originalCartItems = input;   
            await calculateDiscountOnCart({
                'mapParams': inputMap
            }).then((result) => {
                console.log('calculateDiscountOnLoad---- '+result);
                if(!result.isSuccess){
                    if(this.retryAttemptOnLoad < 2){
                        this.retryApiCalloutOnLoad(val);
                    }else{
                        this.showLoader = false;
                        this.isLoadOver = true;
                        this.retryAttemptOnLoad = 0;
                        console.log('there was some error in calculating discount--', result);
                        this.template.querySelector('c-b2b-show-toast-message').showToast('Something went wrong while calculating discount please contact your admin.','error');
                        // this.dispatchEvent(
                        //     new ShowToastEvent({
                        //         title: 'Error',
                        //         message: 'Something went wrong while calculating discount please contact your admin.',
                        //         variant: 'error',
                        //         mode: 'sticky'
                        //     })
                        // );
                        this.getCartItemWithPricingDetailsCart(this.cartItemsTemp);
                    }
                }else{
                    this.isLoadOver = true;
                    this.retryAttemptOnLoad = 0;
                    this.getCartItemWithPricingDetailsCart(this.cartItemsTemp);
                }
            }).catch((error) => {
                this.spinnerValue = false;
                this.customLoader = false;
                console.log('getCartItemWithPricingDetailsApex error444 '+JSON.stringify(error));
            });
        }
    }

    async getCartItemWithPricingDetailsCart(val){
        this.messageState = B2B_Loading_Message;
        console.log('cartitems value>>>'+JSON.stringify(val));
        if(val != undefined){          
            //this.hasCartitems = false;
            let inputMap = {};
            inputMap.originalCartItems = val;   
            await getCartItemWithPricingDetailsApex({
                'inputData': inputMap
            }).then((result) => {
                console.log('getCartItemWithPricingDetailsApex before---- ',result.cartItemData);
                result.cartItemData.forEach(elm => {
                    if(Object.values(elm.ProductDetails.variationAttributes).length > 0){
                        let attributeArray = [];
                        var str = '';
                        attributeArray = Object.values(elm.ProductDetails.variationAttributes);
                        attributeArray.forEach(element => {
                            str += element.label + ": " + element.value + ", ";
                        });
                        str = str.substring(0, str.length - 2);
                        elm['varaiationArray'] = str;
                    }
                });
                console.log('getCartItemWithPricingDetailsApex after---- ',result.cartItemData);
                this.cartItems = result.cartItemData;
                this._cartItemCount = Number(result.cartItemData.length);
                fireEvent(this.pageRef, CART_ITEMS_UPDATED_EVT);
                this.spinnerValue = false;
                if(this.isLoadOver){
                    this.customLoader = false;
                    this.isLoadOver = false;
                }
            }).catch((error) => {
                this.spinnerValue = false;
                this.customLoader = false;
                console.log('getCartItemWithPricingDetailsApex error444 '+JSON.stringify(error));
                //this.querySelector('c-b2b-show-toast-message').showToast('Something went wrong!!','error');
            });
        }
    }

    @wire(CurrentPageReference)
    pageRef;
    spinnerValue = false;
    _cartItemCount = 0;
    isCartItemListIndeterminate = false;

    @track cartItems = [];
    isDiscountApplied = false;

    sortOptions = [
        { value: 'CreatedDateDesc', label: this.labels.CreatedDateDesc },
        { value: 'CreatedDateAsc', label: this.labels.CreatedDateAsc },
        { value: 'NameAsc', label: this.labels.NameAsc },
        { value: 'NameDesc', label: this.labels.NameDesc }
    ];
    categPath = [{"id":"0ZGDn000000oRTWOA2","name":"Products"}, {"id":"0ZG8Z000000GsRzWAK","name":"Cart"}];

    pageParam = null;

    sortParam = 'CreatedDateDesc';

    isCartClosed = false;

    currencyCode;
    isCartEmpty = false;

  //   get isCartEmpty() {
  //       return Array.isArray(this.cartItems) && this.cartItems.length === 0;
  //   }

    get labels() {
        return {
            loadingCartItems: LoadingCartItems,
            clearCartButton: clearCartButton,
            sortBy: SortBy,
            cartHeader: CartHeader,
            emptyCartHeaderLabel: EmptyCartHeaderLabel,
            emptyCartBodyLabel:EmptyCartBodyLabel ,
            closedCartLabel: ClosedCartLabel,
            CreatedDateDesc: CreatedDateDesc,
            CreatedDateAsc: CreatedDateAsc,
            NameAsc: NameAsc,
            NameDesc: NameDesc
        };
    }

    get cartHeader() {
        return `${this.labels.cartHeader} (${this._cartItemCount})`;
    }


    get resolvedEffectiveAccountId() {
        console.log('Inside resolvedEffectiveAccountId');
        const effectiveAccountId = this.effectiveAccountId || '';
        console.log('effectiveAccountId',effectiveAccountId);
        let resolved = null;
        if (
            effectiveAccountId.length > 0 &&
            effectiveAccountId !== '000000000000000'
        ) {
            resolved = effectiveAccountId;
        }
        return resolved;
    }
    runOnce = true;
    get path() {
        if(this.runOnce){
            this.getBreadcrumbs();
        }
        return {
            journey: this.categPath.map(
            (category) => ({
                id: category.id,
                name: category.name
            })
        )
    };
    }

    getBreadcrumbs(){
        console.log('inside getBreadcrumbs');
        
        getCategoryId({
            cartId: this.recordId
           //cartId : '0a6Dn000000xZxZ'
        }).then((result) => {
            console.log('result---- ',result);
            this.categPath = [{"id":result,"name":"Products"}, {"id":this.recordId,"name":"Cart"}];
            this.runOnce = false;
        }).catch((error) => {
            console.error('deletion order error: ', error);
        })
    }

    _cardContentMapping;

    @api
    get cardContentMapping() {
        return this._cardContentMapping;
    }
    set cardContentMapping(value) {
        this._cardContentMapping = value;
    }

    connectedCallback() {
        this.spinnerValue = true;
        this.spinnerValue = false;
    }

    updateCartItems() {
        console.log('Inside Update Cart Method');
        console.log('communityId',communityId);
        console.log('this.resolvedEffectiveAccountId',this.resolvedEffectiveAccountId);
        console.log('this.recordId',this.recordId);
        console.log('this.pageParam',this.pageParam);
        console.log('this.sortParam',this.sortParam);
        this.spinnerValue = true;
        return getCartItems({
            communityId: communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId,
            activeCartOrId: this.recordId,
            pageParam: this.pageParam,
            sortParam: this.sortParam

        })
            .then((result) => {
                console.log('Inside Result',result.cartItems);
                this.spinnerValue = false;
                //this.isCartItemListIndeterminate = true;
                let cartItemsTmp = result.cartItems;
                this.recordId = cartItemsTmp[0].cartItem.cartId;
                let isDiscountApplied = false;
                this._cartItemCount = Number(result.cartSummary.totalProductCount);
                this.currencyCode = result.cartSummary.currencyIsoCode;
                 //this.isCartDisabled = LOCKED_CART_STATUSES.has(
                  //  result.cartSummary.status
                 //);
                this.isCartDisabled = false;
                if(cartItemsTmp.length != 0){
                    return getCartItemsByCartId({
                        cartId: cartItemsTmp[0].cartItem.cartId
                    })
                    .then((res) => {
                        cartItemsTmp.forEach(item => {
                            let cartItemId = item['cartItem']['cartItemId'];
                            if(res[cartItemId]) item.desc2 = res[cartItemId]['productDescription'];
                            if(res[cartItemId]) item.entry = res[cartItemId]['priceBookEntryId'];

                            if(res[cartItemId]){ 
                                if(res[cartItemId]['productSellingModel'] == 'Term Monthly'){
                                    item.model = 'Annual Subscription (paid monthly)';
                                } else if(res[cartItemId]['productSellingModel'] == 'Evergreen Monthly'){
                                    item.model = 'Annual Subscription (paid upfront)';
                                } else {
                                    item.model = res[cartItemId]['productSellingModel'];
                                }
                                if(res[cartItemId]['discount'] > 0){
                                    isDiscountApplied = true;
                                    item.discount = res[cartItemId]['discount'] + res[cartItemId]['TotalPrice'];
                                    item.discountPercent = (res[cartItemId]['discount']*100)/item.discount + '%';

                                }
                            }
                        });

                        this.isDiscountApplied = isDiscountApplied;
                        //this.cartItems = cartItemsTmp;
                        //this.isCartEmpty = Array.isArray(this.cartItems) && this.cartItems.length === 0;
                        fireEvent(this.pageRef, CART_ITEMS_UPDATED_EVT);
                        console.log('refreshApex spinnerValue1');
                        //refreshApex(this.cartItems);
                        console.log('refreshApex spinnerValue2');
                        this.spinnerValue = false;
                        console.log('refreshApex spinnerValue3');
                    })
                }
                this.isCartEmpty = Array.isArray(this.cartItems) && this.cartItems.length === 0;
                this.spinnerValue = false;
                this.isCartItemListIndeterminate = false;
            })
            .catch((error) => {
                this.isCartEmpty = Array.isArray(this.cartItems) && this.cartItems.length === 0;
                //const errorMessage = error.body.message;
                this.cartItems = undefined;
                this.isCartItemListIndeterminate = false;
                this.spinnerValue = false;
                //this.isCartClosed = isCartClosed(errorMessage);
                console.log('Exception 2 with spinner  errorUp '+JSON.stringify(error));
            });
    } 

    handleChangeSortSelection(event) {
        this.sortParam = event.target.value;
        this.updateCartItems();
    }

    handleCartUpdate() {
        debugger;
        console.log('Exception 3 with spinner console handle cart update');
        this.dispatchEvent(
            new CustomEvent(CART_CHANGED_EVT, {
                bubbles: true,
                composed: true
            })
        );
        this.spinnerValue = false;
        fireEvent(this.pageRef, CART_ITEMS_UPDATED_EVT);
        console.log('Exception 3.1 with spinner console handle cart update');
        //refreshApex(this.cartItems);
        console.log('Exception 3.2 with spinner console handle cart update');
        this.spinnerValue = false;
    }

    async handleQuantityChanged(evt) {
        if(this.isRMACart){
            const result = await LightningConfirm.open({
                message: 'This cart contains RMA items, do you want to proceed to modify the cart, this will delete your exsting RMA requests ?',
                variant: 'headerless',
                label: 'this is the aria-label value',
                // setting theme would have no effect
            });
            if(!result){
                return;
            }
		}
        this.spinnerValue = true;
        this.customLoader = true;
        const { cartItemId, quantity } = evt.detail;

        await updateItemInCart(cartItemId,quantity).then((fulfilled) => {
            console.log("added product to cart" ,fulfilled);
            this.calculateDiscount(fulfilled);
        }).catch(error => {
            console.log('error' ,error);
            this.spinnerValue = false;
            this.customLoader = false;
            this.template.querySelector('c-b2b-show-toast-message').showToast('Your cart has been updated.','error');
        });

    }

    retryAttempt = 0;
    async retryApiCallout(inputVal){
        this.messageState = B2B_Loading_Message;
        this.retryAttempt = this.retryAttempt + 1;
        this.calculateDiscount(inputVal);
    }

    async calculateDiscount(input){
        if(this.retryAttempt == 1){
            this.messageState = 'Please wait';
        }else{
            this.messageState = B2B_CalculateDiscount_SpinnerMessage;
        }
        console.log('calculateDiscount(fulfilled)--- ', input);
        let mapParams = {
            cartItemId : input.cartItemId
        }
        await calculateDiscountOnItem({
            mapParams: mapParams
        }).then((results) => {
            console.log('calculateDiscount results- ',results);
            if(!results.isSuccess){
                if(this.retryAttempt < 2){
                    this.retryApiCallout(input);
                }else{
                    this.showLoader = false;
                    if(this.cartItemsTemp != undefined){
                        this.isLoadOver = true;
                        this.retryAttempt = 0;
                        this.getCartItemWithPricingDetailsCart(this.cartItemsTemp);
                    }
                    console.log('there was some error in calculating discount--', results);
                    this.template.querySelector('c-b2b-show-toast-message').showToast('Something went wrong while calculating discount please contact your admin.','error');
                    // this.dispatchEvent(
                    //     new ShowToastEvent({
                    //         title: 'Error',
                    //         message: 'Something went wrong while calculating discount please contact your admin.',
                    //         variant: 'error',
                    //         mode: 'sticky'
                    //     })
                    // );
                }
            }else{
                if(this.cartItemsTemp != undefined){
                    this.isLoadOver = true;
                    this.retryAttempt = 0;
                    this.getCartItemWithPricingDetailsCart(this.cartItemsTemp);
                }
            }
            //this.spinnerValue = false;
            //this.template.querySelector('c-b2b-show-toast-message').showToast('Your cart has been updated.','success');
        }).catch((error) => {
            console.log('calculateDiscount error');
            console.log(error);
            this.spinnerValue = false;
            this.customLoader = false;
            this.template.querySelector('c-b2b-show-toast-message').showToast('Your cart has been updated.','error');
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         title: 'Error',
            //         message: 'Something went wrong while calculating discount please contact your admin.',
            //         variant: 'error',
            //         mode: 'sticky'
            //     })
            // );
        });
    }
 
    handleCartItemDelete(evt) {
        const { cartItemId } = evt.detail;
        deleteCartItem({
            communityId,
            effectiveAccountId: this.effectiveAccountId,
            activeCartOrId: this.recordId,
            cartItemId
        })
            .then(() => {
                this.removeCartItem(cartItemId);

                this.navigateToCart(this.recordId);
            })
            .catch((e) => {
                console.log(e);
            });
    }

    handleClearCartButtonClicked() {

        deleteCurrentCart().then((fulfilled) => {
            console.log("added product to cart" ,fulfilled);
            this.cartItems = undefined;
            this._cartItemCount = 0;
            this.spinnerValue = false;
            //fireEvent(this.pageRef, CART_ITEMS_UPDATED_EVT);
            fireEvent(this.pageRef, CLEAR_CART_EVT);
            this.template.querySelector('c-b2b-show-toast-message').showToast('Your cart has been updated.','success');
        }).catch(error => {
            console.log('error' ,error);
            this.spinnerValue = false;
            this.template.querySelector('c-b2b-show-toast-message').showToast('Your cart has been updated.','error');
        });

        // deleteCart({
        //     communityId,
        //     effectiveAccountId: this.effectiveAccountId,
        //     activeCartOrId: this.recordId
        // })
        //     .then(() => {
        //         this.spinnerValue = false;
        //         this.cartItems = undefined;
        //         this._cartItemCount = 0;
        //     })
        //     .then(() => {
        //         return createCart({
        //             communityId,
        //             effectiveAccountId: this.effectiveAccountId
        //         });
        //     })
        //     .then((result) => {
        //         console.log('test ',result);
        //         this.navigateToCart(this.recordId);
        //         this.handleCartUpdate();
        //         this.spinnerValue = false;
        //     })
        //     .catch((e) => {
        //         this.spinnerValue = false;
        //         console.log('Exception 5 with spinnerss@ ',e);
        //     });
    }
    recordPageUrl =''
    navigateToCart(cartId) {
        //let url = window.location.origin;
        //let url2 = window.location.href;
        //alert(cartId +' hh '+url +' 22 '+ url2);
        
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: 'https://smlwrdev1-dev-ed.develop.my.site.com/b2cstore/cart'
            }
            
        },
        true // Replaces the current page in your browser history with the URL
    );
    this.spinnerValue = false;
    }

    removeCartItem(cartItemId) {
        const removedItem = (this.cartItems || []).filter(
            (item) => item.cartItem.cartItemId === cartItemId
        )[0];
        const quantityOfRemovedItem = removedItem
            ? removedItem.cartItem.quantity
            : 0;
        const updatedCartItems = (this.cartItems || []).filter(
            (item) => item.cartItem.cartItemId !== cartItemId
        );
        this.cartItems = updatedCartItems;
        this._cartItemCount -= Number(quantityOfRemovedItem);
        this.handleCartUpdate();
    }

    updateCartItemInformation(cartItem) {
        let count = 0;
        const updatedCartItems = (this.cartItems || []).map((item) => {
            let updatedItem = { ...item };
            if (updatedItem.cartItem.Id === cartItem.Id) {
                updatedItem.cartItem = cartItem;
            }
            count += Number(updatedItem.cartItem.quantity);
            return updatedItem;
        });
        this.cartItems = updatedCartItems;
        this._cartItemCount = count;
        this.updateCartItems();
    } 
}