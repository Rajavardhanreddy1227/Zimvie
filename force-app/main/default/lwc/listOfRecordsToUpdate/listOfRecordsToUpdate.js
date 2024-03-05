import { LightningElement, api, wire,  track } from 'lwc';
import loadRecords from '@salesforce/apex/listOfRecordsToUpdateController.loadRecords';
import processPayment from '@salesforce/apex/listOfRecordsToUpdateController.processPayment';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ToastContainer from 'lightning/toastContainer';
import Customersupport from '@salesforce/label/c.Customer_support';
import Invoices from '@salesforce/label/c.Invoices';
import No_Invoive from '@salesforce/label/c.No_Invoive';
import apply_credits from '@salesforce/label/c.apply_credits';
import Total_Records from '@salesforce/label/c.Total_Records';
import Page_s from '@salesforce/label/c.Page_s';
import Invoice_number from '@salesforce/label/c.Invoice_number';
import Sequence from '@salesforce/label/c.Sequence';
import contact_for_credits from '@salesforce/label/c.contact_for_credits';
import DueDate from '@salesforce/label/c.DueDate';
import Transaction_Date from '@salesforce/label/c.Transaction_Date';
import Status from '@salesforce/label/c.Status';
import Class from '@salesforce/label/c.Class';
import Days_Late from '@salesforce/label/c.Days_Late';
import Original from '@salesforce/label/c.Original';
import Balance_Due from '@salesforce/label/c.Balance_Due';
import PO_Number from '@salesforce/label/c.PO_Number';
import Term from '@salesforce/label/c.Term';
import StartDate from '@salesforce/label/c.StartDate';
import EndDate from '@salesforce/label/c.EndDate';
import APPLY from '@salesforce/label/c.APPLY';
import RESET from '@salesforce/label/c.RESET';
import Show_Open_Invoices from '@salesforce/label/c.Show_Open_Invoices';
import B2B_Loading_Message from '@salesforce/label/c.B2B_Loading_Message';
import B2BInvoice_INV_TOTAL from '@salesforce/label/c.B2BInvoice_INV_TOTAL';
import B2BInvoice_CancelAndClose from '@salesforce/label/c.B2BInvoice_CancelAndClose';
import B2BInvoice_TotalAmountToPay from '@salesforce/label/c.B2BInvoice_TotalAmountToPay';
import cancelButton from '@salesforce/label/c.Cancel_Button';
import B2BInvoice_Next from '@salesforce/label/c.B2BInvoice_Next';
import B2B_Back_Btn from '@salesforce/label/c.B2B_Back_Btn';
import B2B_Submit_Payment from '@salesforce/label/c.B2B_Submit_Payment';



const paymentScreenColumns =  [
    { label: 'Invoice Number', fieldName: 'Name' },
    { label: 'Due Date', fieldName: 'Due_Date__c', type: 'date' },
    { label: 'Related To Account', fieldName: 'RelatedAcc' },
    { label: 'Balance', fieldName: 'Balance__c', type: 'currency' },
];
export default class ListOfRecordsToUpdate extends LightningElement {
    labels={
        Customersupport,
        Invoices,
        No_Invoive,
        apply_credits,
        contact_for_credits,
        Total_Records,
        Page_s,
        Invoice_number,
        Sequence,
        DueDate,
        Transaction_Date,
        Status,
        Class,
        Days_Late,
        Original,
        Balance_Due,
        PO_Number,
        Term,
        StartDate,
        EndDate,
        APPLY,
        RESET,
        Show_Open_Invoices,
        B2BInvoice_INV_TOTAL,
        B2BInvoice_CancelAndClose,
        B2BInvoice_TotalAmountToPay,
        cancelButton,
        B2BInvoice_Next,
        B2B_Back_Btn,
        B2B_Submit_Payment

    };
@api objectApiName;
@api fieldsName;
@api actionName; 
@track checkedId = [];
@api showExportButton;
@api exportButtonName;
showopeninvoice = true;
customLoader = false;
messageState = B2B_Loading_Message;
isPaymentScreen;
isNewCardScreen;
selectedRecords = [];
selectedRows=[];
selectedIds=[];
totalAmountToPay;
paymentScreenColumns = paymentScreenColumns;
_accid;
isPaymentScreenBtnShow=false;
adjInvoiceNumber;
showAdjPopup=false;
paymentToken; 
isDetailView = false;
selectedInvoice = ''

@track
saveCardFromWallet = true;
@track
randerForm = false;
@track
hideWallets = false;

@track
receiptId;

filterStartDate;
filterEndDate;
errorMsg = '';
 get isDateError(){
         let isDateError = false;
        if( this.filterEndDate < this.filterStartDate){
           this.errorMsg = 'End date should ahead of Start Date';
           isDateError = true;
        }
        return isDateError;
    }

@api 
set accid(val){
    console.log('accid in list lwc is '+val);
    this._accid = val;
}
get accid(){
    return this._accid;
}

_DataTableColumnResponse

@api 
set DataTableColumnResponse(val){
    console.log('val=='+val);
    this._DataTableColumnResponse = val;
}
get DataTableColumnResponse(){
    return this._DataTableColumnResponse;
}


pageSizeOptions = [20, 10, 25, 50, 75, 100]; //Page size options
records = []; //All records available in the data table
totalRecords = 0; //Total no.of records
pageSize; //No.of records to be displayed per page
totalPages; //Total no.of pages
pageNumber = 1; //Page number    
recordsToDisplay = []; //Records to be displayed on the page
searchedRecords = []; // searched result of records
 
@track sortBy;
@track sortDirection;

 connectedCallback() {
    this.customLoader = true;

        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';
    }
@wire(loadRecords, {objectApiName:'$objectApiName', fieldsName:'$fieldsName', accid:'$accid'})
 
    loadRecords({ error, data }) 
    {
       console.log('load records completed :: ');
       console.log(data);
        if(data) 
        {
            
            console.log('inv records');
            console.log(data);
            let records = JSON.parse(data);
            //this.DataTableColumnResponse = data.lstDataTableColumns;
            this.records = records; // all records

            let tempRecords = JSON.parse( JSON.stringify( records ) );
            console.log('temp records>>'+ JSON.stringify(tempRecords));
            
            
            tempRecords = tempRecords.map( row => {
                return { ...row,
                         RelatedAcc: row.invoice.Related_To_Account__r.Name,
                         RelatedCon: row.invoice.Bill_To_Contact__r != null ? row.invoice.Bill_To_Contact__r.Name : '',
                         Name: row.invoice.Name,
                         Id: row.invoice.Id,
                         Status__c: row.invoice.Status__c,
                         Total_Tax__c: row.invoice.Total_Tax__c,
                         Total_Amount_With_Tax__c: row.invoice.Total_Amount_With_Tax__c,
                         Type__c: row.invoice.Type__c,
                         Balance__c: row.invoice.Balance__c,
                         Terms__c: row.invoice.Terms__c,
                         Days_Late__c: row.invoice.Days_Late__c,
                         Original__c: row.invoice.Original__c,
                         Sequence__c: row.invoice.Sequence__c,
                         PO_Number__c: row.invoice.PO_Number__c,
                         Due_Date__c: row.invoice.Due_Date__c,
                         Invoice_Date__c: row.invoice.Invoice_Date__c,};
            })
            this.searchedRecords = this.records= [...tempRecords];
            //this.sortBy = 'Due_Date__c';
            this.sortBy = 'Invoice_Date__c';
            this.sortDirection = 'desc';
            this.searchedRecords = this.sortData(this.sortBy, this.sortDirection, this.searchedRecords);
            if(this.showopeninvoice){
                this.showOpenInvoices(this.searchedRecords);
            }
            for(let i=0;i<this.searchedRecords.length;i++){
                let rec = this.searchedRecords[i];
                rec.index = i+1;
                rec.showAdjustmentBtn = false;
                //rec.disabled = this.searchedRecords[i].Type__c == 'Invoice' && this.searchedRecords[i].Status__c == 'Open' && this.searchedRecords[i].Balance__c > 0 ? false : true;
                if(this.searchedRecords[i].invoice?.Number_of_Installments__c != undefined){
                    rec.disabled = this.searchedRecords[i].Type__c == 'Invoice' && this.searchedRecords[i].Status__c == 'Open' && this.searchedRecords[i].Balance__c > 0 && this.searchedRecords[i].invoice.Number_of_Installments__c == 1 ? false : true;
                }else{
                    rec.disabled = this.searchedRecords[i].Type__c == 'Invoice' && this.searchedRecords[i].Status__c == 'Open' && this.searchedRecords[i].Balance__c > 0 ? false : true;
                }
                rec.showAdjustmentBtn = this.searchedRecords[i].Type__c == 'Credit' ? true : false;
                rec.isCreditOpen = this.searchedRecords[i].Type__c == 'Credit' && this.searchedRecords[i].Status__c == 'Open' ? true : false;
                this.searchedRecords[i] = rec;
            }
            console.log('temp records after>>'+ JSON.stringify(this.searchedRecords));
            //this.searchedRecords = records; // all searched records
            this.totalRecords = records.length; // update total records count                 
            this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
            this.paginationHelper(); // call helper menthod to update pagination logic 
            this.customLoader = false;
        } 
        else if (error) 
        {
            console.log(error);
            this.error = error;
            this.customLoader = false;
        }
    }

    
     handleApplyFilter(){
           // let filteredInvoices = [];
        console.log('this.searchedRecords ',this.searchedRecords);
            if(  this.searchedRecords !== undefined && this.filterStartDate !== undefined && this.filterEndDate !== undefined ){
        
                this.searchedRecords  =  this.searchedRecords.filter(x =>{
                     console.log('this.x ',x);
                return (x.Due_Date__c <= this.filterEndDate || this.filterEndDate === null) && ( x.Due_Date__c >= this.filterStartDate || this.filterStartDate === null )});
        
            }
          //  this.searchedRecords = [...filteredInvoices];
            console.log('this.searchedRecordsAfterFilter ',this.searchedRecords);
            this.paginationHelper();
        }  

        handleResetFilter(){
            this.searchedRecords = [...this.records];
            this.filterStartDate = this.filterEndDate = null;
            this.paginationHelper();
        }
        handleChangeStartDate(event){
            this.filterStartDate = event.detail.value;
            console.log('filterStartDate '+ this.filterStartDate);
        }

        handleChangeEndDate(event){
            this.filterEndDate = event.detail.value;
            console.log('filterEndDate '+ this.filterEndDate);
        }
      handleSearch(event) {
        const searchKey = event.target.value.toLowerCase();
 
        if (searchKey) {
            if (this.records) {
                let searchedRec = [];
 
                for (let record of this.records) {
                    let valuesArray = Object.values(record);
 
                    for (let val of valuesArray) {
                        //console.log('val is ' + val);
                        let strVal = String(val);
 
                        if (strVal) {
 
                            if (strVal.toLowerCase().includes(searchKey)) {
                                searchedRec.push(record);
                                break;
                            }
                        }
                    }
                }
                //console.log('Matched Accounts are ' + JSON.stringify(searchedRec));
                this.searchedRecords = searchedRec;
                this.paginationHelper();
            }
        } else {
            this.searchedRecords = this.records;
            this.paginationHelper();
        }
    }

    handleCheck(event){
        this.selectedRecords=[];
        this.selectedRows=[];

        event.detail.selectedRows.forEach(row=>{
            if(row.Type__c == 'Invoice' && row.Status__c == 'Open'){ //Condition allow checkbox to select 
                this.selectedRows=[...this.selectedRows, row.Id];
                this.selectedRecords.push(row);
            }
        });
    console.log('selectedRows ',this.selectedRows);
    console.log('selectedRecords ',this.selectedRecords);

/*
     this.checkedId = [];
     const selectedRows = event.detail.selectedRows;
     
     for (let i = 0; i < selectedRows.length; i++) {
          this.checkedId.push(selectedRows[i].Id);
        }*/
    }
    handleClick(event){
       // let paramData = this.checkedId;
       
       this.selectedRows=[];
       this.selectedRecords=[];
        if(this.selectedIds.length > 0){
            this.isPaymentScreen = true;
            for(var i=0;i<this.selectedIds.length;i++){
                let row = this.searchedRecords.filter(rec => rec.Id == this.selectedIds[i]);
                this.selectedRows.push(row[0]);
                this.selectedRecords.push(row[0]);
            }
        }
        console.log('here selected rows>>'+JSON.stringify(this.selectedRows));
        //Calculate total
       // this.selectedRecords = this.template.querySelector("lightning-datatable").getSelectedRows();
        this.totalAmountToPay = this.calculateTotal();

      /*  let ev = new CustomEvent('actionclicked', 
                                 {
                                     detail : { data: paramData  } 
                                 }
                                );
        this.dispatchEvent(ev);  */
    }

    handleInvoiceSelection(event){
        this.selectedIds = [];
        this.isPaymentScreenBtnShow = false;
        let allCheckBox = this.template.querySelectorAll(`[data-id="checkbox"]`);
        console.log('here all checkbox value');
        console.log(allCheckBox);
        
        for (var i=0;i<allCheckBox.length;i++) {
            if (allCheckBox[i].checked) {
                this.selectedIds.push(allCheckBox[i].name);
            }
        }
        console.log('here selectedIds>>>'+this.selectedIds);
        if(this.selectedIds.length>0){
            this.isPaymentScreenBtnShow = true;
        }
       

    }
calculateTotal(){
    console.log('selected records ', this.selectedRecords);
    var total = 0;
         for (var i = 0; i < this.selectedRecords.length; i++) {
              total = total + this.selectedRecords[i].invoice.Balance__c;
            }
    total = parseFloat(total.toFixed(2));
    return total;
}

    doSorting(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        this.searchedRecords = this.sortData(this.sortBy, this.sortDirection, this.searchedRecords);
        this.paginationHelper();
    }

    sortData(fieldname, direction, data) {
        let parseData = JSON.parse(JSON.stringify(data));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1: -1;
        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        return parseData;
    } 
    
    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
    }
    nexthandlecancel(event){
        this.isPaymentScreen = false;
    }
    handleNextClick() { 
        this.isPaymentScreen = false;
        this.isNewCardScreen = true;
        this.randerForm = false;
    }

   /* handlePaymentClick() {

        // console.log('selectedRecords ', this.selectedRecords);
        // var invoiceList = [];
        // this.selectedRecords.forEach(ele=>{
        //     invoiceList.push(ele.Id);
        // });
        // let dataMap ={};
        // dataMap.selectedInvoices = invoiceList;
        // dataMap.receiptAmount = this.totalAmountToPay;
        // dataMap.paymentToken = this.paymentToken;
        // processPayment({dataMap: dataMap})
        // .then(response=>{
        //     console.log('response ', response);
        //     if(response.isSuccess){
        //         alert('Paid Successfully');
        //     }

        // })
        // .catch(error=>{
        //     console.log(' error', error);

        // });
    }*/

    handleBackForm() {
        this.isNewCardScreen = false;
        this.isPaymentScreen = true;
    }

    handleSuccess() {
        alert('Paid Successfully');
    }

    handleRecordsPerPage(event) {
        this.pageSize = event.target.value;
        this.paginationHelper();
    }
    previousPage() {
        this.pageNumber = this.pageNumber - 1;
        this.paginationHelper();
    }
    nextPage() {
        this.pageNumber = this.pageNumber + 1;
        this.paginationHelper();
    }
    firstPage() {
        this.pageNumber = 1;
        this.paginationHelper();
    }
    lastPage() {
        this.pageNumber = this.totalPages;
        this.paginationHelper();
    }

    // JS function to handel pagination logic 
    paginationHelper() {
        this.recordsToDisplay = [];
         // calculate total pages
        this.totalPages = Math.ceil(this.searchedRecords.length / this.pageSize);
        // set page number 
        if (this.pageNumber <= 1) {
            this.pageNumber = 1;
        } else if (this.pageNumber >= this.totalPages) {
            this.pageNumber = this.totalPages;
        }
        // set records to display on current page 
        for (let i = (this.pageNumber - 1) * this.pageSize; i < this.pageNumber * this.pageSize; i++) {
            if (i === this.searchedRecords.length) {
                break;
            }
            this.recordsToDisplay.push(this.searchedRecords[i]);
            console.log('here records to display>>'+JSON.stringify(this.recordsToDisplay));
            this.totalRecords = this.searchedRecords.length;
        }
      
    }


    handleExport() {
        var selectedRecords =  this.template.querySelector("lightning-datatable").getSelectedRows();
        var array;
        if(selectedRecords.length > 0){
            console.log('selectedRecords are ');            
            console.log(selectedRecords);
            // var jsonObject = JSON.stringify(selectedRecords);
            // console.log('Json Object Data',jsonObject);
            // const csvContent = this.ConvertToCSV(jsonObject);
             console.log('JcsvContent',selectedRecords);
    //          const removeAtt = ['attributes', 'Related_To_Account__r', 'Bill_To_Contact__r','Related_To_Account__c','Bill_To_Contact__c','Id'];
    //          array= typeof selectedRecords != 'object' ? JSON.parse(selectedRecords) : selectedRecords;
    //         array.forEach(element => {
    //         removeAtt.forEach(e=> {
    //         delete element[e];
    //    });
    // });
        const csvContent = this.ConvertToCSV(selectedRecords);
        this.downloadCSV(csvContent);
        }  else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'warning!',
                    message: 'Please select rows to export',
                    variant: 'warning'
                })
            )
          //  alert('Please select rows to export.');
        }
        //const table = this.template.querySelector('lightning-datatable');
        //const csvContent = this.convertTableToCSV(table);

        //this.downloadCSV(csvContent);
    }
ConvertToCSV(objArray) {
	const removeAtt = ['attributes', 'Related_To_Account__r', 'Bill_To_Contact__r', 'Id', 'Related_To_Account__c', 'Bill_To_Contact__c'];
	const rename = [{
			key: 'Name',
			value: 'Invoice Number'
		}, {
			key: 'Invoice_Date__c',
			value: 'Invoice Date'
		},

		{
			key: 'Due_Date__c',
			value: 'Due Date'
		}, {
			key: 'Description__c',
			value: 'Description'
		}, {
			key: 'Total_Tax__c',
			value: 'Total Tax'
		},

		{
			key: 'Total_Amount_With_Tax__c',
			value: 'Total Amount With Tax'
		}, {
			key: 'RelatedAcc',
			value: 'Related Account'
		}, {
			key: 'RelatedCon',
			value: 'Related Contact'
		}
	];

	var array = typeof objArray != 'object' ? JSON.parse(objArray) : objArray;
	array.forEach(element => {
		removeAtt.forEach(e => {
			delete element[e];
		});
	});
    console.log(array);
    var json = array;
	let keySizes = [];
	json.forEach(j => {
		keySizes.push(Object.keys(j).length);
	});
	let index = 0;
	let lagest = 0;;
	for (var i = 0; i < keySizes.length; i++) {
		if (keySizes[i] > lagest) {
			lagest = keySizes[i];
    		index = i;
		}
	}
	var fields = Object.keys(json[index])
	var replacer = function(value) {
		return value === null ? '' : value
	}
	var csv = json.map(function(row) {
		return fields.map(function(fieldName) {
			//return JSON.stringify(row[fieldName], replacer)
			return replacer(row[fieldName]);
		}).join(',')
	})
	console.log(fields);
	var newFields = [];
	fields.forEach(f => {
		rename.forEach(r => {
			if (f === r.key) {
				console.log('value: ', r.value);
				newFields.push(r.value);
			}
		});
	});

	console.log(newFields);
	csv.unshift(newFields.join(',')) // add header column
	csv = csv.join('\r\n');
	console.log(csv);
	return csv;



}
Collapse

//  ConvertToCSV(objArray) {
     
//             var array = typeof objArray != 'object' ? JSON.parse(objArray) : objArray;
//             var str = 'Invoice Number,Invoice Date,Due Date,Description,Total Tax,Total Amount,Related To Account,Related To Contact\n';

//             for (var i = 0; i < array.length; i++) {
//                 var line = '';
//                 for (var index in array[i]) {
//                     if (line != '') line += ','

//                     line += array[i][index];
//                 }

//                 str += line + '\r\n';
//             }

//             return str;
//         }
    convertTableToCSV(table) {
        let csvContent = '';

        const rows = table.rows;
        for (let i = 0; i < rows.length; i++) {
            const cells = rows[i].cells;
            for (let j = 0; j < cells.length; j++) {
            const cell = cells[j];
            const text = cell.innerText.replace(/"/g, '""'); // Handle double quotes
            const formattedValue = /^\d+\/\d+$/.test(text) ? ` ${text}` : text; // Add equals sign for number fields

            csvContent += `"${formattedValue}",`;
            }
            csvContent += '\n';
        }

        return csvContent;
    }


    downloadCSV(csvContent) {
        const element = document.createElement('a');
        element.href = 'data:text/csv;charset=utf-8,' + encodeURIComponent(csvContent);
        element.download = 'Invoices_details.csv';
        element.style.display = 'none';
        document.body.appendChild(element);
        element.click();
        document.body.removeChild(element);
    }

    handletoggle(event){
        console.log('here toogle>>>'+this.showopeninvoice);
        console.log(event);
        console.log(event.target.checked);
        this.showopeninvoice = event.target.checked;
        console.log('here records>>>'+JSON.stringify(this.searchedRecords));
        if(this.showopeninvoice){
            this.showOpenInvoices(this.searchedRecords);
        }else{
            this.searchedRecords = [...this.records];
        }
        this.sortBy = 'Due_Date__c';
        this.sortDirection = 'asc';
        this.searchedRecords = this.sortData(this.sortBy, this.sortDirection, this.searchedRecords);
        for(let i=0;i<this.searchedRecords.length;i++){
            let rec = this.searchedRecords[i];
            rec.index = i+1;
            rec.showAdjustmentBtn = false;
            //rec.disabled = this.searchedRecords[i].Type__c == 'Invoice' && this.searchedRecords[i].Status__c == 'Open' && this.searchedRecords[i].Balance__c > 0 ? false : true;
            if(this.searchedRecords[i].invoice?.Number_of_Installments__c != undefined){
                rec.disabled = this.searchedRecords[i].Type__c == 'Invoice' && this.searchedRecords[i].Status__c == 'Open' && this.searchedRecords[i].Balance__c > 0 && this.searchedRecords[i].invoice.Number_of_Installments__c == 1 ? false : true;
            }else{
                rec.disabled = this.searchedRecords[i].Type__c == 'Invoice' && this.searchedRecords[i].Status__c == 'Open' && this.searchedRecords[i].Balance__c > 0 ? false : true;
            }
            rec.showAdjustmentBtn = this.searchedRecords[i].Type__c == 'Credit' ? true : false;
            rec.isCreditOpen = this.searchedRecords[i].Type__c == 'Credit' && this.searchedRecords[i].Status__c == 'Open' ? true : false;
            this.searchedRecords[i] = rec;
        }
        /*for(let i=0;i<this.searchedRecords.length;i++){
            let rec = this.searchedRecords[i];
            rec.index = i+1;
            rec.showAdjustmentBtn = this.searchedRecords[i].Type__c == 'Credit' ? true : false;
            rec.isCreditOpen = this.searchedRecords[i].Type__c == 'Credit' && this.searchedRecords[i].Status__c == 'Open' ? true : false;
            rec.disabled = this.searchedRecords[i].Type__c == 'Invoice' && this.searchedRecords[i].Status__c == 'Open' ? false : true;
            this.searchedRecords[i] = rec;
        }*/
        this.paginationHelper();
    }

    showOpenInvoices(records){
        this.searchedRecords  =  records.filter(x =>{
            console.log('this.x ',x);
       return (x.Status__c == 'Open' && x.Type__c == 'Invoice')});
       /* function compare( a, b) {
            if(a.Status__c == 'Pending' && a.Type__c == 'Invoice'){
               return -1;
              }
            if(a.Status__c == 'Pending'){
                return 1;
            }
                return 0;
        }
        records.sort( compare );*/
    }

    handleCreateAdjustment(event){
        console.log('handleCreateAdjustment btn inside'+this.showAdjPopup);
        this.showAdjPopup = true;

    }

    handleAdjustmentSubmitBtn(event){
        
        console.log('inside handleAdjustmentSubmitBtn'+this.adjInvoiceNumber);

    }

    handleAdjInput(event){
        console.log('inside handleAdjInput'+event.detail.value);
        console.log(event);
        this.adjInvoiceNumber = event.detail.value;
    }

    closeModal(){
        this.adjInvoiceNumber = '';
        this.showAdjPopup = false;
    }

    //Pagination code
    get hasMorePages() {
        console.log('this.recordsToDisplay.length='+this.recordsToDisplay.length);
        console.log('this.pageSize='+this.pageSize);
        return this.totalRecords > this.pageSize;
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

    handleCardRadioSelection(event){
        this.hideWallets = event.detail.hideWallets;
        this.randerForm = event.detail.randerForm;
        this.saveCardFromWallet = true;
    }

    handlePayClickP() {
         console.log('selectedRecords ', this.selectedRecords);
         var invoiceList = [];
         this.selectedRecords.forEach(ele=>{
             invoiceList.push(ele.Id);
         });
         let dataMap ={};
         dataMap.selectedInvoices = invoiceList;
         dataMap.receiptAmount = this.totalAmountToPay;
         dataMap.paymentToken = this.paymentToken;
        processPayment({dataMap: dataMap})
         .then(response=>{
             console.log('response ', response);
             if(response.isSuccess){
                 console.log('Receipt created Successfully');
                 this.receiptId = response.receiptId;
                 console.log('Receipt Id=> ',response.receiptId);
                if(this.receiptId){
                    this.template.querySelector("c-b2-b_-cyber-source-invoice-form").handlePayClick(this.receiptId);
                    //this.template.querySelector("c-b2-b_-cyber-source-invoice-form").handlePayClickStoredAlso(this.receiptId);
                }
             }
        
         })
         .catch(error=>{
             console.log(' error', error);

         });
    }

    showInvoiceDetails(event){
        console.log('here inside showInvoiceDetails');
        console.log(event);
        console.log('values>>>'+event.target.dataset.value);
        this.selectedInvoice = event.target.dataset.value;
        this.isDetailView = true;
    }

    backtoallinvoice(){
        this.isDetailView = false;
        window.location = window.origin + '/Zimvie/accountmanagement?c__page=invoice';
    }
}