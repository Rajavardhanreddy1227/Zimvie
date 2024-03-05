import { LightningElement } from 'lwc';
import loading from '@salesforce/label/c.loading';
import Careers from '@salesforce/label/c.Careers';
import Investors from '@salesforce/label/c.Investors';
import Global_Contacts from '@salesforce/label/c.Global_Contacts';
import Contact_US from '@salesforce/label/c.Contact_US';
import Privacy_Notice from '@salesforce/label/c.Privacy_Notice';
import Legal_Notices from '@salesforce/label/c.Legal_Notices';
import Other_Websites_Mobile_Apps from '@salesforce/label/c.Other_Websites_Mobile_Apps';
import Copyright_2023_ZimVie_Inc from '@salesforce/label/c.Copyright_2023_ZimVie_Inc';

export default class b2b_footer extends LightningElement { 
    labels = {loading,Careers,Investors,Global_Contacts,Contact_US,Privacy_Notice,Legal_Notices,Other_Websites_Mobile_Apps,
        Copyright_2023_ZimVie_Inc};
}