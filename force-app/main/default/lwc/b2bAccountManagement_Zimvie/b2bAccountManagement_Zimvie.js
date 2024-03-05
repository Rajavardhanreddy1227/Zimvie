import {  LightningElement, api, wire,  track } from 'lwc';
import contextApi from 'commerce/contextApi';
import isguest from '@salesforce/user/isGuest';
import InvoiceNumber from '@salesforce/label/c.InvoiceNumber';
import InvoiceDate from '@salesforce/label/c.InvoiceDate';
import DueDate from '@salesforce/label/c.DueDate';
import RelatedToAccount from '@salesforce/label/c.RelatedToAccount';
import RelatedToContact from '@salesforce/label/c.RelatedToContact';
import Description from '@salesforce/label/c.Description';
import TotalTax from '@salesforce/label/c.TotalTax';
import TotalAmountWithTax from '@salesforce/label/c.TotalAmountWithTax';
import PayNow from '@salesforce/label/c.PayNow';
import Export from '@salesforce/label/c.Export';
//import fetchOrderDetails from '@salesforce/apex/B2BAccountManagementController.fetchOrderDetails';

const invoiceColumns = [
    { label: InvoiceNumber, fieldName: 'Name',sortable: "true" },
    { label: InvoiceDate, fieldName: 'Invoice_Date__c', type: 'date',sortable: "true" },
    { label: DueDate, fieldName: 'Due_Date__c', type: 'date',sortable: "true" },
    { label: 'Status', fieldName: 'Status__c', type: 'text',sortable: "true" },
    /*{ label: RelatedToAccount, fieldName: 'RelatedAcc',sortable: "true" },
    { label: RelatedToContact, fieldName: 'RelatedCon',sortable: "true" },*/
    { label: Description, fieldName: 'Description__c' },
    { label: TotalTax, fieldName: 'Total_Tax__c', type: 'currency' },
    { label: TotalAmountWithTax, fieldName: 'Total_Amount_With_Tax__c', type: 'currency',sortable: "true" },
];
export default class B2bAccountManagement_Zimvie extends LightningElement {
   labels={PayNow,Export};
   invColumns = invoiceColumns;
    isGuestUser = isguest;
    invoiceAction(event){
        console.log(event.detail);
    }
    effectiveAccountId;
    loggedinUserId;
    orderDetails;
    connectedCallback() {
   //console.log('i m in connectedcallback');
   const result = contextApi.getSessionContext();
   result.then((response) => {
      // console.log("getSessionContext result");
      //  console.log(response);
      console.log('Logged In user Id', response.userId);
      console.log('Effective Account Id', response.effectiveAccountId);
      this.effectiveAccountId = response.effectiveAccountId;
      this.loggedinUserId = response.userId;
      /*fetchOrderDetails({
            contactId: this.loggedinUserId
         })
         .then(data => {
            console.log('Order');
            console.log('Order Details==', JSON.parse(data));
            //  console.log('Order Details==',data);
            this.orderDetails = JSON.parse(data);;
         })
         .catch(error => {

         });*/
   }).catch((error) => {
      console.log("getSessionContext result");
      console.log(error);
   });

}
}