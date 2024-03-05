import { LightningElement, api } from "lwc";

import { NavigationMixin } from "lightning/navigation";
import setFavorite from '@salesforce/apex/Ortho_MyAppsController.setFavorite';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import Ortho_Mobile_My_App_Error_Title from '@salesforce/label/c.Ortho_Mobile_My_App_Error_Title'; 
import Ortho_Mobile_My_App_Success_Title from '@salesforce/label/c.Ortho_Mobile_My_App_Success_Title'; 
import Ortho_Mobile_My_App_Default_Title from '@salesforce/label/c.Ortho_Mobile_My_App_Default_Title'; 

export default class OrthoMyAppItem extends NavigationMixin(LightningElement) {
  @api appitem;
  @api isfavorite;

  handleClick(evt) {
    evt.stopPropagation();
    evt.preventDefault();
    const pageRef = {
      type: "standard__webPage",
      attributes: {
        url: this.appitem.MobileStartUrl || this.appitem.StartUrl
      }
    };

    this[NavigationMixin.Navigate](pageRef);
  }
  handleFavoriteClick(evt) {
    evt.stopPropagation();
    evt.preventDefault();
    setFavorite({appId: this.appitem.Id, appName: this.appitem.Name, isFavorite: !this.isfavorite})
    .then(() => {
      this.refreshCache();
    })
    .catch(error => {
        this.fireToast('error', error.body.message);
    });
    
  }

  refreshCache(){
    this.dispatchEvent(new CustomEvent('refreshapps'));
  }

  fireToast(type, message){
    let title = Ortho_Mobile_My_App_Default_Title;
    if(type ==='error' ){
      title = Ortho_Mobile_My_App_Error_Title;
    }
    if(type === 'success'){
      title = Ortho_Mobile_My_App_Success_Title;
    }

    const event = new ShowToastEvent({
        title: title,
        message: message
    });
    this.dispatchEvent(event);
  }

  get iconVariant() {
    return this.isfavorite ? 'warning' : '';
  }
}