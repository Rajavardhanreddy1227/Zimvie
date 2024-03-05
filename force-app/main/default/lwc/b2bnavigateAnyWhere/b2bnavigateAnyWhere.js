import { LightningElement,api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import basePath from "@salesforce/community/basePath";
export default class B2bnavigateAnyWhere extends NavigationMixin (LightningElement) {
@api url;
@api pageType;
@api pageName;
connectedCallback() {
    console.log('this.pageName', this.pageName);
    console.log('this.pageType', this.pageType);
     
       /* this[NavigationMixin.GenerateUrl](this.cPageRef)
            .then(url => this.url = url);
            console.log('this.url', this.url);*/
      /*  this[NavigationMixin.Navigate]({
            type: this.pageType,
            attributes: {
                name: this.pageName
                
            }
        });*/
    window.location = basePath;
}
}