import { LightningElement, wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation'; 
import {fireEvent} from 'c/b2b_pubsub';
import { registerListener, unregisterAllListeners } from 'c/b2b_pubsub';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import {
    subscribe,
    unsubscribe,
    MessageContext, APPLICATION_SCOPE
  } from "lightning/messageService";
  import TERM_COND from "@salesforce/messageChannel/B2BTermChecked__c";

export default class B2B_PlaceOrderButton extends LightningElement {

    isTermChecked;

    @wire(CurrentPageReference) pageRef; 

    @wire(MessageContext)
    messageContext;

    receivedMessage;
    subscription = null;


    subscribeMessage(){
       
        console.log("in handle subscribe");
        if (this.subscription) {
          return;
        }
        //4. Subscribing to the message channel
        this.subscription = subscribe(
          this.messageContext,
          TERM_COND,
          (message) => {
            this.handleMessage(message);
          }
        );

        }

        handleMessage(message){
            this.isTermChecked = message.messageToSend;
        }

    connectedCallback(){
        this.subscribeMessage();
        registerListener("handleCheckTermsCons", this.handleTC, this); 
    }

    handleTC(isTermChecked){
        console.log(JSON.stringify(isTermChecked));
        this.isTermChecked = isTermChecked;

    }
    

    disconnectedCallback(){
        unregisterAllListeners(this);
        unsubscribe(this.subscription);
    }
    

    

    handlePlaceOrder(){
       if(this.isTermChecked){
        fireEvent(this.pageRef, "placeOrderEvent", null); 
       }else{
        const evt = new ShowToastEvent({
            title: "Error",
            message: "Terms and Conditions must be accepted first by clicking the checkbox.",
            variant: "error",
            mode: "dismissable"
          });
          this.dispatchEvent(evt);

       }


    }


}