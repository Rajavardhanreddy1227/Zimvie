import { LightningElement, wire, api } from 'lwc';
import Success from '@salesforce/label/c.Success';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';

export default class NavToMobileOpptyFilter extends NavigationMixin(LightningElement) {labels={Success};
    @wire(CurrentPageReference)
    pageRef;
    handleNavigate() {
        //console.log('Going to :'+this.pageRef);
        var compDefinition = {
            componentDef: "c:customOpptySearch",
            attributes: {
                propertyValue: this.pageRef.url
            }
        };
        // Base64 encode the compDefinition JS object
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }
}