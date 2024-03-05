import { LightningElement, wire } from 'lwc';
import CustomerService from '@salesforce/label/c.CustomerService';
import Resources from '@salesforce/label/c.Resources';
import Customer_Services from '@salesforce/label/c.Customer_Services';
import Returns_Exchanges from '@salesforce/label/c.Returns_Exchanges';
import Lifetime_Implant_Waanty_Program from '@salesforce/label/c.Lifetime_Implant_Waanty_Program';
import Courtesy_Implant_Replacement from '@salesforce/label/c.Courtesy_Implant_Replacement';
import Restorative_Reimbursement_Benefit from '@salesforce/label/c.Restorative_Reimbursement_Benefit';
import Product_Experience_Complaints_PER from '@salesforce/label/c.Product_Experience_Complaints_PER';
import Find_A_Encode_Empower_Lab_EEL from '@salesforce/label/c.Find_A_Encode_Empower_Lab_EEL';
import EDUCATION from '@salesforce/label/c.EDUCATION';
import Customer_Service_Request_An_Account from '@salesforce/label/c.Customer_Service_Request_An_Account';
import Already_A_Customer_Registration from '@salesforce/label/c.Already_A_Customer_Registration';
import eStore_Shopping_Experience from '@salesforce/label/c.eStore_Shopping_Experience';
import Invoice_Accesss_Payment from '@salesforce/label/c.Invoice_Accesss_Payment';
import Return_Replace from '@salesforce/label/c.Return_Replace';
import Excel_Loyalty_Program_Education from '@salesforce/label/c.Excel_Loyalty_Program_Education';
import { CurrentPageReference } from 'lightning/navigation';

export default class B2b_resources extends LightningElement {
    labels={CustomerService};
    isZimvieBrand;
    hideComponent = false;
    labels = {Resources,Customer_Services,Returns_Exchanges,Lifetime_Implant_Waanty_Program,Courtesy_Implant_Replacement,
        Restorative_Reimbursement_Benefit,Product_Experience_Complaints_PER,Find_A_Encode_Empower_Lab_EEL,EDUCATION,
        Customer_Service_Request_An_Account,Already_A_Customer_Registration,eStore_Shopping_Experience,Invoice_Accesss_Payment,
        Return_Replace,Excel_Loyalty_Program_Education};
    
    connectedCallback() {
        let brandVal = localStorage['selectedBrand'];
        if(brandVal == 'azure'){
            this.isZimvieBrand = false;
        }
        else{
            this.isZimvieBrand = true;
        }
    }
    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          var pageName = currentPageReference.attributes.name;
          if(pageName == 'Home'){
              this.hideComponent = false;
          }
          else{
              this.hideComponent = true;
          }
       }
    }
}