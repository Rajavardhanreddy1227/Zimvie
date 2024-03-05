import { LightningElement, track, api,wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import contextApi from 'commerce/contextApi';
import ToastContainer from 'lightning/toastContainer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ModalRecordEditForm from "c/b2b_shippingaddmodal";
import LightningConfirm from 'lightning/confirm';
import {deleteRecord} from 'lightning/uiRecordApi';
import Addresses from '@salesforce/label/c.Addresses';
import Add_New_Address from '@salesforce/label/c.Add_New_Address';
import AddAddress from '@salesforce/label/c.AddAddress';
import AddressType from '@salesforce/label/c.AddressType';
import Street from '@salesforce/label/c.Street';
import Remove from '@salesforce/label/c.Remove';
import Nick_Name from '@salesforce/label/c.Nick_Name';
import All_Addresses from '@salesforce/label/c.All_Addresses';
import Favorites from '@salesforce/label/c.Favorites';
import Edit from '@salesforce/label/c.Edit';
import City from '@salesforce/label/c.City';
import State from '@salesforce/label/c.State';
import PostalCode from '@salesforce/label/c.PostalCode';
import Country from '@salesforce/label/c.Country';
import Default from '@salesforce/label/c.Default';
import IsDefault from '@salesforce/label/c.IsDefault';
import loading from '@salesforce/label/c.loading';
import SearchAddress from '@salesforce/label/c.SearchAddress';
import { refreshApex } from '@salesforce/apex';
import Id from '@salesforce/user/Id';
import fetchAddressRecords from '@salesforce/apex/b2B_CustomAddressComponentController.fetchAddressRecords';
import addFav from '@salesforce/apex/b2B_CustomAddressComponentController.addFav';
import removeFav from '@salesforce/apex/b2B_CustomAddressComponentController.removeFav';
import addDefault from '@salesforce/apex/b2B_CustomAddressComponentController.addDefault';
//import b2B_CustomAddressComponentHelper from "./b2B_CustomAddressComponentHelper";
const actions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' },
];
const addressColumns = [
    { label: AddressType, fieldName: 'AddressType' },
    { label: Street, fieldName: 'Street' },
    { label: City, fieldName: 'City' },
    { label: State, fieldName: 'State' },
    { label: PostalCode, fieldName: 'PostalCode' },
    { label: Country, fieldName: 'Country' },
    { label: IsDefault, fieldName: 'IsDefault' , type: 'boolean'},
    {
        label: 'Favorite?',
        fieldName: '',
        cellAttributes: { iconName: { fieldName: 'dynamicIcon' } }
    },
    {
        type: 'action',
        typeAttributes: { rowActions: actions},cellAttributes:{class:{fieldName:'cssClass'} }
    },
];
export default class b2B_CustomAddressComponent extends NavigationMixin(LightningElement) {
    userId = Id;
    labels = {
            loading,
            AddAddress,
            SearchAddress,
            Addresses,
            Street,
            City,
            State,
            PostalCode,
            Country,
            IsDefault,
            Add_New_Address,
            Nick_Name,
            Default,
            Favorites,
            Edit,
            Remove,
            Nick_Name,
            All_Addresses
            };
    //state = {};
    recordId;
    //sobjectApiName = 'ContactPointAddress';
    //relatedFieldApiName = 'ParentId';
    //numberOfRecords = 10;
    //sortedBy = 'Name';
    //sortedDirection = "ASC";
    //rowActionHandler;
    //fields = 'AddressType,Street,City,State,PostalCode,Country,IsDefault';//AddressFirstName,AddressLastName
    columns = addressColumns;
    addressData;
    //customActions = [];
    //helper = new b2B_CustomAddressComponentHelper()
    //showRelatedList = false;
    //hasRecords = false;
    //effectiveAccountId;
    favoriteAddresses = [];
    nonFavoriteAddresses = [];
    loading = false;

    connectedCallback() {
        const result = contextApi.getSessionContext();
        result.then((response) => {
            this.recordId = response.effectiveAccountId == '000000000000000' ? '0018L00000GssWnQAJ' : response.effectiveAccountId;
            //this.effectiveAccountId = this.state.recordId;
            //this.showRelatedList = true;
            console.log('account id for address is '+this.recordId);
            //this.fetchData(this.recordId);
        }).catch((error) => {
            console.log("getSessionContext result");
            console.log(error);
        });

        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';
    }   
    favAddAvailable;
    constResult;

    @wire(fetchAddressRecords,{recordId:'$recordId'})
    wiredObj(result){
        this.constResult = result;
        console.log('here address result>>'+JSON.stringify(this.constResult));
        if(this.constResult.error){
            console.log('error' ,this.constResult.error);
        } else if(this.constResult.data){
            let tempData = JSON.parse(this.constResult.data);
            tempData.lstFavAdd.forEach(element => {
                if(element.CreatedById == this.userId && (element.ORAAddressId__c == '' || element.ORAAddressId__c == null)){
                    element['cssClass'] = 'actioncls';
                } else {
                    element['cssClass'] = 'slds-hide actioncls';
                }
            });
            tempData.lstDefAdd.forEach(element => {
                if(element.CreatedById == this.userId && (element.ORAAddressId__c == '' || element.ORAAddressId__c == null)){
                    element['cssClass'] = 'actioncls';
                } else {
                    element['cssClass'] = 'slds-hide actioncls';
                }
            });
            this.addressData = tempData;
            this.favoriteAddresses = this.addressData.lstFavAdd;
            this.favAddAvailable = this.favoriteAddresses?.length > 0 ? true : false;
            this.nonFavoriteAddresses = this.addressData.lstDefAdd;
            this.allAddressNull = this.nonFavoriteAddresses.length > 0 ? false : true;
            this.loading = false;
            console.log(JSON.stringify(this.addressData));
        }
    }

    fetchData(val){
        this.loading = true;
        console.log('calling apex method : ');
        fetchAddressRecords({recordId:val}).then((res) => {
            console.log('address result is:');
            console.log(res);
            let tempData = JSON.parse(res);
            tempData.lstFavAdd.forEach(element => {
                if(element.CreatedById == this.userId){
                    element['cssClass'] = 'actioncls';
                } else if(element.CreatedById != this.userId){
                    element['cssClass'] = 'slds-hide actioncls';
                }
            });
            tempData.lstDefAdd.forEach(element => {
                if(element.CreatedById == this.userId){
                    element['cssClass'] = 'actioncls';
                } else if(element.CreatedById != this.userId){
                    element['cssClass'] = 'slds-hide actioncls';
                }
            });
            this.addressData = tempData;
            this.favoriteAddresses = this.addressData.lstFavAdd;
            this.nonFavoriteAddresses = this.addressData.lstDefAdd;
            this.allAddressNull = this.nonFavoriteAddresses.length > 0 ? false : true;
            this.loading = false;
            console.log(JSON.stringify(this.addressData));
        }).catch(error => {
            console.log('error' ,error);
        });
    }

    handleFav(event){
        this.loading = true;
        addFav({addId:event.target.dataset.id})
            .then((data) => {
                //this.fetchData(this.recordId);
                refreshApex(this.constResult);
                const evt = new ShowToastEvent({
                    title: "Success",
                    message: "Address has been marked as Favorite",
                    variant: "success"
                    });
                    this.dispatchEvent(evt);
                })
            .catch((error) => {
                console.log('error='+JSON.stringify(error));
            });
    }

    handleUnFav(event){
        this.loading = true;
        removeFav({addId:event.target.dataset.id})
            .then((data) => {
                //this.fetchData(this.recordId);
                refreshApex(this.constResult);
                const evt = new ShowToastEvent({
                    title: "Success",
                    message: "Address has been marked as Non-Favorite",
                    variant: "success"
                    });
                    this.dispatchEvent(evt);
                })
            .catch((error) => {
                console.log('error='+JSON.stringify(error));
            });
    }

    handleMakeDefault(event){
        this.loading = true;
        addDefault({addId:event.target.dataset.id})
            .then((data) => {
                //this.fetchData(this.recordId);
                refreshApex(this.constResult);
            })
            .catch((error) => {
                console.log('error='+JSON.stringify(error));
            });
    }
    

    /*wireResult;
    @wire(fetchAddressRecords,{recordId:'$recordId'})
    wiredResult(result){
        console.log('address wired result is:');
        console.log(result);
        this.wireResult = result;
        if(result.error){
            console.error('Error'+JSON.stringify(result.error));
        } else if(result.data){
            let tempData = result.data;
            tempData.forEach(element => {
                if(element.IsFavourite__c == true){
                    element['dynamicIcon'] = 'utility:favorite';
                }
            });
            this.addressData = tempData;
        }
    }*/
    async showPopup() {
        
        const recordId = await ModalRecordEditForm.open({
            size: "small",effectiveAccountId:this.recordId
        });
        
        if (recordId) {
            await this.showSuccessToast(recordId);
            //this.init(this.state.recordId)
            //refreshApex(this.wireResult);
            //this.fetchData(this.recordId);
            refreshApex(this.constResult);
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

        const data = await this.helper.fetchData(this.state);
        let temp = {};
        temp = data.records;
        //console.log('records==');
        //console.log(temp);
        this.state.records = [...temp];
        this.state.iconName = data.iconName;
        this.state.sobjectLabel = data.sobjectLabel;
        this.state.sobjectLabelPlural = data.sobjectLabelPlural;
        this.state.title = data.title;
        this.state.parentRelationshipApiName = data.parentRelationshipApiName;
        this.state.columns = this.helper.initColumnsWithActions(this.columns, this.customActions);
        console.log(this.state.columns);
        this.hasRecords = this.state.records != null && this.state.records.length;
    }*/

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        //if (this.rowActionHandler) {
        //    this.rowActionHandler.call()
        //} else {
        switch (actionName) {
            case "delete":
                this.handleDeleteRecord(row);
                break;
            case "edit":
                this.handleEditRecord(row);
                break;
            default:
        }
        //}
    }

    async handleEditRecord(evt) {
        console.log('calling modal');
        console.log(evt.target.dataset.id);
        console.log(evt);
        const recordId = await ModalRecordEditForm.open({
            size: "small",recordId:evt.target.dataset.id
        });
        
        if (recordId) {
            await this.showSuccessToast(recordId);
            //this.init(this.state.recordId);
            //refreshApex(this.wireResult);
            //this.fetchData(this.recordId);
            refreshApex(this.constResult);
        }
    }

    async handleDeleteRecord(evt) {
        let targetId = evt.target.dataset.id;
        const result = await LightningConfirm.open({
            message: 'Do you really want to delete this address?',
            variant: 'headerless',
            label: 'Confirm',
            // setting theme would have no effect
        });

        if(result){
            deleteRecord(targetId)
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record deleted',
                        variant: 'success'
                    })
                );
                //this.init(this.state.recordId);
                //refreshApex(this.wireResult);
                //this.fetchData(this.recordId);
                refreshApex(this.constResult);
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error deleting record',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
        }
    }
    allAddressNull;
    handleSearch(event){
        console.log(event);
        console.log(event.target.value);
        let value = event.target.value.toLowerCase();
        if(!this.addressData){
            return;
        }
        if(value !== '' ){
            
            let tempData = JSON.parse(JSON.stringify(this.addressData));
            this.favoriteAddresses = tempData.lstFavAdd;
            this.nonFavoriteAddresses = tempData.lstDefAdd;

            console.log('value>>'+value);

            console.log('here fav records>>>'+JSON.stringify(this.favoriteAddresses));
            let tempFav = this.favoriteAddresses;
            let favrecords = [];
            favrecords = tempFav.filter(function (el) {
                return el.City?.toLowerCase().includes(value) || el.State?.toLowerCase().includes(value) || el.PostalCode?.toLowerCase().includes(value) || el.Country?.toLowerCase().includes(value) || 
                el.Street?.toLowerCase().includes(value);
                }
            );
            
            this.favoriteAddresses = [...favrecords];
            console.log('here new fav records>>>'+JSON.stringify(this.favoriteAddresses));

            console.log('here non-fav records>>>'+JSON.stringify(this.nonFavoriteAddresses));
            let tempNonFav = this.nonFavoriteAddresses;
            let nonfavrecords = [];
            nonfavrecords = tempNonFav.filter(function (el) {
                return el.City?.toLowerCase().includes(value) || el.State?.toLowerCase().includes(value) || el.PostalCode?.toLowerCase().includes(value) || el.Country?.toLowerCase().includes(value) || 
                el.Street?.toLowerCase().includes(value);
                }
            );
            
            this.nonFavoriteAddresses = [...nonfavrecords];
            this.allAddressNull = this.nonFavoriteAddresses.length > 0 ? false : true;
            console.log('here new non fav records>>>'+JSON.stringify(this.nonFavoriteAddresses));
        }
        else{
            let tempData = JSON.parse(JSON.stringify(this.addressData));
            this.favoriteAddresses = tempData.lstFavAdd;
            this.nonFavoriteAddresses = tempData.lstDefAdd;
        }
            
    }
}