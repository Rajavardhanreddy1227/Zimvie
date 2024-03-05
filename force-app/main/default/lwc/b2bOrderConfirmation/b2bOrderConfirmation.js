import { LightningElement, wire, track,api } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';

import Subtotal from '@salesforce/label/c.Subtotal';
import ShippingCosts from '@salesforce/label/c.ShippingCosts';
import Taxes from '@salesforce/label/c.Taxes';
import Total from '@salesforce/label/c.Total';
import loading from '@salesforce/label/c.loading';
import checkoutCartSummary_DiscountAdjustments from '@salesforce/label/c.checkoutCartSummary_DiscountAdjustments';
import checkoutCartSummary_ShippingDiscount from '@salesforce/label/c.checkoutCartSummary_ShippingDiscount';
import checkoutCartSummary_ShippingTax from '@salesforce/label/c.checkoutCartSummary_ShippingTax';

import {OrderItemsAdapter} from 'commerce/orderApi';
import { resolve } from 'c/b2B2C_cmsResourceResolver';


import getOrderProductSummary from '@salesforce/apex/B2BOrderConfirmationController.getOrderProductSummary';
import sendOrderConfirmEmail from '@salesforce/apex/B2BOrderConfirmationController.sendOrderConfirmEmail';
//import B2BDefaultImageUrl from '@salesforce/label/c.B2BDefaultImageUrl';
import B2B_Loading_Message from '@salesforce/label/c.B2B_Loading_Message';
export default class B2bOrderConfirmation extends LightningElement {

   @api ordersummaryidfromcontext;
   
   labels = {
      Subtotal,
      ShippingCosts,
      Taxes,
      Total,
      loading,
      checkoutCartSummary_DiscountAdjustments,
      checkoutCartSummary_ShippingDiscount,
      checkoutCartSummary_ShippingTax
   }
   messageState = B2B_Loading_Message;
   isLoading = true;
   orderSummaryNumber;
   orderSummaryId;
   
   @track orderLineItems;
   @track contactEmail;
   @track orderSummary;
   @track orderNumber;
   event2;
   @wire(CurrentPageReference)
   getStateParameters(currentPageReference) {
      console.log('currentPageReference',JSON.stringify(currentPageReference));
      this.isLoading=true;
       if (currentPageReference) {
         this.orderSummaryNumber = currentPageReference.state?.orderNumber;
         // if(this.orderSummaryNumber != null && this.orderSummaryNumber.trim() !=''){
         //    setTimeout(() => {
              
         //     }, 5000);
         //    //this.getOrderSummary();
         // }
      }
   }

   connectedCallback() {
      this.isLoading=true;
      if(this.orderSummaryNumber != null && this.orderSummaryNumber.trim() !='') {
         setTimeout(() => {
            this.getOrderSummary();
            this.sendEmail();
         }, 5000);
      }
   }

   sendEmail() {
         let mapParams = {
            orderSummaryNumber: this.orderSummaryNumber,
         }
         console.log('mapParams',mapParams)
         sendOrderConfirmEmail({
            mapParams: mapParams
         })
            .then((result) => {
               console.log('sendOrderConfirmEmail result');
               console.log(result);
               if (result.isSuccess) {
                  console.log('Email Sent');
               }
            })
            .catch((error) => {
               console.log('sendOrderConfirmEmail catch error');
               console.log(error);
            })
   }
   
  

   getOrderSummary() {
      this.isLoading = true;
      let mapParams = {
         orderSummaryNumber: this.orderSummaryNumber,
      }
      console.log('mapParams',mapParams)
      getOrderProductSummary({
         mapParams: mapParams
      })
         .then((result) => {
            console.log('getOrderProductSummary result');
            console.log(result);
            this.isLoading = false;
            if (result.isSuccess) {
               if (result.orderSummary) {
                  this.isLoading = true;
                  let tempOrderSummary = result.orderSummary;
                  tempOrderSummary.TotalAdjDistAmount = -1 * (tempOrderSummary.TotalProductAmount - tempOrderSummary.TotalAdjustedProductAmount);
                  //tempOrderSummary.TotalDeliveryAdjDistAmount = -1*tempOrderSummary.TotalDeliveryAdjDistAmount;
                  tempOrderSummary.TotalDeliveryAdjDistAmountCustom = -1*(tempOrderSummary.TotalDeliveryAmount - tempOrderSummary.TotalAdjustedDeliveryAmount);
                  this.orderSummary = tempOrderSummary;
                  this.contactEmail = result.orderSummary.Owner.Email;
                  this.orderSummaryId = result.orderSummary.Id;
                  this.orderNumber=result.orderSummary.Order_Number__c;
                  this.poNumber = result.orderSummary.PoNumber;
               }
               if (result.orderItemSummaryList) {
                  this.orderLineItems = result.orderItemSummaryList
                  // let orderLineItems = result.orderItemSummaryList;
                  // orderLineItems.forEach(element => {
                  //    if(element.Product2.DisplayUrl && cartItem.Product2.DisplayUrl != null){
                  //       element.productImage = element.Product2.DisplayUrl;
                  //    }
                  //    else{
                  //      // element.productImage = this.labels.B2BDefaultImageUrl;
                  //    }
                  // });
                  // this.orderLineItems = orderLineItems;
               }
            }else{
               this.getOrderSummary();
            }
            //this.isLoading = false;
         })
         .catch((error) => {
            console.log('getOrderProductSummary catch error');
            console.log(error);
            //this.isLoading = false;
         })
   }
  
       @wire(OrderItemsAdapter,{orderSummaryId:'$orderSummaryId'})
        wiredObj(result){
           if(!result){
              return;
           }
         console.log('OrderItemsAdapter Confirmation Items');
          console.log(JSON.stringify(result.data.items));
           console.log(JSON.stringify(result.data.items.length));
             console.log('orderLineItems Lenght',this.orderLineItems.length);
          let productImages=JSON.stringify(result.data.items);
          for(let i=0; i<result.data.items.length; i++){
           console.log('Product Iamges Product ID',i);
           console.log(result.data.items[i].product.productId);
             this.orderLineItems.forEach(element=>{
             console.log('Product ID');
             console.log(element.Product2Id);
             if(result.data.items[i].product.productId==element.Product2Id){
               console.log('Product ID Found');
               console.log('ImageURL',result.data.items[i].product.media.url);
               
               //element.productImage=result.data.items[i].product.media.url;
               element.productImage = resolve(result.data.items[i].product.media.url);
             }
              
          });

          }
          this.isLoading = false;
         
    }
  
   
}