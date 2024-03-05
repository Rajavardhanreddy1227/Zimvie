import { LightningElement, api, wire,  track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import loadRecords from '@salesforce/apex/Zimvie_recordlistController.loadRecords';
//import { gql, graphql } from 'lightning/uiGraphQLApi';
import SELECTFILTERS from '@salesforce/label/c.SELECTFILTERS';
import TotalRecords from '@salesforce/label/c.TotalRecords';
import Showing from '@salesforce/label/c.Showing';
import picklist from '@salesforce/label/c.picklist';
import date from '@salesforce/label/c.date';

export default class Zimvie_recordlist extends LightningElement {
    labels={
        SELECTFILTERS,
        TotalRecords,
        Showing,
        picklist,
        date
    }
@api objectApiName;
@api fieldsName;
@api actionName;
@track checkedId = [];
@track DataTableColumnResponse;
pageSizeOptions = [5, 10, 25, 50, 75, 100]; //Page size options
records = []; //All records available in the data table
totalRecords = 0; //Total no.of records
pageSize; //No.of records to be displayed per page
totalPages; //Total no.of pages
pageNumber = 1; //Page number    
recordsToDisplay = []; //Records to be displayed on the page
searchedRecords = []; // searched result of records

@api filterfield1;
@api filterfield2;
isfirstfilterpicklist;
is2ndfilterpicklist;

@wire(getObjectInfo, { objectApiName: '$objectApiName' })
    recvdObject({error, data}){
        if(data){
            //console.log(data);
            const field1 = data.fields[this.filterfield1];
            //console.log('field1.dataType='+field1.dataType);
            this.isfirstfilterpicklist = field1.dataType == 'Picklist' ? true : false;

            const field2 = data.fields[this.filterfield2];
            //console.log('field2.dataType='+field2.dataType);
            this.is2ndfilterpicklist = field2.dataType == 'Picklist' ? true : false;
        }else{
            console.log(error);
        }
    }

/*@wire(graphql, {
        query: gql`
          query AccountWithName {
            uiapi {
                query {
                    Account (first: 10) @category(name: "recordQuery") {
                        edges {
                            node {
                                Id
                                Name @category(name: "StringValue") { 
                                    value
                                }
                            }
                        }
                    }
                }
            }
        }`
    })
    graphqlQueryResult({ data, errors }) {
        if (data) {
            console.log('graphQl results :: == :: ');
            console.log(data.uiapi.query.Account.edges.map(edge => edge.node));
        }
        this.errors = errors;
    }*/
@wire(loadRecords, {objectApiName:'$objectApiName', fieldsName:'$fieldsName'})
    loadRecords({ error, data }) 
    {
        if(data) 
        {
            this.DataTableColumnResponse = data.lstDataTableColumns;
            this.records = data.lstDataTableData; // all records
            this.searchedRecords = data.lstDataTableData; // all searched records
            this.totalRecords = data.lstDataTableData.length; // update total records count                 
            this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
            this.paginationHelper(); // call helper menthod to update pagination logic 
        } 
        else if (error) 
        {
            this.error = error;
        }
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
     this.checkedId = [];
     const selectedRows = event.detail.selectedRows;
     for (let i = 0; i < selectedRows.length; i++) {
          this.checkedId.push(selectedRows[i].Id);
        }
    }
    handleClick(event){
        let paramData = this.checkedId;
        let ev = new CustomEvent('actionclicked', 
                                 {
                                     detail : { data: paramData  } 
                                 }
                                );
        this.dispatchEvent(ev);  
    }

    get bDisableFirst() {
        return this.pageNumber == 1;
    }
    get bDisableLast() {
        return this.pageNumber == this.totalPages;
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
            this.totalRecords = this.searchedRecords.length;
        }
      
    }


}