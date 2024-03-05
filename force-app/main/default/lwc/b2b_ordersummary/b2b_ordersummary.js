import { LightningElement, wire, api } from 'lwc';
import { startReOrder, OrdersAdapter } from 'commerce/orderApi';
import contextApi from 'commerce/contextApi';
import getOrderSummaries from '@salesforce/apex/B2BAccountManagementController.getOrderSummariesForAccount';
import ToastContainer from 'lightning/toastContainer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshCartSummary } from 'commerce/cartApi';
import Ordered_Date from '@salesforce/label/c.Ordered_Date';
import Order_Number from '@salesforce/label/c.Order_Number';
import START_REORDER from '@salesforce/label/c.START_REORDER';
import Status from '@salesforce/label/c.Status';
import Total from '@salesforce/label/c.Total';
import ViewDetailsLabel from '@salesforce/label/c.ViewDetailsLabel';
import VIEW_ALL_ORDERS from '@salesforce/label/c.VIEW_ALL_ORDERS';
import Orders from '@salesforce/label/c.Orders';
import Filter_by_date from '@salesforce/label/c.Filter_by_date';
import StartDate from '@salesforce/label/c.StartDate';
import EndDate from '@salesforce/label/c.EndDate';
import APPLY from '@salesforce/label/c.APPLY';
import RESET from '@salesforce/label/c.RESET';
import Order from '@salesforce/label/c.Order';
import Order_Date from '@salesforce/label/c.Order_Date';
import PO_Number from '@salesforce/label/c.PO_Number';
import Source from '@salesforce/label/c.Source';
import Oracle_Order from '@salesforce/label/c.Oracle_Order';
import Recent_Orders from '@salesforce/label/c.Recent_Orders';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
const columns = [
    {
        label: 'eShop Order', fieldName: 'Order_Number', sortable: "true", type: "button",
        typeAttributes: {
            label: { fieldName: 'Order_Number' },
            variant: 'base'
        },
        cellAttributes: {
            class: 'customtd'
        }
    },
    {
        label: 'Order Date', fieldName: 'orderedDate', type: 'date', sortable: "true"
        ,
        cellAttributes: {
            class: 'customtd'
        }
    },
    {
        label: 'Status', fieldName: 'status', sortable: "true"
        ,
        cellAttributes: {
            class: 'customtd'
        }
    },
    {
        label: 'PO Number', fieldName: 'PoNumber', sortable: "true"
        ,
        cellAttributes: {
            class: 'customtd'
        }
    },
    {
        label: 'Source', fieldName: 'OrderSource', sortable: "true"
        ,
        cellAttributes: {
            class: 'customtd'
        }
    },
    {
        label: 'Zimvie Order', fieldName: 'OracleOrderNumber', sortable: "true"
        ,
        cellAttributes: {
            class: 'customtd'
        }
    },
    { label: 'Total', fieldName: 'totalAmount', type: 'currency', cellAttributes: { alignment: 'left', class: 'customtd' },typeAttributes:{currencyCode: { fieldName: 'currencyCode'}} ,sortable: "true" },
];
const recentcols = [
    { label: 'Order Number', fieldName: 'Order_Number' },
    { label: 'Ordered Date', fieldName: 'orderedDate', type: 'date' },
    { label: 'Total', fieldName: 'totalAmount', type: 'currency', cellAttributes: { alignment: 'left' } },
    {
        label: 'View Details', fieldName: 'recordlink', type: 'url', typeAttributes: {
            label: 'View Details',
            target: '_self'
        }
    },
];

export default class B2b_ordersummary extends LightningElement {
    currentPageReference;
    showOrderListView = true;
    _showRecent;
    accId;
    selectedMemberId;
    filterdByMemberData;
    labels = {
        Ordered_Date, Order_Number, START_REORDER, Status, Total, ViewDetailsLabel,
        VIEW_ALL_ORDERS, Orders, Filter_by_date, StartDate, EndDate, APPLY, RESET, Order, Order_Date, PO_Number, Source, Oracle_Order, Recent_Orders
    };
    @api
    set showRecent(val) {
        this._showRecent = val;
        if (val == 'true') {
            this.pagesize = 3;
            this.showViewLink = true;
            this.columns = recentcols;
            this.tableStyle = '';
        }
    }
    get showRecent() {
        return this._showRecent;
    }
    loader = false;
    refselectedId = null;
    @wire(CurrentPageReference)
    setCurrentPageReference(currentPageReference) {
        if (currentPageReference) {
            this.showOrderListView = true;
            this.currentPageReference = currentPageReference;
            let RecordIdFromRef = this.currentPageReference.state.c__recordid;
            if (RecordIdFromRef) {
                this.refselectedId = RecordIdFromRef;
            }
        }
    }
    connectedCallback() {
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';

        const result = contextApi.getSessionContext();

        result.then((response) => {
            console.log('effective account id == ' + response.effectiveAccountId);
            this.accId = response.effectiveAccountId;
            //this.loadOrderSummaries();
        }).catch((error) => {
            console.log("getSessionContext result error");
            console.log(error);
        });
    }

    showViewLink = false;
    pagesize = 20;
    newPageToken = undefined;
    nextPageToken;
    prevPageToken;
    tableData;
    origTableData;
    columns = columns;
    rawTableData;
    filterstartdate = null;
    filterenddate = null;


    
pageSizeOptions = [5, 10, 20, 50, 75, 100]; //Page size options
totalRecords = 0; //Total no.of records
pageSize; //No.of records to be displayed per page
totalPages; //Total no.of pages
pageNumber = 1; //Page number    
recordsToDisplay = []; 
    sortBy;
    sortDirection;
//Pagination code
    get hasMorePages() {
        console.log('this.totalRecords.length='+this.totalRecords);
        console.log('this.pageSize='+this.pageSize);
        return this.totalRecords > this.pageSize;
    }
    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.sortData(this.sortBy, this.sortDirection);
    }

    sortData(fieldname, direction) {
        console.log(fieldname);
        let parseData = JSON.parse(JSON.stringify(this.recordsToDisplay));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            /*if(fieldname == 'totalAmount'){
                x = keyValue(x) ? keyValue(x) : 0; // handling null values
                y = keyValue(y) ? keyValue(y) : 0;
            } else {
                x = keyValue(x) ? keyValue(x) : ''; // handling null values
                y = keyValue(y) ? keyValue(y) : '';
            }*/

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
        this.recordsToDisplay = parseData;
    }



    tableStyle = 'height: 230px;display: block;';

 /*   @wire(OrdersAdapter, {
        fields: ['OriginalOrderId', 'GrandTotalAmount', 'PoNumber', 'Order_Source__c', 'OracleOrderId__c', 'Order_Number__c', 'CreatedById', 'CurrencyIsoCode'],
        pageSize: '$pagesize',
        pageToken: '$newPageToken',
        ownerScoped: false
    })
    wiredobj(result) {
        console.log('received order result==');
        console.log(result);
        if (result.data) {
            this.nextPageToken = result.data.nextPageToken;
            this.prevPageToken = result.data.previousPageToken;
           this.rawTableData = result.data.orderSummaries;
            if (this.rawTableData) {
                this.processData();
            }

        }
    }
 
*/
    @wire(getOrderSummaries, {
        accountId: '$accId',
    })
    orderSummaries(result) {
        console.log('***getOrderSummaries result==');
        console.log(result);
        if (result.data) {
           // this.nextPageToken = result.data.nextPageToken;
            //this.prevPageToken = result.data.previousPageToken;
            this.rawTableData = result.data.orderSummaries;
            if (this.rawTableData) {
                this.processData();
            }

        }
    }
  /*  goPrevious() {
        this.newPageToken = this.prevPageToken;
    }
    gonext() {
        this.newPageToken = this.nextPageToken;
    }
    get isPrevDisabled() {
        return !this.prevPageToken;
    }
    get isNextDisabled() {
        return !this.nextPageToken;
    }*/
    recordsavailable = false;
    processData() {
        let tempArr = [];
        this.rawTableData.forEach(function (currentItem, index) {
            let tempobj = {};
            //tempobj.orderNumber = currentItem.orderNumber;
            //tempobj.orderSummaryId = currentItem.orderSummaryId;
            tempobj.orderedDate = currentItem.OrderedDate;
            tempobj.status = currentItem.Status;
            tempobj.totalAmount = currentItem.GrandTotalAmount;//totalAmount;
            tempobj.PoNumber = currentItem.PoNumber;
            tempobj.OrderSource = currentItem.Order_Source__c;
            tempobj.OracleOrderNumber = currentItem.OracleOrderId__c;
            tempobj.Order_Number = currentItem.Order_Number__c;
            tempobj.recordlink = window.origin + '/Zimvie/OrderSummary/' + currentItem.Id;
            tempobj.recordId = currentItem.Id;
            tempobj.ownerId = currentItem.OwnerId;
            tempobj.orderId = currentItem.OriginalOrderId;
            tempobj.currencyCode = currentItem.CurrencyIsoCode;
            tempArr.push(tempobj);
        });
        console.log('here temparr>>'+JSON.stringify(tempArr));
        this.origTableData = tempArr;
        console.log('here original tabledata>>'+JSON.stringify(this.origTableData));
        this.filterBasedOnSelectedMember();
        this.tableData = this.filterdByMemberData;
        this.recordsavailable = this.tableData?.length > 0 ? true : false;
        this.totalRecords = this.tableData.length; // update total records count                 
        this.pageSize = 20; //set pageSize with default value as first option
        if (this.refselectedId) {
            this.selectedOrderId = this.refselectedId;
            this.showOrderListView = false;
        }

        console.log('tableData=' + JSON.stringify(this.tableData));
        this.sortedColumn = "number";
        this.paginationHelper();
        //this.sortedDirection = 'desc';
        //this.sortRecs();
    }

    handleChangeSelectedMember(event) {
        this.selectedMemberId = event.detail;
        this.filterBasedOnSelectedMember();
        this.searchOrders();
        this.paginationHelper();
    }
    filterBasedOnSelectedMember() {
        this.filterdByMemberData = [];
        if (!this.origTableData) {
            return;
        }
        this.filterdByMemberData = [...this.origTableData];
        console.log('selectedMemberId ', this.selectedMemberId);

        console.log('here filterdByMemberData records>>>' + JSON.stringify(this.filterdByMemberData));
        if (this.selectedMemberId) {

            let temp = this.filterdByMemberData;
            if (this.selectedMemberId !== 'All') {
                let records = [];
                let parentThis = this;
                records = temp.filter(function (el) {
                    let ownerId = el.ownerId;
                    return ownerId == parentThis.selectedMemberId;
                }
                );
                console.log('here new records in filterBasedOnSelectedMember method >>>' + JSON.stringify(records));
                this.filterdByMemberData = [...records];
            }




            console.log('here new state rescords>>>' + JSON.stringify(this.filterdByMemberData));
        }

    }
    handleStartDateSearch(event) {
        //console.log(event);
        console.log(event.target.value);
        //console.log(event.detail.value);
        if (event.target.value) {
            this.filterstartdate = new Date(String(event.target.value));
        } else {
            var pastdt = new Date();
            pastdt.setFullYear(pastdt.getFullYear() - 500);
            this.filterstartdate = pastdt;
        }
        console.log(this.filterstartdate);

    }
    handleEndDateSearch(event) {
        //console.log(event);
        console.log(event.target.value);
        //console.log(event.detail?.value);
        if (event.target.value) {
            this.filterenddate = new Date(String(event.target.value));
        } else {
            var ftrdt = new Date();
            ftrdt.setFullYear(ftrdt.getFullYear() + 500);
            this.filterenddate = ftrdt;
        }
        console.log(this.filterenddate);

    }

    startsearch() {
        if (!this.filterstartdate) {
            let pastDt = new Date();
            pastDt.setFullYear(pastDt.getFullYear() - 500);
            this.filterstartdate = pastDt;
        }
        if (!this.filterenddate) {
            let ftrdt = new Date();
            ftrdt.setFullYear(ftrdt.getFullYear() + 500);
            this.filterenddate = ftrdt;
        }
        this.searchOrders();
        this.paginationHelper();
    }
    searchOrders() {
        if (!this.origTableData) {
            return;
        }
        this.tableData = [...this.filterdByMemberData];
        this.totalRecords = this.tableData.length;
        console.log('here records in search orders method>>>' + JSON.stringify(this.tableData));
        if (this.filterstartdate !== null && this.filterenddate !== null) {
            let temp = this.tableData;
            let records = [];
            let parentThis = this;
            records = temp.filter(function (el) {
                let tmpDate = new Date(el.orderedDate);
                let recDate = new Date(String(tmpDate.getFullYear()) + '-' + String(tmpDate.getMonth()) + '-' + tmpDate.getDate());
                let stdate = new Date(String(parentThis.filterstartdate.getFullYear()) + '-' + String(parentThis.filterstartdate.getMonth()) + '-' + parentThis.filterstartdate.getDate());//parentThis.filterstartdate.toISOString().split('T')[0];
                let endate = new Date(String(parentThis.filterenddate.getFullYear()) + '-' + String(parentThis.filterenddate.getMonth()) + '-' + parentThis.filterenddate.getDate());//parentThis.filterenddate.toISOString().split('T')[0];
                console.log(recDate);
                console.log(stdate);
                console.log(endate);
                return recDate <= endate && recDate >= stdate;
            }
            );

            console.log('here new rescords>>>' + JSON.stringify(records));
            this.tableData = [...records];
            this.recordsavailable = this.tableData?.length > 0 ? true : false;
            this.totalRecords = this.tableData.length; // update total records count                 
            this.pageSize = 20;
            console.log('here new state rescords>>>' + JSON.stringify(this.tableData));
        }

        //}
        //else{
        //    this.tableData = [...this.origTableData];
        //}
    }
    clearFilter() {
        this.template.querySelector(`[data-id="startdate"]`).value = null;
        this.template.querySelector(`[data-id="enddate"]`).value = null;
        this.filterstartdate = null;
        this.filterenddate = null;
        this.startsearch();
        this.paginationHelper();
    }
    navigatetoView() {
        window.location = window.origin + '/Zimvie/accountmanagement?c__page=order';
    }
    startOrder(event) {
        this.loader = true;
        startReOrder({ orderSummaryId: event.target.dataset.id, cartStateOrId: 'active' }).then((fulfilled) => {
            //console.log("added product to cart" ,fulfilled);
            refreshCartSummary();
            this.loader = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'Your cart has been updated.',
                    variant: 'success',
                    mode: 'dismissable'
                })
            );

        }).catch(error => {
            console.log('error', error);
            /*this.showLoader = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message:
                        '{0} could not be added to your cart at this time. Please try again later.',
                    messageData: [this.displayableProduct.name],
                    variant: 'error',
                    mode: 'dismissable'
                })
            );*/
        });
    }
    navigateToOrderSummary(event) {
        window.location = window.origin + '/Zimvie/accountmanagement?c__page=order&c__recordid=' + event.target.dataset.id;
        //window.location = event.target.dataset.link;
    }

    /*showOrderDetailView(){
        let targetId = event.target.dataset.targetId;
        this.selectedOrderId = targetId;
        this.showOrderListView = false;
    }*/
    showOrderDetailView(event) {
        const recId = event.detail.row.recordId;
        console.log('recId: ', recId);
        this.selectedOrderId = recId;
        this.showOrderListView = false;
    }
    hideOrderDetailView() {
        this.showOrderListView = true;
        window.location = window.origin + '/Zimvie/accountmanagement?c__page=order';
    }

    handlePreviousPage(evt) {
        evt.stopPropagation();

        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    handleNextPage(evt) {
        evt.stopPropagation();

        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }

    handlePageSelect(evt) {
        evt.stopPropagation();
        this.pageNumber = evt.detail;
        this.paginationHelper();
    }

    // JS function to handel pagination logic 
    paginationHelper() {
        this.recordsToDisplay = [];
         // calculate total pages
        this.totalPages = Math.ceil(this.tableData.length / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.tableData.length) {
                break;
            }
            this.recordsToDisplay.push(this.tableData[i]);
            console.log('here records to display in pagination helper>>'+JSON.stringify(this.recordsToDisplay));
            this.totalRecords = this.tableData.length;
        }
      
    }
   
}