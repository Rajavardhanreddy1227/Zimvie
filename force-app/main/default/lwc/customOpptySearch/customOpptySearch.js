import { LightningElement, api, wire, track } from 'lwc';  
import serachOppts from '@salesforce/apex/MobileOpptyFilterController.searchOpportunities';
import getUSOrthoRecordTypeIds from '@salesforce/apex/MobileOpptyFilterController.getUSOrthoRecordTypeIds';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import OPPORTUNITY_OBJECT from '@salesforce/schema/Opportunity';
import PRODUCT_GROUP from '@salesforce/schema/Opportunity.Product_Group__c';
import COMPETITOR from '@salesforce/schema/Opportunity.Competitor__c';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'
import { CurrentPageReference } from 'lightning/navigation';

const actions = [
    { label: 'Show details', name: 'show_details' },
    { label: 'Delete', name: 'delete' },
];

const COLS = [
    {label: 'Id', fieldName: 'Id', type: 'text'},
    {label: 'Name', fieldName: 'Name', type: 'text'},
    {label: 'Assigned Team', fieldName: 'Team', type: 'text'},
    {label: 'Owner', fieldName: 'OwnerName', type: 'text'},
    {label: 'Surgeon', fieldName: 'SurgeonName', type: 'text'},
    {label: 'Name', fieldName: 'NameUrl', type: 'url', typeAttributes: { label:{fieldName: 'Name'}, target: '_blank'}, sortable: true},
    {label: 'Desciption', fieldName: 'Desc', type: 'text', sortable: true},
    {
        type: 'action',
        typeAttributes: { rowActions: actions, menuAlignment: 'left' },
    },
];


 export default class customOpptySearch extends NavigationMixin(LightningElement) {  
    cols=COLS;
    data = [];
    @api propertyValue;
   @track accountName; 
   @track record;
   @track accountRecordId;
   @track surgeonName;
   @track surgeonRecordId;
   @track ownerId;
   @track teamId;
   @track productGrpId;
   @track competitorId;
   @track searchData;
   @api recordId;
   
   @track productGroupList;
   @track competitorList;
   @track error;
   @track wirePickListValues;
   @track plValues;
   @track noRecordsFound = true;

   cbBPTarget = false;
   cbDriveAndDefend = false;

   handleViewOppty(event) {
    const selectedRecordId = event.target.name;
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: selectedRecordId,
                objectApiName: 'Opportunity', // objectApiName is optional
                actionName: 'view'
            }
        });
   }
   
   handleRowAction(event) {
    console.log('In handleRowAction');
    console.log(event.detail);
    rowId = event.target.dataset.id;
    console.log(rowId);
    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            //recordId: event.detail.id,
            recordId: rowId,
            objectApiName: 'Opportunity',
            actionName: 'view'
        },
    });
}

getSelectedName(event) {
    const selectedRows = event.detail.selectedRows;
    // Display that fieldName of the selected rows
    for (let i = 0; i < selectedRows.length; i++){
        console.log("You selected: " + selectedRows[i].Name);
    }

    this[NavigationMixin.Navigate]({
        type: 'standard__recordPage',
        attributes: {
            //recordId: event.detail.id,
            recordId: selectedRows[0].id,
            objectApiName: 'Opportunity',
            actionName: 'view'
        },
    });
}
    handleBPTargetCB(event) {
        this.cbBPTarget = event.target.checked;
    }

    handleDriveAndDefendCB(event) {
        this.cbDriveAndDefend = event.target.checked;
    }

   onAccountSelection(event){  
    this.accountName = event.detail.selectedValue;  
    this.accountRecordId = event.detail.selectedRecordId;  
   }

   onSurgeonSelection(event){  
    this.surgeonName = event.detail.selectedValue;  
    this.surgeonRecordId = event.detail.selectedRecordId;  
   }

   onOwnerSelection(event){  
    this.ownerId = event.detail.selectedRecordId;  
   }

   onProdGrpSelection(event){       
    this.productGrpId = '"'+ event.detail.value+'"';
    console.log('Product Group is: '+this.productGrpId);
   }

   onMultiProdGrpSelection(event) {
    this.productGrpId = JSON.stringify(event.detail);
   }

   onTeamSelection(event){      
    this.teamId= event.detail.selectedRecordId;  
   }

   onCompetitorSelection(event){       
    this.competitorId = '"'+ event.detail.value+'"';
    console.log('Product Group is: '+this.competitorId);
   }

   onMultiCompetitorSelection(event) {
    this.competitorId = JSON.stringify(event.detail);
    console.log('Product Group is: '+this.competitorId);
   }


   @wire(getObjectInfo, { objectApiName: OPPORTUNITY_OBJECT })
   opptyMetadata;
   
  
   //Fetch PickList Values for Product Group
   @wire(getPicklistValues, {
       recordTypeId : '$opptyMetadata.data.defaultRecordTypeId',
       fieldApiName : PRODUCT_GROUP
   }
    )
   wirePickListValues( {data, error}) {
    let recTypeList = [];
    let usOrthoRecIds = ['0123b000000QfrzAAC', '012800000002ReSAAU', '012C0000000GZzaIAG', '012C0000000Ga1gIAC', '012C0000000Ga2FIAS', '012C0000000GaIOIA0', '012C0000000QEmMIAW', '012C0000000YQrEIAW'];
       if (data) {
           this.error = undefined;
           
           /*getUSOrthoRecordTypeIds()
            .then(result => {result.forEach(element => {
                console.log('Printing the Element for usOrthoRecIds... '+ element); 
                usOrthoRecIds.push(String.valueOf(element));
                }
                );})
            .catch(
                console.log(error)
                );
            */
                console.log('Array of US Ortho Record Types is ready and it has : '+usOrthoRecIds.length+ ' elements.');
                console.log(usOrthoRecIds);
                
                const rtis = this.opptyMetadata.data.recordTypeInfos;
       
           const rIDs = Object.keys(rtis);
           rIDs.forEach(element => {
               //console.log(rtis[element].recordTypeId);
               
               if (usOrthoRecIds.indexOf(rtis[element].recordTypeId) !== -1) 
               {
                //console.log('Woo hoo ! Record Type Id Exists');
                let prd = {};
                prd.label=rtis[element].name;
                prd.value=rtis[element].recordTypeId;
                recTypeList.push(prd);
               }
               else
               {
                   //console.log('Record Type Id '+rtis[element].recordTypeId+' does not exist in usOrthoRecIds');
               }
               /*
               var bFound = false;
               for (var i=0; i<usOrthoRecIds.length;i++){
                console.log('Checking if '+ rtis[element].recordTypeId + ' = '+usOrthoRecIds[i]);

                    if (rtis[element].recordTypeId == usOrthoRecIds[i])
                    {
                        bFound = true;
                        break;
                    }
                }
                if (bFound==true)
                {
                    console.log('Woo hoo ! Record Type Id Exists');
                    let prd = {};
                    prd.label=rtis[element].name;
                    prd.value=rtis[element].recordTypeId;
                    recTypeList.push(prd);
                }
                else
                {
                    console.log('Record Type Id '+rtis[element].recordTypeId+' does not exist in usOrthoRecIds');
                }      */      
               
               
           });

            this.productGroupList = recTypeList;
       }
       
    }

    //Fetch PickList Values for Competitor
    @wire(getPicklistValues, {
        recordTypeId : '$opptyMetadata.data.defaultRecordTypeId',
        fieldApiName : COMPETITOR
    }
     )
     plValues( {data, error}) {
        if (data) {
            console.log(`Picklist values for Competitor List are `,data.values);
            this.competitorList = data.values;
            this.error = undefined;
        }
        
        if (error) {
         console.log(`Error while fetching Picklist value ${error}`);
         this.error = error;
         this.competitorList = undefined;
        }
     }

     // This method calls the apex method to search records
    handleSearch() {
        /*if(!this.accountRecordId) {
            this.errorMsg = 'Please select an account to search.';
            this.searchData = undefined;
            return;
        }*/
        console.log('Initiating Search of Opportunities');
        console.log('BP Target: '+`${this.cbBPTarget}`);
        console.log('Drive and Defend: '+`${this.cbDriveAndDefend}`);
        console.log('Owner: '+`${this.ownerId}`);
        console.log('Account: '+`${this.accountName}`);
        console.log('Product Group: '+`${this.productGrpId}`);
        console.log('Team: '+`${this.teamId}`);

        serachOppts({acctId : this.accountRecordId, srgnId: this.surgeonRecordId, prdGrpId: this.productGrpId, teamId: this.teamId, cmptrId: this.competitorId, ownerId: this.ownerId, bpTrgt: this.cbBPTarget, drvDfnd: this.cbDriveAndDefend})
        .then(result => {
            let searchData1 = [];
            result.forEach((record) => {
                //record.Name = '/' + record.Id;
                console.log('Processing : '+record.Name);
                console.log(record);
                let ot = {};
                ot.Id = record.Id;
                ot.Name = record.Name;
                ot.NameUrl = '/'+record.Id;
                ot.OwnerName = record.Owner.Name;
                if (record.Account != undefined && record.Account.Name != undefined)
                {
                    ot.AccountName = record.Account.Name;
                }                
                else   
                    ot.AccountName = '';
                ot.RecordTypeName = record.RecordType.Name;
                console.log(record);
                if (record.Surgeon_Name__r != undefined && record.Surgeon_Name__r.Name != undefined)
                {
                    ot.SurgeonName = record.Surgeon_Name__r.Name;
                }                
                else   
                    ot.SurgeonName = '';

                if (record.StageName != undefined)
                {
                    ot.StageName = record.StageName;
                }                
                else   
                    ot.StageName = '';

                if (record.CloseDate != undefined)
                {
                    ot.CloseDate = record.CloseDate;
                }                
                else   
                    ot.CloseDate = '';

                if (record.Territory2 != undefined && record.Territory2.Name != undefined)
                {
                    console.log('Territory Name : '+record.Territory2.Name);
                    ot.AssignedTeam = record.Territory2.Name;
                }                
                else   
                    ot.AssignedTeam = '';
                
                /*ot.NameUrl = '/'+record.Id;*/
                ot.Desc = 'Test';
                // and so on for other fields
                searchData1.push(ot);
                this.noRecordsFound = false;
            }
            );

            this.searchData = searchData1;
            console.log('Found '+ this.searchData.length+ ' records');
            if (searchData1.length == 0)           
            {
                this.noRecordsFound = true;
            }

            const event = new ShowToastEvent({                
                "message": "Found " + this.searchData.length + " records",
                "messageData": [
                    'Salesforce',
                    {
                        noOfRecords: this.searchData.length
                    }
                ]
            });
            this.dispatchEvent(event);

            //console.log(searchData1);                 
            
        })
        .catch(error => {
            this.searchData = undefined;
            console.log(error);
            window.console.log('error =====> '+JSON.stringify(error));
            if(error) {
                this.errorMsg = error.body.message;
            }
        }) 
    }
    

    handleClearAll() {
        this.template.querySelector('form').reset();
    }

    handleCancel() {
        
        var url = window.location.href; 
        //console.log(this.propertyValue);
        var value = url.substr(0,url.lastIndexOf('/') + 1);
        window.history.back();        
        return false;
        
        /*var compDefinition = {
            componentDef: "c/orthoDefaultListview"            
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        //console.log(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            //type: 'standard__webPage',
            type: 'standard__component',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });*/
    }

 }