import { LightningElement,api } from 'lwc';
//import {applicationLogging, consoleLogging} from 'c/b2bUtil';
//import basePath from '@salesforce/community/basePath';
import OriginalPriceLabel from '@salesforce/label/c.OriginalPriceLabel';
import ViewDetailsLabel from '@salesforce/label/c.ViewDetailsLabel';
import PriceUnavailableLabel from '@salesforce/label/c.PriceUnavailableLabel';
export default class B2bRecommendedProductListCard extends LightningElement {

    label = {
        OriginalPriceLabel,
        ViewDetailsLabel,
        PriceUnavailableLabel
    };

    @api
    get displayData() {
        return this._displayData;
    }

    set displayData(value) {
        this._displayData = value;
    }

    @api
    get cartLocked() {
        return this._cartLocked;
    }
    set cartLocked(value) {
        this._cartLocked = value;
    }

    @api
    get viewOnlyStorefront() {
        return this._viewOnlyStorefront;
    }
    set viewOnlyStorefront(value) {
        this._viewOnlyStorefront = value;
    }

    get isVariantProduct() {
        return this.displayData.isVariantProduct; 
    }
    /**
     * Gets the product price.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get price() {
        return this.displayData.unitPrice;
    }

    get imageUrl(){
        return this.displayData.productImage;
    }

    get productQOM(){
        return this.displayData.productQUM;
    }

    get listingPrice() {
        return this.displayData.listPrice;
    }

    get unitPrice() {
        return this.displayData.unitPrice;
    }

    get productName() {
        return this.displayData.productName;
    }

    get currency() {
        return this.displayData.currencyIsoCode;
    }

    get productCode() {
        return this.displayData.productCode;
    }

    get canShowListingPrice() {
        return (
            this.displayData.unitPrice &&
            this.displayData.listPrice &&
            // don't show listing price if it's less than or equal to the negotiated price.
            Number(this.displayData.listPrice) > Number(this.displayData.unitPrice)
        );
    }
    
    /**
     * Whether or not the product has price.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get hasPrice() {
        return !!this.price;
    }

    get isAddToCartDisabled()
    {
        return this.viewOnlyStorefront || this.cartLocked;
    }

    notifyShowDetail(evt) {
        evt.preventDefault();

        this.dispatchEvent(
            new CustomEvent('showdetail', {
                bubbles: true,
                composed: true,
                detail: { productId: this.displayData.productId }
            })
        );
    }

    _cartLocked;
    _displayData;
    _viewOnlyStorefront;

}