import { LightningElement, api,wire} from 'lwc';
import isguest from '@salesforce/user/isGuest';
import getMetadataDetails from '@salesforce/apex/b2bSiteImageController.getMetadataDetails';
import getProductDetails from '@salesforce/apex/b2bSiteImageController.getProductDetails';
import getCategoryDetails from '@salesforce/apex/b2bSiteImageController.getCategoryDetails';

export default class B2bSiteImageComponent extends LightningElement {
    headerDescription;
    header;
    @api 
    set metaconfgroupkey(val){
        this._metaconfgroupkey = val;
        this.fetchData();
    }
    get metaconfgroupkey(){
        return this._metaconfgroupkey;
    }
    imageDetails;
    error;
    imageSizeCss;
    showDetails;
    isShopByCategory;
    isBioMaterial;
    isCarousel;
    newTagCSS;
    isZimvieBrand;

    fetchData(){
        let metaKeyVal = this.metaconfgroupkey;
        let countryVal = isguest == true? localStorage['myKey'] : 'LogedinUser';
        let brandVal = localStorage['selectedBrand'];
        let langVal = localStorage['selectedlanguage'];
        if(brandVal == 'azure'){
            this.newTagCSS = 'new-tag-azure';
            this.isZimvieBrand = false;
        }
        else{
            this.newTagCSS = 'new-tag-zimvie';
            this.isZimvieBrand = true;
        }
        getMetadataDetails({metaConfGroupKey: metaKeyVal,
                            country: countryVal,
                            brand: brandVal,
                            language: langVal})
        .then((result) => {
            this.error = undefined;
            if(result.length > 0){
                this.header = result[0].SiteImageGroup__r.HeaderTitle__c;
                this.headerDescription = result[0].SiteImageGroup__r.HeaderDescription__c;
                if(metaKeyVal == "ShopByCategory"){
                    this.isShopByCategory = true;
                    getCategoryDetails({metadaDetails: result})
                        .then((categoryImageResult) => {
                            this.imageDetails = categoryImageResult;
                            if(this.imageDetails.length > 0){
                                this.showDetails = true;
                            }
                    })
                }
                else if(metaKeyVal == "BioMaterials"){
                    this.isBioMaterial = true;
                    getProductDetails({metadaDetails: result})
                        .then((productImageResult) => {
                            this.imageDetails = productImageResult;
                            if(this.imageDetails.length > 0){
                                this.showDetails = true;
                            }
                        })
                }
                else if(metaKeyVal == "Carousel"){
                    this.imageDetails = result;
                    this.isCarousel = true;
                    this.showDetails = true;
                }
                this.imageSizeCss = 'imageCss slds-col slds-small-size--1-of-1 slds-large-size_1-of-' + result.length;
                this.imageSizeCss_bio = 'imageCssBio slds-col slds-small-size--1-of-1 slds-large-size_1-of-' + result.length;
            }
        })
        .catch((error) => {
            this.imageDetails = undefined;
            this.error = error;
        });
    }
}