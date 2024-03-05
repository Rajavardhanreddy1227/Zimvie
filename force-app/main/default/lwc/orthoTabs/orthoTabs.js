import { LightningElement, api } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import orthoStyle from "@salesforce/resourceUrl/ortho";
import { NavigationMixin } from "lightning/navigation";

import Ortho_Mobile_Tabs_Dashboard_Label from '@salesforce/label/c.Ortho_Mobile_Tabs_Dashboard_Label'; 
import Ortho_Mobile_Tabs_Communications_Label from '@salesforce/label/c.Ortho_Mobile_Tabs_Communications_Label'; 
import Ortho_Mobile_Tabs_My_Apps_Label from '@salesforce/label/c.Ortho_Mobile_Tabs_My_Apps_Label'; 

export default class OrthoTabs extends NavigationMixin(LightningElement) {
  @api selectedTab;

  labels = {
    Ortho_Mobile_Tabs_Dashboard_Label,
    Ortho_Mobile_Tabs_Communications_Label,
    Ortho_Mobile_Tabs_My_Apps_Label,
  }
  handleTabClick(ev) {
    const link = ev.target.getAttribute("data-link");
    var pageReference = {
        type: "standard__navItemPage",
        attributes: {
          apiName: link
        }
      }
    this[NavigationMixin.Navigate](pageReference);
  }

  renderedCallback() {
    loadStyle(this, orthoStyle);
    const indicator = this.template.querySelector(".indicator");
    indicator.className = `${indicator.className} ${this.selectedTab}`;
  }
}