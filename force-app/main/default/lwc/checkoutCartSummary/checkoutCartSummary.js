import { LightningElement, api, wire, track } from 'lwc';
import communityId from '@salesforce/community/Id';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/b2b_pubsub';
import checkoutCartSummary_OrderSummary from '@salesforce/label/c.checkoutCartSummary_OrderSummary';
import checkoutCartSummary_OrderSubtotal from '@salesforce/label/c.checkoutCartSummary_OrderSubtotal';
import checkoutCartSummary_DiscountAdjustments from '@salesforce/label/c.checkoutCartSummary_DiscountAdjustments';
import checkoutCartSummary_Tax from '@salesforce/label/c.checkoutCartSummary_Tax';
import checkoutCartSummary_Shipping from '@salesforce/label/c.checkoutCartSummary_Shipping';
import checkoutCartSummary_ShippingDiscount from '@salesforce/label/c.checkoutCartSummary_ShippingDiscount';
import checkoutCartSummary_ShippingTax from '@salesforce/label/c.checkoutCartSummary_ShippingTax';
import checkoutCartSummary_TissueHandlingFee from '@salesforce/label/c.checkoutCartSummary_TissueHandlingFee';
import checkoutCartSummary_Totals from '@salesforce/label/c.checkoutCartSummary_Totals';
import { CartSummaryAdapter, CartItemsAdapter } from "commerce/cartApi";
import checkoutOrderSummaryData from '@salesforce/apex/b2B_checkoutAddressController.checkoutOrderSummaryData';

const VIEW_SUMMARY_DETAILS = 'viewSummaryDetails';
const HIDE_SUMMARY_DETAILS = 'hideSummaryDetails';

/**
 * @slot headerText ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Summary", textDisplayInfo: "{\"headingTag\": \"h2\", \"textStyle\": \"heading-medium\"}", "textDecoration": "{\"bold\": true}" }}] })
 * @slot subtotalLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Subtotal", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot promotionsLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Promotions", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot taxLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Tax", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot shippingLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Shipping", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot shipDiscountLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Shipping Discount", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot shipTaxLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Shipping Tax", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot tissueHandleLabel ({ locked: false, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Tissue Handling", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"body-regular\"}" }}] })
 * @slot totalLabel ({ locked: true, defaultContent: [{ descriptor: "dxp_base/textBlock", attributes: {text: "Total", textDisplayInfo: "{\"headingTag\": \"p\", \"textStyle\": \"heading-small\"}", "textDecoration": "{\"bold\": true}" }}] })
 */
export default class CheckoutCartSummary extends LightningElement {

    label = {
        checkoutCartSummary_OrderSummary,
        checkoutCartSummary_OrderSubtotal,
        checkoutCartSummary_DiscountAdjustments,
        checkoutCartSummary_Tax,
        checkoutCartSummary_Shipping,
        checkoutCartSummary_ShippingDiscount,
        checkoutCartSummary_ShippingTax,
        checkoutCartSummary_TissueHandlingFee,
        checkoutCartSummary_Totals
    };

    spinnerValue = false;
    cartSubTotal;
    cartPromotion;
    cartProdTax;
    cartShipping;
    cartTotal;
    cartShippingDiscount;
    cartShippingTax;
    cartTissueFee;
    originalCartId;
    currencyCode;

    showSummaryDetails = false; 

    @wire(CurrentPageReference) pageRef; 

    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        if(!data){
            return;
        }
        else if (data) {
            console.log("order summary setCartSummary Cart data- ", data);
            this.originalCartId = data.cartId;
            this.fetchSummaryData();
        } else if (error) {
            console.error(error);
        }
    }
    // @wire(CartItemsAdapter, { webstoreId:this.webstoreId, cartStateOrId: 'current' })
    // onGetCartItems(result) {
    //     if(!result){
    //         eturn;
    //     }
    //     console.log("CartItemsAdapter Id", result);
    //     console.log("CartItemsAdapter Id", result.data );
    //     //console.log("cartItems Id", result.data.cartItems);
    //     if(result.data){
    //         console.log("cartItems Id", result.data.cartItems);
    //         //this.cartItemMap = result.data.cartItems;
    //         console.log("cartItemMap", JSON.stringify(this.cartItemMap));
    //     }  
        
    // }

    showDetails(event){
        console.log('showDetails--- ',event);
        this.showSummaryDetails = true;
        if(this.originalCartId){
            this.fetchSummaryData();
        }
    }

    hideDetails(event){
        console.log('hideDetails--- ',event);
        this.showSummaryDetails = false;
        if(this.originalCartId){
            this.fetchSummaryData();
        }
    }

    connectedCallback() {
        this.isPreview = this.isInSitePreview();
        this.isCheckout = this.isCheckoutFunction();
        if(this.isCheckout){
            this.cartSubTotal = 10;
            this.cartPromotion = 10;
            this.cartTotal = 10;
        }
        if (this.isPreview) {
            this.cartSubTotal = 100;
            this.cartPromotion = 100;
            this.cartTotal = 100;
        }
        if(!this.isPreview){
            registerListener(VIEW_SUMMARY_DETAILS,this.showDetails,this);
            registerListener(HIDE_SUMMARY_DETAILS,this.hideDetails,this);
        }
    }

    async fetchSummaryData(){
        if(this.originalCartId != undefined){
            let inpMap = {};
            inpMap.cartId = this.originalCartId;
            await checkoutOrderSummaryData({
                inputMap : inpMap
            }).then((res) => {
                console.log('fetchSummaryData checkoutOrderSummaryData res-- ' ,res);
                this.cartSubTotal = res.summaryData.OrderSubtotal;
                this.cartPromotion = res.summaryData.DiscountAdjustments * -1;
                this.cartProdTax = res.summaryData.Tax;
                this.cartShipping = res.summaryData.Shipping;
                this.cartShippingDiscount = res.summaryData.ShippingDiscount * -1;
                this.cartShippingTax = res.summaryData.ShippingTax;
                this.cartTissueFee = res.summaryData.TissueHandlingFee;
                this.currencyCode = res.summaryData.currencyCode;
                if(this.showSummaryDetails){
                    this.cartTotal = res.summaryData.Total;
                }else{
                    this.cartTotal = res.summaryData.DummyTotal;
                }
                this.spinnerValue = false;
            }).catch(error => {
                console.log('error' ,error);
            });
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
}