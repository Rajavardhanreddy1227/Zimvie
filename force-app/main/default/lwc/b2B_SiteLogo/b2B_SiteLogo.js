import { LightningElement, wire } from 'lwc';
import brandimages from '@salesforce/resourceUrl/brandimages';
import basePath from '@salesforce/community/basePath';
import { CurrentPageReference } from 'lightning/navigation';

export default class B2B_SiteLogo extends LightningElement {
    imgurl;
    homeUrl;
    hideComponent = false;
    renderedCallback() {
        if(localStorage['selectedBrand'] == 'azure'){
            this.imgurl = brandimages + '/azure.png';
            this.homeUrl = basePath+'/';
        } else {
            this.imgurl = brandimages + '/zimvie.png';
            this.homeUrl = basePath+'/';
        }
    }
    handleBrandClick(){
        window.location.href=this.homeUrl;
    }
    
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          var pageName = currentPageReference.attributes.name;
          if(pageName == 'Current_Checkout'){
              this.hideComponent = true;
          }
          else{
              this.hideComponent = false;
          }
       }
    }
}