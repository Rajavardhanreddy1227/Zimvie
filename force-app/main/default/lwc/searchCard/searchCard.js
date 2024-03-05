import { LightningElement, api,wire } from 'lwc';
import {addItemToCart} from 'commerce/cartApi';
import { NavigationMixin } from 'lightning/navigation';
import PriceUnavailable from '@salesforce/label/c.PriceUnavailable';
import AddtoCartLabel from '@salesforce/label/c.AddtoCartLabel';
import ViewOptions from '@salesforce/label/c.ViewOptions';
import SignToBuy from '@salesforce/label/c.SignToBuy';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ToastContainer from 'lightning/toastContainer';
import isguest from '@salesforce/user/isGuest';
import basePath from '@salesforce/community/basePath';
import calculateDiscountOnItem from '@salesforce/apex/B2BCartController.calculateDiscountOnItem';
import LightningConfirm from 'lightning/confirm';
import { CartSummaryAdapter } from "commerce/cartApi";
import getRMACartDetail from '@salesforce/apex/B2BCartController.getRMACartDetail';
import B2B_AddToCart_SpinnerMessage from '@salesforce/label/c.B2B_AddToCart_SpinnerMessage';
import B2B_CalculateDiscount_SpinnerMessage from '@salesforce/label/c.B2B_CalculateDiscount_SpinnerMessage';
import B2B_Loading_Message from '@salesforce/label/c.B2B_Loading_Message';
import B2B_Add_To_Cart_Success_Msg from '@salesforce/label/c.B2B_Add_To_Cart_Success_Msg';
import B2B_Success_Label from '@salesforce/label/c.B2B_Success_Label';
import B2B_Error_Msg_Label from '@salesforce/label/c.B2B_Error_Msg_Label';
import B2B_Add_To_Cart_Error_Msg from '@salesforce/label/c.B2B_Add_To_Cart_Error_Msg';
import B2B_Cart_RMA_Msg from '@salesforce/label/c.B2B_Cart_RMA_Msg';
import signInURL from '@salesforce/label/c.Okta_Sign_in_URL';
/**
 * An organized display of a single product card.
 *
 * @fires SearchCard#calltoaction
 * @fires SearchCard#showdetail
 */
export default class SearchCard extends NavigationMixin(
    LightningElement
){
    labels = {
        PriceUnavailable,ViewOptions,AddtoCartLabel,SignToBuy,
        B2B_CalculateDiscount_SpinnerMessage,
        B2B_AddToCart_SpinnerMessage,
        B2B_Loading_Message,
        B2B_Add_To_Cart_Success_Msg,
        B2B_Success_Label,
        B2B_Error_Msg_Label,
        B2B_Add_To_Cart_Error_Msg,
        B2B_Cart_RMA_Msg,
        signInURL
    };
    isguest = isguest;
    messageState = B2B_Loading_Message;
    /**
     * An event fired when the user clicked on the action button. Here in this
     *  this is an add to cart button.
     *
     * Properties:
     *   - Bubbles: true
     *   - Composed: true
     *   - Cancelable: false
     *
     * @event SearchLayout#calltoaction
     * @type {CustomEvent}
     *
     * @property {String} detail.productId
     *   The unique identifier of the product.
     *
     * @export
     */

    /**
     * An event fired when the user indicates a desire to view the details of a product.
     *
     * Properties:
     *   - Bubbles: true
     *   - Composed: true
     *   - Cancelable: false
     *
     * @event SearchLayout#showdetail
     * @type {CustomEvent}
     *
     * @property {String} detail.productId
     *   The unique identifier of the product.
     *
     * @export
     */

    /**
     * A result set to be displayed in a layout.
     * @typedef {object} Product
     *
     * @property {string} id
     *  The id of the product
     *
     * @property {string} name
     *  Product name
     *
     * @property {Image} image
     *  Product Image Representation
     *
     * @property {object.<string, object>} fields
     *  Map containing field name as the key and it's field value inside an object.
     *
     * @property {Prices} prices
     *  Negotiated and listed price info
     */

    /**
     * A product image.
     * @typedef {object} Image
     *
     * @property {string} url
     *  The URL of an image.
     *
     * @property {string} title
     *  The title of the image.
     *
     * @property {string} alternativeText
     *  The alternative display text of the image.
     */

    /**
     * Prices associated to a product.
     *
     * @typedef {Object} Pricing
     *
     * @property {string} listingPrice
     *  Original price for a product.
     *
     * @property {string} negotiatedPrice
     *  Final price for a product after all discounts and/or entitlements are applied
     *  Format is a raw string without currency symbol
     *
     * @property {string} currencyIsoCode
     *  The ISO 4217 currency code for the product card prices listed
     */

    /**
     * Card layout configuration.
     * @typedef {object} CardConfig
     *
     * @property {Boolean} showImage
     *  Whether or not to show the product image.
     *
     * @property {string} resultsLayout
     *  Products layout. This is the same property available in it's parent
     *  {@see LayoutConfig}
     *
     * @property {Boolean} actionDisabled
     *  Whether or not to disable the action button.
     */

    /**
     * Gets or sets the display data for card.
     *
     * @type {Product}
     */
    @api
    displayData;

    /**
     * Gets or sets the card layout configurations.
     *
     * @type {CardConfig}
     */
    @api
    config;
    cartId;
    isRMACart = false;
    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
     if(!data){
            return;
           }
       else if (data) {
            console.log("PLP Cart--- ", data);
            console.log("PLP Cart ID---", data.cartId);
            this.cartId=data.cartId;
            if(this.cartId!=undefined){
              this.getCartDetail();
            }
           } else if (error) {
             console.error(error);
           //  alert('RMA Error');
        }
    }
    getCartDetail(){
        console.log('GetCartDetail--- ');
               let mapParams = {
                   cartId : this.cartId
               }
                getRMACartDetail({
                   mapParams: mapParams
               }).then((results) => {
                   console.log('getRMACartDetail PLP results- ',results);
                   this.isRMACart = results.IsRMACart;
               }).catch((error) => {
                   console.log('getRMACartDetail PLP error');
                   console.log(error);
              
               });
       
       }
    
    connectedCallback(){
        console.log('display data>>>'+JSON.stringify(this.displayData));
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';
    }

    @api
    isFeatured;
      
    /**
     * Gets the product image.
     *
     * @type {Image}
     * @readonly
     * @private
     */
    get image() {
        let tempVar = this.displayData.image || {};
        //console.log('val==');
        //console.log(tempVar);
        //return tempVar;
        /* 
            let img = [...this.displayData.image];
            console.log('IMG==');
            console.log(img);
            if(img && img.url){
                img.url = img.url.replace("/Zimvie", "/Zimvie/sfsites/c");
            }
            return img;
        */

        let newImg = {};
        newImg['alternateText'] = tempVar.alternateText;
        let lang = localStorage['selectedlanguage'];
        let url = '';
        console.log('lang>>'+lang);
        if(lang != undefined && lang != '' && lang != 'en_US'){
            let replacedvalue = '/Zimvie/'+lang;
            url = tempVar.url.replace(replacedvalue, "/Zimvie/sfsites/c")
        }else{
            url = tempVar.url.replace("/Zimvie", "/Zimvie/sfsites/c");
        }
        newImg['url'] = url;//tempVar.url.replace("/Zimvie", "/Zimvie/sfsites/c");
        console.log('val==');
        console.log(newImg);
        return newImg;
    }

    /**
     * Gets the product fields.
     *
     * @type {object.<string, object>[]}
     * @readonly
     * @private
     */
    get fields() {
        return (this.displayData.fields || []).map(({ name, value }, id) => ({
            id: id + 1,
            tabIndex: id === 0 ? 0 : -1,
            // making the first field bit larger
            class: id
                ? 'slds-truncate slds-text-heading_small'
                : 'slds-truncate slds-text-heading_medium',
            // making Name and Description shows up without label
            // Note that these fields are showing with apiName. When builder
            // can save custom JSON, there we can save the display name.
            value:
                name === 'Name' || name === 'Description'
                    ? value
                    : `${name}: ${value}`
        }));
    }

    /**
     * Whether or not the product image to be shown on card.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get showImage() {
        return !!(this.config || {}).showImage;
    }

    /**
     * Whether or not disable the action button.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get actionDisabled() {
        return !!(this.config || {}).actionDisabled;
    }

    /**
     * Gets the product price.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get price() {
        const prices = this.displayData.prices;
        return prices.negotiatedPrice || prices.listingPrice;
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

    get isSimple(){
        return this.displayData.productClass === 'Simple';
    }

    get minPrice(){
        return this.displayData.minPrice ? this.displayData.minPrice : 0.00;
    }

    get maxPrice(){
        return this.displayData.maxPrice ? this.displayData.maxPrice : 0.00;
    }

    get parentPrices(){
        if(this.displayData.productClass !='VariationParent' ){
            const  parentData = this.displayData.variationData;
            console.log(parentData);
            if( this.displayData.id == parentData.variantParentId){
                return parentData.minPrice;
            }
        }
       
    }

    /**
     * Gets the original price for a product, before any discounts or entitlements are applied.
     *
     * @type {string}
     */
    get listingPrice() {
        return this.displayData.prices.listingPrice;
    }

    /**
     * Gets whether or not the listing price can be shown
     * @returns {Boolean}
     * @private
     */
    get canShowListingPrice() {
        const prices = this.displayData.prices;

        return (
            prices.negotiatedPrice &&
            prices.listingPrice &&
            // don't show listing price if it's less than or equal to the negotiated price.
            Number(prices.listingPrice) > Number(prices.negotiatedPrice)
        );
    }

    /**
     * Gets the currency for the price to be displayed.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get currency() {
        return this.displayData.prices.currencyIsoCode;
    }

    /**
     * Gets the container class which decide the innter element styles.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get cardContainerClass() {
        return this.config.resultsLayout === 'grid'
            ? 'slds-box card-layout-grid'
            : 'card-layout-list';
    }

    get articleClass() {
        return this.isFeatured ? 'width:410px;' : '';
    }

    /**
     * Emits a notification that the user wants to add the item to their cart.
     *
     * @fires SearchCard#calltoaction
     * @private
     */
    showLoader = false;
    async notifyAction() {
        if(this.isRMACart){
            const result = await LightningConfirm.open({
                message: this.labels.B2B_Cart_RMA_Msg,
                variant: 'headerless',
                label: 'this is the aria-label value',
                // setting theme would have no effect
            });
            if(!result){
                return;
            }
		}
        this.showLoader = true;
        this.messageState = B2B_AddToCart_SpinnerMessage;
        addItemToCart(this.displayData.id,1).then((fulfilled) => {
                console.log("added product to cart" ,fulfilled);
                //this.calculateDiscount(fulfilled);
                this.showLoader = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.labels.B2B_Success_Label,
                        message: this.labels.B2B_Add_To_Cart_Success_Msg,//'Your cart has been updated.',
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
            }).catch(error => {
                console.log('error' ,error);
                console.log(error);
                this.showLoader = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.labels.B2B_Error_Msg_Label,
                        message:this.labels.B2B_Add_To_Cart_Error_Msg,
                        messageData: [this.displayData.name],
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
            });


        /*
        this.dispatchEvent(
            new CustomEvent('calltoaction', {
                bubbles: true,
                composed: true,
                detail: {
                    productId: this.displayData.id,
                    productName: this.displayData.name
                }
            })
        );*/
    }
    
    retryAttempt = 0;
    async retryApiCallout(inputVal){
        this.messageState = B2B_Loading_Message;
        this.retryAttempt = this.retryAttempt + 1;
        this.calculateDiscount(inputVal);
    }

    calculateDiscount(input){
        if(this.retryAttempt == 0){
            this.messageState = B2B_CalculateDiscount_SpinnerMessage;
        }
        if(this.retryAttempt == 1){
            this.messageState = 'Please wait';
        }
        console.log('calculateDiscount(fulfilled)--- ', input);
        let mapParams = {
            cartItemId : input.cartItemId
        }
        calculateDiscountOnItem({
            mapParams: mapParams
        }).then((results) => {
            console.log('calculateDiscount results- ',results);
            if(!results.isSuccess){
                if(this.retryAttempt < 2){
                    this.retryApiCallout(input);
                }else{
                    this.showLoader = false;
                    this.retryAttempt = 0;
                    console.log('there was some error in calculating discount--', results);
                }
            }else{
                this.showLoader = false;
                this.retryAttempt = 0;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.labels.B2B_Success_Label,
                        message: this.labels.B2B_Add_To_Cart_Success_Msg,//'Your cart has been updated.',
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
            }
        }).catch((error) => {
            console.log('calculateDiscount error');
            console.log(error);
            this.showLoader = false;
            this.retryAttempt = 0;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.labels.B2B_Error_Msg_Label,
                        message:this.labels.B2B_Add_To_Cart_Error_Msg,
                        messageData: [this.displayData.name],
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
        });
    }

    /**
     * Emits a notification that the user indicates a desire to view the details of a product.
     *
     * @fires SearchCard#showdetail
     * @private
     */
    notifyShowDetail(evt) {

        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/product/'+this.displayData.id
            }
        });
        /*
        evt.preventDefault();

        this.dispatchEvent(
            new CustomEvent('showdetail', {
                bubbles: true,
                composed: true,
                detail: { productId: this.displayData.id }
            })
        );*/
    }
    goToLogin(){
        console.log('here login base path>>'+basePath);
        console.log('here url>>'+window.location.href);
        window.location.href=this.labels.signInURL;//window.origin+'/Zimvievforcesite/login';
        //window.location.href=basePath+'vforcesite/login';
    }
}