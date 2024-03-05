import { LightningElement, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
export default class Zimvie_storethemechange extends LightningElement {
    selectedcategory;

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
            let categoryId = currentPageReference.attributes.recordId || null;
            console.log('currentPageReference===');
            console.log(currentPageReference);
            let attributes = currentPageReference.attributes;
            console.log('attributes===');
            console.log(attributes);

            this.selectedcategory = categoryId;

            let gridCls = this.template.querySelector(".slds-grid");
            gridCls?.classList.add('dynamiccolorCSS'); 
       }
    }

}