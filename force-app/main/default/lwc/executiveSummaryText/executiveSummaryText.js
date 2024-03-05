import { LightningElement, api, wire , track } from 'lwc';
import getActiveExecutiveSummary from '@salesforce/apex/businessPlanExecutiveSummary.getActiveExecutiveSummary' ;  
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import Executive_Summary from '@salesforce/schema/Executive_Summary__c';
import SUMMARY_FIELD from '@salesforce/schema/Executive_Summary__c.Executive_Summary_fld__c';
import ID_FIELD from '@salesforce/schema/Executive_Summary__c.Id';


export default class executiveSymmaryText extends LightningElement {
    @api height ;
    @api recordId; 
    @api summaryId;
    @track disabled = false;
    @track error;
    @track summaryText;
    @track formats = ['font','table', 'size', 'bold', 'italic', 'underline',
        'strike', 'list', 'indent', 'align', 'link',
        'image', 'clean', 'header', 'color'];

    @wire(getActiveExecutiveSummary, {bpid:'$recordId' })
     executiveSymmaryTextfld; 
    
    

     handleChange(event) {
        //console.log('label values --->>' + event.target.label);
        
        if (event.target.label === 'Executive Summary') {
            this.summaryText = event.target.value;
        }
        if(event.target.label === 'Id' ){
            this.summaryId = event.target.value; 
        }
        
    
    }
    
    updateSummary() {
        this.summaryId = this.template.querySelector("[data-field='ID']").value; 
        let record = {
            fields: {
                Id: this.summaryId,
                Executive_Summary_fld__c: this.summaryText
            
            },
        };
        updateRecord(record)
            // eslint-disable-next-line no-unused-vars
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Record Is Updated',
                        variant: 'sucess',
                    }),
                );
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error on data save',
                        message: error.message.body,
                        variant: 'error',
                    }),
                );
            });
    
    
    }
    /*
    updateSummary() {

        updateActiveExecutiveSummary (
            {
                sumID : '$summaryId' 
                , SummaryValue : '$summaryText'
            }
        )
        .then(() => {
            return refreshApex(this.executiveSymmaryTextfld);
        })
        .catch((error) => {
            this.message = 'Error received: code' + error.errorCode + ', ' +
                'message ' + error.body.message;
        });
    }   */    
     
}