import { api,wire } from "lwc";
import LightningModal from "lightning/modal";
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import COUNTRY_CODE from '@salesforce/schema/User.CountryCode';
import BILLING_STATE_CODE from '@salesforce/schema/User.StateCode';
import progress from '@salesforce/label/c.progress';
import NewAddress from '@salesforce/label/c.NewAddress';
import EditAddress from '@salesforce/label/c.EditAddress';
import Makethismydefaultaddress from '@salesforce/label/c.Makethismydefaultaddress';
import Address from '@salesforce/label/c.Address';
import Street from '@salesforce/label/c.Street';
import City from '@salesforce/label/c.City';
import State from '@salesforce/label/c.State';
import PostalCode from '@salesforce/label/c.PostalCode';
import Country from '@salesforce/label/c.Country';
import SearchAddress from '@salesforce/label/c.SearchAddress';
import Name from '@salesforce/label/c.Name';
import Save from '@salesforce/label/c.Save';
import validateAddress from '@salesforce/apex/B2B_AddressValidationController.validateAddress';
import getOracleIdAndStore from '@salesforce/apex/B2B_AddressValidationController.getOracleIdAndStore';
import updateContactAddress from '@salesforce/apex/B2B_AddressValidationController.updateContactAddress';
import deleteContactPointAddress from '@salesforce/apex/B2B_AddressValidationController.deleteContactPointAddress';
import validateNickName from '@salesforce/apex/B2B_AddressValidationController.validateNickName';
import contextApi from 'commerce/contextApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import communityId from '@salesforce/community/Id';
import addFav from '@salesforce/apex/b2B_CustomAddressComponentController.addFav';
import addDefault from '@salesforce/apex/b2B_CustomAddressComponentController.addDefault';
import B2B_AddToCart_SpinnerMessage from '@salesforce/label/c.B2B_AddToCart_SpinnerMessage';
import B2B_CalculateDiscount_SpinnerMessage from '@salesforce/label/c.B2B_CalculateDiscount_SpinnerMessage';
import B2B_Loading_Message from '@salesforce/label/c.B2B_Loading_Message';

export default class B2b_shippingaddmodal extends LightningModal {
    @api recordId;
    @api effectiveAccountId;
    isValidAddress = false;
    showLoader = false;
    accId;
    oracleAddressId;
    inpNickName;
    
    _countries = [];
    _countryToStates = {};

    selectedCountry;
    selectedState;

    fieldMap = {};

    connectedCallback(){
        const result = contextApi.getSessionContext();
        result.then((response) => {
           console.log('here session context>>'+JSON.stringify(response));
           this.accId = response.effectiveAccountId;
        }).catch((error) => {
            console.log("getSessionContext result");
            console.log(error);
        });
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
    modalHeaderText = '';
    //loadAddress = false;
    handleonloadrecord(event){
        //console.log('handleonloadrecord called');
        //console.log(event);
        console.log('record id is: '+this.recordId);
        if(this.recordId){
            //console.log('handleonloadrecord called');
            //console.log(JSON.stringify(event.detail.records));
            let fieldData = event.detail.records[this.recordId].fields;

            this.address.street = fieldData.Street.value;
            this.address.city = fieldData.City.value;
            
            this.address.postalcode = fieldData.PostalCode.value;
            this.address.country = fieldData.CountryCode.value;
            this.selectedCountry = fieldData.CountryCode.value;
            this.address.province = fieldData.StateCode.value;

            this.inpNickName = fieldData.Name.value;
            
            this.modalHeaderText = this.labels.EditAddress;
            console.log('this.address==');
            console.log(this.address);
            //this.loadAddress = true;
        } else {
            this.modalHeaderText = this.labels.NewAddress;
            //this.loadAddress = true;
        }
    }

    get countries() {
        return this._countries;
    }

    get states() {
        //console.log(this._countryToStates);
        return this._countryToStates[this.selectedCountry] || [];
    }

    labels={
        progress,
        NewAddress,
        EditAddress,
        Makethismydefaultaddress,
        Address,
        SearchAddress,
        Name,
        Street,
        City,
        State,
        PostalCode,
        Country,
        Save,
        B2B_CalculateDiscount_SpinnerMessage,
        B2B_AddToCart_SpinnerMessage,
        B2B_Loading_Message
    };
    errors;
    messageState = B2B_Loading_Message;
    

    address = {
        street: '',
        city: '',
        country: '',
        province: '',
        postalcode: '',
        addType: 'Shipping',
        isdefault: false,
        name:'',
        isfavorite:false
    };

    handleAddressChange(event){
        
        console.log(event.detail+'>>>'+JSON.stringify(this.recordId));
        this.address.street = event.detail.street;
        this.address.city = event.detail.city;
        this.address.province = event.detail.province;
        this.address.postalcode = event.detail.postalCode;
        this.address.country = event.detail.country;
        this.selectedCountry = event.detail.country;
        this.selectedState = event.detail.province;
    }

    handleNickNameChange(event){
        console.log('>>>'+event);
        this.inpNickName = event.detail.value;
    }

    async submitForm(event){
        console.log('I am called');
        //event.preventDefault();     
        this.showLoader = true;

        let inputField = this.template.querySelector( '[ data-id="name" ]' );
        let phonefield = this.template.querySelector( '[ data-id="phone" ]' );
        let firstnamefield = this.template.querySelector( '[ data-id="fname" ]' );
        let lastnamefield = this.template.querySelector( '[ data-id="lname" ]' );
        
        console.log( 
            'Value is',
            inputField.value            
        );
        let billingCountryAddValidation = false;

        const fields = {};
        fields.Name = inputField.value;
        fields.First_Name__c = firstnamefield.value;
        fields.Last_Name__c = lastnamefield.value;
        fields.PhoneNumber=phonefield.value;
        console.log('this.address>>'+JSON.stringify(this.address));
        fields.Street = this.address.street;
        fields.City = this.address.city;
        fields.StateCode = this.address.province;
        fields.PostalCode = this.address.postalcode;
        fields.CountryCode = this.address.country;
        fields.AddressType = this.address.addType;
        fields.ParentId = this.effectiveAccountId;
        console.log('here for test>>'+this.address.country);
        if(fields.CountryCode == 'US' || fields.CountryCode == 'CA'){
            if(fields.Street != '' &&  fields.City != '' && fields.StateCode != '' && fields.CountryCode != '' && fields.PostalCode != ''){
                await validateAddress({
                    city:fields.City,
                    countryCode:fields.CountryCode,
                    stateCode:fields.StateCode,
                    postalCode:fields.PostalCode,
                    street:fields.Street,
                    accountId:this.accId
                }).then(result =>{
                    
                    console.log('validate address result>>'+JSON.stringify(result));
                    if(result.statusCode == '200' && !!result.validationResponse.result && !!result.validationResponse.result.address && !!result.validationResponse.result.address.addressComponents && result.validationResponse.result.address.addressComponents.length != 0){
                        //let address = result.validationResponse.result.address.addressComponents.find(add=> (add.confirmationLevel == 'UNCONFIRMED_AND_SUSPICIOUS' || add.confirmationLevel == 'UNCONFIRMED_BUT_PLAUSIBLE'));
                        let isaddress = true;
                        for(let i=0;i<result.validationResponse.result.address.addressComponents.length;i++){
                            if(result.validationResponse.result.address.addressComponents[i].confirmationLevel == 'UNCONFIRMED_AND_SUSPICIOUS' || 
                            result.validationResponse.result.address.addressComponents[i].confirmationLevel == 'UNCONFIRMED_BUT_PLAUSIBLE'){
                                isaddress = false;
                                break;
                            }
                            if(!!result.validationResponse.result.address.addressComponents[i].spellCorrected && result.validationResponse.result.address.addressComponents[i].spellCorrected){
                                isaddress = false;
                                break;
                            }
                            if(!!result.validationResponse.result.address.addressComponents[i].replaced && result.validationResponse.result.address.addressComponents[i].replaced){
                                isaddress = false;
                                break;
                            }
                            /*if(!!result.validationResponse.result.address.addressComponents[i].inferred && result.validationResponse.result.address.addressComponents[i].inferred){
                                isaddress = false;
                                break;
                            }*/
                        }
                        console.log('isAddressCorrect>>>'+isaddress);
                        if(!isaddress){
                            this.isValidAddress = false;
                        }
                        else{
                            if(!!result.billingCountryCode && result.billingCountryCode == this.address.country){
                                this.isValidAddress = true;
                            }else{
                                this.isValidAddress = false;
                                billingCountryAddValidation = true;
                            }
                        }
                    }
                }).catch(error=>{
                    console.log('error in valiadte address>>');
                    console.log(error);
                    this.showLoader = false;
                })
        
                if(!this.isValidAddress){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: billingCountryAddValidation ? 'Shipping country does not match with the Billing country on this account.' : 'Please Enter a Valid Address.',
                            variant: 'Error',
                            mode: 'dismissable'
                        })
                    );
                    this.showLoader = false;
                }
                if(this.isValidAddress){
                    this.fieldMap.City = fields.City;
                    this.fieldMap.CountryCode = fields.CountryCode;
                    this.fieldMap.StateCode = fields.StateCode;
                    this.fieldMap.PostalCode = fields.PostalCode;
                    this.fieldMap.Street = fields.Street;
                    this.fieldMap.accId = this.accId;
                    this.fieldMap.Name = fields.Name;
                    console.log('fieldMap is set---- ',this.fieldMap);
                    //this.callGetOracleIdAndStore(fields.City, fields.CountryCode, fields.StateCode, fields.PostalCode, fields.Street, this.accId, fields.Name);
                    console.log('here inside submit condition');
                    //this.template.querySelector('lightning-record-edit-form').submit(fields);
                    this.callvalidateAddress(fields);
                    //this.showLoader = false;
                }
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please Enter all Fields',
                        variant: 'Error',
                        mode: 'dismissable'
                    })
                );
                this.showLoader = false;
            }
        }else{
            if(fields.Street != '' &&  fields.City != '' && fields.CountryCode != '' && fields.PostalCode != ''){
                await validateAddress({
                    city:fields.City,
                    countryCode:fields.CountryCode,
                    stateCode:fields.StateCode,
                    postalCode:fields.PostalCode,
                    street:fields.Street,
                    accountId:this.accId
                }).then(result =>{
                    
                    console.log('validate address result>>'+JSON.stringify(result));
                    if(result.statusCode == '200' && !!result.validationResponse.result && !!result.validationResponse.result.address && !!result.validationResponse.result.address.addressComponents && result.validationResponse.result.address.addressComponents.length != 0){
                        //let address = result.validationResponse.result.address.addressComponents.find(add=> (add.confirmationLevel == 'UNCONFIRMED_AND_SUSPICIOUS' || add.confirmationLevel == 'UNCONFIRMED_BUT_PLAUSIBLE'));
                        let isaddress = true;
                        for(let i=0;i<result.validationResponse.result.address.addressComponents.length;i++){
                            if(result.validationResponse.result.address.addressComponents[i].confirmationLevel == 'UNCONFIRMED_AND_SUSPICIOUS' || 
                            result.validationResponse.result.address.addressComponents[i].confirmationLevel == 'UNCONFIRMED_BUT_PLAUSIBLE'){
                                isaddress = false;
                                break;
                            }
                            if(!!result.validationResponse.result.address.addressComponents[i].spellCorrected && result.validationResponse.result.address.addressComponents[i].spellCorrected){
                                isaddress = false;
                                break;
                            }
                            if(!!result.validationResponse.result.address.addressComponents[i].replaced && result.validationResponse.result.address.addressComponents[i].replaced){
                                isaddress = false;
                                break;
                            }
                            /*if(!!result.validationResponse.result.address.addressComponents[i].inferred && result.validationResponse.result.address.addressComponents[i].inferred){
                                isaddress = false;
                                break;
                            }*/
                        }
                        console.log('isAddressCorrect>>>'+isaddress);
                        if(!isaddress){
                            this.isValidAddress = false;
                        }
                        else{
                            if(!!result.billingCountryCode && result.billingCountryCode == this.address.country){
                                this.isValidAddress = true;
                            }else{
                                this.isValidAddress = false;
                                billingCountryAddValidation = true;
                            }
                        }
                    }
                }).catch(error=>{
                    console.log('error in valiadte address>>');
                    console.log(error);
                    this.showLoader = false;
                })
        
                if(!this.isValidAddress){
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: billingCountryAddValidation ? 'Shipping country does not match with the Billing country on this account.' : 'Please Enter a Valid Address.',
                            variant: 'Error',
                            mode: 'dismissable'
                        })
                    );
                    this.showLoader = false;
                }
                if(this.isValidAddress){
                    this.fieldMap.City = fields.City;
                    this.fieldMap.CountryCode = fields.CountryCode;
                    this.fieldMap.StateCode = fields.StateCode;
                    this.fieldMap.PostalCode = fields.PostalCode;
                    this.fieldMap.Street = fields.Street;
                    this.fieldMap.accId = this.accId;
                    this.fieldMap.Name = fields.Name;
                    console.log('fieldMap is set---- ',this.fieldMap);
                    //this.callGetOracleIdAndStore(fields.City, fields.CountryCode, fields.StateCode, fields.PostalCode, fields.Street, this.accId, fields.Name);
                    console.log('here inside submit condition');
                    //this.template.querySelector('lightning-record-edit-form').submit(fields);
                    this.callvalidateAddress(fields);
                    //this.showLoader = false;
                }
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please Enter all Fields',
                        variant: 'Error',
                        mode: 'dismissable'
                    })
                );
                this.showLoader = false;
            }
        }
    }

    async callGetOracleIdAndStore(inputCity, inputCountryCode, inputStateCode, inputPostalCode, inputStreet, inputAccountId, inputNickName, cpaId){

        await getOracleIdAndStore({
            city: inputCity,
            countryCode: inputCountryCode,
            stateCode: inputStateCode,
            postalCode: inputPostalCode,
            street: inputStreet,
            accountId: inputAccountId,
            nickName: inputNickName,
            commId: communityId,
            addressId: cpaId
        }).then(res =>{
            console.log('response from getOracleIdAndStore---- ', res);
            if(res?.errorResponse?.RequestResult?.Status == 'ERROR'){
                var msg = res?.errorResponse?.RequestResult?.Message != undefined ? res?.errorResponse?.RequestResult?.Message : 'Error from Orcale integration, Please contact your admin';
                this.callDeleteContactPointAddress(cpaId, msg);
            }else{
                this.oracleAddressId = res.oracleAddressId;
                this.closePopupSuccess(cpaId);
            }

        }).catch(error=>{
            console.log('error in getOracleIdAndStore ',error);
            this.showLoader = false;
        })
    }
    async callDeleteContactPointAddress(cpaId, errMsg){

        await deleteContactPointAddress({
            addressId: cpaId,
        }).then(res =>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: errMsg,
                    variant: 'Error',
                    mode: 'dismissable'
                })
            );
            console.log('response from deleteContactPointAddress---- ', res);
            this.showLoader = false;
        }).catch(error=>{
            console.log('error in deleteContactPointAddress ',error);
            this.showLoader = false;
        })
    }

    async callvalidateAddress(inpFields){
        let input = {};
        input.accId = this.accId;
        input.nickName =  this.inpNickName;
        await validateNickName({
            inpMap: input,
        }).then(res =>{
            console.log('response from callvalidateAddress---- ', res);
            if(!res.alreadyExists){
                this.template.querySelector('lightning-record-edit-form').submit(inpFields);
            }else{
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'This address already exists. Please use a different Nick-Name',
                        variant: 'Error',
                        mode: 'dismissable'
                    })
                );
                this.showLoader = false;
            }
        }).catch(error=>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Error while saving',
                    variant: 'Error',
                    mode: 'dismissable'
                })
            );
            console.log('error in callvalidateAddress ',error);
            this.showLoader = false;
        })
    }

    /*handleChangeAddName(event){
        //console.log(event.detail.value);
        this.address.name = event.detail.value;
    }*/
    async callUpdateContactAddress(recId){
        if(this.oracleAddressId != undefined){
            await updateContactAddress({
                addressId: recId,
                oraId: this.oracleAddressId
            }).then(res =>{
                console.log('response from updateContactAddress---- ', res);
            }).catch(error=>{
                console.log('error in updateContactAddress ',error);
                this.showLoader = false;
            })
        }
        else{
            console.log('cannot update because oracle address is null');
        }
    }

    handleSuccess(event) {
        console.log('fieldMap get in handleSuccess---- ',this.fieldMap);
        this.callGetOracleIdAndStore(this.fieldMap.City, this.fieldMap.CountryCode, this.fieldMap.StateCode, this.fieldMap.PostalCode, this.fieldMap.Street, this.fieldMap.accId, this.fieldMap.Name, event.detail.id);
        //this.callUpdateContactAddress(event.detail.id);
        //this.closePopupSuccess(event.detail.id);
    }
    async closePopupSuccess(recId) {
        
        let defAddfield = this.template.querySelector( '[ data-id="defAdd" ]' );
        let favAddfield = this.template.querySelector( '[ data-id="favAdd" ]' );
        
        if(favAddfield.checked){
            await addFav({addId:recId})
            .then((data) => {
                this.showLoader = false;
            })
            .catch((error) => {
                console.log('error='+JSON.stringify(error));
            });
        }
        if(defAddfield.checked){
            await addDefault({addId:recId})
            .then((data) => {
                this.showLoader = false;
            })
            .catch((error) => {
                console.log('error='+JSON.stringify(error));
            });
        }  
        this.close(recId);
    }

    closePopup() {
        this.close();
    }
}