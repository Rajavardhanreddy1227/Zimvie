import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import ThankYouforYourPurchase from '@salesforce/label/c.ThankYouforYourPurchase';
import Yourorder from '@salesforce/label/c.Yourorder';
import orderplaced from '@salesforce/label/c.orderplaced';
import ContactEmail from '@salesforce/label/c.ContactEmail';
import Clickheretocanceltheorder from '@salesforce/label/c.Clickheretocanceltheorder';
import PO_Number from '@salesforce/label/c.PO_Number';
import ContinueShopping from '@salesforce/label/c.ContinueShopping';
export default class B2bOrderConfirmationMessage extends NavigationMixin(LightningElement) {

    @api orderSummaryNumber;
    @api contactEmail;
    @api orderSummaryId;
    @api orderNumber;
    
    labels = {
        ThankYouforYourPurchase,
        Yourorder,
        orderplaced,
        ContactEmail,
        Clickheretocanceltheorder,
        PO_Number,
        ContinueShopping
    }
    get orderSummaryUrl(){
       // return "./OrderSummary/"+ this.orderSummaryId;
       return './accountmanagement?c__page=order&c__recordid='+this.orderSummaryId;
    }
    handleContinueShopping(evt){
        evt.preventDefault();
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/'
            }
        });
    }
}