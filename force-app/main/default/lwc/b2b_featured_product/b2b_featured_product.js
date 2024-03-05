import { LightningElement } from 'lwc';
import isguest from '@salesforce/user/isGuest';
export default class B2b_featured_product extends LightningElement {
   isguestuser = isguest;

}