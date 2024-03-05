import { LightningElement, api } from 'lwc';
import checkbox from '@salesforce/label/c.checkbox';
export default class B2b_TermsAndConditions extends LightningElement {labels={checkbox};
 _checkedByDefault;  
    checked;
    showError = false;
    termsInfo;
 @api 
    contentId;
     @api
     get checkedByDefault() {
         return this._checkedByDefault;
     }
  
     set checkedByDefault(value) {
         this._checkedByDefault = value;
         this.checked = value;
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
      * Report false and show the error message until the user accepts the Terms
      */
     @api
     get checkValidity() {
         this.showError = !this.checked;
         return this.checked;
     }
   
     /**
      * Report false and show the error message until the shopper accepts the 
      * Terms Checkout has reportValidity functionality.
      * 
      * One-page Layout: reportValidity is triggered clicking place order.
      * 
      * Accordion Layout: reportValidity is triggered clicking each section's 
      * proceed button.
      *
      * @returns boolean
      */
     @api
     reportValidity() {
         this.showError = !this.checked;
         if(this.showError){
            throw new 
           Error(
           'Terms and Conditions must be accepted first by clicking the checkbox');
         }
  
         return this.checked;
     }
  
    /**
     * Works in Accordion when terms component before payment component.
     * 
     * Works in One Page when terms component placed anywhere.
     * 
     * Can be in same step/section as payment component as long as it is placed 
     * before payment info.
     *
     * (In this case this method is redundant and optional but shows as an 
     * example of how checkoutSave can also throw an error to temporarily halt 
     * checkout on the ui)
     */
     @api
     checkoutSave() {
       if (!this.checkValidity) {
         throw new 
           Error(
           'Terms and Conditions must be accepted first by clicking the checkbox');
         }
     }
  
     /**
      * The method is called in one-page layout only when the place order button 
      * is clicked. Used in conjunction with the payment component/section for 
      * checkout one-page layout.
      *
      * Must be placed before the payment component in the same payment section 
      * or any prior section.
      *
      * @type Promise<void>
      */
      @api
     placeOrder() {
         return this.reportValidity();
     }
  
     /**
      * Check and uncheck the checkbox. Show error unless checked.
      * @param {*} event
      */
     handleChange(event) {
         this.checked = event.target.checked;
         this.showError = !this.checked;
     }
}