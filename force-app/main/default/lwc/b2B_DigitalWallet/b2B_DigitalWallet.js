import { api, LightningElement, track } from 'lwc';

import getDigitalWallets from '@salesforce/apex/B2B_PaymentController.getDigitalWallets';
import deleteDigitalWallet from '@salesforce/apex/B2B_PaymentController.deleteDigitalWallet';


export default class B2B_DigitalWallet extends LightningElement {

    labels = {
        B2B_My_Wallet : 'My Wallet',
        B2B_card_Number_Label : 'Card Number',
        B2B_Card_Exp_Month_Label : 'Expiry Month',
        B2B_Card_Exp_Year_Label : 'Expiry Year',
        B2B_card_Type_Label : 'Card Type',
        B2B_Card_Exp_Date : 'Card Expiry Date',
        B2B_Card_Action : 'Card Action',
        B2B_Cart_Remove :  'Remove Card',
        B2B_Edit : 'Edit',
        B2B_NO_Saved_Cards : 'No Saved Card'
    };

    isLoading = false;

    @api
    isWalletPage = false;

    @track
    digitalWallets = [];

    connectedCallback() {
        this.fetchWallets();
    }



    @api customerToken;

    selectWallet(event) {
        this.dispatchEvent(new CustomEvent('walletselect', { detail: event.target.value }));
    }

    removeDigitalWallet(event) {
        // consoleLogging('digital wallet id');
        // consoleLogging(event.target.dataset.id);
        console.log('event.wallet.id--'+event.target.dataset.id);          
        let digitalWalletId = event.target.dataset.id;
        let digitalWallet = this.digitalWallets.filter((wallet) => (wallet.Id === digitalWalletId))[0];
        let dataMap = {
            'paymentInstrumentId': digitalWallet.GatewayToken,
            'customerTokenId': this.customerToken,
            'digitalWalletId': digitalWalletId
        }
        this.isLoading = true;
        deleteDigitalWallet({
            'dataMap': dataMap
        })
            .then((result) => {
                if(result.isSuccess){
                    let remainingItems = this.digitalWallets.filter((wallet) => (wallet.Id !== digitalWalletId));
                    this.digitalWallets = remainingItems;
                    // consoleLogging('this.digitalWallets:');
                    // consoleLogging(this.digitalWallets);       
                    console.log('this.digitalWallets:--');          
                    console.log('this.digitalWallets:--'+this.digitalWallets);            
                }else{
                    // consoleLogging('error deleteDigitalWallet:');
                    // consoleLogging(result.msg);
                    console.log('error deleteDigitalWallet:--');
                    console.log('error deleteDigitalWallet:--'+result.msg);
                }
                this.isLoading = false;
            })
            .catch((error) => {
                console.log('error :--'+error);
                this.isLoading = false;
            })
    }

    get hasWallets() {
        return (this.digitalWallets.length > 0);
    }

    @api
    uncheckRadioButtons() {
        let buttons = this.template.querySelectorAll('input[type=radio][name=digitalWallet]:checked');
        if (buttons && buttons.length > 0) {
            buttons.forEach((btn) => {
                btn.checked = false;
            })
        }
    }

    fetchWallets() {
        this.isLoading = true;
        let dataMap = {};
        getDigitalWallets({
            'dataMap': dataMap
        })
            .then((result) => {
                console.log('result---->'+result);
                if (result.isSuccess) {
                    let digitalWallets = result.digitalWallets;
                    if (this.isWalletPage) {
                        digitalWallets.forEach((wallet) => {
                            let today = new Date();
                            let someday = new Date();
                            someday.setFullYear(wallet.ExpiryYear__c, wallet.ExpiryMonth__c, 1);
                            if (someday <= today) {
                                wallet.isExpired = true;
                            }
                        });
                        this.digitalWallets = digitalWallets;
                    } else {
                        let validCards = digitalWallets.filter((wallet) => {
                            let today = new Date();
                            let someday = new Date();
                            someday.setFullYear(wallet.ExpiryYear__c, wallet.ExpiryMonth__c, 1);
                            return someday > today;
                        });
                        this.digitalWallets = validCards;
                    }
                }else{
                    console.log('result-msg--->'+result.msg);
                }
                this.isLoading = false;
            })
            .catch((error) => {
                console.log('error---->'+error);
                this.isLoading = false;
            })
    }

    @api
    refreshData() {
        this.fetchWallets();
    }

    editDigitalWallet(event) {
        console.log('event.target.dataset.id---->'+event.target.dataset.id);
        let walletToEdit = this.digitalWallets.filter((wallet) => wallet.Id === event.target.dataset.id);
        this.dispatchEvent(new CustomEvent('editwallet', { detail: walletToEdit[0] }));
    }

}