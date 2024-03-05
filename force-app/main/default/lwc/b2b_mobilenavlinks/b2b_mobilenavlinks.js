import { LightningElement, wire } from 'lwc';
import isGuest from "@salesforce/user/isGuest";
import {CurrentPageReference } from 'lightning/navigation';

export default class B2b_mobilenavlinks extends LightningElement {
    isguest = isGuest;
    basePath = window.origin + '/Zimvie';
    hideComponent = false;
    navigateToAccMgmt(){
        window.location = this.basePath+'/accountmanagement';
    }
    logout(){
        const sitePrefix = this.basePath.replace(/\/s$/i, ""); 
        window.location = sitePrefix + "/secur/logout.jsp";
    }
    SIGNIN(){
        window.location = this.basePath+'vforcesite/login';
    }
    REGISTER(){
        window.location = this.basePath+'/SelfRegister';
    }

    handleNavigation(event){
        event.stopPropagation();
        // Store menu container
        var mobileMenu = this.template.querySelector('.mobile-menu');
        
        var rotation = this.template.querySelector('.mobile-btn-close');

        
        if (mobileMenu.classList.contains('mobile-menu-hide') || (!mobileMenu.classList.contains('mobile-menu-hide') && !mobileMenu.classList.contains('mobile-menu-show'))) {
            mobileMenu.classList.remove("mobile-menu-hide");
            mobileMenu.classList.add("mobile-menu-show");

        } else if(mobileMenu.classList.contains('mobile-menu-show')){
            mobileMenu.classList.remove("mobile-menu-show");
            mobileMenu.classList.add("mobile-menu-hide");

        }
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