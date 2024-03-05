import { LightningElement,api,wire,track } from 'lwc';
import retrieveWallet from '@salesforce/apex/B2BAccountManagementController.retrieveWallet';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//MY Wallet
import getStoredWallet from "@salesforce/apex/B2B_CYBSPaymentContoller.getStoredWallet";
import deletePaymentMethod from "@salesforce/apex/B2B_CYBSPaymentContoller.deletePaymentMethod";
import updateWalletInfo from "@salesforce/apex/B2B_CYBSPaymentContoller.updateWalletInfo";
import walletcards from '@salesforce/resourceUrl/walletcards';
import deactivatePaymentMethod from "@salesforce/apex/B2B_CYBSPaymentContoller.deactivatePaymentMethod";
import setPayment from "@salesforce/apex/B2B_PaymentController.setPayment";
import getCustomerToken from '@salesforce/apex/B2B_PaymentController.getCustomerToken';
import getComponentSetup from "@salesforce/apex/B2B_CYBSPaymentContoller.getComponentSetup";
import CyberJSComp from "c/b2b_cyber_js";
import USER_ID from "@salesforce/user/Id";
import { getRecord } from "lightning/uiRecordApi";
import CurrencyIsoCode_FIELD from "@salesforce/schema/User.DefaultCurrencyIsoCode";
export default class B2BWallet extends LightningElement {
    _accid;
    //Store wallet
    StoredWallets;
    storePaymentId;
    microform;

    @track
    randerForm = false;
    @api
    storePaymentId;

    showNewCardForm = false;

    months;
    years;
    cardTypes;
    cardType;
    cardName;
    cardNickName;
    selectedMonth;
    selectedYear;
    customerToken;
    cardNumber;
    cardCVV;
    
    visacardurl=walletcards+ '/card-visa.png';
    showDeletePopup = false;
    showNewCardForm = false;

    @track
    saveCardFromWallet = true;

    @api 
    set accId(val){
        console.log('accid value for wallet is '+val);
        this._accid = val;
    }
    get accId(){
        return this._accid;
    }
    
    _isGuest;
    @api 
    set isGuest(val){
        console.log('guest value for wallet is '+val);
        this._isGuest = val;
    }
    get isGuest(){
        return this._isGuest;
    }

    error;
    otherParam = '';
    walletData;
    walletIdToDeactivate;

    @wire(retrieveWallet, { accId: '$accId'})
    objwallet ({ error, data }) 
    {
        if (data) {
           console.log('walletData=='+data);
           this.walletData = JSON.parse(data);
        } 
        else if (error) { 
            this.error = error;  
            console.log('Error Message'+error);
        }   
    }

    @wire(getRecord, {
        recordId: USER_ID,
        fields: [CurrencyIsoCode_FIELD]
      })
      wireuser({ error, data }) {
        if (error) {
          console.log("Error in geting User Currency " + error);
        } else if (data) {
          console.log(" User Currency " + data.fields.DefaultCurrencyIsoCode.value);
          this.userCurrencyCode = data.fields.DefaultCurrencyIsoCode.value;
          this.getMonthYearValues();
          this.getCardTypesValues();
        }
      }

    handleCardRadioSelection(event){
        this.hideWallets = event.detail.hideWallets;
        this.randerForm = event.detail.randerForm;
        this.saveCardFromWallet = true;
    }
    //Remove Start
    handlePayClickP() {
        this.template.querySelector("c-b2-b_-cyber-source-wallet-form").handlePayClick();
    }
    //remove End
    connectedCallback() {
        this.saveCardFromWallet = true;
        //Store Wallet
        getStoredWallet()
        .then((result) => {
            this.StoredWallets = result;
            //this.isLoaded = true;
        }).catch((error) => {
            this.error = error;
            //this.isLoaded = true;
        });
    }
    // deletePaymentMethod(event){
    //     //const action = event.detail.action;
    //     this.storePaymentId = event.target.value;
    //     deletePaymentMethod({storedPaymentId : this.storePaymentId})
    //     .then((result) => {
    //         const evt = new ShowToastEvent({
    //             title: "Delete",
    //             message: "Payment Method has been deleted successfully",
    //             variant: "success",
    //             mode: "dismissable"
    //           });
    //           this.dispatchEvent(evt);
    //           this.connectedCallback();
    //     }).catch((error) => {
    //         console.log('error -->'+error);
    //     });
    // }

    handleDeactiate(event) {
        // console.log('1',JSON.stringify(event.target.dataset));
        // console.log('2',JSON.stringify(event.target.dataset.value));
        // console.log('3',JSON.stringify(event.target.value));
        // let walletId = event.target.dataset.value;
        console.log('this.storePaymentId', this.walletIdToDeactivate);
        deactivatePaymentMethod({storedPaymentId : this.walletIdToDeactivate})
        .then(() => {
            const evt = new ShowToastEvent({
                title: "Delete",
                message: "Payment Method has been deactivated successfully",
                variant: "success",
                mode: "dismissable"
            });
            this.dispatchEvent(evt);
            this.connectedCallback();
            this.showDeletePopup = false;
        }).catch((error) => {
            console.log('error -->'+ JSON.stringify(error));
        });
    }

    handleOpenDeletePopup(event) {
        this.showDeletePopup = true;
        this.walletIdToDeactivate = event.target.dataset.value;
    }

    handleClose() {
        this.showDeletePopup = false;
    }

    handlDefaultChange(event){
        //const action = event.detail.action;
        this.storePaymentId = event.target.dataset.value;
        updateWalletInfo({storedPaymentId : this.storePaymentId})
        .then((result) => {
            // const evt = new ShowToastEvent({
            //     title: "Delete",
            //     message: "Payment Method has been deleted successfully",
            //     variant: "success",
            //     mode: "dismissable"
            //   });
            //   this.dispatchEvent(evt);
              this.connectedCallback();
        }).catch((error) => {
            console.log('error -->'+error);
        });
    }

    // handleOpenNewCardFrom() {
    //     this.showNewCardForm = true;
    //     console.log('this.showNewCardForm', this.showNewCardForm);

    //     console.log('workworkwork');
    //     new CyberJSComp(this).execute();
    //     getComponentSetup({ cardId: null })
    //     .then((result) => {
    //         console.log('resultresultresult', result);
    //         for (let key in result) {
    //             if(key==='keyId') {
    //                 this.kId = result.keyId;
    //                 console.log("Key for Flex " + this.kId);
            
    //                 var flex = new Flex(this.kId);
    //                 this.microform = flex.microform({
    //                 input: { "line-height": "1.875rem" }
    //                 });
            
    //                 var number = this.microform.createField("number", {
    //                 placeholder: "Card Card Number"
    //                 });

    //                 if(this.cardType == 'American Express'){
    //                 securityCode = this.microform.createField("securityCode", {
    //                     placeholder: "••••"
    //                 });
    //                 } else{
    //                 var  securityCode = this.microform.createField("securityCode", {
    //                     placeholder: "•••"
    //                 });
    //                 }
    //                 number.load(".cardNumberContainer");
    //                 securityCode.load(".cvvContainer");
    //             }
    //         }
    //     })
    //     .catch((error) => {
    //         console.log(
    //         "____Error while microform setup_____" + JSON.stringify(error)
    //         );
    //     });
    // }

    // handleSave() {
    //     console.log('GGGGGGGGG111111');
    //     this.getMonthYearValues();
    //     console.log('GGGGGGGGG');
    //     var options = {
    //         expirationMonth: this.selectedMonth,
    //         expirationYear: this.selectedYear
    //       };

    //     var self = this;
    //     console.log('this.selectedMonth', this.selectedMonth);
    //     console.log('self.selectedMonth', self.selectedMonth);
    //     this.microform.createToken(options, function (err, token) {
    //         console.log('tokentokentoken', token);
    //         setPaymentInfo({
    //             token : token,
    //             expirationMonth: self.selectedMonth,
    //             expirationYear: self.selectedYear,
    //             cardholderName: self.cardName,
    //             cardholderNickName: self.cardNickName,
    //             cardType: self.cardType
    //         })
    //         .then(() => {
    //             const evt = new ShowToastEvent({
    //             title: "Saved",
    //             message: "Payment Method has been saved successfully",
    //             variant: "success",
    //             mode: "dismissable"
    //           });
    //             this.dispatchEvent(evt);
    //         })
    //         .catch((error) => {
    //             console.log('error -->'+ JSON.stringify(error));
    //         });
    //     });
    // }


    handleOpenNewCardFrom() {
        this.showNewCardForm = true;
        let dataMap = {};
        getCustomerToken({
            'dataMap': dataMap
        }).then((result) => {
            console.log('result ', result);
            if (result.isSuccess) {
                this.customerToken = result.customerTokenId;
                console.log('Success getCustomerToken');
            }
        }).catch((error) => {
            console.log('11111 ' + JSON.stringify(error));
        })
    }

    handleSave() {
        const creditCardData = this.getCreditCardFromComponent();
        console.log('creditCardData', creditCardData);
        const addressData = {};
        console.log('this.customerToken', this.customerToken);
        if (this.customerToken) {
            let dataMap = {
                'paymentType': 'CardPayment',
                'billingaddress': JSON.stringify(addressData),
                'paymentInfo': JSON.stringify(creditCardData),
                'customerTokenId': this.customerToken
            }
            setPayment({
                'dataMap': dataMap
            }).then((result) => {
                if (result.isSuccess) {
                    const evt = new ShowToastEvent({
                        title: "Saved",
                        message: "Payment Method has been saved successfully",
                        variant: "success",
                        mode: "dismissable"
                    });
                    this.dispatchEvent(evt);
                }
            }).catch((error) => {
                console.log('add card error ' + JSON.stringify(error));
            });
        }
    }

    getMonthYearValues() {
        let months = [];
        let years = [];
        let currYear = new Date().getFullYear();
        for (let i = 0; i < 20; i++) {
            if (i < 12) {
                if(i<9) {
                    months.push({ label: String('0'+(i + 1)), value: String('0'+(i + 1))});
                } else{
                    months.push({ label: String(i + 1), value: String(i + 1) });
                }
            }
            years.push({ label: String(currYear + i), value: String(currYear + i) });
        }
        this.months = months;
        this.years = years;
    }

    getCardTypesValues() {
        let cardTypes = [];

        cardTypes.push({ label: "Visa", value: "Visa" });
        cardTypes.push({ label: "Master Card", value: "MasterCard" });
        if(this.userCurrencyCode && (this.userCurrencyCode == 'USD')) {
            cardTypes.push({ label: "American Express", value: "American Express" });
        }

        this.cardTypes = cardTypes;
    }

    handleCardTypeChange(event) {
        this.cardType = event.target.value;
        console.log("cardType  " + this.cardType);
    }
    handleMonthChange(event) {
        this.selectedMonth = event.target.value;
        console.log("Month  " + this.selectedMonth);
    }
    handleYearChange(event) {
        this.selectedYear = event.target.value;
        console.log("Year  " + this.selectedYear);
    }
    handleCardNickname(event) {
        this.cardNickName = event.target.value;
    }
    handleCardName(event) {
        this.cardName = event.target.value;
        console.log("cardName  " + this.cardName);
    }
    handleCardNumber(event) {
        this.cardNumber = event.target.value;
        console.log("cardNumber  " + this.cardNumber);
    }
    handleCardCVV(event) {
        this.cardCVV = event.target.value;
        console.log("cardCVV  " + this.cardCVV);
    }

    getCreditCardFromComponent() {
        const cardPaymentData = {
            'cardHolderName': this.cardName,
            'cardNumber': this.cardNumber,
            'cvv': this.cardCVV,
            'expiryYear': this.selectedYear,
            'expiryMonth': this.selectedMonth,
            'cardType': this.cardType
        };
        return cardPaymentData;
    }

}