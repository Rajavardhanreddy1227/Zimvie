import { LightningElement, wire, api, track } from 'lwc';
/*import getCommerceCheckout from "@salesforce/apex/CommerceCheckout.getCommerceCheckout";*/
/*import updateCommerceDeliveryMethodCheckout from "@salesforce/apex/CommerceCheckout.updateCommerceDeliveryMethodCheckout";*/
import communityId from '@salesforce/community/Id';
import { CurrentPageReference } from 'lightning/navigation'; 
import { registerListener, unregisterAllListeners } from 'c/b2b_pubsub';
import { loadCheckout,updateDeliveryMethod } from 'commerce/checkoutApi';
import fetchOrderDeliveryMethods from "@salesforce/apex/b2B_checkoutAddressController.fetchOrderDeliveryMethods";
import getShippingDiscount from "@salesforce/apex/b2B_checkoutAddressController.getShippingDiscount";

import getSelectedDeliveryMethod from "@salesforce/apex/B2b_ShippingMethod.getSelectedDeliveryMethod";

import callTaxIntegrationCustom from "@salesforce/apex/b2B_checkoutAddressController.callTaxIntegrationCustom";
import {fireEvent} from 'c/b2b_pubsub';
import ShippingMethodMessage from '@salesforce/label/c.ShippingMethodMessage';
import B2B_AddToCart_SpinnerMessage from '@salesforce/label/c.B2B_AddToCart_SpinnerMessage';
import B2B_CalculateDiscount_SpinnerMessage from '@salesforce/label/c.B2B_CalculateDiscount_SpinnerMessage';
import B2B_CalculateTax_SpinnerMessage from '@salesforce/label/c.B2B_CalculateTax_SpinnerMessage';
import B2B_Loading_Message from '@salesforce/label/c.B2B_Loading_Message';
const VIEW_SUMMARY_DETAILS = 'viewSummaryDetails';
const HIDE_SUMMARY_DETAILS = 'hideSummaryDetails';

export default class B2b_ShippingMethod extends LightningElement {
    shippingInstructions;
    parsedData;
    showComp = true;
    showHeaderLabel = true;
    isDisabled = true;
    showError = false;
    _checkoutMode = 1;
    _isShowEmptyMessage = false;
    _emptyMessage = '';
    @api transformedOptions;
    @api name = 'delivery-method';
    @api selectedOption;
    @track currentCommunityId;
    loader = false;
    inpMap = {};
    cartId;
    isShippingCalculated =  false;
    isTaxCalculated = false;
    labels={
        ShippingMethodMessage,
        B2B_Loading_Message,
        B2B_CalculateDiscount_SpinnerMessage,
        B2B_AddToCart_SpinnerMessage,
        B2B_CalculateTax_SpinnerMessage
    };
    messageState = B2B_Loading_Message;
    connectedCallback() {
        this.currentCommunityId = communityId;
        console.log("communityId: "+communityId);
        this.setDetails(null);
        registerListener("checkoutIntegrationEvent", this.setDetails, this); 
        registerListener("removeCheckoutIntegrationEvent", this.removeSetDetails, this); 
    }

    @wire(CurrentPageReference) pageRef; 

    disconnectedCallback() { 
        unregisterAllListeners(this); 
    } 
    removeSetDetails(){
        console.log('remove shipping methods');
        this.transformedOptions = undefined;
    }
    setDetails(loadMethods){ 
        console.log('fetching getCommerceCheckout == '+loadMethods);
        //if(loadMethods){
        //this.call_getCommerceCheckout(loadMethods);
        //}
        this.isPreview = this.isInSitePreview();
        if(this.isPreview){
            this.transformedOptions = [
                {
                    id: '2Dmxx0000004CFVCA2',
                    name: 'UPS Ground 3-5 business days',
                    shippingFee: '3.24',
                    currencyIsoCode: 'USD',
                    carrier: 'UPS',
                    classOfService: 'Same day UPS Ground',
                    selected: false,
                },
                {
                    id: '2Dmxx0000005DEWDB3',
                    name: 'UPS Next Day 2 business days',
                    shippingFee: '2.13',
                    currencyIsoCode: 'USD',
                    carrier: 'UPS',
                    classOfService: 'Next day UPS Ground',
                    selected: true,
                },
            ];
        } else {
            if(loadMethods != null){
                this.loader = true;
                let arr = [];
                let tempOrderMethods = JSON.parse(loadMethods.data);
                tempOrderMethods.forEach(currentItem => {
                    arr.push(currentItem.Id);
                });
                fetchOrderDeliveryMethods({lstOrderMethodId : arr,cdgId:loadMethods.cdgId})
                .then((res) => {
                   //console.log('CartDeliveryGroupMethod Response ::::');
                    //console.log(res);
                    this.loader=false;
                    this.transformedOptions = this.processData(res);
                    this.getSelectedDeliveryMethod(loadMethods.cartId);
                }).catch(error => {
                    console.log('error' ,error);
                    this.transformedOptions = Null;
                });
            }
            else{
                console.log('setDetails error, null values passed');
            }
        }
    } 
    getSelectedDeliveryMethod(cartId){
        getSelectedDeliveryMethod({cartId : cartId})
        .then((res) => {
            //console.log('cart Delivery Method selected : '+res);
            if(res != null){
                console.log('handle change called : ')
                //this.updateOptions(res);
                this.selectedOption = res;
                this.handleChange(undefined);
                //this.transformedOptions = Null;
            } else {
                this.selectedOption = this.transformedOptions[0].id;
                this.handleChange(undefined);
            }
        }).catch(error => {
            console.log('error' ,error);
        });
    }
    processData(res){
        let tempList = [];
        res.forEach(currentItem => {
            tempList.push({id:currentItem.DeliveryMethodId,name:currentItem.DeliveryMethod.Name,shippingFee:currentItem.ShippingFee,currencyIsoCode:currentItem.CurrencyIsoCode});
        });
        tempList.sort((a, b) => a.shippingFee - b.shippingFee);
        return tempList;
    }

    

    /**
     * Determines if you are in the experience builder currently
     */
    isInSitePreview() {
        let url = document.URL;
        
        return (url.indexOf('sitepreview') > 0 
            || url.indexOf('livepreview') > 0
            || url.indexOf('live-preview') > 0 
            || url.indexOf('live.') > 0
            || url.indexOf('.builder.') > 0
            || url.indexOf('.preview.') > 0);
    }

    /**
     * Updates the exisitng options and rebuilds the array to keep the selection
     */
    updateOptions(value){
        const newtransformedOptions = [];

        this.transformedOptions.forEach(option => {
            if(option.id == value){
                const newOption = {...option, selected:true};
                newtransformedOptions.push(newOption);
            }else{
                const newOption = {...option, selected:false};
                newtransformedOptions.push(newOption);
            }
            this.transformedOptions = newtransformedOptions
        });
    }

    /**
     * 
     * handle event for any change in selection of the shipping options
     */
    async handleChange(event){
        debugger;
        console.log('disabling options : ');
        // disable while the component is saving the values
        this.isDisabled = true;
        this.loader = true;
        console.log('event == ');
        console.log(event)
        if(event !== undefined){
            this.selectedOption = event.target.value;
        }

        
        console.log('event.target.value='+this.selectedOption);
        await updateDeliveryMethod(this.selectedOption);
        this.updateOptions(this.selectedOption);
        this.isDisabled = false;
        this.callGetShippingDiscount();
        loadCheckout(); //do after updating discount on shipping
        //this.loader = false;
        /*const deliveryAddressGroup = {
            deliveryMethodId: event.target.value
        }
        
        updateCommerceDeliveryMethodCheckout({communityId: this.currentCommunityId, payload : JSON.stringify(deliveryAddressGroup)})
        .then(result => {
            this.dispatchEvent(new CustomEvent('dataready', { bubbles: true, composed: true }));
            // enable the fields once the api responds
            this.isDisabled = false;
        })
        .catch(error => {
            console.log("Error in Submit call back:", error);
            this.isDisabled = false;
        })*/
    }

    retryAttemptShipDiscount = 0;
    async retryApiCalloutShipDiscount(){
        this.messageState = B2B_Loading_Message;
        this.retryAttemptShipDiscount = this.retryAttemptShipDiscount + 1;
        this.callGetShippingDiscount();
    }

    async callGetShippingDiscount(){
        this.inpMap.commId = communityId;
        if(this.retryAttemptShipDiscount == 1){
            this.messageState = 'Please wait';
        }else{
            this.messageState = B2B_CalculateDiscount_SpinnerMessage;
        }
        await getShippingDiscount({
            inputMap: this.inpMap
        }).then(res =>{
            console.log('response from getOracleIdAndStore---- ', res);
            if(!res.isSuccess){
                if(this.retryAttemptShipDiscount < 2){
                    this.retryApiCalloutShipDiscount();
                }else{
                    fireEvent(this.pageRef, HIDE_SUMMARY_DETAILS, null); 
                    this.loader = false;
                    this.messageState = B2B_Loading_Message;
                    this.isShippingCalculated = false;
                    this.template.querySelector('c-b2b-show-toast-message').showToast('Something went wrong while calculating discount please contact your admin.','error');
                }
            }else{
                this.cartId = res.cartId;
                this.isShippingCalculated = true;
                this.callTaxIntegrationCustomFunc();
                loadCheckout();
            }
        }).catch(error=>{
            this.isShippingCalculated = false;
            fireEvent(this.pageRef, HIDE_SUMMARY_DETAILS, null); 
            console.log('error in getOracleIdAndStore ',error);
            this.loader = false;
            this.messageState = B2B_Loading_Message;
        })
    }

    retryAttemptTax = 0;
    async retryApiCalloutTax(){
        this.messageState = B2B_Loading_Message;
        this.retryAttemptTax = this.retryAttemptTax + 1;
        this.callTaxIntegrationCustomFunc();
    }

    async callTaxIntegrationCustomFunc(){
        if(this.retryAttemptTax == 1){
            this.messageState = 'Please wait';
        }else{
            this.messageState = B2B_CalculateTax_SpinnerMessage;
        }
        //fireEvent(this.pageRef, VIEW_SUMMARY_DETAILS, null); 
        await callTaxIntegrationCustom({
            inputCartId: this.cartId
        }).then(res =>{
            if(!res.isSuccess){
                if(this.retryAttemptTax < 2){
                    this.retryApiCalloutTax();
                }else{
                    console.log('error in callTaxIntegrationCustomFunc ',res);
                    this.template.querySelector('c-b2b-show-toast-message').showToast('Something went wrong while calculating tax please contact your admin.','error');
                    fireEvent(this.pageRef, HIDE_SUMMARY_DETAILS, null); 
                    this.loader = false;
                    this.isTaxCalculated = false;
                    this.retryAttemptTax = 0;
                    this.messageState = B2B_Loading_Message;
                }
            }else{
                console.log('response from callTaxIntegrationCustomFunc---- ', res);
                loadCheckout();
                fireEvent(this.pageRef, VIEW_SUMMARY_DETAILS, null);
                this.loader = false;
                this.isTaxCalculated = true;
                this.retryAttemptTax = 0;
                this.messageState = B2B_Loading_Message;
            }
        }).catch(error=>{
            console.log('error in callTaxIntegrationCustomFunc ',error);
            fireEvent(this.pageRef, HIDE_SUMMARY_DETAILS, null); 
            this.loader = false;
            this.messageState = B2B_Loading_Message;
            this.isTaxCalculated = false;
            this.retryAttemptTax = 0;
        })
    }

    /**
     * The current checkout mode for this component
     *
     * @type {CheckoutMode}
     */
    @api get checkoutMode() {
        return this._checkoutMode;
    }

    /**
     * Handles the checkout mode and puts the component in the right state
     * If the component is not currently being edited it'll go into disbaled state
     */
    set checkoutMode(value) {
        switch(value){
            case 1:
                this.isDisabled = false;
                break;
            case 2:
                this.isDisabled = true;
                break;
            case 3:
                this.isDisabled = true;
                break;
            default:
                this.isDisabled = false;
        }
        this._checkoutMode = value;
    }

    /**
     * Report false and show the error message until the user accepts the Terms
     */
    @api
    get checkValidity() {
        return true;
    }
  
    /**
     * Report false and show the error message until the shopper accepts the 
     * Terms Checkout has reportValidity functionality.
     * 
     * One-page Layout: reportValidity is triggered clicking place order.
     * 
     * Accordion Layout: reportValidity is triggered clicking each section's 
     * proceed button.
     *
     * @returns boolean
     */
    @api
    reportValidity() {
        let isValid = true;
        console.log('shippingMethod reportvalidity called');
        if( !this.isShippingCalculated || !this.isTaxCalculated ){
            isValid = false;
            this.template.querySelector('c-b2b-show-toast-message').showToast('Please select a valid shipping address and method','error');
            throw new Error('Required data is missing');
        }
        return isValid;
    }
 
   /**
    * Works in Accordion when terms component before payment component.
    * 
    * Works in One Page when terms component placed anywhere.
    * 
    * Can be in same step/section as payment component as long as it is placed 
    * before payment info.
    *
    * (In this case this method is redundant and optional but shows as an 
    * example of how checkoutSave can also throw an error to temporarily halt 
    * checkout on the ui)
    */
    @api
    checkoutSave() {
        if (!this.checkValidity) {
            throw new 
            Error(
            'A delivery method must be selected');
        }
    }
}