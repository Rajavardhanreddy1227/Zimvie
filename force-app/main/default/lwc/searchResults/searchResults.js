import { LightningElement, api, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import contextApi from 'commerce/contextApi';
import communityId from '@salesforce/community/Id';
import getFeatureProducts  from '@salesforce/apex/B2BProductListController.getFeatureProducts';
import getNewProducts  from '@salesforce/apex/B2BProductListController.getNewProducts';
import productSearch from '@salesforce/apex/B2BProductListController.productSearch';
import getCategoryId from '@salesforce/apex/B2BProductListController.getCategoryId'
import getCartSummary from '@salesforce/apex/B2BGetInfo.getCartSummary';
import addToCart from '@salesforce/apex/B2BGetInfo.addToCart';
import FEATUREDPRODUCTS from '@salesforce/label/c.FEATUREDPRODUCTS';
import NEWPRODUCTS from '@salesforce/label/c.NEWPRODUCTS';
import LoadingProducts from '@salesforce/label/c.LoadingProducts';
import Filters from '@salesforce/label/c.Filters';
import { transformData } from './dataNormalizer';
import isguest from '@salesforce/user/isGuest';
import retrieveLoyalty from '@salesforce/apex/B2BAccountManagementController.retrieveLoyalty';
import Clear_All from '@salesforce/label/c.Clear_All';
import Items from '@salesforce/label/c.Items';
import Result from '@salesforce/label/c.Result';
/**
 * A search resutls component that shows results of a product search or
 * category browsing.This component handles data retrieval and management, as
 * well as projection for internal display components.
 * When deployed, it is available in the Builder under Custom Components as
 * 'B2B Custom Search Results'
 */
export default class SearchResults extends NavigationMixin(LightningElement) {
    /**
     * Gets the effective account - if any - of the user viewing the product.
     *
     * @type {string}
     */
     labels = {FEATUREDPRODUCTS,LoadingProducts,Filters,NEWPRODUCTS,Clear_All,Items,Result};
    fetchCategory(brand){
        debugger;
        getCategoryId({
                'brandname': brand
            })
            .then((result) => {
                this._recordId = result;
                this.triggerProductSearch();
            })
            .catch((error) => {
                this.error = error;
                console.log(error);
            });
    }
    effectiveAccountId;
    categoryId;
    loyaltyData = [];
    showFilters = 'slds-show_small';
    filterOpenForMobile = false;

    showFilterView(){
        this.showFilters = this.showFilters?'':'slds-show_small';
        this.filterOpenForMobile = !this.filterOpenForMobile;
    }

   // connectedCallback() {
        // const result = contextApi.getSessionContext();
        // result.then((response) => {
        //     this.effectiveAccountId = response.effectiveAccountId;
        // }).catch((error) => {
        //     console.log("getSessionContext result");
        //     console.log(error);
        // });
   // }

    /**
     *  Gets or sets the unique identifier of a category.
     *
     * @type {string}
     */
    @api
    get recordId() {
        return this._recordId;
    }
    set recordId(value) {
        this._recordId = value;
        this._landingRecordId = value;
        //this._refinements = [];
        //alert('calling by category id ');
        if(value != null && value != undefined && value != ''){
            this.triggerProductSearch();
        }
        
    }

    /**
     *  Gets or sets the search term.
     *
     * @type {string}
     */
    @api
    get term() {
        return this._term;
    }
    set term(value) {
        console.log('term setter called with value '+value);
        this._term = value;
        if (value) {
            //this._refinements = [];
            //alert('calling by term ');
            this.triggerProductSearch();
        }
    }

    /**
     *  Gets or sets fields to show on a card.
     *
     * @type {string}
     */
    @api
    get cardContentMapping() {
        return this._cardContentMapping;
    }
    set cardContentMapping(value) {
        this._cardContentMapping = value;
    }

    /**
     *  Gets or sets the layout of this component. Possible values are: grid, list.
     *
     * @type {string}
     */
    @api
    resultsLayout;

    /**
     *  Gets or sets whether the product image to be shown on the cards.
     *
     * @type {string}
     */
    @api
    showProductImage;

    _func = 'search';
    @api
    set func(val){
        this._func = val;
    }
    get func(){
        return this._func;
    }

    get isFeatured(){
        return this.func == 'feature' || this.func == 'new';
    }
    dataAvailable = true;
    /**
     * Triggering the search query imperatively. We can do declarative way if
     *  '_isLoading` is not required. It would be something like this.
     *
     *  @wire(productSearch, {
     *      communityId: communityId,
     *      searchQuery: '$searchQuery',
     *      effectiveAccountId: '$resolvedEffectiveAccountId'
     *  })
     *  searchHandler(res) {
     *      if (res) {
     *          if (res.error) {
     *              this.error = res.error;
     *          } else if (res.data) {
     *              this.displayData = res.data;
     *          }
     *      }
     *  }
     *
     *  Note that setting the loading status while changing the parameter could
     *  work, but somtimes it gets into a weird cache state where no network
     *  call or callback (to your searchHandler where you can reset the load
     *  state) and you get into infinite UI spinning.
     *
     * @type {ConnectApi.ProductSummaryPage}
     * @private
     */

    variationInfo;

   async triggerProductSearch() {
       console.log('resolvedEffectiveAccountId-->'+this.resolvedEffectiveAccountId);
       console.log('this._term=='+this._term);
        const searchQuery = JSON.stringify({
            searchTerm: this._term,
            categoryId: this._recordId,
            refinements: this._refinements,
            // use fields for picking only specific fields
            // using ./dataNormalizer's normalizedCardContentMapping
            //fields: normalizedCardContentMapping(this._cardContentMapping),
            page: this._pageNumber - 1,
            includePrices: true
        });

        console.log(searchQuery);
        this._isLoading = true;

        let dataMap = {
            communityId: communityId,
            searchQuery: searchQuery,
            effectiveAccountId: this.effectiveAccountId,
            selectedCountry: localStorage['myKey'],
            isGuest:isguest
        };

        console.log(dataMap)

        // communityId: communityId,
        //     searchQuery: searchQuery,
        //     effectiveAccountId: this.resolvedEffectiveAccountId
        if(this.func == 'search'){
            await productSearch({
            'dataMap': dataMap
            })
                .then((res) => {
                    let result = JSON.parse(res);
                    console.log('prod result>>>'+JSON.stringify(result));
                    this.variationInfo = result.variationInfo;
                    //let products = result.searchResult.productsPage.products;

                    //to filter out the renew and enroll product from the product list.
                    console.log('retrieveLoyalty');



                        if(this.loyaltyData.loyaltyStatus == 'Renew'){
                            if(!!result.searchResult && !!result.searchResult.productsPage && !!result.searchResult.productsPage.products && result.searchResult.productsPage.products.length != 0){
                                let filteredProducts = result.searchResult.productsPage.products.filter(prod => prod.fields.StockKeepingUnit.value != 'ELP1YR');
                                console.log('here filtered products>>>'+JSON.stringify(filteredProducts));
                                result.searchResult.productsPage.products = filteredProducts;
                            }
                         }
                         if(this.loyaltyData.loyaltyStatus == 'Enroll'){
                            if(!!result.searchResult && !!result.searchResult.productsPage && !!result.searchResult.productsPage.products && result.searchResult.productsPage.products.length != 0){
                                let filteredProducts = result.searchResult.productsPage.products.filter(prod => prod.fields.StockKeepingUnit.value != 'ELPRENEW');
                                console.log('here filtered products>>>'+JSON.stringify(filteredProducts));
                                result.searchResult.productsPage.products = filteredProducts;
                            }
                         }
                         if(this.loyaltyData.loyaltyStatus == 'None'){
                            if(!!result.searchResult && !!result.searchResult.productsPage && !!result.searchResult.productsPage.products && result.searchResult.productsPage.products.length != 0){
                                let filteredProducts = result.searchResult.productsPage.products.filter(prod => prod.fields.StockKeepingUnit.value != 'ELP1YR' && prod.fields.StockKeepingUnit.value != 'ELPRENEW');
                                console.log('here filtered products>>>'+JSON.stringify(filteredProducts));
                                result.searchResult.productsPage.products = filteredProducts;
                            }
                         }


                    this.displayData = result.searchResult;
                    console.log('this.displayData',this.displayData);
                    console.log('this.displayData.categoriesData',this.displayData.categoriesData);
                    console.log('this.displayData.layoutData',this.displayData.layoutData);
                    console.log('this.displayData.total=='+this.displayData.total);
                    this.dataAvailable = this.displayData && this.displayData.total && parseInt(this.displaydata.total) > 0 ? true : false;
                    console.log('Displayable search data :--- ');
                    console.log(this.displayData);
                    console.log(result);
                    this._isLoading = false;
                })
                .catch((error) => {
                    this.error = error;
                    this._isLoading = false;
                    console.log(error);
                });
        } else if(this.func == 'feature'){
            getFeatureProducts({
            'dataMap': dataMap
            })
                .then((result) => {
                    console.log('feature product data : '+result);
                    let res = JSON.parse(result);
                    this.variationInfo = res.variationInfo;
                    this.displayData = res.searchResult;
                    this.dataAvailable = this.displayData && this.displayData.categoriesData && this.displayData.layoutData ? true : false;
                    console.log('Displayable featured data : ');
                    console.log(this.displayData);
                    this.showCard = this.displayData.layoutData.length > 0;
                    this._isLoading = false;
                })
                .catch((error) => {
                    this.error = error;
                    this._isLoading = false;
                    console.log(error);
                });
        } else if(this.func == 'new'){
            getNewProducts({
            'dataMap': dataMap,'selectedbrand' : localStorage['selectedBrand']
            })
                .then((result) => {
                    console.log('New product data : '+result);
                    let res = JSON.parse(result);
                    this.variationInfo = res.variationInfo;
                    this.displayData = res.searchResult;
                    this.dataAvailable = this.displayData && this.displayData.categoriesData && this.displayData.layoutData ? true : false;
                    console.log('Displayable new data : ');
                    console.log(this.displayData);
                    this.showCard = this.displayData.layoutData.length > 0;
                    this._isLoading = false;
                })
                .catch((error) => {
                    this.error = error;
                    this._isLoading = false;
                    console.log(error);
                });
        }

    }

    getLoyaltyData(accountId){
        retrieveLoyalty({
            accId: accountId
        }).then((results) => {
            console.log('retrieveLoyalty',JSON.stringify(results));
             this.loyaltyData = JSON.parse(results);

        }).catch((error) => {
            console.log('inside search result retrieveLoyalty error');
            console.log(error);
        });

    }

    get ProductHeader(){
        if(this.func == 'feature'){
            return this.labels.FEATUREDPRODUCTS;
        } else if(this.func == 'new'){
            return this.labels.NEWPRODUCTS;
        }
    }

    showCard = false;

    /**
     * Gets the normalized component configuration that can be passed down to
     *  the inner components.
     *
     * @type {object}
     * @readonly
     * @private
     */
    get config() {
        return {
            layoutConfig: {
                resultsLayout: this.resultsLayout,
                cardConfig: {
                    showImage: this.showProductImage,
                    resultsLayout: this.resultsLayout,
                    actionDisabled: this.isCartLocked
                }
            }
        };
    }

    /**
     * Gets or sets the normalized, displayable results for use by the display components.
     *
     * @private
     */
    get displayData() {

        console.log('display categoriesData is ');
        console.log(this._displayData?.categoriesData);
        return this._displayData || {};
    }
    set displayData(data) {
        this._displayData = transformData(data, this._cardContentMapping,this.variationInfo);
    }

    /**
     * Gets whether product search is executing and waiting for result.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get isLoading() {
        return this._isLoading;
    }

    /**
     * Gets whether results has more than 1 page.
     *
     * @type {Boolean}
     * @readonly
     * @private
     */
    get hasMorePages() {
        return this.displayData.total > this.displayData.pageSize;
    }

    /**
     * Gets the current page number.
     *
     * @type {Number}
     * @readonly
     * @private
     */
    get pageNumber() {
        return this._pageNumber;
    }

    /**
     * Gets the header text which shows the search results details.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get headerText() {
        let text = '';
        const totalItemCount = this.displayData.total;
        const pageSize = this.displayData.pageSize;

        if (totalItemCount > 1) {
            const startIndex = (this._pageNumber - 1) * pageSize + 1;

            const endIndex = Math.min(
                startIndex + pageSize - 1,
                totalItemCount
            );

            text = `${startIndex} - ${endIndex} of ${totalItemCount} `+this.labels.Items;
        } else if (totalItemCount === 1) {
            text = '1 '+this.labels.Result;
        }

        return text;
    }

    /**
     * Gets the normalized effective account of the user.
     *
     * @type {string}
     * @readonly
     * @private
     */
    get resolvedEffectiveAccountId() {
        const effectiveAcocuntId = this.effectiveAccountId || '';
        let resolved = null;

        if (
            effectiveAcocuntId.length > 0 &&
            effectiveAcocuntId !== '000000000000000'
        ) {
            resolved = '0038L00000B7kq4QAB';
        }
        return resolved;
    }

    /**
     * Gets whether the cart is currently locked
     *
     * Returns true if the cart status is set to either processing or checkout (the two locked states)
     *
     * @readonly
     */
    get isCartLocked() {
        const cartStatus = (this._cartSummary || {}).status;
        return cartStatus === 'Processing' || cartStatus === 'Checkout';
    }

    @track isListView;
    @track isGridView;
    @track gridIconClass = 'slds-p-around_xxx-small gridClass slds-float_right active ';
    @track listIconClass = 'slds-p-around_xxx-small listClass  slds-float_right ';

    /**
     * The connectedCallback() lifecycle hook fires when a component is inserted into the DOM.
     */
    //connectedCallback() {
     //   console.log('Testing');
     //   console.log('EffectiveAccountId-->'+this.effectiveAccountId);
      //  console.log('EffectiveAccountId-->'+this.resolvedEffectiveAccountId);

      ///  this.updateCartInformation();
   // }
   brandName;

    connectedCallback() {
        //debugger;
        this.dataAvailable=true;
        const result = contextApi.getSessionContext();
        result.then((response) => {
            this.effectiveAccountId = response.effectiveAccountId;// == '000000000000000' ? '0018L00000GssWnQAJ' : response.effectiveAccountId;
            //this.updateCartInformation();
            this.getLoyaltyData(this.effectiveAccountId);
            if(this._func != 'search'){
                this.brandName = localStorage['selectedBrand'] == 'azure' ? 'Azure' : 'Zimvie';
                this.fetchCategory(this.brandName);
            }
            //this.triggerProductSearch();
        }).catch((error) => {
            console.log("getSessionContext result");
            console.log(error);
        });
        //this.updateCartInformation();
    }

    handleSwitchLayout(e) {
        this.resultsLayout = e.currentTarget.dataset.value;
        this.gridIconClass = this.resultsLayout === 'grid' ? 'slds-p-around_xxx-small gridClass slds-float_right active' :  'slds-p-around_xxx-small slds-float_right gridClass ';
        this.listIconClass = this.resultsLayout === 'list' ? 'slds-p-around_xxx-small listClass  slds-float_right active' :  'slds-p-around_xxx-small  slds-float_right listClass ';
        this.triggerProductSearch();
    }

    /**
     * Handles a user request to add the product to their active cart.
     *
     * @private
     */
    handleAction(evt) {
        evt.stopPropagation();

        addToCart({
            communityId: communityId,
            productId: evt.detail.productId,
            quantity: '1',
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then(() => {
                this.dispatchEvent(
                    new CustomEvent('cartchanged', {
                        bubbles: true,
                        composed: true
                    })
                );
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Your cart has been updated.',
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
            })
            .catch(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message:
                            '{0} could not be added to your cart at this time. Please try again later.',
                        messageData: [evt.detail.productName],
                        variant: 'error',
                        mode: 'dismissable'
                    })
                );
            });
    }

    /**
     * Handles a user request to clear all the filters.
     *
     * @private
     */
    handleClearAll(/*evt*/) {
        this._refinements = [];
        this._recordId = this._landingRecordId;
        this._pageNumber = 1;
        this.template.querySelector('c-search-filter').clearAll();
        this.triggerProductSearch();
    }

    /**
     * Handles a user request to navigate to the product detail page.
     *
     * @private
     */
    handleShowDetail(evt) {
        evt.stopPropagation();

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: evt.detail.productId,
                actionName: 'view'
            }
        });
    }

    /**
     * Handles a user request to navigate to previous page results page.
     *
     * @private
     */
    handlePreviousPage(evt) {
        evt.stopPropagation();

        this._pageNumber = this._pageNumber - 1;
        this.triggerProductSearch();
    }

    /**
     * Handles a user request to navigate to next page results page.
     *
     * @private
     */
    handleNextPage(evt) {
        evt.stopPropagation();

        this._pageNumber = this._pageNumber + 1;
        this.triggerProductSearch();
    }

    handlePageSelect(evt) {
        evt.stopPropagation();

        this._pageNumber = evt.detail;
        this.triggerProductSearch();
    }

    /**
     * Handles a user request to filter the results from facet section.
     *
     * @private
     */
    handleFacetValueUpdate(evt) {
        evt.stopPropagation();

        this._refinements = evt.detail.refinements;
        this._pageNumber = 1;
        this.triggerProductSearch();
    }



    /**
     * Handles a user request to show a selected category from facet section.
     *
     * @private
     */
    handleCategoryUpdate(evt) {
        evt.stopPropagation();
        console.log('Category Search Start');
        this._recordId = evt.detail.categoryId;
        this._pageNumber = 1;
        this.triggerProductSearch();
    }

    /**
     * Ensures cart information is up to date
     */
    updateCartInformation() {
        getCartSummary({
            communityId: communityId,
            effectiveAccountId: this.resolvedEffectiveAccountId
        })
            .then((result) => {
                console.log('Result-->'+JSON.stringify(result));
                this._cartSummary = result;
            })
            .catch((e) => {
                // Handle cart summary error properly
                // For this sample, we can just log the error
                console.log(e);
            });
    }

    _displayData;
    _isLoading = false;
    _pageNumber = 1;
    _refinements = [];
    _term;
    _recordId;
    _landingRecordId;
    _cardContentMapping;
    _effectiveAccountId;
    /**
     * The cart summary information
     * @type {ConnectApi.CartSummary}
     */
    _cartSummary;
}