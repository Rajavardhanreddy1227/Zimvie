import { LightningElement,track,api } from 'lwc';
import Product_Experience_Report from '@salesforce/label/c.Product_Experience_Report';
import Product_Experience_Report_desc from '@salesforce/label/c.Product_Experience_Report_desc';
import mailToZimvie from '@salesforce/label/c.mailToZimvie';
import zimvieEmailAddress from '@salesforce/label/c.zimvieEmailAddress';
import or from '@salesforce/label/c.or';

export default class B2bwarranty extends LightningElement {
    loader = false;
    @track currentStep = 2;
    currentStageIndex;
    labels={Product_Experience_Report,Product_Experience_Report_desc,mailToZimvie,zimvieEmailAddress,or};

    @track currentStage = 1;
    @track showForm = true;

    // Define the stages dynamically
    get stages() {
        return [
            { label: 'Event',value:'event'},
            { label: 'Device',value:'device'},
            { label: 'Reporter',value:'reporter'},
            { label: 'Patient',value:'patient'},
        ];
    }

    handleFormSubmit() {
        // Handle form submission logic here

        // If there are more stages, go to the next stage
        if (this.currentStage < this.stages.length) {
            this.currentStage++;
        } else {
            // If all stages are completed, hide the form
            this.showForm = false;
        }
    }
}