import { LightningElement, track, api,wire } from "lwc";
import {updateShippingAddress,loadCheckout,notifyCheckout,restartCheckout,CheckoutInformationAdapter} from 'commerce/checkoutApi';
import { CartSummaryAdapter } from "commerce/cartApi";

import contextApi from 'commerce/contextApi';
import ToastContainer from 'lightning/toastContainer';
import AddAddress from '@salesforce/label/c.AddAddress';
import AddressType from '@salesforce/label/c.AddressType';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ModalRecordEditForm from "c/b2b_shippingaddmodal";
import Street from '@salesforce/label/c.Street';
import City from '@salesforce/label/c.City';
import State from '@salesforce/label/c.State';
import PostalCode from '@salesforce/label/c.PostalCode';
import Country from '@salesforce/label/c.Country';
import IsDefault from '@salesforce/label/c.IsDefault';
import loading from '@salesforce/label/c.loading';
import { updateRecord } from 'lightning/uiRecordApi';
import SearchAddress from '@salesforce/label/c.SearchAddress';
import Default from '@salesforce/label/c.Default';
import Id from '@salesforce/user/Id';
import Add_New_Address from '@salesforce/label/c.Add_New_Address';
//import initDataMethod from "@salesforce/apex/b2B_CustomAddressComponentController.initData";
import fetchAddressRecords from '@salesforce/apex/b2B_CustomAddressComponentController.fetchCheckoutAddressRecords';
import updateAddressOnCDG from "@salesforce/apex/b2B_checkoutAddressController.updateAddressOnCDG";
import callShippingIntegration from "@salesforce/apex/b2B_checkoutAddressController.callShippingIntegration";
import ifOrcaleAddId from "@salesforce/apex/b2B_checkoutAddressController.ifOrcaleAddId";
import communityId from '@salesforce/community/Id';
import {fireEvent} from 'c/b2b_pubsub';
import { CurrentPageReference } from 'lightning/navigation'; 
import Selected_Address from '@salesforce/label/c.Selected_Address';
import Edit from '@salesforce/label/c.Edit';
import getCDGID from "@salesforce/apex/b2B_checkoutAddressController.getCDGID";

const addressColumns = [
    { label: AddressType, fieldName: 'AddressType' },
    //{ label: 'First Name', fieldName: 'AddressFirstName'},
    //{ label: 'Last Name', fieldName: 'AddressLastName'},
    { label: Street, fieldName: 'Street' },
    { label: City, fieldName: 'City' },
    { label: State, fieldName: 'State' },
    { label: PostalCode, fieldName: 'PostalCode' },
    { label: Country, fieldName: 'Country' },
    { label: IsDefault, fieldName: 'IsDefault' , type: 'boolean'},
];

const HIDE_SUMMARY_DETAILS = 'hideSummaryDetails';

export default class B2B_CheckoutAddress extends LightningElement {
    userId = Id;
    labels = {loading,AddAddress,SearchAddress,Default,Add_New_Address,Selected_Address,Edit};
    recordId;

    loader = false;
    @track
    addressData;
    dataRecords;
    cartId;
    selectedAddressId;
    //@track state = {}
    //sobjectApiName = 'ContactPointAddress';
    //relatedFieldApiName = 'ParentId';
    //numberOfRecords = 100;
    //sortedBy = 'Name';
    //sortedDirection = "ASC";
    //fields = 'AddressType,Street,City,State,StateCode,PostalCode,Country,CountryCode,IsDefault,Name';//AddressFirstName,AddressLastName
    //columns = addressColumns;
    //customActions = [];
    //helper = new b2B_CustomAddressComponentHelper()
    //showRelatedList = false;
    //hasRecords = false;
    fetchDataCalled = false;
    
    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        console.log("data Id- suumar-ff", data);
        if (data) {

            console.log("Cart aa Id", data.cartId);
            console.log("Cart aa data", data.webstoreId);
            this.cartId = data.cartId;
            if(data.cartId !== undefined){
                if(this.fetchDataCalled == true){
                    return;
                }
                /////
                getCDGID({
                    cartId : data.cartId
                }).then((res) => {
                    this.currentDeliveryGroupId = res;
                }).catch(error => {
                    console.log('error' ,error);
                });
                /////
                const result = contextApi.getSessionContext();
                result.then((response) => {
                    this.recordId = response.effectiveAccountId == '000000000000000' ? '0018L00000GssWnQAJ' : response.effectiveAccountId;
                    //this.effectiveAccountId = this.state.recordId;
                    //this.showRelatedList = true;
                    console.log('this.recordId -->'+this.recordId);
                    this.fetchData(this.recordId);
                    this.fetchDataCalled = true;
                }).catch((error) => {
                    console.log("getSessionContext result");
                    console.log(error);
                });
            }
        } else if (error) {
            console.error('====Error'+error);
        }
    }
    connectedCallback() {
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';

        /*const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';*/
        
    } 
    shippingMethodOptions;
    currentDeliveryGroupId;
    @wire(CurrentPageReference) pageRef; 

    /*@wire(CheckoutInformationAdapter)
    wiredobj(result) {
        console.log('received checkout result==');
        console.log(result);
        if(result.data && result.data.deliveryGroups){
            if(result.data.deliveryGroups.items.length > 0){
                this.currentDeliveryGroupId = result.data.deliveryGroups.items[0].id;
                if(result.data.deliveryGroups.items[0].availableDeliveryMethods.length <= 0){
                    console.log('calling integration');
                    //this.callAddressIntegration();
                } 
                else {
                    this.shippingMethodOptions = JSON.stringify(result.data.deliveryGroups.items[0].availableDeliveryMethods);
                }
            }
        }
    }
    integrationCalled = false;
    //checkoutIntegrationCalled = false;
    async callAddressIntegration(){
        if(this.integrationCalled == true){
            return;
        }
        this.loader = true;
        await callShippingIntegration({CdgId : this.currentDeliveryGroupId})
        .then((res) => {
            this.loader=false;
            this.integrationCalled = true;
            console.log('integration calling completed');
            //restartCheckout();
            //notifyCheckout({state:null});
        }).catch(error => {
            console.log('error' ,error);
        });
    }*/
    async handleEditRecord(event) {
        console.log('calling modal');
        const recordId = await ModalRecordEditForm.open({
            size: "small",recordId:event.target.name
        });
        
        if (recordId) {
            await this.showSuccessToast(recordId);
            //this.init(this.state.recordId);
            //refreshApex(this.wireResult);
            this.fetchData(this.recordId);
        }
    }

    /*async init(recordId) {
        this.hasRecords = false;
        this.state.showRelatedList = recordId != null;
        if (! (recordId
            && this.sobjectApiName
            && this.relatedFieldApiName
            && this.fields
            && this.columns)) {
            this.state.records = [];
            return;
        }

        this.state.fields = this.fields
        this.state.relatedFieldApiName= this.relatedFieldApiName
        this.state.recordId= recordId
        this.state.numberOfRecords= this.numberOfRecords
        this.state.sobjectApiName= this.sobjectApiName
        this.state.sortedBy= this.sortedBy
        this.state.sortedDirection= this.sortedDirection
        this.state.customActions= this.customActions

        const data = await this.fetchData(this.state);
        let temp = {};
        temp = data.records;
        this.dataRecords = data.records;
        //console.log('records==');
        //console.log(temp);
        this.state.records = [...temp];
        console.log(JSON.stringify(this.state.records));
        this.state.iconName = data.iconName;
        this.state.sobjectLabel = data.sobjectLabel;
        this.state.sobjectLabelPlural = data.sobjectLabelPlural;
        this.state.title = data.title;
        this.state.parentRelationshipApiName = data.parentRelationshipApiName;
        this.state.columns = this.initColumnsWithActions(this.columns, this.customActions);
        console.log(this.state.columns);
        this.hasRecords = this.state.records != null && this.state.records.length;
    }*/
    favoriteAddresses = [];
    nonFavoriteAddresses = [];

    fetchData(val){
        console.log('calling apex method : ');
        fetchAddressRecords({recordId : val, cartId : this.cartId}).then((res) => {
            console.log('address result is:');
            console.log(res);
           
            let tempData = JSON.parse(res);
            console.log('selectedAddressId---->'+tempData.selectedAddressId);
            this.selectedAddressId = tempData.selectedAddressId;
            tempData.lstFavAdd.forEach(element => {
                if(element.CreatedById == this.userId && (element.ORAAddressId__c == '' || element.ORAAddressId__c == null)){
                    element['cssClass'] = '';
                } else {
                    element['cssClass'] = 'slds-hide';
                }
            });
            tempData.lstDefAdd.forEach(element => {
                if(element.CreatedById == this.userId && (element.ORAAddressId__c == '' || element.ORAAddressId__c == null)){
                    element['cssClass'] = '';
                } else {
                    element['cssClass'] = 'slds-hide';
                }
            });
            let tempArr = tempData;
            this.favoriteAddresses = tempArr.lstFavAdd;
            this.nonFavoriteAddresses = tempArr.lstDefAdd;
            let newArr = this.favoriteAddresses.concat(this.nonFavoriteAddresses);
            this.addressData = newArr;
            this.addressData.forEach(element => {
                if(this.selectedAddressId !== undefined && this.selectedAddressId == element.Id){
                    element['isSelected'] = true;
                    this.selectedAddress = element;
                }else{
                    element['isSelected'] = false;
                }
            });
            if(this.selectedAddressId !== undefined && this.selectedAddressId != null){
                this.callIfOrcaleAddId(this.selectedAddressId);
            }
            this.dataRecords = newArr;
            console.log(JSON.stringify(this.addressData, 'test>>>>>'));

            // for (let i = 0; i < this.addressData.length; i++) {
            //     const obj = arrayOfObjects[i];
            //     if(obj.IsDefault){
                    
            //         this.handleDefualtAddress(obj.Id);
            //     }
               
            //   }

            
           
        }).catch(error => {
            console.log('error' ,error);
        });
    }

    /*initColumnsWithActions(columns, customActions) {
        if (!customActions.length) {
           customActions = [
               { label: 'Edit', name: 'edit' },
               { label: 'Delete', name: 'delete' }
           ]
       }
       return [...columns, { type: 'action', typeAttributes: { rowActions: customActions } }]
      }

    processData(data, state){
        let records = [];
        const tempRecords = data.records;
        tempRecords.forEach(element => {
            if(element.AddressType == 'Shipping'){
                records.push(element);
            }
        });

        records.sort((a, b) => {
            if (a.IsDefault === b.IsDefault) {
              return 0;
            } else if (a.IsDefault) {
              return -1;
            } else {
              return 1;
            }
        });

       // this.generateLinks(records)
        if (records.length > state.numberOfRecords) {
            records.pop()
            data.title = `${data.sobjectLabelPlural} (${state.numberOfRecords}+)`
        } else {
            data.title = `${data.sobjectLabelPlural} (${Math.min(state.numberOfRecords, records.length)})`
        }     
        data.records = records;
        return data;
    }*/

    handleInputChange(event){
        let value = event.detail.value.toLowerCase();
        if(value !== ''){
            this.searchRecordFlag = false;
            this.addressData = [...this.dataRecords];
            console.log('value>>'+value);
            console.log('here records>>>'+JSON.stringify(this.addressData));
            let temp = this.addressData;
            let records = [];
            records = temp.filter(function (el) {
                let combinedValue = el.Street?.toLowerCase()+', '+el.City?.toLowerCase()+', '+el.State?.toLowerCase()+','+el.CountryCode?.toLowerCase()+', '+el.PostalCode?.toLowerCase();
                console.log('combinedValue='+combinedValue);
                return el.City?.toLowerCase().includes(value) || el.State?.toLowerCase().includes(value) || el.PostalCode?.toLowerCase().includes(value) || el.CountryCode?.toLowerCase().includes(value) || 
                el.Street?.toLowerCase().includes(value) || combinedValue.includes(value);
            }
            );
            
            console.log('here new rescords>>>'+JSON.stringify(records));
            this.addressData = [...records];
            this.addressData.forEach(element => {
                if(this.selectedAddressId !== undefined && this.selectedAddressId == element.Id){
                    element['isSelected'] = true;
                }else{
                    element['isSelected'] = false;
                }
            });
            console.log('here new state rescords>>>'+JSON.stringify(this.addressData));
        }
        else{
            this.addressData = [...this.dataRecords];
            this.addressData.forEach(element => {
                if(this.selectedAddressId !== undefined && this.selectedAddressId == element.Id){
                    element['isSelected'] = true;
                }else{
                    element['isSelected'] = false;
                }
            });
        }
            
    }
    async callIfOrcaleAddId(cpAddId){
        let inpMap = {};
        inpMap.cpaId = cpAddId;
        inpMap.commId = communityId;
        await ifOrcaleAddId({
            inputMap : inpMap
        }).then((res) => {
            console.log('ifOrcaleAddId res-- ' ,res);
            if(res.errorResponse != undefined){
                this.loader = false;
                fireEvent(this.pageRef, "removeCheckoutIntegrationEvent", null); 
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: 'Please select a valid address.',
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
            }else{
                this.loader = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Shipping Address has been updated for this order.',
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
                this.fetchOrderDeliveryMethods();
            }
        }).catch(error => {
            console.log('error' ,error);
        });
    }

    selectedAddress = null;
    handleAddressSelection(event){
        this.loader = true;
        fireEvent(this.pageRef, HIDE_SUMMARY_DETAILS, null); 
        let id;
        if(event === undefined){
            if(this.selectedAddressId !== undefined){
                this.id = this.selectedAddressId;
            }
        }else{
            this.id = event.target.dataset.id;
        }
        console.log('this.id----->'+this.id);
        //this.callIfOrcaleAddId(id);
        //let selectedAddressId = this.template.querySelector(`[id="${id}"]`).value;
        console.log('selectedAddressId>>'+id);
        console.log('this.currentDeliveryGroup==');
        let selectedAddress;
        console.log(this.currentDeliveryGroupId);
        this.addressData.forEach(element => {
            if(element.Id == this.id){
                selectedAddress = element;
            }
        });
        console.log('selectedAddress ==>>');
        console.log(selectedAddress);
        this.selectedAddress = selectedAddress;
        this.selectedAddressId = selectedAddress.Id;
        this.addressData.forEach(element => {
            if(this.selectedAddressId !== undefined && this.selectedAddressId == element.Id){
                element['isSelected'] = true;
            }else{
                element['isSelected'] = false;
            }
        });
        updateAddressOnCDG({
            Id:this.currentDeliveryGroupId,DeliverToCity:selectedAddress.City,
            DeliverToCountryCode:selectedAddress.CountryCode,DeliverToPostalCode:selectedAddress.PostalCode,
            DeliverToStateCode:selectedAddress.StateCode,DeliverToStreet:selectedAddress.Street,
            DeliverToName:selectedAddress.Name,
            cpaId: selectedAddress.Id,
            commId: communityId
        }).then((res) => {
            //this.loader=false;
            // this.dispatchEvent(
            //     new ShowToastEvent({
            //         title: 'Success',
            //         message: 'Shipping Address has been updated for this order.',
            //         variant: 'success',
            //         mode: 'dismissable'
            //     })
            // );
            //this.fetchOrderDeliveryMethods();
            this.callIfOrcaleAddId(this.id);
        }).catch(error => {
            console.log('error' ,error);
        });
    }

    async fetchOrderDeliveryMethods(){
        this.loader = true;
        await callShippingIntegration({cartId : this.cartId})
        .then((res) => {
            this.loader=false;
            console.log('integration calling completed');
            console.log('sending data to shipping method ');
            let tempWrap = {};
            tempWrap['data'] = res;
            tempWrap['cdgId'] = this.currentDeliveryGroupId;
            tempWrap['cartId'] = this.cartId;
            fireEvent(this.pageRef, "checkoutIntegrationEvent", tempWrap); 
        }).catch(error => {
            console.log('error' ,error);
        });
    }

    async showPopup() {
        
        const recordId = await ModalRecordEditForm.open({
            size: "small",effectiveAccountId:this.recordId
        });
        
        if (recordId) {
            await this.showSuccessToast(recordId);
            //loadCheckout();
            //this.init(this.state.recordId)
            //refreshApex(this.wireResult);
            //
            this.fetchData(this.recordId);
        }
    }

    async showSuccessToast(recordId) {
        const evt = new ShowToastEvent({
        title: "Success",
        message: "Address Updated",
        variant: "success"
        });
        this.dispatchEvent(evt);
    }
}