import { LightningElement,api } from "lwc";
//MY Wallet
import getStoredWallet from "@salesforce/apex/B2B_CYBSPaymentContoller.getStoredWallet";
import Default from '@salesforce/label/c.Default';
import card_ending_no from '@salesforce/label/c.card_ending_no';

export default class B2B_StoredPaymentList extends LightningElement {

     //Store wallet
    storedWallets;
    cStorePaymentId;
    myWallet = false;
    labels={Default,card_ending_no};
    @api
    hideAllWallets;
    connectedCallback() {
        console.log('Inside connected ');
        console.log('hideAllWallets -- '+this.hideAllWallets);
        //Store Wallet
        getStoredWallet()
            .then((result) => {
            this.storedWallets = result;
            for(let i=0; i<this.storedWallets.length; i++){
                console.log(this.storedWallets[i].Id);
                if(this.storedWallets[i].IsDefault__c){
                    this.cStorePaymentId = this.storedWallets[i].Id
                }
            }
            const selectedEvent = new CustomEvent("storedpaymentvaluechange", {
                detail: this.cStorePaymentId
            });
        
            // Dispatches the event.
            this.dispatchEvent(selectedEvent);
            console.log(' this.cStorePaymentId--'+ this.cStorePaymentId);
            console.log('this.hideAllWallets -- '+this.hideAllWallets);
            //this.hideAllWallets = false;
            }).catch((error) => {
                this.error = error;
                this.hideAllWallets = true;
            });
    }
     //Stored payment
    handleStorePaymentSelection(event) {
        this.cStorePaymentId = event.target.value;
        const selectedEvent = new CustomEvent("storedpaymentvaluechange", {
            detail: this.cStorePaymentId
          });
      
          // Dispatches the event.
          this.dispatchEvent(selectedEvent);
    }
    
}