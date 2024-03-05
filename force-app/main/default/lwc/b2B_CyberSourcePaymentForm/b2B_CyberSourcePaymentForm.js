import { LightningElement, api, wire, track } from "lwc";
import { CheckoutInformationAdapter, placeOrder, simplePurchaseOrderPayment } from "commerce/checkoutApi";
import {
  FlowAttributeChangeEvent,
  FlowNavigationNextEvent,
  FlowNavigationBackEvent
} from "lightning/flowSupport";
import { NavigationMixin } from 'lightning/navigation';
import { CartSummaryAdapter } from "commerce/cartApi";
import communityPath from '@salesforce/community/basePath';
import checkoutApi from 'commerce/checkoutApi';
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import CyberJSComp from "c/b2b_cyber_js";
import getComponentSetup from "@salesforce/apex/B2B_CYBSPaymentContoller.getComponentSetup";
import getAddress from '@salesforce/apex/B2B_CYBSPaymentContoller.getAddress';
import AuthorizationAPI from "@salesforce/apex/B2B_CYBSPaymentContoller.AuthorizationAPI";
import saveNewCard from "@salesforce/apex/B2B_CYBSPaymentContoller.saveNewCard";
import is3Dsecure from "@salesforce/apex/B2B_CYBSPaymentContoller.is3Dsecure";
import isPoOrCreditCart from "@salesforce/apex/B2B_CYBSPaymentContoller.isPoOrCreditCart";
import checkoutStoredPayment from "@salesforce/apex/B2B_CYBSPaymentContoller.checkoutUsingStoredPayment";
//MY Wallet
import getStoredWallet from "@salesforce/apex/B2B_CYBSPaymentContoller.getStoredWallet";
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
import checkoutAddError from '@salesforce/label/c.B2B_Checkout_Address_Error';
import SelectLabel from '@salesforce/label/c.SelectLabel';
import Address from '@salesforce/label/c.Address';
import Street from '@salesforce/label/c.Street';
import City from '@salesforce/label/c.City';
import State from '@salesforce/label/c.State';
import PostalCode from '@salesforce/label/c.PostalCode';
import Country from '@salesforce/label/c.Country';
import SearchAddress from '@salesforce/label/c.SearchAddress';
import Save_This_Card_For_Future_Purchase from '@salesforce/label/c.Save_This_Card_For_Future_Purchase';
import isShippingAddSelected from "@salesforce/apex/B2B_CYBSPaymentContoller.isShippingAddSelected";
import { registerListener, unregisterAllListeners } from 'c/b2b_pubsub';
import { CurrentPageReference } from 'lightning/navigation'; 
import {fireEvent} from 'c/b2b_pubsub';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import COUNTRY_CODE from '@salesforce/schema/User.CountryCode';
import BILLING_STATE_CODE from '@salesforce/schema/User.StateCode';

const HAS_SHIPPING_AND_TAX = 'hasShippingAndTax';
const DONT_HAVE_SHIPPING_AND_TAX = 'dontHaveShippingAndTax';

export default class B2B_CyberSourcePaymentForm extends NavigationMixin(
  LightningElement
) {
  kId;
  microform;
  months;
  years;
  cardTypes;
  //Payment Option
  poNumberShow = false;
  showSpinner = false;
  messageState = 'Loading';
  @api
  saveFromWallets;
  @api
  renderCyberSourceForm;
  poNumberCheckout;
  isCreditCardShow=true;
  isPOCardShow=false;
  showBillingAddressForm = false;


  // //Store wallet
  // storedWallets;
  @api
  paymentId;

  @api
  isTermSelected;

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
  selectSavecard=false;
  isLoaded = false;
  is3DSecure=false;
  isTermLoader = false;
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
  shippingAddress = null;
  @track showError = false;
  @track error;
  

  label = {
    Address,
    Street,
    City,
    State,
    PostalCode,
    Country,
    SearchAddress,
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
  isShowGenricMsg=false;
  paymentTermLabel;
  isPaymentTermSelected = false;
  isDefault = true;

  eventMessage;
  closeModal = false;
  @api availableActions;
  checkoutId;
  inpVal;

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

    @wire(CurrentPageReference) pageRef; 

   @api
   async completePayment(){
      
      console.log(this.inpVal);
      let purchaseOrderInputValue;
      if(this.inpVal != null){
        purchaseOrderInputValue = this.inpVal;
      }else{
        purchaseOrderInputValue = 'Term 30';
      }
      let po;
      if(!this.shippingAddress){
        await getAddress({cartId : this.cartId}).then(result =>{
       
          if(result){
            console.log('checkout data == ', result);
            let checkoutData = result ? JSON.parse(result) : result;
            this.shippingAddress = checkoutData?.deliveryGroups?.items[0]?.deliveryAddress;
            this.checkoutId = checkoutData?.checkoutId;
          }
  
        }).catch(error =>{
          const evt = new ShowToastEvent({
            title: "Error",
            message: "Please select any stored payment",
            variant: "error",
            mode: "dismissable"
          });
          this.dispatchEvent(evt);
        })
      }
      
      else{
        console.log(JSON.stringify(this.shippingAddress) + ' -- Shipping Address');
        po = simplePurchaseOrderPayment(this.checkoutId, purchaseOrderInputValue, this.shippingAddress);
        console.log('po=');
        console.log(po);
      }
      
      return po;
   }

   
  async disconnectedCallback() {
    try {
      unregisterAllListeners(this);
     
    } catch (mess) {
      let m = mess.message || mess.body.message || (mess.body.pageErrors?.length > 0 && mess.body.pageErrors[0].message);
      alert(m);
    }
  }

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


  handleCardRadio(event) {
    
    // this.poNumberShow = false;
    this.myWallet = false;
    this.showBillingAddressForm = false;
    this.hideWallets = true;
    this.isTermSelected = false;
    this.paymentId = '';
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
                placeholder: "CVV"
              });
            } else{
              var  securityCode = this.microform.createField("securityCode", {
                placeholder: "CVV"
              });
            }
            number.load(".cardNumberContainer");
            securityCode.load(".cvvContainer");
            this.isLoaded = true;
          }
          else{
            this.isShowGenricMsg=true;
            const evt = new ShowToastEvent({
        title: "Error",
        message: "Something went wrong. Unable to load the form. Please try again.",
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(evt);
            this.isLoaded = true;
          }
        }
        
        
      })
      .catch((error) => {
        const evt = new ShowToastEvent({
        title: "Error",
        message: error,
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(evt);
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

  handlePoNum(inpVal){
    console.log(inpVal);
    this.inpVal=inpVal;

  }

  isShippingAndTaxCalculted = false;

  hasShippingAndTaxFunc(event){
    this.isShippingAndTaxCalculted = true;
  }

  dontHaveShippingAndTaxFunc(event){
    this.isShippingAndTaxCalculted = false;
  }

  connectedCallback() {

    registerListener("poChangeEvent", this.handlePoNum, this); 
    registerListener("placeOrderEvent", this.handlePlaceOrderBtn, this);
    registerListener(HAS_SHIPPING_AND_TAX, this.hasShippingAndTax, this);
    registerListener(DONT_HAVE_SHIPPING_AND_TAX, this.dontHaveShippingAndTax, this);
   

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
     
    });
   
    console.log("Order Id-----xxx-->" + this.orderId);
    
     //check is account is 3D secure enable or not 
      is3Dsecure()
        .then(result => {
          console.log('Is 3D secure -->', result);
          this.is3DSecure=result;
        })
        .catch(error => {
          const evt = new ShowToastEvent({
            title: "Error",
            message: error,
            variant: "error",
            mode: "dismissable"
          });
          this.dispatchEvent(evt);
          console.error('Error in checking for 3D secure :', error);
      });
  }

  @api
   useStoredPayment() {
    console.log('paymentId---->'+this.paymentId);

   
    if (typeof this.paymentId === "undefined") {
     
      const evt = new ShowToastEvent({
        title: "Error",
        message: "Please select any stored payment",
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(evt);
      
    } else if(this.isTermSelected == false){
      checkoutStoredPayment({
        orderId: this.cartId,
        webstoreId : this.webstoreId,
        cartId: this.cartId,
        storedPaymentId: this.paymentId,
        userCurrencyCode: this.userCurrencyCode
      })
        .then((result) => {
          console.log("toast is running"+result);
          this.showSpinner = false;

          setTimeout(() => {
            this.placeOrderCYB();
          }, 6000);
        })
        .catch((error) => {
         const evt = new ShowToastEvent({
        title: "Error",
        message: error,
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(evt);
          this.error = error;
          this.stopLoading = true;
          this.showSpinner = false;
        });
    }else{

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

  handlePlaceOrderBtn(event) {
    // this.poNumberCheckout = event.target.value;
    // console.log("PO Number " + this.poNumberCheckout);
    // this.isPoNull=false;
    this.handlePlaceOrderCustom();
    // if(this.isShippingAndTaxCalculted){
    //   this.handlePlaceOrderCustom();
    // }else{
    //   const evt = new ShowToastEvent({
    //     title: "Error",
    //     message: "Discount and Tax is not calculated",
    //     variant: "error",
    //     mode: "sticky"
    //   });
    //   this.dispatchEvent(evt);
    // }
  }

  handleCardTypeChange(event) {
    this.cardType = event.target.value;
    this.handleCardRadio(event);
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
     
      const evt = new ShowToastEvent({
        title: "Error",
        message: "Please select any stored payment",
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(evt);
     
    } else {
      this.showSpinner = true;
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
  handlePayClick() {

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
      //this.showSpinner = true;

      var d = new Date();

      if (
        typeof this.cardName === "undefined" ||
        typeof this.cardNickName === "undefined" ||
        typeof this.cardType === "undefined"
      ) {
        const evt = new ShowToastEvent({
          title: "Error",
          message: "Enter valid data",
          variant: "error",
          mode: "dismissable"
        });
        this.dispatchEvent(evt);
        this.showSpinner = false;
        this.stopLoading = true;
      } else if (
        (typeof this.selectedYear === "undefined" ||
        typeof this.selectedMonth === "undefined") ||
        (this.selectedYear <= d.getFullYear() &&
        this.selectedMonth <= d.getMonth())
      ) {
        const evt = new ShowToastEvent({
          title: "Error",
          message: this.label.cardInvalidDateError,
          variant: "error",
          mode: "dismissable"
        });
        this.dispatchEvent(evt);
        this.showSpinner = false;
        this.stopLoading = true;
      } else {
        var options = {
          expirationMonth: this.selectedMonth,
          expirationYear: this.selectedYear
        };

        var self = this;
        this.microform.createToken(options, function (err, token) {
          JSON.stringify(err);
          if (err) {
            self.showSpinner = false;
            if(err.details[0].location == 'number'){
              const evt = new ShowToastEvent({
                title: "Error",
                message: "Please enter valid Card Number ",
                variant: "error",
                mode: "dismissable"
              });
              self.dispatchEvent(evt);
              self.stopLoading = true;
            } else if(err.details[0].location == 'securityCode'){
              const evt = new ShowToastEvent({
                title: "Error",
                message: "Please enter valid CVV Number",
                variant: "error",
                mode: "dismissable"
              });
              self.dispatchEvent(evt);
              self.stopLoading = true;
            }
          } else {
            
            self.jwtToken = token;
            var notUsableToken = token;
            self.tokenWithCartId = notUsableToken + "&CartId=" + self.cartId+'&isSaveCard='+self.selectSavecard+'&NickName='+self.cardNickName+'&CardHolderName='+self.cardName;
            if (self.is3DSecure) {
                
            } else {
              console.log('saveFromWallets---->'+self.saveFromWallets);
              if(self.saveFromWallets){
                saveNewCard({
                  token: token,
                  expirationMonth: self.selectedMonth,
                  expirationYear: self.selectedYear,
                  cardholderName: self.cardName,
                  cardholderNickName: self.cardNickName,
                  cardType: self.cardType,
                  isJWT : 'true'
                })
                .then((result) => {
                  console.log("saveNewCardresult__", result);
                  console.log('test -->'+result?.authResponse);
                  console.log('Done');
                  setTimeout(() => {
                    window.location.reload();
                  }, 6000);
                 
                })
                .catch((error) => {
                  self.showSpinner = false;
                  const evt = new ShowToastEvent({
                    title: "Error",
                    message: error,
                    variant: "error",
                    mode: "dismissable"
                  });
                  self.dispatchEvent(evt);
                  self.stopLoading = true;
                  console.log(
                    "____Error while calling server_____" +
                      JSON.stringify(error)
                  );
                });
              }else{
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
                  saveFromWallet : false,
                  hasBillingAddress : self.showBillingAddressForm,
                  billingAddress : JSON.stringify(self.address),
                  isStoredPayment : false,
                  storedCardNumber : null
                })
                  .then((result) => {
                    console.log("transaction was successful__", result);
                    console.log('test -->'+result?.authResponse);
                            setTimeout(() => {
                              self.placeOrderCYB();
                            }, 6000);
                  })
                  .catch((error) => {
                    self.showSpinner = false;
                    const evt = new ShowToastEvent({
                      title: "Error",
                      message: error,
                      variant: "error",
                      mode: "dismissable"
                    });
                    self.dispatchEvent(evt);
                    self.stopLoading = true;
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
    }else{
      const evt = new ShowToastEvent({
        title: "Error",
        message: "Please Select One of the Payment Option",
        variant: "error",
        mode: "dismissable"
      });
      this.dispatchEvent(evt);
      this.stopLoading = true;

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


  placeOrderWithPurchaseOrder(){

    const result = checkoutApi.simplePurchaseOrderPayment();
    result.then(response => {

      console.log('response purchase order----->'+ JSON.stringify(response));


    }).catch((error) => {
      const evt = new ShowToastEvent({
        title: "Error",
        message: error,
        variant: "error",
        mode: "dismissable"
      });
     this.dispatchEvent(evt);

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
      const evt = new ShowToastEvent({
        title: "Error",
        message: error,
        variant: "error",
        mode: "dismissable"
      });
     this.dispatchEvent(evt);

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
     isValid = false;
  
     handlePlaceOrderCustom() {
      
      isShippingAddSelected({cartId : this.cartId}).then(result =>{
       
        if(result){
          console.log('shipping', result);

          if(this.paymentId === null && this.renderCyberSourceForm == false && this.isTermSelected == false){

            console.log('No payment method selected');
            fireEvent(this.pageRef, "shoLoader", false); 
            const evt = new ShowToastEvent({
              title: "Error",
              message: "Please select a payment method.",
              variant: "error",
              mode: "dismissable"
            });
            this.dispatchEvent(evt);
            
          }else{

           this.isValid = true;
           this.placeOrderCustom();

          }
        }else{
          const evt = new ShowToastEvent({
            title: "Error",
            message: "Please select a Shipping Address.",
            variant: "error",
            mode: "dismissable"
          });
          this.dispatchEvent(evt);
          //  this.isValid = result;
          
        }

      }).catch(error =>{
        console.log(error, 'isShippingAddress error');
        // this.isTermLoader = false;
       
      })
      
       return this.isValid;
     }

        /**
    * checkout save
    */
    async placeOrderCustom() {

        if(this.stopLoading) {
          fireEvent(this.pageRef, "shoLoader", false); 
          this.stopLoading = false;
          throw new Error('Error');
        }

     
        console.log('simplePurchaseOrder: in checkout save');
        fireEvent(this.pageRef, "shoLoader", true); 

        if (!this.handlePlaceOrderCustom()) {
          fireEvent(this.pageRef, "shoLoader", false); 
          throw new Error('Required data is missing');
          
      
        }

        try {
            console.log('simplePurchaseOrder checkoutSave in try', this.isTermSelected);

            if(this.isTermSelected){
              this.showSpinner = true;
             await this.completePayment();
             const result = await placeOrder();
              if (result.orderReferenceNumber) {
                this.showSpinner = false;
                this.navigateToOrder(result.orderReferenceNumber);
              } else {
                  this.showSpinner = false;
                  throw new Error("Required orderReferenceNumber is missing");
              }
          
            }else{

              if(this.paymentId !== null && this.paymentId !== ''){

                if (this.isExecuting) {
                  return;
                }

                this.useStoredPayment();
                this.isExecuting = true;

              }else if(this.renderCyberSourceForm == true && this.paymentId === ''){
                
                if (this.isExecuting) {
                  return;
                }
                this.handlePayClick();
                this.isExecuting = true;
              
              }else{

                console.log('No payment method selected');
              }
             
          
            }
            
            if (result.orderReferenceNumber) {
                this.navigateToOrder(result.orderReferenceNumber);
            } else {
            
                throw new Error("Required orderReferenceNumber is missing");
            }
          
        } catch (e) {
            //this.stopLoading = true;
            throw e;
        }

        //fireEvent(this.pageRef, "shoLoader", false); 

       
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

address = {
  street: '',
  city: '',
  country: '',
  province: '',
  postalcode: '',
  addType: 'Billing',
  isdefault: false
  
};

handleBillingAddress() {
      this.template.querySelector(".billing-address").checked = this.showBillingAddressForm;
      this.showBillingAddressForm = !this.showBillingAddressForm;
      
}

handleAddressChange(event) {
  this.address.street = event.detail.street;
  this.address.city = event.detail.city;
  this.address.province = event.detail.province;
  this.address.postalcode = event.detail.postalCode;
  this.address.country = event.detail.country;
  console.log('address = ' + JSON.stringify(this.address));
  this.selectedCountry = event.detail.country;
  this.selectedState = event.detail.province;
}

@wire(getPicklistValues, {
  recordTypeId: '012000000000000AAA',
  fieldApiName: COUNTRY_CODE
})
wiredCountires({ data }) {
  this._countries = data?.values;
}

@wire(getPicklistValues, { recordTypeId: '012000000000000AAA', fieldApiName: BILLING_STATE_CODE })
wiredStates({ data }) {
  //console.log('state data ='+data);
  if (!data) {
      return;
  }

  const validForNumberToCountry = Object.fromEntries(Object.entries(data.controllerValues).map(([key, value]) => [value, key]));

  this._countryToStates = data.values.reduce((accumulatedStates, state) => {
      const countryIsoCode = validForNumberToCountry[state.validFor[0]];

      return { ...accumulatedStates, [countryIsoCode]: [...(accumulatedStates?.[countryIsoCode] || []), state] };
  }, {});
}

get countries() {
  return this._countries;
}

get states() {
  //console.log(this._countryToStates);
  return this._countryToStates[this.selectedCountry] || [];
}

_countries = [];
_countryToStates = {};

selectedCountry;
selectedState;

stopLoading = false;
isExecuting = false;



//------------end-----------------------------------//

}