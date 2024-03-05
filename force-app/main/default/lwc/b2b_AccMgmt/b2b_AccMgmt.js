import { LightningElement, wire,track } from 'lwc';
import contextApi from 'commerce/contextApi';
import communityId from '@salesforce/community/Id';
import fetchConditions from '@salesforce/apex/B2BAccountManagementController.fetchConditions';
//import getLoggedInUserDetail from '@salesforce/apex/B2BAccountManagementController.getLoggedInUserDetail';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
//import { getRecord } from 'lightning/uiRecordApi';
//import USER_ID from '@salesforce/user/Id'; //this is how you will retreive the USER ID of current in user.
//import IS_BUYER_MANAGER from '@salesforce/schema/User.Is_Buyer_Manager__c';
import My_Profile from '@salesforce/label/c.My_Profile';
import Members from '@salesforce/label/c.Members';
import My_Account from '@salesforce/label/c.My_Account';
import My_Lists from '@salesforce/label/c.My_Lists';
import Addresses from '@salesforce/label/c.Addresses';
import Orders from '@salesforce/label/c.Orders';
import Invoices from '@salesforce/label/c.Invoices';
import Wallet from '@salesforce/label/c.Wallet';
import eReturns from '@salesforce/label/c.eReturns';
import rmaStatus from '@salesforce/label/c.rmaStatus';
import Warranty_Complaints from '@salesforce/label/c.Warranty_Complaints';


export default class B2b_AccMgmt extends NavigationMixin(LightningElement) {
    labels = 
     {
        My_Profile,
        Members,
        My_Account,
        My_Lists,
        Addresses,
        Orders,
        Invoices,
        Wallet,
        eReturns,
        rmaStatus,
        Warranty_Complaints
    };
    commId = communityId;
    currentPageReference;
    
    selectedPageId = 'profile';
    accId;
    //accountData;
    isConsignmentsCustomer;

    @track error ;
    @track IsBuyerUser;

    connectedCallback() {
        //console.log('i m in connectedcallback');
        const result = contextApi.getSessionContext();
        result.then((response) => {
            //console.log("getSessionContext result");
            //console.log(response);
            this.accId = response.effectiveAccountId;
            this.accId = this.accId == null || this.accId == undefined ? '0018L00000GssWnQAJ' : this.accId;
            this.fetchInfoFromApex();
        }).catch((error) => {
            console.log("getSessionContext result");
            console.log(error);
        });
    }

    fetchInfoFromApex(){
        fetchConditions({
            accId: this.accId
        }).then((results) => {
            //console.log('ParsefetchAccountDetails',JSON.parse(results));
            let res =JSON.parse(results);
            //console.log('res ====',res);
            this.isConsignmentsCustomer=res[0];
            this.IsBuyerUser = res[1];
        }).catch((error) => {
            console.log('fetchAccountDetails error');
            console.log(error);
        });
    }
 
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        if (currentPageReference) {
            this.currentPageReference = currentPageReference;
            this.setCurrentPageIdBasedOnUrl();
        }
    }
 
    get newPageReference() {
        return Object.assign({}, this.currentPageReference, {
            state: Object.assign({}, this.currentPageReference.state, this.newPageReferenceUrlParams)
        });
    }
 
    get newPageReferenceUrlParams() {
        return {
            c__page: this.selectedPageId
        };
    }
 
    setCurrentPageIdBasedOnUrl() {
        this.selectedPageId = this.currentPageReference.state.c__page;
        let targetId = this.selectedPageId;
        let target = this.template.querySelector(`[data-id="${targetId}"]`);
        if(!target){
            return;
        }
        target.checked = true;
        this.showSelectedComponent();
    }
 
    handleNavigatemobile(event) {
        this.selectedPageId = event.detail.openSections;
 
        this.navigateToNewPage();
    }

    handleNavigatedesktop(event){
        this.selectedPageId = event.target.dataset.id;
        //console.log('this.selectedPageId == '+this.selectedPageId);
        this.navigateToNewPage();
        this.showSelectedComponent();
    }
    
    showSelectedComponent(){
        
        let profileTargetId = 'profilediv';
        this.template.querySelector(`[data-id="${profileTargetId}"]`).style='display:none;';

        let memberTargetId = 'memberdiv';
        this.template.querySelector(`[data-id="${memberTargetId}"]`).style='display:none;';
               
        let addTargetId = 'addressdiv';
        this.template.querySelector(`[data-id="${addTargetId}"]`).style='display:none;';

        let orderTargetId = 'orderdiv';
        this.template.querySelector(`[data-id="${orderTargetId}"]`).style='display:none;';

        let invTargetId = 'invoicediv';
        this.template.querySelector(`[data-id="${invTargetId}"]`).style='display:none;';

        let walletTargetId = 'walletdiv';
        this.template.querySelector(`[data-id="${walletTargetId}"]`).style='display:none;';

        let rmaTargetId = 'rmadiv';
        this.template.querySelector(`[data-id="${rmaTargetId}"]`).style='display:none;';

        let rmaStatusTargetId = 'rmastatusdiv';
        this.template.querySelector(`[data-id="${rmaStatusTargetId}"]`).style='display:none;';

        let warrantyTargetId = 'warrantystatusdiv';
        console.log('warrantyd='+warrantyTargetId);
        this.template.querySelector(`[data-id="${warrantyTargetId}"]`).style='display:none;';

        let listTargetId = 'listdiv';
        this.template.querySelector(`[data-id="${listTargetId}"]`).style='display:none;';

        let selectedPageId = this.selectedPageId + 'div';
        console.log('selectedPageId='+selectedPageId);
        this.template.querySelector(`[data-id="${selectedPageId}"]`).style='display:block;';
    }

    navigateToNewPage() {
        this[NavigationMixin.Navigate](
            this.newPageReference,
            false // if true js history is replaced without pushing a new history entry onto the browser history stack
        );        // if false new js history entry is created. User will be able to click browser back/forward buttons
    }
}