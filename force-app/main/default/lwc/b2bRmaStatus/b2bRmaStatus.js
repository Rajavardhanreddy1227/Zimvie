import { LightningElement,wire,api} from 'lwc';
import ToastContainer from 'lightning/toastContainer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import rma from '@salesforce/label/c.rma';
import rmaType from '@salesforce/label/c.rmaType';
import rmaStatus from '@salesforce/label/c.rmaStatus';
import createdDate from '@salesforce/label/c.createdDate';
import status from '@salesforce/label/c.Status';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import retrieveRMAStatus from '@salesforce/apex/B2BAccountManagementController.retrieveRMAStatus';
import getRmaTypes from '@salesforce/apex/B2BAccountManagementController.getRmaTypes';
import getRmaStatuses from '@salesforce/apex/B2BAccountManagementController.getRmaStatuses';
import contextApi from 'commerce/contextApi';
import StartDate from '@salesforce/label/c.StartDate';
import EndDate from '@salesforce/label/c.EndDate';
import APPLY from '@salesforce/label/c.APPLY';
import RESET from '@salesforce/label/c.RESET';
import Filter_by_date from '@salesforce/label/c.Filter_by_date';
import Total_Records from '@salesforce/label/c.Total_Records';
const columns = [
    { label: 'RMA #', fieldName: 'rmaName',sortable: "true",type:"button",
        typeAttributes: {
            label: { fieldName: 'rmaName' },
            variant:'base'
        },
        cellAttributes:{
            class:'customtd'
        }
    },
    { label: 'RMA Type', fieldName: 'rmaType', type: 'rmaType',sortable: "true"
        ,
        cellAttributes:{
            class:'customtd'
        } 
    },
    { label: 'Created Date', fieldName: 'createdDate',sortable: "true"
        ,
        cellAttributes:{
            class:'customtd'
        }
    },
    { label: 'Status', fieldName: 'rmaStatus',sortable: "true" 
        ,
        cellAttributes:{
            class:'customtd'
        }
    }
];
export default class B2bRmaStatus extends LightningElement {
    rmaTypes;
    rmaStatuses;
    accId;
    currentPageReference;
    labels={rma,rmaType,createdDate,status,StartDate,EndDate,APPLY,RESET,rmaStatus,Filter_by_date,Total_Records};
    loader = false;
    
    sortBy;
    sortDirection;
    
    showRMASTatusListView = true;
    showViewLink = true;
    selectedRMAStatusRecordId;
    rmaStatusPageSize = 5;
    newPageToken = undefined;
    nextPageToken;
    prevPageToken;
    @api
    totalRecords;
    rmaTypeFilter = '';
    statusFilter = '';
    filterstartdate = null;
    filterenddate = null;

    rmaStatusTableData;
    columns = columns;
    rawTableData;
    tableStyle = 'height: 230px;display: block;';
    
    connectedCallback() {
        console.log('RMA RMA 283472389744723');
        //this.fetchRetrieveRMAStatus();
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';
        const result = contextApi.getSessionContext();
        
        result.then((response) => {
            console.log('RMA status effective account id == '+response.effectiveAccountId);
            this.accId = response.effectiveAccountId;
            this.fetchRetrieveRMAStatus();
        }).catch((error) => {
            console.log("getSessionContext result error");
            console.log(error);
        });
    } 
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        console.log(fieldname);
        let parseData = JSON.parse(JSON.stringify(this.rmaStatusTableData));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : '';
            y = keyValue(y) ? keyValue(y) : '';
            var xContent = (isNaN(x)) 
              ? (x.toLowerCase() === '-')
                    ? 0 : x.toLowerCase()
              : parseFloat(x);
            var yContent = (isNaN(y)) 
              ? (y.toLowerCase() === '-')
                    ? 0 : y.toLowerCase()
              : parseFloat(y);
            
            return isReverse * ((xContent > yContent) - (yContent > xContent));
        });
        this.rmaStatusTableData = parseData;
    }  

    showOrderDetailView(event) {
        const recId = event.detail.row.recordId;
        console.log('recId: ', recId);
        this.selectedOrderId = recId;
        this.showOrderListView = false;
    }

    fetchRetrieveRMAStatus() {
        this.loader = true;
        console.log('this.accId:'+this.accId);
        retrieveRMAStatus({ 
            accId: this.accId,
            pageSize: this.rmaStatusPageSize,
            pageToken: this.newPageToken,
            ownerScoped: false,
            startDateFilter:this.filterstartdate,
            endDateFilter:this.filterenddate,
            rmaTypeFilter:this.rmaTypeFilter,
            statusFilter:this.statusFilter
        })
        .then(res => {
            this.loader = false;
            console.log('rmaStatusTableData res is:'+res);
            let jsonObj = JSON.parse(res);
            console.log('jsonObj:'+jsonObj);
            this.rmaStatusTableData = jsonObj.rmaStatusWrapList;
            this.prevPageToken= jsonObj.previousPageToken;
            this.nextPageToken= jsonObj.nextPageToken;
            this.totalRecords = jsonObj.totalCount;
        })
        .catch( error => {
            console.log(error);
        });
    }
   
    @wire(getRmaTypes)
    wiredRmaTypes({ data, error }) {
        console.log('getRmaTypes data is:'+data);
        if (data) {
            this.rmaTypes = data;
        } else if (error) {
            console.error('Error fetching picklist values: ' + JSON.stringify(error));
        }
    }
    @wire(getRmaStatuses)
    wiredRmaStatuses({ data, error }) {
        if (data) {
            this.rmaStatuses = data;
        } else if (error) {
            console.error('Error fetching picklist values: ' + JSON.stringify(error));
        }
    }
    goPrevious(){
        this.newPageToken = this.prevPageToken;
        this.fetchRetrieveRMAStatus();
    }
    gonext(){
        this.newPageToken = this.nextPageToken;
        this.fetchRetrieveRMAStatus();
    }
    get isPrevDisabled(){
        return !this.prevPageToken;
    }
    get isNextDisabled(){
        return !this.nextPageToken;
    }

    clearFilter(){
        this.template.querySelector(`[data-id="startdate"]`).value = null; 
        this.template.querySelector(`[data-id="enddate"]`).value = null;
        this.filterstartdate = null;
        this.filterenddate = null;
        this.startsearch();
    }

    handleStartDateSearch(event){
        console.log(event.target.value);
        if(event.target.value){
            this.filterstartdate = new Date(String(event.target.value));
        } else {
            var pastdt = new Date();
            pastdt.setFullYear(pastdt.getFullYear() - 500);
            this.filterstartdate = pastdt;
        }
        console.log(this.filterstartdate);
    }
    handleEndDateSearch(event){
        console.log(event.target.value);
        if(event.target.value){
            this.filterenddate = new Date(String(event.target.value));
        } else {
            var ftrdt = new Date();
            ftrdt.setFullYear(ftrdt.getFullYear() + 500);
            this.filterenddate = ftrdt;
        }
        console.log(this.filterenddate);
    }
    handleGetSelectedValueForRMAStatus(event){
        console.log('handleGetSelectedValueForRMAStatus:'+event.target.value);
        this.statusFilter = event.target.value;
    }
    handleGetSelectedValueForRMAType(event){
        console.log('handleGetSelectedValueForRMAType:'+event.target.value);
        this.rmaTypeFilter = event.target.value;
    }
    startsearch(){
        this.newPageToken = 0;
        this.fetchRetrieveRMAStatus();
    }
    showRMAStatusDetailView(event) {
        const recId = event.detail.row.recordId;
        console.log('recId: ', recId);
        this.selectedRMAStatusRecordId = recId;
        this.showRMASTatusListView = false;
    }
    hideRMAStatusDetailView() {
        this.showRMASTatusListView = true;
        //window.location = window.origin + '/Zimvie/accountmanagement?c__page=RMAStatus';
    }
}