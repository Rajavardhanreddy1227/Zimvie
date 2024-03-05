import {api,wire, LightningElement,track} from 'lwc';
import {NavigationMixin} from 'lightning/navigation';
import communityId from '@salesforce/community/Id';
import contextApi from 'commerce/contextApi';
import basePath from '@salesforce/community/basePath';
import FORM_FACTOR from '@salesforce/client/formFactor';
import recommendedReportLabel from '@salesforce/label/c.recommendedReportLabel';
import fetchRecommendedProducts from '@salesforce/apex/B2BRecommendedProductsController.fetchRecommendedProducts';

const LARGE = 'Large';
const MEDIUM = 'Medium';
const SMALL = 'Small';
//const communityId = '0DB8L000000Cai3WAC';
//const basePath = 'https://zimvieglobal--ecommerce.sandbox.my.site.com';
export default class B2bRecommendedProducts  extends  NavigationMixin(LightningElement)
{
    label = {
        recommendedReportLabel
    };

    cartId;
    inactiveCart;
    showRecommendedProducts = false; 
    _recordId;
    _isLoading = true;
    _cartSummary;
    _viewOnlyStorefront = false;
    effectiveAccountId;


    productList = [];
    totalCount = 0;
    pageNumber = 1;

    @track
    recommendedProductList = [];

    @api 
    pageName;

    @api
    sequence;

    @api
    fieldName;

    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        console.log('recordid is '+value);
    }

    @api
    isCartLocked;

    get limitFormFactor() {
        switch(FORM_FACTOR) {
            case LARGE:
            return 4;
            case MEDIUM:
            return 3;
            case SMALL:
            return 1;
            default:
        }
    }

    get totalPages() {
        return Math.ceil( this.totalCount/ this.limitFormFactor);
    }

    get isFirstPage() {
        return this.pageNumber === 1;
    }

    get isLastPage() {
        return this.pageNumber >= this.totalPages;
    }

    handlePrevious() {
        let len = this.limitFormFactor*this.pageNumber - this.limitFormFactor;
        this.pageNumber = this.pageNumber - 1;
        let i = this.limitFormFactor*this.pageNumber - this.limitFormFactor;
        this.recommendedProductList = this.productList.slice(i, len);
    }

    handleNext() {
        let i = this.limitFormFactor*this.pageNumber;
        this.pageNumber = this.pageNumber + 1;
        let len = this.limitFormFactor*this.pageNumber;
        this.recommendedProductList = this.productList.slice(i, len);
    }
    /*connectedCallback(){
        this.effectiveAccountId = '0018L00000GssWnQAJ';
        this.getParentProductOptionsData();
    }*/
    connectedCallback() {
        console.log('i m in connectedcallback');
        const result = contextApi.getSessionContext();
        result.then((response) => {
            console.log("getSessionContext result");
            console.log(response);
            this.effectiveAccountId = response.effectiveAccountId;
            //if(this.effectiveAccountId){
                this.getParentProductOptionsData();
            //}
        }).catch((error) => {
            console.log("getSessionContext result");
            console.log(error);
        });
    }

    getParentProductOptionsData()
    {     
        if(this.recordId)
        {
            let mapReqParams = {
                'recordId' :this.recordId,
                'communityId' : communityId,
                'pageName': 'Product Detail Page',//this.pageName,
                'sortBy' : this.fieldName,
                'sortOrder' : this.sequence
            };
            fetchRecommendedProducts({
                'dataMap' : mapReqParams
            }).then(
                (res) => 
                {
                    console.log('result in recommended products ::');
                    console.log(res);
                    let result = JSON.parse(res);
                    if(result && result.log) 
                    {
                        //applicationLogging(result.log);
                        console.log(result.log);
                    }
                    if(result && result.recommendedProducts && result.recommendedProducts.length > 0 && result.isSuccess) {
                        this.showRecommendedProducts = true;
                        this.recommendedProductList = [];
                        console.log('result');
                        console.log(result);
                        for (let productSummary of result.recommendedProducts) {
                            this.recommendedProductList.push({
                                productId: productSummary.productId,
                                productName: productSummary.productName,
                                productCode: productSummary.productCode,
                                unitPrice: productSummary.unitPrice,
                                isVariantProduct: productSummary.variant,
                                productImage: basePath + '/sfsites/c' + productSummary.image,
                                listPrice: productSummary.listPrice,
                                productQUM: productSummary.quantityOfMeasure,
                                currencyIsoCode: productSummary.currencyIsoCode
                            });
                        }
                        this.productList = this.recommendedProductList;
                        this.totalCount = this.recommendedProductList.length;
                        this.recommendedProductList = this.productList.slice(0, this.limitFormFactor);
                    } else {
                        this.showRecommendedProducts = false;
                    }
                }).catch((e) => {
                console.log(e);
            }).finally(() => {
                this._isLoading = false;
            });
        }
    }
    
    /**
     * Gets the normalized effective account of the user.
     *
     * @type {string}
     * @readonly
     * @private
     */
     get resolvedEffectiveAccountId() {
        if (this.effectiveAccountId.length > 0 && this.effectiveAccountId !== '000000000000000') 
        {
            return this.effectiveAccountId;
        } else {
            return null;
        }
    }

    /**
     * Gets whether the cart is currently locked
     *
     * Returns true if the cart status is set to either processing or checkout (the two locked states)
     *
     * @readonly
     */
    get isCartLocked() {
        return this.inactiveCart;
    }

    get viewOnlyStorefront()
    {
        return this._viewOnlyStorefront;
    }

    handleShowDetail(evt) {
        evt.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: basePath + '/product/' + evt.detail.productId
            }
        }).then(generatedUrl => {
            window.open(generatedUrl,'_blank');
        });
    }

}