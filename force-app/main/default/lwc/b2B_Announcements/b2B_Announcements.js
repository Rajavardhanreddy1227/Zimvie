import { LightningElement,api} from 'lwc';
import fetchAnnouncements from '@salesforce/apex/B2B_AnnouncementsController.fetchAnnouncements';
import isguest from '@salesforce/user/isGuest';


export default class B2B_Announcements extends LightningElement {
    announcements;
    error;
    
    
    @api tabcolour;
    renderedCallback(){
        let brandName = localStorage['selectedBrand'] == 'azure' ? 'Azure' : 'Zimvie';
        let guestcountry = localStorage['myKey'];
        let isGuest = isguest;
        let lang = localStorage['selectedlanguage'];
        let type = window.location.href.includes('checkout') ? 'Shipping Announcement' : 'Home Page Announcement';
        var css = this.template.host.style;
        css.setProperty('--tabColour', this.tabcolour);
        fetchAnnouncements({brandName:brandName,guestcountry:guestcountry,isGuest:isGuest,type:type,language:lang})
        .then(result => {
            console.log('ann>>>'+JSON.stringify(result));
            this.announcements = result;
            this.error = undefined;
        })
        .catch(error => {
            this.error = error;
            this.contacts = undefined;
        });
    }    
}