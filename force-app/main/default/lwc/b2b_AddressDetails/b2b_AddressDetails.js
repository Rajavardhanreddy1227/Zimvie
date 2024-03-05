import { LightningElement, api, track, wire } from "lwc";
export default class B2b_AddressDetails extends LightningElement {
  

       @api city;
       @api country;
       @api postalCode;
       @api state;
       @api street;
     

}