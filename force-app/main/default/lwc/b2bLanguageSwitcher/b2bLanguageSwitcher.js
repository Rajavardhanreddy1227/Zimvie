import { LightningElement, track, api, wire } from 'lwc';
//import { consoleLogging, applicationLogging } from 'c/b2bUtil';
import isguest from '@salesforce/user/isGuest';
import basePath from '@salesforce/community/basePath';
import { CurrentPageReference, NavigationMixin } from 'lightning/navigation';
import lang from '@salesforce/i18n/lang';
import updateLanguage from '@salesforce/apex/B2BLanguageSwitcherController.updateUserLanguage';
import getLanguages from '@salesforce/apex/B2BLanguageSwitcherController.getLanguages';
import getLoggedInUserLanguage from '@salesforce/apex/B2BLanguageSwitcherController.getLoggedInUserLanguage';
//import storeFront from '@salesforce/label/c.B2BStorefrontName';
const storeFront = 'Zimvie';
export default class B2bLanguageSwitcher extends NavigationMixin(LightningElement) {

    isGuestUser = isguest;
    showSpinner = false;
    showSwitcher;
    languages = [];
    preUrl;
    postUrl;
    @api tabcolour;
    

    label = {
        storeFront
    };

    dataMap = {
        'isGuest' : this.isGuestUser
    }
    @wire(getLanguages, { dataMap: '$dataMap',})
    wiredGetLanguages({ error, data }) {
        //console.log('data======'+data);
        if(data == undefined){
            return;
        }
        let dt = JSON.parse(data);
        //
        if (dt && dt.isSuccess) {
            this.languages = dt.languages;
            //if(this.isGuestUser) {
                let code = basePath.replace('/' + this.label.storeFront,'');
                this.getSelectedLang(this.languages, code.replace(/-/g, "_").replace(/\//g,""));
            //}
            this.showSwitcher = true;
            if (dt && dt.log) {
                //applicationLogging(dt.log);
            }
        } else if (error) {
            this.showSwitcher = false;
            //consoleLogging(error);
        }
    }

    connectedCallback() {
        this.handleUrl();
        var css = this.template.host.style;
        css.setProperty('--tabColour', this.tabcolour);
        if(!this.isGuestUser) {
            getLoggedInUserLanguage().then(res => {
                let result = res; 
                let usrlang = result;
                localStorage['selectedlanguage']=usrlang;
                let tempLang = usrlang == 'en_US' ? '' : usrlang;
                if(!window.location.href.includes('/Zimvie/'+tempLang)){
                    localStorage['selectedlanguage']=tempLang;
                    window.location.href = window.origin + '/Zimvie/'+tempLang;
                }
            })
            .catch(error => {
                console.log('here error in the language>>'+error);
            }); 
        }

    }

    handleUrl() {
        let url = window.location.href.split(basePath);
        this.preUrl = url[0];
        this.postUrl = url[1];
    }

    getSelectedLang(langList, val) {
        //consoleLogging('Language Value');
        //consoleLogging(val);
        if(val) {
            this.languages = JSON.parse(JSON.stringify(langList));
            let index;
            let langObj = langList.find(({ code },lIndex) => {
                if(code === val) {
                    index = lIndex;
                    return true;
                }
            });
            let selectedObj = {
                language: langObj.language,
                code: langObj.code,
                selected: true
            };
            this.languages[index] = selectedObj;
        }
    }

    selectLanguage(e) {
        e.preventDefault();
        e.stopPropagation();
        this.showSpinner = true;
        let selectedLang = e.currentTarget.value;
        
        
        if(this.isGuestUser) {
            this.handleUrl();
            localStorage['selectedlanguage']=selectedLang;
            window.open( this.preUrl + '/' + this.label.storeFront + '/' + selectedLang.replace(/_/g, "-") + this.postUrl,'_self');
        } else {
            let dataMap = {
                'langCode': selectedLang 
            };
            console.log(this.preUrl + '/' + this.label.storeFront + '/' + selectedLang.replace(/_/g, "-") + this.postUrl,'_self');
            updateLanguage({'dataMap' : dataMap})
            .then(res => {
                let result = JSON.parse(res);
                if (result && result.isSuccess) {
                    this.handleUrl();
                    localStorage['selectedlanguage']=selectedLang;
                    window.open( this.preUrl + '/' + this.label.storeFront + '/' + selectedLang.replace(/_/g, "-") + this.postUrl,'_self');
                }
            })
            .catch(error => {
                //consoleLogging(error);
            });   
        }
    }

}