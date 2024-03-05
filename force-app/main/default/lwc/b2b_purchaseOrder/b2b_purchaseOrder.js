import { LightningElement, wire, api, track } from 'lwc';
import { NavigationMixin } from "lightning/navigation";
import PurchaseOrder from '@salesforce/label/c.PurchaseOrder';
import {fireEvent} from 'c/b2b_pubsub';
import { CurrentPageReference } from 'lightning/navigation'; 
import { registerListener, unregisterAllListeners } from 'c/b2b_pubsub';

export default class B2b_purchaseOrder extends NavigationMixin(
    LightningElement
  ) {

    @wire(CurrentPageReference) pageRef; 
    
    labels={PurchaseOrder};
    poInput = '';
    showloaderPo = false;

     /**
     * Get purchase order input
     * @returns purchaseOrderInput - payment component
     */
     handlePOInput(event) {
      event.preventDefault();
      this.poInput = event.target.value;
      console.log('Value stored in variable: ' + this.poInput);
        fireEvent(this.pageRef, "poChangeEvent", this.poInput); 
    
    }

    connectedCallback() {

      registerListener("shoLoader", this.handLoader, this); 

    }

    handLoader(showloaderPo){
      this.showloaderPo=showloaderPo;
  
    }


    async disconnectedCallback() {
      unregisterAllListeners(this);
    }



     /**
     * Determines if you are in the experience builder currently
     */
     isInSitePreview() {
        let url = document.URL;

        return (
        url.indexOf("sitepreview") > 0 ||
        url.indexOf("livepreview") > 0 ||
        url.indexOf("live-preview") > 0 ||
        url.indexOf("live.") > 0 ||
        url.indexOf(".builder.") > 0
        );
    }

  




  }