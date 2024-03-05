import { LightningElement, wire } from 'lwc';
import getApps from '@salesforce/apex/Ortho_MyAppsController.getApps';
import { refreshApex } from '@salesforce/apex';
import Ortho_Mobile_My_App_Apps_Label from '@salesforce/label/c.Ortho_Mobile_My_App_Apps_Label'; 
import Ortho_Mobile_My_App_Favorites_Label from '@salesforce/label/c.Ortho_Mobile_My_App_Favorites_Label'; 

export default class OrthoMyApps extends LightningElement {
  @wire(getApps) orthoApps;

  labels = {
    Ortho_Mobile_My_App_Apps_Label,
    Ortho_Mobile_My_App_Favorites_Label
  }

  get apps(){
    return this.orthoApps.data && this.orthoApps.data.apps.length > 0 && this.orthoApps.data.apps;
  }
  get favorites(){
    return this.orthoApps.data && this.orthoApps.data.favorites.length > 0 && this.orthoApps.data.favorites;
  }

  handleRefresh(){
    refreshApex(this.orthoApps)

  }

}