import { LightningElement,api, wire } from 'lwc';
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import isGuest from "@salesforce/user/isGuest";
//import basePath from "@salesforce/community/basePath";
import SIGNIN from '@salesforce/label/c.SIGNIN';
import Register from '@salesforce/label/c.Register';
import Logout from '@salesforce/label/c.Logout';
import signInURL from '@salesforce/label/c.Okta_Sign_in_URL';
import Account_Management from '@salesforce/label/c.Account_Management';

export default class B2B_NavigationLink extends NavigationMixin(LightningElement) {
    isguest = isGuest;
    basePath = window.origin + '/Zimvie';
    labels = {SIGNIN,Register,Logout,Account_Management,signInURL};
    hideComponent = false;

    navigateToAccMgmt(){
        window.location = this.basePath+'/accountmanagement';
    }
    logout(){
        const sitePrefix = this.basePath.replace(/\/s$/i, ""); 
        window.location = sitePrefix + "/secur/logout.jsp";
    }
    SIGNIN(){
        window.location = this.labels.signInURL;//'https://zimvie-oktatest.oktapreview.com/home/zimvie-oktatest_salesforceecommercesaml_1/0oa90xebtgJBX7R1H1d7/aln90xmc0zX6zUZOi1d7';//this.basePath+'vforcesite/login';
    }
    REGISTER(){
        window.location = this.basePath+'/SelfRegister';
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