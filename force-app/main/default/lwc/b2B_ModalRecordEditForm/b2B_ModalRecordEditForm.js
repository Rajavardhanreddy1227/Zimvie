import { api,wire } from "lwc";
import LightningModal from "lightning/modal";
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import COUNTRY_CODE from '@salesforce/schema/User.CountryCode';
import BILLING_STATE_CODE from '@salesforce/schema/User.StateCode';
import progress from '@salesforce/label/c.progress';
import NewAddress from '@salesforce/label/c.NewAddress';
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
export default class B2b_shippingaddmodal extends LightningModal {

    _countries = [];
    _countryToStates = {};

    selectedCountry;
    selectedState;

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

    labels={
        progress,
        NewAddress,
        Makethismydefaultaddress,
        Address,
        SearchAddress,
        Name,
        Street,
        City,
        State,
        PostalCode,
        Country,
        Save
    };
    errors;
    @api effectiveAccountId;

    address = {
        street: '',
        city: '',
        country: '',
        province: '',
        postalcode: '',
        addType: '',
        isdefault: false,
        name:''
    };

    handleAddressChange(event){
        
        //console.log(event.detail);
        this.address.street = event.detail.street;
        this.address.city = event.detail.city;
        this.address.province = event.detail.province;
        this.address.postalcode = event.detail.postalCode;
        this.address.country = event.detail.country;
        this.selectedCountry = event.detail.country;
        this.selectedState = event.detail.province;
    }

    handleSubmit(event){
        event.preventDefault();       
        const fields = event.detail.fields;
        fields.Name = this.address.name;
        fields.Street = this.address.street;
        fields.City = this.address.city;
        fields.StateCode = this.address.province;
        fields.PostalCode = this.address.postalcode;
        fields.CountryCode = this.address.country;
        fields.ParentId = this.effectiveAccountId;
        //console.log('submitted fields');
        //console.log(fields);
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleChangeAddName(event){
        //console.log(event.detail.value);
        this.address.name = event.detail.value;
    }

    handleSuccess(event) {
        this.closePopupSuccess(event.detail.id);
    }
    closePopupSuccess(recId) {
        this.close(recId);
    }

    closePopup() {
        this.close();
    }
}