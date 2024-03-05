import { LightningElement,api,wire } from 'lwc';
import contextApi from 'commerce/contextApi';
import PointsBalance from '@salesforce/label/c.PointsBalance';
import EnrollmentStatus from '@salesforce/label/c.EnrollmentStatus';
import StatusTier from '@salesforce/label/c.StatusTier';
import StartDate from '@salesforce/label/c.StartDate';
import EndDate from '@salesforce/label/c.EndDate';
import RenewSku from '@salesforce/label/c.RenewSKU';
import EnrollSku from '@salesforce/label/c.EnrollSKU';
import ResetPassword from '@salesforce/label/c.B2B_Reset_Password_Link';
import My_profile_and_password from '@salesforce/label/c.My_profile_and_password';
import Account_Profile from '@salesforce/label/c.Account_Profile';
import First_Name from '@salesforce/label/c.First_Name';
import Last_Name from '@salesforce/label/c.Last_Name';
import Company_Name from '@salesforce/label/c.Company_Name';
import Customer_Number from '@salesforce/label/c.Customer_Number';
import Reset_Password from '@salesforce/label/c.Reset_Password';
import Password from '@salesforce/label/c.Password';
import Excel_Loyalty_Program from '@salesforce/label/c.Excel_Loyalty_Program';
import Coordinator_Name from '@salesforce/label/c.Coordinator_Name';
import Coordinator_Email from '@salesforce/label/c.Coordinator_Email';
import Enrollment from '@salesforce/label/c.Enrollment';
import Status from '@salesforce/label/c.Status';
import Renew from '@salesforce/label/c.Renew';
import Status_Tier from '@salesforce/label/c.Status_Tier';
import Points from '@salesforce/label/c.Points';
import This_account_is_not_enrolled_in_Loyalty_program from '@salesforce/label/c.This_account_is_not_enrolled_in_Loyalty_program';
import Enroll_in_Loyalty_Program from '@salesforce/label/c.Enroll_in_Loyalty_Program';
import Your_Loyalty_Points from '@salesforce/label/c.Your_Loyalty_Points';
import SILVER from '@salesforce/label/c.SILVER';
import X1_199_999_pts from '@salesforce/label/c.X1_199_999_pts';
import Gold from '@salesforce/label/c.Gold';
import X200_000_499_999_pts from '@salesforce/label/c.X200_000_499_999_pts';
import Titanium from '@salesforce/label/c.Titanium';
import X500_000_999_999_pts from '@salesforce/label/c.X500_000_999_999_pts';
import Tantalum from '@salesforce/label/c.Tantalum';
import X1_000_000_pts from '@salesforce/label/c.X1_000_000_pts';
import Questions_on_your_account_information from '@salesforce/label/c.Questions_on_your_account_information';
import Call_800_345_6789 from '@salesforce/label/c.Call_800_345_6789';


import retrieveLoyalty from '@salesforce/apex/B2BAccountManagementController.retrieveLoyalty';
import getLoyaltyProduct from '@salesforce/apex/B2BAccountManagementController.getLoyaltyProduct';
import {addItemToCart} from 'commerce/cartApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import communityId from '@salesforce/community/Id';
import ToastContainer from 'lightning/toastContainer';
import FORM_FACTOR from '@salesforce/client/formFactor';
import B2B_Add_To_Cart_Success_Msg from '@salesforce/label/c.B2B_Add_To_Cart_Success_Msg';
import B2B_Success_Label from '@salesforce/label/c.B2B_Success_Label';
import B2B_Error_Msg_Label from '@salesforce/label/c.B2B_Error_Msg_Label';
import B2B_Add_To_Cart_Error_Msg from '@salesforce/label/c.B2B_Add_To_Cart_Error_Msg';
import calculateDiscountOnItem from '@salesforce/apex/B2BCartController.calculateDiscountOnItem';
export default class B2BLoyalty extends  NavigationMixin (LightningElement){
    // _accid;
    // @api 
    // set accId(val){
    //     console.log('accid value for loyalty is '+val);
    //     this._accid = val;
    // }
    // get accId(){
    //     return this._accid;
    // }

    labels={
        PointsBalance,
        EnrollmentStatus,
        StatusTier,
        StartDate,
        EndDate,
        RenewSku,
        EnrollSku,
        ResetPassword,
        My_profile_and_password,
        Account_Profile,
        First_Name,
        Last_Name,
        Company_Name,
        Customer_Number,
        Reset_Password,
        Password,
        Excel_Loyalty_Program,
        Coordinator_Name,
        Coordinator_Email,
        Enrollment,
        Status,
        Renew,
        Status_Tier,
        Points,
        This_account_is_not_enrolled_in_Loyalty_program,
        Enroll_in_Loyalty_Program,
        Your_Loyalty_Points,
        SILVER,
        X1_199_999_pts,
        Gold,
        X200_000_499_999_pts,
        Titanium,
        X500_000_999_999_pts,
        Tantalum,
        X1_000_000_pts,
        Questions_on_your_account_information,
        Call_800_345_6789,
        B2B_Add_To_Cart_Success_Msg,
        B2B_Success_Label,
        B2B_Error_Msg_Label,
        B2B_Add_To_Cart_Error_Msg


    }
    _isGuest;
    @api 
    set isGuest(val){
        console.log('guest value for loyalty is '+val);
        this._isGuest = val;
    }
    get isGuest(){
        return this._isGuest;
    }
    accId;
    error;
    otherParam = '';
    loyaltyData;
    showModal=false;
    showRenewal=false;
    showEnroll=false;
    showActiveLoyalty=false;
    showPurchase = false;
    loyaltyProd;
    showLoader=false;
    url = window.location.href;
    showLoyaltyData=false;
    productImage;
    mobileDevice = false;
    connectedCallback() {

        if(FORM_FACTOR=='Small'){
            this.mobileDevice = true;
        }
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';

        const result = contextApi.getSessionContext();
        
         result.then((response) => {
            console.log('here session context>>'+JSON.stringify(response));
         this.accId = response.effectiveAccountId;
         console.log('AccountId',this.accId)
         this.getretrieveLoyalty();
         

   }).catch((error) => {
    console.log("getSessionContext result");
    console.log(error);
 });
    }
    getretrieveLoyalty(){
        retrieveLoyalty({
            accId: this.accId
        }).then((results) => {
            this.showEnroll = false;
            this.showRenewal = true;
            console.log('retrieveLoyalty',JSON.stringify(results));
            this.loyaltyData = JSON.parse(results);
            if(this.loyaltyData.userCountry == 'United States' || this.loyaltyData.userCountry == 'Canada'){
                this.showLoyaltyData = true;
            }
            
            if(this.loyaltyData.loyaltyStatus == 'Renew'){
                this.showEnroll = false;
                this.showRenewal = true;
                this.showActiveLoyalty = false;
                this.getLoyaltyprod(this.loyaltyData.loyaltyStatus);
             }
             if(this.loyaltyData.loyaltyStatus == 'Enroll'){
                this.showRenewal = false;
                this.showEnroll = true;
                this.showActiveLoyalty = false;
                this.getLoyaltyprod(this.loyaltyData.loyaltyStatus);
             }
             if(this.loyaltyData.loyaltyStatus == 'None'){
                this.showRenewal = false;
                this.showEnroll = false;
                this.showActiveLoyalty = true;
             }
        
        }).catch((error) => {
            console.log('retrieveLoyalty error');
            console.log(error);
        });

    }

    // @wire(retrieveLoyalty, { accId: this.accId})//, { accId: '$accId', isGuest:'$isGuest', otherParam: this.otherParam}
    // objLoyalty ({ error, data }) 
    // {
    //      console.log('AccountId',this.accId)
    //     if (data) {
    //        console.log('loyaltyData=='+data);
    //        this.loyaltyData = JSON.parse(data);
    //     } 
    //     else if (error) { 
    //         this.error = error;  
    //         console.log('Error Message'+error);
    //     }   
    // }

    handleRenewLoyalty(){
        console.log('inside handleRenewLoyalty');
        this.showModal = true;
    }

    handleEnrollLoyalty(){
        console.log('inside handleEnrollLoyalty');
        this.showModal = true;
    }

    addToCart(){
        console.log('inside handlePurchaseLoyaltyRenewal'+this.loyaltyProd.Id);
        this.showLoader=true;
        addItemToCart(this.loyaltyProd.id,1).then((fulfilled) => {
            console.log("added product to cart" ,fulfilled);
            this.showLoader = false;
            this.calculateDiscount(fulfilled);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.labels.B2B_Success_Label,
                        message: this.labels.B2B_Add_To_Cart_Success_Msg,
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
            this.showModal = false;

            
        }).catch(error => {
            console.log('error' ,error);
            this.showLoader = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.B2B_Error_Msg_Label,
                    message:this.labels.B2B_Add_To_Cart_Error_Msg,
                    messageData: [this.loyaltyProd.name],
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
        });
    }

    calculateDiscount(input){
        console.log('calculateDiscount(fulfilled)--- ', input);
        let mapParams = {
            cartItemId : input.cartItemId
        }
        calculateDiscountOnItem({
            mapParams: mapParams
        }).then((results) => {
            console.log('calculateDiscount results- ',results);
        }).catch((error) => {
            console.log('calculateDiscount error');
            console.log(error);
        });
    }

    handleCancel(){
        this.showModal=false;
    }

    getLoyaltyprod(status){
        let prodsku;
        if(status == 'Renew'){
            prodsku=this.labels.RenewSku;
        }else if(status == 'Enroll'){
            prodsku=this.labels.EnrollSku;
        }
        console.log('prodsku>>>'+prodsku);
        getLoyaltyProduct({
            sku : prodsku,
            communityId : communityId,
            effectiveAccountId : this.accId
        }).then(result =>{
            console.log('result>>'+JSON.stringify(result));
            this.loyaltyProd = result;
            if(!!this.loyaltyProd.mediaGroups && this.loyaltyProd.mediaGroups != null){
                let media = this.loyaltyProd.mediaGroups.filter(media=> media.developerName == 'productDetailImage');
                if(!!media && media.length != 0){
                    this.productImage = media[0].mediaItems[0].url;
                }
            }else{
                this.productImage = this.loyaltyProd.defaultImage.url;
            }
        }).catch((error) => {
            console.log('getLoyaltyprod error');
            console.log(error);
        });
    }

    handleResetPassword(){
        let url = this.labels.ResetPassword;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: url
            }
          });
    }
    
}