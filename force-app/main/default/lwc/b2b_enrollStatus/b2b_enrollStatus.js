import { LightningElement, api, wire } from 'lwc';
import { getSessionContext } from 'commerce/contextApi';
import errorOnCart from '@salesforce/apex/B2BCartController.getEnrollStatus';

export default class B2b_enrollStatus extends LightningElement {
@api effectiveAccountId;
isLoading = false;
showMessage=false;
async getAccountId()

    {
        const result = await getSessionContext();
        if(result && result.effectiveAccountId)
        {
            this.effectiveAccountId = result.effectiveAccountId;
        }
    }

    connectedCallback(){
        this.getAccountId();
    }

    errorOnCart(){
        this.isLoading = true;
        let mapParams = {
            effectiveAccountId : this.effectiveAccountId
        }
        errorOnCart({
            mapParams: mapParams
        }).then((results) => {
            console.log('errorOnCart results');
            console.log(results);
            if(results){
                this.template.querySelector('c-b2b-show-toast-message').showToast('You are not allowed to checkout','error');
            }
            this.isLoading = false;
        }).catch((error) => {
            console.log('errorOnCart error');
            console.log(error);
            this.isLoading = false;
        });
    }
    
}