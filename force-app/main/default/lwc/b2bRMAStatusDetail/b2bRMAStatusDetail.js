import { LightningElement,api } from 'lwc';
import loading from '@salesforce/label/c.loading';
import rmaStatus from '@salesforce/label/c.rmaStatus';
import rmaStatusDetail from '@salesforce/label/c.rmaStatusDetail';
import rmaType from '@salesforce/label/c.rmaType';
import CurrencyIsoCode from '@salesforce/label/c.CurrencyIsoCode';
import cancellationReason from '@salesforce/label/c.cancellationReason';
import rmaOrderType from '@salesforce/label/c.rmaOrderType';
import shipToAddress from '@salesforce/label/c.shipToAddress';
import raisedBy from '@salesforce/label/c.raisedBy';
import rmaTotalIncludingTax from '@salesforce/label/c.rmaTotalIncludingTax';
import createdDate from '@salesforce/label/c.createdDate';
import status from '@salesforce/label/c.Status';
import BacktoAllRMSStatus from '@salesforce/label/c.BacktoAllRMSStatus';
import getRMAStatusDetail from '@salesforce/apex/B2BAccountManagementController.getRMAStatusDetail';

export default class B2bRMAStatusDetail extends LightningElement {
    @api recordId;
    objRMAStatusDetail;
    labels = { loading,rmaStatus,rmaStatusDetail,rmaType,createdDate,status,CurrencyIsoCode,cancellationReason,rmaOrderType,shipToAddress,raisedBy,rmaTotalIncludingTax,BacktoAllRMSStatus};
    connectedCallback() {
        this.isLoading = true;
        getRMAStatusDetail({ recordId: this.recordId })
            .then((result) => {
                try {
                    this.isLoading = false;
                    console.log('getRMAStatusDetail result>>>'+JSON.stringify(result));
                    this.objRMAStatusDetail = result.RMAStatusDetailRecord;
                    this.baseURL = result.BaseURL;
                }catch(e){
                    this.isLoading = false;
                    console.log('getRMAStatusDetail ERROR==' + error);
                }
            }).catch((error) => {
                this.isLoading = false;
                console.log('getRMAStatusDetail==ERROR==' + JSON.stringify(error));
            });
    }
    handleBacktoallRMAStatus() {
        this.dispatchEvent(new CustomEvent('backtoallrmastatus', {
            detail: {}
        }));
    }
}