import { LightningElement, track, api, wire } from 'lwc';
import isguest from '@salesforce/user/isGuest';
import basePath from '@salesforce/community/basePath';
import CustomerService from '@salesforce/label/c.CustomerService';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';

const customerServiceURL = 'https://www.zimvie.com/en/customer-service/dental.html';
export default class B2B_CustomerService extends NavigationMixin(LightningElement) {
    labels={CustomerService};
    isGuestUser = isguest;
    showSpinner = false;

    label = {
        customerServiceURL
    };

    dataMap = {
        'isGuest' : this.isGuestUser
    }

}