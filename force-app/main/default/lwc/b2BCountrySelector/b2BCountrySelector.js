import { LightningElement, wire, api, track } from 'lwc';
//import findAnnouncementByguest from '@salesforce/apex/b2b_zim_announcemet.findAnnouncementByguest';
import fetchLocales from '@salesforce/apex/B2BCountrySelectorController.fetchLocales';
import isguest from '@salesforce/user/isGuest';
import Id from '@salesforce/user/Id';
import { NavigationMixin } from 'lightning/navigation';
import basePath from '@salesforce/community/basePath';
import {getRecord, updateRecord} from 'lightning/uiRecordApi';
import Clickheretochangethecountry from '@salesforce/label/c.Clickheretochangethecountry';
import CountrySelector from '@salesforce/label/c.CountrySelector';
import countrySelectorTermsContent from '@salesforce/label/c.countrySelectorTermsContent';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ToastContainer from 'lightning/toastContainer';
import svgLogo from '@salesforce/resourceUrl/svgLogo';
const FIELDS = ['User.customLocale__c','User.LocaleSidKey'];
const storeFront = 'Zimvie';

export default class B2BCountrySelector extends LightningElement {
    checkinIcon = svgLogo + '/svglogo/location.svg';
    editIcon = svgLogo + '/svglogo/edit.svg';
    item = false;
    isGuestUser = isguest;
    userId = Id;
    localePicklist;
    countryValue;
    countryLabel;
    showPopup = false;
    terms = false;
    labels={Clickheretochangethecountry,CountrySelector,countrySelectorTermsContent};
    locale;
    localeValue;
    preUrl;
    postUrl;
    LanguageBasedOnCountry = new Map([['United States','en_US'],['Canada','en_US'],['France','fr'],['Germany','de'],['Spain','es']]);
    
    @api tabcolour;
    closeModal(){
        this.showPopup = false;
    }

    displayPopup(){
        this.showPopup = true;
    }

    label = {
        storeFront
    };

    @wire(getRecord, { recordId: '$userId', fields: FIELDS})
    objUser({ error, data }) {
        console.log('data======'+data);
        if(data == undefined){
            return;
        }
          if(this.isGuestUser){
        console.log('Locale======'+data.fields?.LocaleSidKey?.displayLabel);
        this.showPopup = data.fields?.customLocale__c?.value == null ? true : false;
        
        console.log('Localevalue======'+data.fields?.LocaleSidKey?.displayValue);
        this.localeValue = data.fields?.LocaleSidKey?.displayValue;
        const myArray = this.localeValue.split("(");
        this.locale=myArray[1].split(")")[0]; 
          }
    }
    



    @wire(fetchLocales)
    localePicklistData ({ error, data }) 
    {
        console.log('Test Data');
        if (data) {
           console.log('Country Data Value',JSON.stringify(data));
           let tempcountrylst = JSON.parse(data);
           tempcountrylst.sort();
           this.localePicklist = tempcountrylst;
        } 
        else if (error) { 
            this.error = error;  
            console.log('Error Message',error);
        }   
         if(this.isGuestUser){
             var myVar = localStorage['myKey'] ;
             console.log('localStorageKey-----',myVar)
             this.locale=myVar;
             if(myVar==undefined){
              this.displayPopup();
             }
        }
    }

    connectedCallback() {
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';
        var css = this.template.host.style;
        css.setProperty('--tabColour', this.tabcolour);
        console.log('here country>>'+window.location.href.split(basePath));
        console.log('basePath'+basePath);
    }

    handleChange(event){
     
        this.countryValue = event.detail.value;
        this.countryLabel = event.target.options.find(opt => opt.value === event.detail.value).label;
        console.log('isGuestUser',this.isGuestUser)
        console.log('Country Value',event.detail.value) 
        console.log('Country label',this.locale) 
        
           if(event.detail.value!='Canada' && event.detail.value!='United States' && this.isGuestUser){
               this.terms=true;
               this.item=false;
         }else{this.terms=false;}
          
        }
     handleChkboxChange(event){
      this.item=event.target.checked;
       console.log('HandleCheckboxChange',this.item);
     }

     handleClick() {
    // Use the selected value in your click event logic
    
     console.log('countryValue',this.countryValue);
     console.log('CheckboxChange',this.item);
     if(this.countryValue==undefined){
         this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Please select the Country first',
                    variant: 'error'
                })
            ) 
            return;
     }
     if(this.countryValue!='Canada' && this.countryValue!='United States' && this.isGuestUser && !this.item){
          this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Please select the checkbox first',
                    variant: 'error'
                })
            )
     }else{
        var base_url = window.location.origin
           let fields = {
            Id: this.userId,
            LocaleSidKey: this.countryValue,
            customLocale__c:this.countryValue
        }
        const recordInput = { fields };
        if(this.isGuestUser){
            this.locale=this.countryLabel;
            localStorage['myKey'] =this.locale;
             console.log('localStorageKey-----1',localStorage['myKey'])
        }
        else{
         updateRecord(recordInput)
        .then(() =>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!',
                    message: 'Country updated successfully',
                    variant: 'success'
                })
            )
        })
        .catch(error =>{
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Something went wrong while updating country '+JSON.stringify(error),
                    variant: 'error'
                })
            )
        });
        }
        
        localStorage['selectedlanguage'] = this.LanguageBasedOnCountry.get(this.locale);
        
        let url = window.location.href.split(basePath);
        this.preUrl = url[0];
        this.postUrl = url[1];
       
        let selectedlang = this.LanguageBasedOnCountry.get(this.locale);
        window.open( this.preUrl + '/' + this.label.storeFront + '/' + selectedlang.replace(/_/g, "-") + this.postUrl,'_self');
        this.closeModal();
       
        //window.location.reload();
     }
  }
  
}