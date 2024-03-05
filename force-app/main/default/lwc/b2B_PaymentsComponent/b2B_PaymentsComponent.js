import { LightningElement,api,wire,track } from 'lwc';
import CreditCard from '@salesforce/label/c.B2B_Checkout_CreditCard';
import PurchaseOrder from '@salesforce/label/c.PurchaseOrder';
import Enter_PO_Number from '@salesforce/label/c.Enter_PO_Number';
import Place_Order from '@salesforce/label/c.Place_Order';
import Place_Order_W from '@salesforce/label/c.Place_Order_W';
import Payment_By_Term from '@salesforce/label/c.Payment_By_Term';
import getAvailableTerms from '@salesforce/apex/B2B_PaymentByTermController.getLoggedInUserAccountDetails';

export default class B2B_PaymentsComponent extends LightningElement {
    labels={CreditCard,PurchaseOrder,Enter_PO_Number,Place_Order,Place_Order_W, Payment_By_Term};
    //myWallet = false;
    @track
    hideWallets = false;
    @track
    randerForm = false;
    showTabTwo = false;
    // renderPaymentTerm = false;
    paymentTermPO = '';
    // isOrderPlaced = false;

    isTermSelected = false;

    
    isShowSpinner = false;
    
    @api
    storePaymentId;
@track
    saveCardFromWallet = false;
    //Stored payment
    handleStorePaymentSelectionP(event) {
        this.storePaymentId = event.detail;
        this.randerForm = false;
    }   
    handleCardRadioSelection(event){
        // this.hideWallets = event.detail.hideWallets;
        this.hideWallets = false;
        this.randerForm = event.detail.randerForm;
        this.renderPaymentTerm = event.detail.renderPaymentTerm;
        this.paymentTermPO = event.detail.termAccount;
        this.isTermSelected = 'false';
   }

//    handlePlaceOrderButton(event){
//         console.log('handle place order button');
//         this.isShowSpinner = event.detial.isShowloader;
//    }

        handlePaymentTerm(event){
            this.isTermSelected = event.detail.isTermSelected;
            console.log(this.isTermSelected, '---isTermSelected');

        }


        connectedCallback(){
            console.log('test testing');
            this.fetchAvailableTerms();
          
        }
    
        fetchAvailableTerms(){
            getAvailableTerms().then(result => {
    
              if(result != null){
                console.log(JSON.stringify(result), 'account data');
                this.showTabTwo = true;
                // this.availableTerms = result;
              }
    
            }).catch(error => {
    
                console.error('Error fetching accounts:', error);
             });
    
        }

    handlePayClickP() {
        this.template.querySelector("c-b2-b_-cyber-source-payment-form").handlePayClick();
    }

    useStoredPaymentP() {
        this.template.querySelector("c-b2-b_-cyber-source-payment-form").useStoredPayment();
    }

    // handlePayClickTerm(){
    //     this.isOrderPlaced = true;
    //     this.template.querySelector("c-b2-b_-cyber-source-payment-form").handlePaymentTermClick();
    // }
}