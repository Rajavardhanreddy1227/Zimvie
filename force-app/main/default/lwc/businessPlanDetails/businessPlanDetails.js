import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { reduceErrors } from 'c/ldsUtils';
import getSalesSummary from '@salesforce/apex/BusinessPlanSalesSummaryController.getSalesSummary';
import {
    getRecord,
    updateRecord,
    generateRecordInputForUpdate,
    getFieldValue
} from 'lightning/uiRecordApi';
import { CurrentPageReference } from 'lightning/navigation';
import { registerListener, unregisterAllListeners } from 'c/pubsub';
import FIELD_ID from '@salesforce/schema/Business_Plan__c.Id';
import FIELD_NAME from '@salesforce/schema/Business_Plan__c.Name';
import FIELD_AVP from '@salesforce/schema/Business_Plan__c.AVP_Name__c';
import FIELD_TERRITORY from '@salesforce/schema/Business_Plan__c.Territory_Account_Name__r.Name';
import FIELD_STATUS from '@salesforce/schema/Business_Plan__c.Status__c';
import FIELD_QUARTER from '@salesforce/schema/Business_Plan__c.Quarter__c';
import FIELD_YEAR from '@salesforce/schema/Business_Plan__c.Year__c';
import FIELD_ADSTOTAL from '@salesforce/schema/Business_Plan__c.ADS__c';
import FIELD_ADS_DOLLARGROWTH from '@salesforce/schema/Business_Plan__c.ADS_Dollar_Growth__c';
import FIELD_ADSPERCENTGROWTH from '@salesforce/schema/Business_Plan__c.ADS_Growth__c';

//import FIELD_IRRIGATION from '@salesforce/schema/Business_Plan__c.Irrigation__c';
//import FIELD_PICTURE_URL from '@salesforce/schema/Business_Plan__c.Picture_URL__c';
const generateRandomNumber = () => {
    return Math.round(Math.random() * 100);
};
const fields = [
    FIELD_ID,
    FIELD_NAME,
    FIELD_AVP,
    FIELD_TERRITORY,
    FIELD_STATUS,
    FIELD_QUARTER,
    FIELD_YEAR,
    FIELD_ADSTOTAL,
    FIELD_ADS_DOLLARGROWTH,
    FIELD_ADSPERCENTGROWTH
    /*,
    FIELD_IRRIGATION,
    FIELD_PICTURE_URL*/
];

const columns = [
    { label: 'Product Group', fieldName: 'Product_Group__c' },
    { label: '2019 Sales', fieldName: 'Y_2_Sales__c' , type: 'currency' },
    { label: '2020 Sales', fieldName: 'Y_1_sales__c' , type: 'currency' },
    { label: '2021 FULL YEAR ESTIMATE', fieldName: 'Full_Year_Estimate__c', type: 'currency' },
    /*{ label: '2020 FULL YEAR ADS $ GROWTH EST', fieldName: 'Planned_Growth__c', type: 'currency',  cellAttributes: { class: { fieldName: 'Product_Group__c' }}},*/
    { label: '2022 ADS SALES PLAN', fieldName: 'ADS__c', type: 'currency' },
    { label: '2022 ADS $ GROWTH', fieldName: 'ADS_Dollar_Growth__c', type: 'currency' },
    { label: '2022 ADS % GROWTH', fieldName: 'ADS_Growth__c', type: 'number' },
];

export default class businessPlanDetails extends NavigationMixin(LightningElement) {
    @track error;
    @track businessPlan;
    @track imageStatus;
    @track recordId;
    @track columns = columns;
    @track data = [];
    
    @wire(CurrentPageReference) pageRef;

    @wire(getSalesSummary , { recordId: '$recordId' })
    wiredRecordsMethod({ error, data }) {
        if (data) {
            this.data  = data;
            this.error = undefined;
        } else if (error) {
            this.error = error;
            this.data  = undefined;
        }
        this.tableLoadingState  = false;
    }

    @wire(CurrentPageReference) pageRef;

    @wire(getRecord, {
        recordId: '$recordId',
        fields
    })
    wiredRecord({ error, data }) {
        if (error) {
            this.error = error;
            this.businessPlan = undefined;
        } else if (data) {
            this.error = undefined;           
            this.businessPlan = data;
        }
    }

    connectedCallback() {
        registerListener(
            'businessplan__fieldselected',
            this.handleRecordChanged,
            this
        );
    }

    disconnectedCallback() {
        unregisterAllListeners(this);
    }

    get businessPlanName() {
        return getFieldValue(this.businessPlan, FIELD_NAME);
    }

    get businessPlanAVP() {
        return getFieldValue(this.businessPlan, FIELD_AVP);
    }

    get businessPlanQUARTER() {
        return getFieldValue(this.businessPlan, FIELD_QUARTER);
    }

    get businessPlanYEAR() {
        return getFieldValue(this.businessPlan, FIELD_YEAR);
    }
    get businessPlanADSTotal() {
        return getFieldValue(this.businessPlan, FIELD_ADSTOTAL);
    }
    get businessPlanADSDOLLARGROWTH() {
        return getFieldValue(this.businessPlan, FIELD_ADS_DOLLARGROWTH);
    }
    get businessPlanADSPERCENTGROWTH() {
        return getFieldValue(this.businessPlan, FIELD_ADSPERCENTGROWTH);
    }

    get businessPlanStatus() {
        return getFieldValue(this.businessPlan, FIELD_STATUS);
    }

    
    get isAlert() {
        return getFieldValue(this.harvestField, FIELD_STATUS) === 'Alert';
    }

    get isWarning() {
        return getFieldValue(this.harvestField, FIELD_STATUS) === 'Warning';
    }

    handleToggleChange(event) {
        /*
        let recordUpdate = generateRecordInputForUpdate(this.harvestField);
        recordUpdate.fields.Irrigation__c = event.target.checked;
        updateRecord(recordUpdate)
            // eslint-disable-next-line no-unused-vars
            .then(result => {
                // leave here, not needed
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error on data save',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
            }); */
    }

    handleNavigateToRecordHome() {
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                actionName: 'view',
                recordId: this.recordId
            }
        });
    }

    handleRecordChanged(recordId) {
        this.recordId = recordId;
    }

}