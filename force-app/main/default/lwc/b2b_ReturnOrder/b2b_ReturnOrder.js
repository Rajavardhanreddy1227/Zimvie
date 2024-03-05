import { LightningElement,api,wire,track } from 'lwc';
import ToastContainer from 'lightning/toastContainer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import orderNumber from '@salesforce/label/c.orderNumber';
export default class B2b_ReturnOrder extends LightningElement {labels={orderNumber};
 @api recordId;
    orderId;
}