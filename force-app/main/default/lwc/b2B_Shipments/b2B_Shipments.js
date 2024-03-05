import { LightningElement, api, wire } from 'lwc';
import getShipments from '@salesforce/apex/ShipmentController.getShipments';

export default class ShipmentController extends LightningElement {
 @api recordId;
 @api recordidcstm;
 shipments;

 connectedCallback() {
   const currentURL = window.location.href;
   const idPattern = /\/([a-zA-Z0-9]+)$/;
   const match = currentURL.match(idPattern);

   if (match && match.length >= 2) {
     this.recordId = match[1];
   }
   if (this.recordidcstm) {
     this.recordId = this.recordidcstm;
   }
 }

 @wire(getShipments, { orderId: '$recordId' })
 wiredShipments({ error, data }) {
   console.log('Record ID:', this.recordId);
   if (data) {
     this.shipments = data;
     console.log('getShipments:', data);
   } else if (error) {
     console.log('getShipments Error:', error);
     console.error('Error fetching shipments:', error);
   }
 }
}