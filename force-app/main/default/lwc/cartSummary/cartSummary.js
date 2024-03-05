import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import communityId from '@salesforce/community/Id';
import getCartItemWithPricingDetailsApex from '@salesforce/apex/LWR_CartController.getCartItemWithPricingDetailsApex';

import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/b2b_pubsub';
const CART_ITEMS_UPDATED_EVT = 'cartitemsupdated';

/**
 * @slot headerText ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Summary", textDisplayInfo: "{\"headingTag\": \"h2\", \"textStyle\": \"heading-medium\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot promotionsLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Promotions", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot shippingChargeLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Delivery Charge", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot shippingLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Shipping", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot subtotalLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Subtotal", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot taxIncludedLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Tax included", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}", textAlign: "right" }}] })
 * @slot serviceTermsLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Service Terms", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}", textAlign: "right" }}] })
 * @slot taxLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Tax", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot totalLabel ({ locked: true, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Total", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"heading-small\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot subtotalLabel1 ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Subtotal", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot ContactUsLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Contact Us", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}", textAlign: "right" }}] })
 */
export default class CartSummary extends NavigationMixin(LightningElement) {

    @wire(CurrentPageReference) pageRef;


    @api cartSubTotal;
    @api cartPromotion;
    @api cartShipping;
    @api cartTax;
    @api cartTotal;
    @api cartOriginalTotal;
    @api currencyCode;


    _cartOriginlIds;
    @api 
    get cartOriginlIds(){
        return this._cartOriginlIds;
    }
    set cartOriginlIds(val){
        console.log('cartOriginlIds---- ',val);
    }

    hasCartitems = false;

    _cartItems;
    _cartOriginlItems;
    @api 
    get cartOriginlItems(){
        return this._cartOriginlItemsl;
    }
    set cartOriginlItems(value){
        if(value != undefined){
            //this._cartOriginlItems =  JSON.parse(JSON.stringify(value));    
            //this.hasCartitems = true; //do not enable here....
            if(JSON.parse(JSON.stringify(value)).length > 0){
                this._cartItems = value;
                this.spinnerValue = true;
                this.getCartItemWithPricingDetails(value);
            }else{
                this.spinnerValue = false;
                //this.querySelector('c-b2b-show-toast-message').showToast('Cart is empty','warning');
            }
        }else{
            this.spinnerValue = false;
        }
    }

    isCheckout = false;
    cartItemIds = new Set();
    spinnerValue = false;

    connectedCallback() {
        this.isPreview = this.isInSitePreview();
        this.isCheckout = this.isCheckoutFunction();
        if(this.isCheckout){
            //this.cartSubTotal = 10;
            this.cartPromotion = 10;
            this.cartShipping = 10;
            this.cartTax = 10;
            this.cartTotal = 10;
            this.cartOriginalTotal = 10;
        }
        if (this.isPreview) {
            this.hasCartitems = false;
            this.cartSubTotal = 100;
            this.cartPromotion = 100;
            this.cartShipping = 100;
            this.cartTax = 100;
            this.cartTotal = 100;
            this.cartOriginalTotal = 100;
            this._cartOriginlItems = '';
        }
        if(!this.isCheckout && !this.isPreview){
            //listen to quantity update on cart page.
            //this.spinnerValue = true;
            registerListener(CART_ITEMS_UPDATED_EVT,this.callgetCartItemWithPricingDetails,this);
        }
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    isInSitePreview() {
        let url = document.URL;
        
        return (url.indexOf('sitepreview') > 0 
            || url.indexOf('livepreview') > 0
            || url.indexOf('live-preview') > 0 
            || url.indexOf('live.') > 0
            || url.indexOf('.builder.') > 0);
    }

    isCheckoutFunction(){
        let url = document.URL;
        return (url.indexOf('checkout') > 0);
    }

    /**
     * Enable the component to render as light DOM
     *
     * @static
     */
    static renderMode = 'light';

    handleProductDetailNavigation(evt) {
        console.log('handleShowDetail-----');
        evt.preventDefault();
        const productId = evt.target.dataset.productid;
        evt.stopPropagation();
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/product/detail/'+productId
            }
        });
    }

    callgetCartItemWithPricingDetails(){
        if(this._cartItems != undefined){
            this.spinnerValue = true;
            this.getCartItemWithPricingDetails(this._cartItems);
        }else{
            //this.querySelector('c-b2b-show-toast-message').showToast('Something went wrong!! error while updating cart details on quantity update','error');
            console.log('error while updating cart details on quantity update');
        }
    }

    getCartItemWithPricingDetails(val){
        if(val != undefined){           //if(this._cartOriginlItems != undefined){
            this.hasCartitems = false;
            let inputMap = {};
            inputMap.originalCartItems = val;   //this._cartOriginlItems;
            getCartItemWithPricingDetailsApex({
                'inputData': inputMap
            }).then((result) => {
                console.log('getCartItemWithPricingDetailsApex---- ',result);
                result.cartItemData.forEach(element => {
                    if( element.data.productSellingModel == 'Term Monthly' ){
                        //element.data.set('model','Annual Subscription (paid monthly)');
                        element.data['model'] = 'Annual Subscription (paid monthly)';
                        element.data['paymentTerm'] = 'per month';
                    }else if( element.data.productSellingModel == 'Evergreen Monthly' ){
                       // element.data.set('model','Annual Subscription (paid upfront)');
                        element.data['model'] = 'Annual Subscription (paid upfront)';
                        element.data['paymentTerm'] = 'per month';
                    }else{
                        //element.data.set('model','One-Time');
                        element.data['model'] = 'One-Time';
                        element.data['paymentTerm'] = '';
                    }
                });
                this._cartOriginlItems = result.cartItemData;
                console.log('this._cartOriginlItems----- ',this._cartOriginlItems);
                if(this._cartOriginlItems != undefined){
                    var rec = this._cartOriginlItems[0];
                    //this.cartSubTotal = rec.data.cartTotalProductAmount;
                    this.cartSubTotal = rec.data.cartTotalListAmount;
                    this.cartPromotion = rec.data.cartTotalAdjustmentAmount;
                    this.cartShipping = rec.data.cartTotalChargeAmount;
                    this.cartTax = rec.data.cartTotalTaxAmount;
                    this.currencyCode = rec.data.currencyIsoCodeValue;
                    //this.cartTotal = rec.data.cartGrandTotalAmount;
                    this.cartTotal = this.cartSubTotal + this.cartShipping + this.cartTax + this.cartPromotion;
                }
                this.hasCartitems = true;
                this.spinnerValue = false;
                //this.querySelector('c-b2b-show-toast-message').showToast('Success','success');
            }).catch((error) => {
                this.spinnerValue = false;
                console.log('getCartItemWithPricingDetailsApex error444 '+JSON.stringify(error));
                //this.querySelector('c-b2b-show-toast-message').showToast('Something went wrong!!','error');
            });
        }
    }
}