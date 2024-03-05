import { LightningElement,api, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { CurrentPageReference } from 'lightning/navigation';
import isguest from '@salesforce/user/isGuest';
import Zimvie from '@salesforce/label/c.Zimvie';
import Azure from '@salesforce/label/c.Azure';
import svgLogo from '@salesforce/resourceUrl/svgLogo';
import getBrandDeatils from '@salesforce/apex/b2bSiteImageController.getBrandDetails';

export default class B2BBrandComponent extends NavigationMixin(LightningElement)
{
    labels = { Zimvie, Azure };
    isGuestUser = isguest;
    tabcolour;
    zimVie_Logo = svgLogo + '/svglogo/zimvie-top-logo.svg';
    azure_Logo = svgLogo + '/svglogo/azure-top-logo-w.svg';
    isAzure = false;
    hideComponent = false;
    isZimvieSelected;
    isAzureSelected;
    zimVie_Logo_Checkout = svgLogo + '/svglogo/zimvie-top-logo-w.svg';
    azure_Logo_Checkout = svgLogo + '/svglogo/azure-top-logo-w.svg';

    connectedCallback() {
        if (localStorage['selectedBrand'] == 'azure') {
            this.initCSSVariables('#0044FC');
        }
        else{
            this.initCSSVariables('#005DA6');
        }
        let countryVal = isguest == true ? localStorage['myKey'] : 'LogedinUser';
        getBrandDeatils({ country: countryVal })
            .then((brandList) => {
                for (var indx = 0; indx < brandList.length; indx++) {
                   if (brandList[indx].toLowerCase() == 'azure') {
                        this.isAzure = true;
                        break;
                    }
                }
            })
    }

    @wire(CurrentPageReference)
    getPageReferenceParameters(currentPageReference) {
       if (currentPageReference) {
          var pageName = currentPageReference.attributes.name;
          if(pageName == 'Current_Checkout'){
              this.hideComponent = true;
          }
          else{
              this.hideComponent = false;
          }
       }
    }

    renderedCallback() {
        if (localStorage['selectedBrand'] == 'azure') {
            this.isZimvieSelected = false;
            this.isAzureSelected = true;
            let target = this.template.querySelector('[data-id="azuretile"]');
            if (target) {
                target.checked = true;
            }
            let target2 = this.template.querySelector('[data-id="zimvietile"]');
            if (target2) {
                target2.checked = false;
            }
            this.zimVie_Logo = svgLogo + '/svglogo/zimvie-top-logo-w.svg';
            this.azure_Logo = svgLogo + '/svglogo/azure-top-logo.svg';
        } else {
            this.isZimvieSelected = true;
            this.isAzureSelected = false;
            let target = this.template.querySelector('[data-id="azuretile"]');
            if (target) {
                target.checked = false;
            }
            let target2 = this.template.querySelector('[data-id="zimvietile"]');
            if (target2) {
                target2.checked = true;
            }
            this.zimVie_Logo = svgLogo + '/svglogo/zimvie-top-logo.svg';
            this.azure_Logo = svgLogo + '/svglogo/azure-top-logo-w.svg';
        }
    }
    changebrand(event) {
        let clickedTile = event.currentTarget.dataset.id;
        if (clickedTile == 'zimvietile') {
            localStorage['selectedBrand'] = 'zimvie';
            this.zimVie_Logo = svgLogo + '/svglogo/zimvie-top-logo.svg';
            this.azure_Logo = svgLogo + '/svglogo/azure-top-logo-w.svg';
        }
        else {
            localStorage['selectedBrand'] = 'azure';
            this.zimVie_Logo = svgLogo + '/svglogo/zimvie-top-logo-w.svg';
            this.azure_Logo = svgLogo + '/svglogo/azure-top-logo.svg';
        }
        window.location = window.origin + '/Zimvie';
    }
    initCSSVariables(tabcolour) {
        var css = this.template.host.style;
        css.setProperty('--tabColour', tabcolour);
        this.tabcolour = tabcolour
    }
}