import B2B_CardHolder_Name_Label from '@salesforce/label/c.B2B_CardHolder_Name_Label';
import B2B_Card_CVV_Label from '@salesforce/label/c.B2B_Card_CVV_Label';
import B2B_Card_Exp_Month_Label from '@salesforce/label/c.B2B_Card_Exp_Month_Label';
import B2B_Card_Exp_Year_Label from '@salesforce/label/c.B2B_Card_Exp_Year_Label';
import B2B_card_Number_Label from '@salesforce/label/c.B2B_card_Number_Label';
import B2B_card_Type_Label from '@salesforce/label/c.B2B_card_Type_Label';
// import B2B_CardHolder_Name_PlaceHolder from '@salesforce/label/c.B2B_CardHolder_Name_PlaceHolder';
// import B2B_Card_CVV_Placeholder from '@salesforce/label/c.B2B_Card_CVV_Placeholder';
// import B2B_Card_Number_Placeholder from '@salesforce/label/c.B2B_Card_Number_Placeholder';
// import B2B_Card_Type_Placeholder from '@salesforce/label/c.B2B_Card_Type_Placeholder';
import addrCounty from '@salesforce/label/c.B2B_Country';
import addrState from '@salesforce/label/c.B2B_State';
import addrCity from '@salesforce/label/c.B2B_City';
import addrPostalCode from '@salesforce/label/c.B2B_PostalCode';
import addrLine1 from '@salesforce/label/c.B2B_Address_Line_1';
import addrLine2 from '@salesforce/label/c.B2B_Address_Line_2';
import B2B_CVV_Info from '@salesforce/label/c.B2B_CVV_Info';
import B2B_Invalid_Card_Number from '@salesforce/label/c.B2B_Invalid_Card_Number';
import B2B_Invalid_CVV from '@salesforce/label/c.B2B_Invalid_CVV';

export const labels = {
    InvalidName: 'Enter a valid name.',
    InvalidCreditCardNumber: B2B_Invalid_Card_Number,
    InvalidCvv: B2B_Invalid_CVV,
    InvalidCardType: 'Select a card type.',
    InvalidExpiryMonth: 'Select an expiration month.',
    InvalidExpiryYear: 'Select an expiration year.',
    CardHolderNameLabel: B2B_CardHolder_Name_Label,
    CardTypeLabel: B2B_card_Type_Label,
    CardNumberLabel: B2B_card_Number_Label,
    CvvLabel: B2B_Card_CVV_Label,
    ExpiryMonthLabel: B2B_Card_Exp_Month_Label,
    ExpiryYearLabel: B2B_Card_Exp_Year_Label,
    //CardHolderNamePlaceholder: B2B_CardHolder_Name_PlaceHolder,
   // CardTypePlaceholder: B2B_Card_Type_Placeholder,
   // CardNumberPlaceholder: B2B_Card_Number_Placeholder,
   // CvvPlaceholder: B2B_Card_CVV_Placeholder,
    ExpiryMonthPlaceholder: 'MM',
    ExpiryYearPlaceholder: 'YYYY',
    CvvInfo: B2B_CVV_Info,
    addrCounty:addrCounty,
    addrState:addrState,
    addrLine1,
    addrLine2,
    addrCity,
    addrPostalCode
};

export const cardLabels = {
    Visa: 'Visa',
    MasterCard: 'Master Card',
    AmericanExpress: 'American Express',
    DinersClub: 'Diners Club',
    JCB: 'JCB'
};