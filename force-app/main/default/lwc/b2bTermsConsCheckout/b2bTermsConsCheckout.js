import { LightningElement, api,wire } from 'lwc';
 import contextApi from 'commerce/contextApi';
 import fetchAddresses from '@salesforce/apex/B2BAccountManagementController.fetchAddresses';
 import fetchAllCountryConfigs from '@salesforce/apex/B2BUtils.fetchAllCountryConfigs';
 import DISCALIMER_LINK from '@salesforce/label/c.Terms_Condition_Disclaimer';
 import TERM_COND from "@salesforce/messageChannel/B2BTermChecked__c";
 import { publish, MessageContext } from "lightning/messageService";

 


/**
 * Terms and Conditions has a link to the terms and conditions for the 
 * checkout user to read and a checkbox to accept the terms. Place order 
 * should be blocked by this component when placed in the payment step 
 * before or after the payment component.
 * 
 * One page layout: this component may be placed in its own section 
 * before or after payment.
 *
 * Accordion layout: this component may be placed in its own section 
 * before the payment section.
 * 
 * Accordion layout: this component may be placed directly in the 
 * payment section before or after the payment component.
 */
export default class B2bTermsConsCheckout extends LightningElement {
   _checkedByDefault;  
   checked;
   showError = false;
   effectiveAccountId;
   loggedinUserId;
   billingCountry = '';
   billingCountryCode = '';
   termsConditionsUrl;
   disclaimerLink='';
//    @wire(CurrentPageReference) pageRef;


    @wire(MessageContext)
    messageContext;

   connectedCallback() {

   const result = contextApi.getSessionContext();
   result.then((response) => {

      console.log('**Logged In user Id', response.userId);
      console.log('**Effective Account Id', response.effectiveAccountId);
      this.effectiveAccountId = response.effectiveAccountId;
      this.loggedinUserId = response.userId;
      fetchAddresses({
            AccId: this.effectiveAccountId
         })
         .then(data => {
            console.log('Addresses');
            console.log('Addresses==', JSON.parse(data));
            
            let addresses = JSON.parse(data);
            addresses.forEach((currentItem)=>{
                if (currentItem.AddressType === 'Billing' && currentItem.IsDefault) {
                    console.log(currentItem.Address);
                    console.log('Billing Country Code' + currentItem.Address.countryCode);
                    this.billingCountryCode = currentItem.Address.countryCode;
                    this.billingCountry = currentItem.Address.country;
                }
            });

             fetchAllCountryConfigs()
                .then(data =>{
                    console.log('Configs==', data);
                    let configs = data;
                    configs.forEach((currentItem)=>{
                        if (currentItem.Country_Code__c === this.billingCountryCode || 
                        currentItem.DeveloperName.toLowerCase() === this.billingCountry.toLowerCase() ) {
                        this.link = currentItem.Terms_Condition_URL__c;
                        this.disclaimerLink = this.getdisclaimerLink();
                       console.log('disclaimerLink2',disclaimerLink);
                    }
                    });
                    })
                .catch(error=>{
                    console.log('Configs error==', error);
                });
         })
         .catch(error => {
        console.log("fetchAddresses error");
        console.log(error);
         });
   }).catch((error) => {
      console.log("getSessionContext result");
      console.log(error);
   });

}
   /**
    * The terms may be checked by default from the builder property panel.
    */
    @api
    get checkedByDefault() {
        return this._checkedByDefault;
    }
 
    set checkedByDefault(value) {
        this._checkedByDefault = value;
        this.checked = value;
    }
 
    /**
     * Embed a link directing in the disclaimer string.
     */
    getdisclaimerLink() {
    let disclaimer = DISCALIMER_LINK.replace('{countryName}', this.billingCountry);
    console.log('this.disclaimer1', disclaimer);
       if (disclaimer.indexOf('[[') > 0 
         && disclaimer.indexOf('[[') 
         << disclaimer.indexOf(']]')) {
           return disclaimer
             .replace('[[', `<a href="${this.link}" 
                            target="termsandconditions">`)
             .replace(']]', '</a>');
        } else {
           return `<a href="${this.link}" 
            target="termsandconditions">${disclaimer}</a>`;
        }
    }
 
    // The message to show to the shopper
    @api
    disclaimer;
 
    // The link to the page containing the terms and conditions
    @api
    link;
 
    // The error message instructing the user to accept the terms
    @api
    error;
 
    /**
     * Required by checkout to register as a checkout component
     * 1 = EDIT mode
     */
     @api
    checkoutMode = 1;
 
   
    /**
     * Check and uncheck the checkbox. Show error unless checked.
     * @param {*} event
     */
    handleChange(event) {
        this.checked = event.target.checked;
        console.log(this.checked, 'checked----');
        // this.showError = !this.checked;

        const messaage = {
            messageToSend: this.checked
          };
      

        publish(this.messageContext, TERM_COND, messaage);
        // fireEvent(this.pageRef, 'handleCheckTermsCons', this.checked);
    }
}