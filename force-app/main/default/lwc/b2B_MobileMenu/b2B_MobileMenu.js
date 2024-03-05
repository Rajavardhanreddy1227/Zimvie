import { LightningElement, api } from 'lwc';
import menulabel from '@salesforce/label/c.menulabel';
import isGuest from "@salesforce/user/isGuest";
export default class b2B_MobileMenu extends LightningElement {labels={menulabel};
  @api menuItems;
  isguest = isGuest;
  basePath = window.origin + '/Zimvie';
  goToAccMgmt(){
        window.location = this.basePath+'/accountmanagement';
    }
}