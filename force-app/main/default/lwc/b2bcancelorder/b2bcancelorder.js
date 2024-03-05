import { LightningElement,api,wire,track } from 'lwc';
import ToastContainer from 'lightning/toastContainer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
//import getOrderStatus from '@salesforce/apex/B2BCancelOrderController.getOrderStatus';
import cancelOrderMethod from '@salesforce/apex/B2BCancelOrderController.cancelOrder';
import { NavigationMixin } from 'lightning/navigation';
import contextApi from 'commerce/contextApi';

import { refreshApex } from '@salesforce/apex';
import loading from '@salesforce/label/c.loading';
import Youcancancelthisorder from '@salesforce/label/c.Youcancancelthisorder';
import CancelOrder from '@salesforce/label/c.CancelOrder';
import StartReOrder from '@salesforce/label/c.StartReOrder';
import {startReOrder} from 'commerce/orderApi';
import {refreshCartSummary} from 'commerce/cartApi';
import { getRecord } from 'lightning/uiRecordApi';

import DATE_FIELD from '@salesforce/schema/OrderSummary.CreatedDate';
import STATUS_FIELD from '@salesforce/schema/OrderSummary.Status';
import SOURCE_FIELD from '@salesforce/schema/OrderSummary.Order_Source__c';
import ORDERID_FIELD from '@salesforce/schema/OrderSummary.OriginalOrderId';

import LightningConfirm from 'lightning/confirm';

export default class B2bcancelorder extends NavigationMixin(LightningElement) {
    @api recordId;
    orderId;
    labels={loading,Youcancancelthisorder,CancelOrder,StartReOrder};
    isButtonVisible = false;
    reorderEligible = false;
    showReorder = false;
    connectedCallback() {
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';

        const result = contextApi.getSessionContext();
        
        result.then((response) => {
            this.accId = response.effectiveAccountId;
        }).catch((error) => {
            console.log("getSessionContext result error");
            console.log(error);
        });
    }   
    // $recordId
    @wire(getRecord, { recordId: '$recordId', fields: [DATE_FIELD, STATUS_FIELD,SOURCE_FIELD,ORDERID_FIELD] })
    wiredRecord({ error, data }) {
        if (error) {
            console.error('error:'+JSON.stringify(error));
        } else if (data) {
            //console.log('data==');
            //console.log(data);
            let orderSummaryRecord = data;
            let tempDate = orderSummaryRecord.fields.CreatedDate.value;
            let tempDate2 = Date.parse(String(tempDate));
            const createddate = new Date(tempDate2);
            //console.log('createddate==');
            //console.log(createddate);
            let orderSummStatus = orderSummaryRecord.fields.Status.value;
            //console.log('orderSummStatus==');
            //console.log(orderSummStatus);
            var copiedDate = new Date(createddate.getTime());
            this.isButtonVisible = copiedDate.setMinutes(copiedDate.getMinutes() + 15) > new Date() && orderSummStatus != 'Cancelled' ? true : false;
            //console.log('this.isButtonVisible==');
            //console.log(this.isButtonVisible);
            if(this.isButtonVisible){
                //let dt = createddate.setMinutes(createddate.getMinutes() + 15);
                this.bindCheckStatus(createddate.getTime() + 900000);
            }
            this.orderId = orderSummaryRecord.fields.OriginalOrderId.value;
            //console.log('this.orderId==');
            //console.log(this.orderId);
            this.reorderEligible = orderSummaryRecord.fields.Order_Source__c.value != 'Oracle' && orderSummStatus != 'Cancelled' ? true : false;
            this.showReorder = this.reorderEligible && !this.isButtonVisible ? true : false;
            console.log('this.reorderEligible==');
            console.log(this.reorderEligible);
        }
    }


    @track minutes;
    @track seconds;
    bindCheckStatus(timeSpan){

     var parentThis = this;
     let x = setInterval(() => {
            
            //console.log('changing time every second');
            var now = new Date().getTime();
            //console.log('now='+now);
            var distance = timeSpan - now;
            parentThis.minutes = Math.floor((distance % (1000 * 60 * 60)) / (1000 * 60));
            parentThis.seconds = Math.floor((distance % (1000 * 60)) / 1000);
            
            if (distance < 0) {
                clearInterval(x);
                parentThis.isButtonVisible = false;
                parentThis.showReorder = parentThis.reorderEligible ? true : false;
            }
        }, 1000);
    }
    error;
    loader = false;
    accId;
    async handleCancel(){
        const result = await LightningConfirm.open({
            message: 'Are you sure you want to cancel the order?',
            variant: 'headerless',
            label: 'Are you sure you want to cancel the order?',
            // setting theme would have no effect
        });
        if(!result){
            return;
        }
        this.loader = true;
        cancelOrderMethod({ recId: this.recordId,orderId: this.orderId,accId:this.accId })
            .then((result) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Order has been cancelled',
                        variant: 'success'
                    })
                );
                this.isButtonVisible = false;
                //this.showReorder = this.reorderEligible ? true : false;
                this.loader = false;
                this.error = undefined;
                // Display fresh data in the form
                //return refreshApex(this.wiredRes);
                
            })
            .catch((error) => {
                this.error = error;
                this.loader = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error updating record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
    handleReOrder(){
        this.loader=true;
        startReOrder({orderSummaryId:this.recordId,cartStateOrId:'active'}).then((fulfilled) => {
                //console.log("added product to cart" ,fulfilled);
                refreshCartSummary();
                this.loader=false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Your cart has been updated.',
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
                
            }).catch(error => {
                console.log('error' ,error);
                this.loader = false;
                /*this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message:
                            '{0} could not be added to your cart at this time. Please try again later.',
                        messageData: [this.displayableProduct.name],
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );*/
            });
    }
}