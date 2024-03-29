import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent, unregisterAllListeners } from 'c/pubsub';
import { subscribe, unsubscribe, onError } from 'lightning/empApi';
import getBusinessPlans from '@salesforce/apex/BusinessPlanAVPViewController.getBusinessPlans';

export default class BusinessPlanList extends NavigationMixin(
    LightningElement
) {
    @track empMessage;
    @track error;
    @track selectedItems = [];
    @track popup;
    @track tableData;
    @track treeData;
    @track viewMode = 'tree';
    _columns = [
        { label: 'Name', fieldName: 'Name', type: 'text', sortable: true },
        { label: 'Territory Name', fieldName: 'Territory_Account_Name__c', type: 'text', sortable: true },
        { label: 'AVP', fieldName: 'AVP_Name__c', type: 'text', sortable: true },
        {
            label: 'Year',
            fieldName: 'Year__c',
            type: 'number',
            sortable: true
        },
        {
            label: 'Status',
            fieldName: 'Status__c',
            type: 'text',
            sortable: true
        }
    ];

    @wire(CurrentPageReference) pageRef;

    @wire(getBusinessPlans)
    apexHarvestFields({ error, data }) {
        if (error) {
            this.error = error;
            this.treeData = undefined;
            this.tableData = undefined;
        } else if (data) {
            this.error = undefined;
            this.tableData = data;
            const map = {};
            const items = [];
            data.forEach(field => {
                if (!map[field.AVP_Name__c]) {
                    map[field.AVP_Name__c] = [];
                }
                if (field.Status__c !='Approved') {
                    map[field.AVP_Name__c].push({
                        label: field.Name,
                        name: field.Id,
                        expanded: false
                    });
                }
            });

            Object.keys(map).forEach(key => {
                items.push({
                    label: key,
                    expanded: false,
                    items: map[key]
                });
            });

            items.sort((item1, item2) => {
                return item1.label > item2.label;
            });
            this.treeData = items;
        }
    }

    connectedCallback() {
        // EMP API Error handling
        onError(error => {
            this.error = error;
        });

        subscribe('/event/Field_Status_Change__e', -1, message => {
            this.empMessage = message;
        });
    }

    disconnectedCallback() {
        // pubsub
        unregisterAllListeners(this);

        // EMP API
        if (this.subscription) {
            unsubscribe(this.subscription, () => {
                this.subscription = null;
            });
        }
    }

    get columns() {
        return this._columns;
    }

    get isTable() {
        return this.viewMode === 'table';
    }

    get isTree() {
        return this.viewMode === 'tree';
    }

    get isMap() {
        return this.viewMode === 'map';
    }

    handleMapShow() {
        this.viewMode = 'map';
    }

    handleDatatableShow() {
        this.viewMode = 'table';
    }

    handleTreeShow() {
        this.viewMode = 'tree';
    }

    handleRowSelected(event) {
        this.selectedItems = event.detail.selectedRows;
    }

    handleMapRecordSelected(event) {
        this.selectedItems = event.detail.selectedRecords;
    }

    handleTreeItemSelected(event) {
        const recordId = event.detail.name;
        if (recordId) {
            fireEvent(this.pageRef, 'businessplan__fieldselected', recordId);
        }
    }

    handleAction() {
        this.popup = true;
    }

    handleDialogClose() {
        this.popup = false;
    }

    handleDialogSubmit() {
        this.popup = false;
    }
}