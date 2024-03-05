import { LightningElement, wire, api } from 'lwc';
import getAvailableTerms from '@salesforce/apex/B2B_PaymentByTermController.getLoggedInUserAccountDetails';
import Terms from '@salesforce/label/c.Terms';
import TermsMessage from '@salesforce/label/c.TermsMessage';
import Phone from '@salesforce/label/c.Phone';
import CheckoutTermsPhoneNumber from '@salesforce/label/c.CheckoutTermsPhoneNumber';
import Fax from '@salesforce/label/c.Fax';
import CheckoutTermsFaxNumber from '@salesforce/label/c.CheckoutTermsFaxNumber';
import Email from '@salesforce/label/c.Email';
import CheckoutTermsEmail from '@salesforce/label/c.CheckoutTermsEmail';
import BillingAddress from '@salesforce/label/c.BillingAddress';

export default class B2B_PaymentByTerm extends LightningElement {

    labels={Terms,TermsMessage,Phone,CheckoutTermsPhoneNumber,Fax,CheckoutTermsFaxNumber,Email,CheckoutTermsEmail,BillingAddress};
    availableTerms;
    showTerm = false;
  
    isShowSpinner = false;
    connectedCallback(){
        console.log('test testing');
        this.fetchAvailableTerms();
      
    }

    fetchAvailableTerms(){
        getAvailableTerms().then(result => {


            console.log(JSON.stringify(result), 'account data');
            this.availableTerms = result;

        }).catch(error => {

            console.error('Error fetching accounts:', error);
         });

    }


    handleCardRadio(event){
        this.showTerm = true;
        let termText =  this.availableTerms.Available_Terms__c;
        // Dispatch the custom event with data to be sent to the parent component
        const selectedEvent = new CustomEvent('termselected', {
            detail: { isTermSelected: 'true'}
        });
        this.dispatchEvent(selectedEvent);
    
    }



}