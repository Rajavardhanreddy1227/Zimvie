import { LightningElement, api } from 'lwc';
import getAddressInformation from '@salesforce/apex/B2BOrderConfirmationController.getAddressInformation';
import ShippingMethod from '@salesforce/label/c.ShippingMethod';
import PaymentMethod from '@salesforce/label/c.PaymentMethod';
import PurchaseOrder from '@salesforce/label/c.PurchaseOrder';
import CardNumber from '@salesforce/label/c.CardNumber';
import BillingAddress from '@salesforce/label/c.BillingAddress';
import ShippingAddress from '@salesforce/label/c.ShippingAddress';
import B2B_Checkout_CreditCard from '@salesforce/label/c.B2B_Checkout_CreditCard';
import Terms from '@salesforce/label/c.Terms';
export default class B2bOrderAddressInformation extends LightningElement {
    labels = {
        ShippingMethod,
        PaymentMethod,
        BillingAddress,
        ShippingAddress,
        PurchaseOrder,
        CardNumber,
        B2B_Checkout_CreditCard,
        Terms
    }
    @api orderSummaryNumber;
    billingAddress = {};
    shippingAddress = {};
    shippingMethodName;
    PoNumber;
    DisplayCardNumber;

    connectedCallback(){
        this.getAddressInfo();
    }

    getAddressInfo(){
        let mapParams = {
            orderSummaryNumber: this.orderSummaryNumber,
         }
        getAddressInformation({
            mapParams : mapParams
        })
        .then((result) => {
            console.log('getAddressInformation result');
            console.log(result);
            if(result.isSuccess)
            {
                if(result.orderSummary){
                    this.billingAddress = {
                        Street : result.orderSummary.BillingStreet,
                        City : result.orderSummary.BillingCity,
                        State : result.orderSummary.BillingStateCode,
                        PostalCode : result.orderSummary.BillingPostalCode,
                        Country : result.orderSummary.BillingCountryCode
                    }
                    this.PoNumber = result.orderSummary.PoNumber;
                }
                if(result.orderDeliveryGroups){
                    this.shippingAddress = {
                        Name : result.orderDeliveryGroups.DeliverToName,
                        Street : result.orderDeliveryGroups.DeliverToStreet,
                        City : result.orderDeliveryGroups.DeliverToCity,
                        State : result.orderDeliveryGroups.DeliverToStateCode,
                        PostalCode : result.orderDeliveryGroups.DeliverToPostalCode,
                        Country : result.orderDeliveryGroups.DeliverToCountryCode
                    }
                    if(result.orderDeliveryGroups.OrderDeliveryMethod){
                        this.shippingMethodName = result.orderDeliveryGroups.OrderDeliveryMethod.Name;
                    }
                }
                if(result.orderPayment){
                    this.DisplayCardNumber = result.orderPayment.DisplayCardNumber;
                }
            }
        })
        .catch((error) => {
            console.log('getAddressInformation catch error');
            console.log(error);
        })
    }
}