import { LightningElement,wire } from 'lwc';
import fetchToken from '@salesforce/apex/B2B_CyberSourceIntegration.fetchToken';
export default class b2B_Cybersource extends LightningElement {

    @wire(fetchToken)
    toknReq({error, data}) {
        if (data) {
            console.log(data);
        } else if (error) {
            //this.error = error;
            console.error('error:'+JSON.stringify(error));
        }
    }
}