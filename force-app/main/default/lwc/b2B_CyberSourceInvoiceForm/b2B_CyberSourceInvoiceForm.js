import { LightningElement, api, wire, track } from "lwc";
import { CheckoutInformationAdapter, placeOrder, simplePurchaseOrderPayment } from "commerce/checkoutApi";
import {
  FlowAttributeChangeEvent,
  FlowNavigationNextEvent,
  FlowNavigationBackEvent
} from "lightning/flowSupport";
import { NavigationMixin } from 'lightning/navigation';

import { CartSummaryAdapter } from "commerce/cartApi";

//import { ClientSidePaymentAdapter } from "commerce/checkoutApi"; 

import communityPath from '@salesforce/community/basePath';

import checkoutApi from 'commerce/checkoutApi';

import { ShowToastEvent } from "lightning/platformShowToastEvent";
import CyberJSComp from "c/b2b_cyber_js";
import getComponentSetup from "@salesforce/apex/B2B_CYBSPaymentContoller.getComponentSetup";
//import handlePostPayment from "@salesforce/apex/B2B_CYBSPaymentContoller.handlePostPayment";
import AuthorizationAPI from "@salesforce/apex/B2B_CYBSPaymentContoller.AuthorizationAPI";
import saveNewCard from "@salesforce/apex/B2B_CYBSPaymentContoller.saveNewCard";
import saveNewCardForInv from "@salesforce/apex/B2B_CYBSPaymentContoller.saveNewCardForInv";

import is3Dsecure from "@salesforce/apex/B2B_CYBSPaymentContoller.is3Dsecure";

//checkout with PO
//import checkoutByPO from "@salesforce/apex/B2B_CYBSPaymentContoller.checkoutWithPONumber"; 

//check for payment option
import isPoOrCreditCart from "@salesforce/apex/B2B_CYBSPaymentContoller.isPoOrCreditCart";

import checkoutUsingStoredPaymentInv from "@salesforce/apex/B2B_CYBSPaymentContoller.checkoutUsingStoredPaymentInv";
//MY Wallet
import getStoredWallet from "@salesforce/apex/B2B_CYBSPaymentContoller.getStoredWallet";

//import acceptedCreditCards from "@salesforce/resourceUrl/B2B_AppAssets";

//loggedIn user currency
import { getRecord } from "lightning/uiRecordApi";
import USER_ID from "@salesforce/user/Id"; //this is how you will retreive the USER ID of current in user.
import CurrencyIsoCode_FIELD from "@salesforce/schema/User.DefaultCurrencyIsoCode";
import AccountId_FIELD from "@salesforce/schema/User.Contact.AccountId";

//Custom labels for Credit card page 
import cardNickName from '@salesforce/label/c.B2B_Card_Nick_Name';
import cardName from '@salesforce/label/c.B2B_Card_Name';
import cardType from '@salesforce/label/c.B2B_Card_Type';
import cardNumber from '@salesforce/label/c.B2B_Card_Number';
import cardCVV from '@salesforce/label/c.B2B_CVV';
import cardExpMonth from '@salesforce/label/c.B2B_Expiry_Month';
import cardExpYear from '@salesforce/label/c.B2B_Expiry_Year';
import cardSubmitButton from '@salesforce/label/c.B2B_Submit_Payment';
import cardNumberPlaceHolder from '@salesforce/label/c.B2B_Card_Place_Holder';
import cardPaymentCaptured from '@salesforce/label/c.B2B_Captured_Payment_Message';
import cardGenericError from '@salesforce/label/c.B2B_Generic_Error';
import cardInvalidError from '@salesforce/label/c.B2B_Invalid_Card_Error';
import cardInvalidDateError from '@salesforce/label/c.B2B_Invalid_Date_Error';
import transactionError from '@salesforce/label/c.B2B_Error_In_Transaction';
import paWithLink from '@salesforce/label/c.B2B_Transaction_Field_PA_Created';
import paCreated from '@salesforce/label/c.B2B_PA_Created';
import creditCard from '@salesforce/label/c.B2B_Checkout_CreditCard';
import termandcondition from '@salesforce/label/c.B2B_Term_and_Condition';
import Add_New_Card from '@salesforce/label/c.Add_New_Card';
//import termandconditionerror from '@salesforce/label/c.B2B_Term_and_Conditions_Error';
//import defaultPaymentTerm from '@salesforce/label/c.B2B_Default_Payment_Term';
import checkoutAddError from '@salesforce/label/c.B2B_Checkout_Address_Error';
import SelectLabel from '@salesforce/label/c.SelectLabel';
import Save_This_Card_For_Future_Purchase from '@salesforce/label/c.Save_This_Card_For_Future_Purchase';
import B2B_Loading_Message from '@salesforce/label/c.B2B_Loading_Message';

//import cancelCheckout from "@salesforce/apex/B2B_CheckoutController.cancelCheckout";

export default class B2B_CyberSourceInvoiceForm extends NavigationMixin(
  LightningElement
) {

  @api
  receiptId;
  messageState = B2B_Loading_Message;
  kId;
  microform;
  months;
  years;
  cardTypes;
  errorMessage;
  //Payment Option
  poNumberShow = false;
  
  @api
  saveFromWallets;
  @api
  renderCyberSourceForm;
  poNumberCheckout;
  isCreditCardShow=true;
  isPOCardShow=false;
  isTermSelected = false;

  // //Store wallet
  // storedWallets;
  @api
  paymentId;

  @api orderId;
  cartId;
  webstoreId;
  @api attentionTo;

  poNumber;
  cardType;
  cardName;
  cardNickName;
  selectedMonth;
  selectedYear;
  selectSavecard = true;
  isLoaded = false;
  isLoadedMain = false;
  is3DSecure=false;
  //3d secure
  deviceDataCollectionURL;
  accessToken;
  originUrl;
  jwtToken;
  isSuccessLoad;
  userCurrencyCode;
  stepUpUrl;
  accessTokenSetUp;
  referenceId;
  tokenWithCartId;
  isPoNull=true;
  poNumberTerm;

  @track checkoutId;
  @track shippingAddress;
  @track showError = false;
  @track error;
  

  label = {
    cardNickName,
    cardName,
    cardType,
    cardNumber,
    cardCVV,
    cardExpMonth,
    cardExpYear,
    cardSubmitButton,
    cardNumberPlaceHolder,
    cardPaymentCaptured,
    cardGenericError,
    cardInvalidError,
    cardInvalidDateError,
    transactionError,
    paWithLink,
    paCreated,
    creditCard,
    termandcondition,
    termandconditionerror : 'Error in terms and condition',
    defaultPaymentTerm : 'Default Terms',
    checkoutAddError,
    SelectLabel,
    Save_This_Card_For_Future_Purchase,
    Add_New_Card
  };

  showDefaultPaymentTerm=false;
  isShowPaymentOptionLabel=false;
  //isShowGenricMsg=false; remove
  paymentTermLabel;
  isPaymentTermSelected = false;
  isDefault = true;

  eventMessage;
  closeModal = false;
  @api availableActions;
  checkoutId;

  @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        console.log("data Id- suumar-ff", data);
        if (data) {
            console.log("Cart aa Id", data.cartId);
            console.log("Cart aa data", data.webstoreId);
            this.cartId = data.cartId;
            this.webstoreId = data.webstoreId;
           // this.getCpnFromCart(data);
        } else if (error) {
            console.error('====Error'+error);
        }
    }


    @wire(CheckoutInformationAdapter, {})
    checkoutInfo({ error, data }) {
                console.log("simplePurchaseOrder checkoutInfo");
                if (data) {
                    this.checkoutId = data.checkoutId;
                    console.log("simplePurchaseOrder checkoutInfo checkoutInfo: " +JSON.stringify(data));
                    //this.shippingAddress = data.deliveryGroups.items.deliveryAddress;
                    if (data.checkoutStatus == 200) {
                        console.log("simplePurchaseOrder checkoutInfo checkoutInfo 200");
                       
                    }
                } else if (error) {
                    console.log("##simplePurchaseOrder checkoutInfo Error: " + error);
                }
            } 

   /**
     * complete payment
     */
   @api
   async completePayment(){
       let address =  'TEST TEST'//this.shippingAddress;
       const purchaseOrderInputValue = this.poNumberTerm; //this.getPurchaseOrderInput().value;
       console.log(this.checkoutId + 'checkout id');
       let po = simplePurchaseOrderPayment(this.checkoutId, purchaseOrderInputValue, null);
       return po;
   }

   
  async disconnectedCallback() {
    try {
      // await cancelCheckout({cartId : this.cartId});
    } catch (mess) {
      let m = mess.message || mess.body.message || (mess.body.pageErrors?.length > 0 && mess.body.pageErrors[0].message);
      alert(m);
    }
  }

  // disconnectedCallback() {
  //   alert('DEB:: cancelCheckout 222: this.cartId:' + this.cartId);
  //   cancelCheckout({ cartId: this.cartId });
  // }

  // Navigation to web page 
    cartPage(event) {
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": "/cart/"+this.cartId
            }
        });
    }

  @wire(getRecord, {
    recordId: USER_ID,
    fields: [CurrencyIsoCode_FIELD,AccountId_FIELD]
  })
  wireuser({ error, data }) {
    if (error) {
      console.log("Error in geting User Currency " + error);
    } else if (data) {
      console.log(" User Currency " + data.fields.DefaultCurrencyIsoCode.value);
     
      this.userCurrencyCode = data.fields.DefaultCurrencyIsoCode.value;
      this.getMonthYearValues();
    }
  }

  handlePORadio(event) {
    this.poNumberShow = true;
    this.myWallet = false;
  }

  handleCardRadio(event) {
    
    this.poNumberShow = false;
    this.myWallet = false;
    //this.hideWallets = true;
    this.hideWallets = false;
    this.isTermSelected = false;
    this.renderCyberSourceForm = true;

    const selectedEvent = new CustomEvent("cardradiochanged", {
      detail : {
        hideWallets: this.hideWallets,
        randerForm : true
      }
    });

    // Dispatches the event.
    this.dispatchEvent(selectedEvent);

    new CyberJSComp(this).execute();
    //Setup Micro Form for Setup Credit cart page
    getComponentSetup({ cardId: this.cartId })
      .then((result) => {
        for (let key in result) {
          if(key==='keyId')
          {
            this.kId = result.keyId;
            console.log("Key for Flex " + this.kId);
    
            var flex = new Flex(this.kId);
            this.microform = flex.microform({
              input: { "line-height": "1.875rem" }
            });
    
            var number = this.microform.createField("number", {
              placeholder: "Card Card Number"
            }); //this.label.cardNumberPlaceHolder

            // securityCode = '';
            if(this.cardType == 'American Express'){
               securityCode = this.microform.createField("securityCode", {
                placeholder: "••••"
              });
            } else{
              var  securityCode = this.microform.createField("securityCode", {
                placeholder: "•••"
              });
            }
            number.load(".cardNumberContainer");
            securityCode.load(".cvvContainer");
            this.isLoaded = true;
          }
          else{
            //this.isShowGenricMsg=true; remove
           /* const evt = new ShowToastEvent({
              title: "Error",
              message: "No MID Setup for this account ",
              variant: "error",
              mode: "dismissable"
            });
            this.dispatchEvent(evt);*/
            this.isLoaded = true;
          }
        }
        
        
      })
      .catch((error) => {
        this.isLoaded = true;
        console.log(
          "____Error while microform setup_____" + JSON.stringify(error)
        );
      });
  }

  handleStorePaymentRadio(event) {
    this.poNumberShow = false;
    this.myWallet = true;
  }

  //Device Data collection Iframe
  callIframforSessionId(originUrl) {
    window.addEventListener(
      "message",
      (event) => {
        if (event.origin === originUrl) {
          //"https://centinelapistag.cardinalcommerce.com"

          let data = JSON.parse(event.data);
          console.log("Merchant received a message:", data);
          if (data !== undefined && data.Status) {
            console.log("Songbird ran DF successfully");
            this.isSuccessLoad = "Yes";
            console.log('Inside callIframforSessionId '+this.isSuccessLoad);
          }
        } else {
          console.log("NO Event Listen " + JSON.parse(event.data));
        }
      },

      false
    );
    console.log("Is Ifram load--" + this.isSuccessLoad);
  }
  connectedCallback() {
    console.log('saveFromWallets---->'+this.saveFromWallets);
    const selfthis = this;
    console.log('paymentId---->'+this.paymentId);
    window.addEventListener("message", function (event) {
      console.log("message received " + event.data);
      if (event.data == "Success") {
        console.log("Going to close Modal");

        const evt = new ShowToastEvent({
          title: "Success",
          message: event.data,
          variant: "success",
          mode: "dismissable"
        });
        selfthis.dispatchEvent(evt);
        selfthis.closeModal = false;
        const navigateNextEvent = new FlowNavigationNextEvent();
        selfthis.dispatchEvent(navigateNextEvent);
        selfthis.submitDetails.bind(selfthis);
        console.log("Close Modal " + selfthis.closeModal);
      }
      if (event.data == "User failed authentication") {
        console.log("Going to close Modal");

        const evt = new ShowToastEvent({
          title: "Error",
          message: event.data,
          variant: "error",
          mode: "dismissable"
        });
        selfthis.dispatchEvent(evt);
        selfthis.closeModal = false;
        selfthis.submitDetails.bind(selfthis);
        console.log("Close Modal " + selfthis.closeModal);
      }
      //JSON.stringify(error)
    });
    //this.cardNumber = true;
    console.log("Order Id-----xxx-->" + this.orderId);
    
     //check is account is 3D secure enable or not 
      is3Dsecure()
        .then(result => {
          console.log('Is 3D secure -->', result);
          this.is3DSecure=result;
          //this.handleCardRadio();
        })
        .catch(error => {
          console.error('Error in checking for 3D secure :', error);
      });
  }

  @api
    useStoredPayment() {
    console.log('paymentId---->'+this.paymentId);

   
    if (typeof this.paymentId === "undefined") {
      //alert(B2BStoredPaymentSelection);
      const evt = new ShowToastEvent({
        title: "Error",
        message: "Please select any stored payment",
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(evt);
      //alert('Please select any stored payment');
    } else if(this.isTermSelected == false){
      this.isLoadedMain = true;
      checkoutUsingStoredPaymentInv({
        orderId: this.cartId,
        webstoreId : this.webstoreId,
        cartId: this.cartId,
        storedPaymentId: this.paymentId,
        userCurrencyCode: this.userCurrencyCode,
        receiptId: this.receiptId
      })
        .then((result) => {
          console.log("toast is running"+result);
          this.isLoadedMain = false;

          const evt = new ShowToastEvent({
            title: "Success",
            message: "Your request has been initiated. Thank You",
            variant: "success",
            mode: "dismissable"
          });
          this.dispatchEvent(evt);

          setTimeout(()=>{
            window.location.reload();
          },3500);

        })
        .catch((error) => {
          const evt = new ShowToastEvent({
            title: "Error",
            message: "Transaction Error",
            variant: "error",
            mode: "dismissable"
          });
          this.dispatchEvent(evt);
          //ShowToastEvent.showErrorToast(this,'Error','Transaction Error' );//this.label.Error, this.label.transactionError
          this.error = error;
          this.isLoadedMain = false;
        });
    }else{


    // //   console.log(this.isTermSelected + 'payment1 term-->>>');
    // //  if(this.isTermSelected){
    // //     console.log(this.isTermSelected + 'payment term-->>>');
    // //     setTimeout(() => {
    // //      this.completePayment();
         
    // //     }, 6000);

    // //     this.placeOrderCYB();
       
    //  }

    }
  }

  getMonthYearValues() {
    let months = [];
    let years = [];
    let cardTypes = [];
    let currYear = new Date().getFullYear();
    for (let i = 0; i < 20; i++) {
      if (i < 12) {
        if(i<9){
          months.push({ label: String('0'+(i + 1)), value: String('0'+(i + 1))});
        } else{
          months.push({ label: String(i + 1), value: String(i + 1) });
        }
      }
      years.push({ label: String(currYear + i), value: String(currYear + i) });
    }
    this.months = months;
    this.years = years;

    //cardTypes.push({ label: "American Express", value: "American Express" });
    //cardTypes.push({ label: "Discover", value: "Discover" });
    cardTypes.push({ label: "Visa", value: "Visa" });
    cardTypes.push({ label: "Master Card", value: "Master Card" });
    cardTypes.push({ label: "American Express", value: "American Express" });
    cardTypes.push({ label: "Discover", value: "Discover" });

    this.cardTypes = cardTypes;
  }

  handlePONumber(event) {
    this.poNumberCheckout = event.target.value;
    console.log("PO Number " + this.poNumberCheckout);
    this.isPoNull=false;
  }

  handleCardTypeChange(event) {
    this.cardType = event.target.value;
    //this.handleCardRadio(event); remove
  }
  handleMonthChange(event) {
    this.selectedMonth = event.target.value;
    console.log("Month  " + this.selectedMonth);
  }
  handleYearChange(event) {
    this.selectedYear = event.target.value;
  }
  handleCardNickname(event) {
    this.cardNickName = event.target.value;
  }
  handleCardName(event) {
    this.cardName = event.target.value;
  }
  handlePOChange(event) {
    this.poNumber = event.target.value;
  }

  handleSaveCardButton(event){
    this.selectSavecard = event.target.checked;
     console.log('Save card --'+event.target.checked);
     
  }

  useStoreWallet3DSecure()
  {
    if (typeof this.paymentId === "undefined") {
      //alert(B2BStoredPaymentSelection);
      const evt = new ShowToastEvent({
        title: "Error",
        message: "Please select any stored payment",
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(evt);
      //alert('Please select any stored payment');
    } else {
      this.isLoadedMain = true;
    }
  }

@api
async handlePaymentTermClick(){
     console.log('complete payment ---');
     this.completePayment();
    
    setTimeout(() => {
    console.log('cyb ---');
    this.placeOrderCYB(); 
  
   }, 6000);
   

}

@api
handleInvoiceClick(receiptId) {
  this.receiptId = receiptId;
  console.log('::receiptId1', receiptId);
  console.log('::receiptId2', this.receiptId);

  this.handlePayClick(receiptId);
}

// @api
// handlePayClickStoredAlso(event){
//   console.log('::handlePayClickStoredAlso event', event);
// }

  @api
  handlePayClick(receiptId) {
    this.receiptId = receiptId;
    if (this.myWallet == true) {
      if (this.is3DSecure) {
        //3D Secure 

        this.useStoreWallet3DSecure();
      }
      else{
        this.useStoredPayment();
      }
    } else if (this.renderCyberSourceForm == true) {
      
      console.log(this.isTermSelected, 'istermselected----');
      this.isLoadedMain = true;

      var d = new Date();

      if (
        typeof this.cardName === "undefined" ||
        typeof this.cardNickName === "undefined" ||
        typeof this.cardType === "undefined"
      ) {
        this.errorMessage = "Enter valid data"; //this.label.cardGenericError;
        this.isLoadedMain = false;
      } else if (
        (typeof this.selectedYear === "undefined" ||
        typeof this.selectedMonth === "undefined") ||
        (this.selectedYear <= d.getFullYear() &&
        this.selectedMonth <= d.getMonth())
      ) {
        this.errorMessage = this.label.cardInvalidDateError; //"Invalida Date";
        this.isLoadedMain = false;
      } else {
        this.errorMessage = "";

        var options = {
          expirationMonth: this.selectedMonth,
          expirationYear: this.selectedYear
        };

        var self = this;
        this.microform.createToken(options, function (err, token) {
          JSON.stringify(err);
          if (err) {
            self.isLoadedMain = false;
            if(err.details[0].location == 'number'){
              self.errorMessage = "Please enter valid Card Number "; //self.label.cardInvalidError;
            } else if(err.details[0].location == 'securityCode'){
              self.errorMessage = "Please enter valid CVV Number ";
            }
          } else {
            //alert(token);

            self.jwtToken = token;
            var notUsableToken = token;
            self.tokenWithCartId = notUsableToken + "&CartId=" + self.cartId+'&isSaveCard='+self.selectSavecard+'&NickName='+self.cardNickName+'&CardHolderName='+self.cardName;
            if (self.is3DSecure) {
                
            } else {
              console.log('saveFromWallets---->'+self.saveFromWallets);
              if(self.saveFromWallets){
                console.log('::receiptId save', receiptId);
                saveNewCardForInv({
                  token: token,
                  expirationMonth: self.selectedMonth,
                  expirationYear: self.selectedYear,
                  cardholderName: self.cardName,
                  cardholderNickName: self.cardNickName,
                  cardType: self.cardType,
                  isJWT : 'true',
                  receiptId: receiptId
                })
                .then((result) => {
                  self.isLoadedMain = false;
                  console.log("saveNewCardresult__", result);
                  console.log('test -->'+result?.authResponse);
                  if(result?.authResponse){
                    console.log('Done');
                    const evt = new ShowToastEvent({
                      title: "Success",
                      message: "Your request has been initiated. Thank You",
                      variant: "success",
                      mode: "dismissable"
                    });
                    self.dispatchEvent(evt);
                  }else{
                    console.log('Some issue in creating reciepts');
                    const evt = new ShowToastEvent({
                      title: "Success",
                      message: "Some error occured while payment",
                      variant: "warning",
                      mode: "dismissable"
                    });
                    self.dispatchEvent(evt);
                  }
                  setTimeout(()=>{
                    window.location.reload();
                  },3500);
                })
                .catch((error) => {
                  self.isLoadedMain = false;
                  console.log("____Error while calling server_____" +JSON.stringify(error));
                  const evt = new ShowToastEvent({
                    title: "Error",
                    message: "Error while saving this card, please contact your admin",
                    variant: "error",
                    mode: "sticky"
                  });
                  self.dispatchEvent(evt);
                });
              }
              else{
                AuthorizationAPI({
                  orderId : self.cartId,
                  webstoreId : self.webstoreId,
                  cartId: self.cartId,
                  token: token,
                  isSaveCard : self.selectSavecard,
                  expirationMonth: self.selectedMonth,
                  expirationYear: self.selectedYear,
                  cardholderName: self.cardName,
                  cardholderNickName: self.cardNickName,
                  cardType: self.cardType,
                  isJWT : 'true',
                  saveFromWallet : false
                })
                  .then((result) => {
                    console.log("transaction was successful__", result);
                    console.log('test -->'+result?.authResponse);
                            // setTimeout(() => {
                            //   self.placeOrderCYB();
                            // }, 6000);
                  })
                  .catch((error) => {
                    self.isLoadedMain = false;
                    console.log(
                      "____Error while calling server_____" +
                        JSON.stringify(error)
                    );
                  });
                }
            }
            /* */
          }
        });
      }
    } else {
      const evt = new ShowToastEvent({
        title: "Error",
        message: "Please Select One of the Payment Option",
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(evt);
    }
  }

  loadIFram() {
    var stepUpForm = this.template.querySelector('[data-id="#step-up-form"]');
    console.log("stepUpForm --" + stepUpForm);
    setTimeout(function () {
      if (stepUpForm) stepUpForm.submit();

      this.template.querySelector(stepUpForm).target = "step-up-iframe";
    }, 1000);
    // Step-Up form exists
    console.log("Setup request Summited --");
  }

  //For Modal
  // to close modal set isModalOpen tarck value as false
  _closeModal() {
    this.closeModal = false;
  }
  submitDetails() {
    // to close modal set isModalOpen tarck value as false
    //Add your code to call apex method or do some processing
    this.closeModal = false;
    console.log("close modal called");
  }

  //Custom event fired when PaymentByterm selected
  

  handlePaymentTerm(event){

    this.isTermSelected = event.detail.isTermSelected;
    this.poNumberTerm = event.detail.poNumber;

    console.log(this.poNumberTerm, 'PO Term');

    this.poNumberShow = false;
    this.myWallet = false;
    this.hideWallets = true;
    //hide wallet when the term is selected
    const selectedEvent = new CustomEvent("cardradiochanged", {
      detail : {
        hideWallets: this.hideWallets,
        randerForm : false,
        renderPaymentTerm : true,
        termAccount : this.poNumberTerm

      }
    });

    this.dispatchEvent(selectedEvent);

  }

  placeOrderWithPurchaseOrder(){

    const result = checkoutApi.simplePurchaseOrderPayment();
    result.then(response => {

      console.log('response purchase order----->'+ JSON.stringify(response));


    }).catch((error) => {
      console.log('error purchase order----->'+ JSON.stringify(error));

   });
  }

  placeOrderCYB() {
    const result = checkoutApi.placeOrder();
    result.then((response) => {
     // redirect to order confirmation
     console.log('response----->'+response);
     const evt = new ShowToastEvent({
        title: "Success",
        message: "Successfully Ordered",
        variant: "Success",
        mode: "dismissable"
      });
     this.dispatchEvent(evt);
     this.isLoaded = true;
     console.log('Testttt---'+window.location.origin+communityPath + '/order?orderNumber='+response.orderReferenceNumber);
     window.location.href =  window.location.origin + communityPath + '/order?orderNumber='+response.orderReferenceNumber;
     //window.location.reload();
    }).catch((error) => {
       console.log('error----->'+ JSON.stringify(error));

    });
  }

  handlePreviousButton() {
    const navigatePreviousEvent = new FlowNavigationBackEvent();
    this.dispatchEvent(navigatePreviousEvent);
  }
  get canGoPrevious() {
    return (
      this.availableActions &&
      this.availableActions.some((element) => element == "BACK")
    );
  }

  check;
  handleTermChange(event)
  {
        this.check = event.target.checked;
        this.isDefault = this.check;
        this.isPaymentTermSelected = this.check;
  }

  handleStorePaymentSelectionP(event) {
    this.storePaymentId = event.detail;
    if(this.storePaymentId != null && this.storePaymentId != undefined){
      this.myWallet = true;
      this.paymentId = event.detail;
    }else{
      this.myWallet = false;
    }
    this.randerForm = false;
    this.renderCyberSourceForm = false;
}


//----------------Start Here--------------------///

 /**
     * The current checkout mode for this component
     *
     * @type {CheckoutMode}
     */
 @api
 get checkoutMode() {
     return this._checkoutMode;
 }

 
     /**
     * report validity
     *
     * @returns boolean
     */
     @api
     reportValidity() {
      let isValid = true;
        //  console.log('simplePurchaseOrder: in reportValidity');
        //  const purchaseOrderInput = this.getPurchaseOrderInput().value;
        //  let isValid = false;
 
        //  if (purchaseOrderInput) {
        //      console.log('simplePurchaseOrder purchaseOrderInput: '+JSON.stringify(purchaseOrderInput));
        //      isValid = true;
        //      this.showError = false;
        //  } else {
        //      console.log('simplePurchaseOrder purchaseOrderInput not found: '+JSON.stringify(purchaseOrderInput));
        //      this.showError = true;
        //      this.error = "Please enter a purchase order number.";
        //  }
         return isValid;
     }

        /**
    * checkout save
    */
    @api
    async checkoutSave() {
        console.log('simplePurchaseOrder: in checkout save');

        if (!this.reportValidity()) {
            throw new Error('Required data is missing');
        }

        try {
            console.log('simplePurchaseOrder checkoutSave in try', this.isTermSelected);

            if(this.isTermSelected){
             await this.completePayment();
             const result = await placeOrder();
             if (result.orderReferenceNumber) {
              this.navigateToOrder(result.orderReferenceNumber);
              } else {
                  throw new Error("Required orderReferenceNumber is missing");
              }
          
            }else{

              this.handlePayClick();
          
            }

          

            console.log('simplePurchaseOrder checkoutSave result: '+JSON.stringify(result));

            if (result.orderReferenceNumber) {
                this.navigateToOrder(result.orderReferenceNumber);
            } else {
                throw new Error("Required orderReferenceNumber is missing");
            }
        } catch (e) {
            throw e;
        }
    }

  /**
     * place order
     */
  @api
  async placeOrder() {
      return this.checkoutSave();
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

 /**
     * Naviagte to the order confirmation page
     * @param navigationContext lightning naviagtion context
     * @param orderNumber the order number from place order api response
     */
 navigateToOrder(orderNumber) {
  this[NavigationMixin.Navigate]({
  type: "comm__namedPage",
  attributes: {
      name: "Order"
  },
  state: {
      orderNumber: orderNumber
  }
  });
}


//------------end-----------------------------------//

}