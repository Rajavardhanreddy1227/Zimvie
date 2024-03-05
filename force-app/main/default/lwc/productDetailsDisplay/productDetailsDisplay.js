import { LightningElement, api,wire,track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import fetchProductsFromApex from '@salesforce/apex/B2BGetInfo.fetchProductsFromApex';
import ProductOptionsLabel from '@salesforce/label/c.ProductOptionsLabel';
import SKULabel from '@salesforce/label/c.SKULabel';
import DiameterLabel from '@salesforce/label/c.DiameterLabel';
import LengthLabel from '@salesforce/label/c.LengthLabel';
import QuantityLabel from '@salesforce/label/c.QuantityLabel';
import OnlineAvailabilityLabel from '@salesforce/label/c.OnlineAvailabilityLabel';
import OrderLabel from '@salesforce/label/c.OrderLabel';
import AddtoCartLabel from '@salesforce/label/c.AddtoCartLabel';
import InstockLabel from '@salesforce/label/c.InstockLabel';
import SignToBuy from '@salesforce/label/c.SignToBuy';
import AddToList from '@salesforce/label/c.AddToList';
import DescriptionLabel from '@salesforce/label/c.DescriptionLabel';
import OutStock from '@salesforce/label/c.OutStock';
import WholeNumberLabel from '@salesforce/label/c.WholeNumberLabel';
import BackOrder from '@salesforce/label/c.BackOrder';
import Profile from '@salesforce/label/c.Profile';
import EmergenceProfile from '@salesforce/label/c.Emergence_Profile';
import UnitPrice from '@salesforce/label/c.UnitPrice';
import isguest from '@salesforce/user/isGuest';
import basePath from '@salesforce/community/basePath';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ToastContainer from 'lightning/toastContainer';
import communityId from '@salesforce/community/Id';
import Your_Price from '@salesforce/label/c.Your_Price';
import LightningConfirm from 'lightning/confirm';
import B2B_PDP_Error_Msg from '@salesforce/label/c.B2B_PDP_Error_Msg';
import B2B_Error_Msg_Label from '@salesforce/label/c.B2B_Error_Msg_Label';
import B2B_Cart_RMA_Msg from '@salesforce/label/c.B2B_Cart_RMA_Msg';
import { CartSummaryAdapter } from "commerce/cartApi";
import getRMACartDetail from '@salesforce/apex/B2BCartController.getRMACartDetail';

// A fixed entry for the home page.
const homePage = {
    name: 'Home',
    type: 'standard__namedPage',
    attributes: {
        pageName: 'home'
    }
};

export default class ProductDetailsDisplay extends NavigationMixin(
    LightningElement
) {

    isguest = isguest;
    showDesc = true;
    cartId;
    descIcon = 'utility:chevronup';
    labels = {
        ProductOptionsLabel,
        SKULabel,
        DiameterLabel,
        LengthLabel,
        QuantityLabel,
        OnlineAvailabilityLabel,
        OrderLabel,
        AddtoCartLabel,
        InstockLabel,
        SignToBuy,
        AddToList,
        DescriptionLabel,
        OutStock,
        WholeNumberLabel,
        BackOrder,
        Profile,
        EmergenceProfile,
        UnitPrice,
        Your_Price,
        B2B_PDP_Error_Msg,
        B2B_Error_Msg_Label,
        B2B_Cart_RMA_Msg

    }

    @api
    customFields;

    @api
    cartLocked;

    @api
    description;

    @api
    image;

    @api
    inStock = false;

    @api
    name;

    @api
    price;

    @api
    sku;

    @api
    showFilterOptions

    @api
    media

    @api
    hideQuantity;

    @api
    hideAddToCart;
    @api
    hideSaveForLater;

    _invalidQuantity = false;
    _quantityFieldValue = 1;
    _categoryPath;
    _resolvedCategoryPath = [];
    priceFirstRange=0;
    priceLastRange=0;
    priceCurrency;

    // A bit of coordination logic so that we can resolve product URLs after the component is connected to the DOM,
    // which the NavigationMixin implicitly requires to function properly.
    _resolveConnected;
    _connected = new Promise((resolve) => {
        this._resolveConnected = resolve;
    });

    connectedCallback() {
        this._resolveConnected();
    }

    disconnectedCallback() {
        this._connected = new Promise((resolve) => {
            this._resolveConnected = resolve;
        });
    }
       @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
     if(!data){
            return;
           }
       else if (data) {
            console.log("Product Detail Cart--- ", data);
            console.log("Product Detail Cart ID---", data.cartId);
            console.log("Cart Product Count",this.cartProductCount);
            this.cartProductCount=data.totalProductCount;        
            this.cartId=data.cartId;
            if(this.cartId!=undefined){
              this.getCartDetail();
            }
           } else if (error) {
             console.error(error);
           //  alert('RMA Error');
        }
    }
    isRMACart = false;
getCartDetail(){
 console.log('GetCartDetail--- ');
        let mapParams = {
            cartId : this.cartId
        }
         getRMACartDetail({
            mapParams: mapParams
        }).then((results) => {
            console.log('getRMACartDetail results- ',results);
            this.isRMACart = results.IsRMACart;
        }).catch((error) => {
            console.log('getRMACartDetail error');
            console.log(error);
       
        });

}
    @api
    get categoryPath() {
        return this._categoryPath;
    }

    set categoryPath(newPath) {
        this._categoryPath = newPath;
        this.resolveCategoryPath(newPath || []);
    }

    get hasPrice() {
        return ((this.price || {}).negotiated || '').length > 0;
    }

    /**
     * Gets whether add to cart button should be displabled
     *
     * Add to cart button should be disabled if quantity is invalid,
     * if the cart is locked, or if the product is not in stock
     */
    get _isAddToCartDisabled() {
        return this._invalidQuantity || this.cartLocked;//|| !this.inStock
    }

    handleQuantityChange(event) {
        if (event.target.validity.valid && event.target.value) {
            this._invalidQuantity = false;
            this._quantityFieldValue = event.target.value;
        } else {
            this._invalidQuantity = true;
        }
    }

    /**
     * Emits a notification that the user wants to add the item to their cart.
     *
     * @fires ProductDetailsDisplay#addtocart
     * @private
     */
    async notifyAddToCart(event) {
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
        console.log('Event Detail=='+event.target._quantityFieldValue);
        let buttonName = event.target.dataset.name;
        console.log('buttonName=='+buttonName);
        let prodId = buttonName == 'parentButton' ? null : event.target.dataset.id;
        let varqty;
        console.log('prodId=='+prodId);
        if(prodId != null){
            this.filteredProducts.forEach(currentItem => {
                if(currentItem.Id == prodId){
                    if(currentItem.selectedQty==undefined){
                    varqty = 0;
                    }else{
                       varqty = currentItem.selectedQty; 
                    }
                }
            });
        }
        if(varqty==0){
             this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.labels.B2B_Error_Msg_Label,
                        message: this.labels.B2B_PDP_Error_Msg,
                        variant: 'Error',
                        mode: 'dismissable'
                    })
                );
                return;
        }
      //  toastMsg;
       // return;
        let qty = buttonName == 'parentButton' ? this._quantityFieldValue : varqty;
        console.log('qty=='+qty);
        let params = {quantity:qty,prodId:prodId};
        this.dispatchEvent(
            new CustomEvent('addtocart', {
                detail : params
            })
        );
    }

    /**
     * Emits a notification that the user wants to add the item to a new wishlist.
     *
     * @fires ProductDetailsDisplay#createandaddtolist
     * @private
     */
    notifyAddToList() {
        var selectedEvent = new CustomEvent('addtolist', { detail:        
            {prodId : null}});
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }
    notifyVariationAddToList(event) {
        let prodId = event.target.dataset.id;
        console.log('prodId='+prodId);
        var selectedEvent = new CustomEvent('addtolist', { detail:        
            {prodId : prodId}});
        // Dispatches the event.
        this.dispatchEvent(selectedEvent);
    }

    /**
     * Updates the breadcrumb path for the product, resolving the categories to URLs for use as breadcrumbs.
     *
     * @param {Category[]} newPath
     *  The new category "path" for the product.
     */
    resolveCategoryPath(newPath) {
        const path = [homePage].concat(
            newPath.map((level) => ({
                name: level.name,
                type: 'standard__recordPage',
                attributes: {
                    actionName: 'view',
                    recordId: level.id
                }
            }))
        );

        this._connected
            .then(() => {
                const levelsResolved = path.map((level) =>
                    this[NavigationMixin.GenerateUrl]({
                        type: level.type,
                        attributes: level.attributes
                    }).then((url) => ({
                        name: level.name,
                        url: url
                    }))
                );

                return Promise.all(levelsResolved);
            })
            .then((levels) => {
                this._resolvedCategoryPath = levels;
            });
    }

    /**
     * Gets the iterable fields.
     *
     * @returns {IterableField[]}
     *  The ordered sequence of fields for display.
     *
     * @private
     */
    get _displayableFields() {
        // Enhance the fields with a synthetic ID for iteration.
        return (this.customFields || []).map((field, index) => ({
            ...field,
            id: index
        }));
    }

    @api
    isVariationParent;
    _variations;
    @api

    set variations(val){
        console.log('variants reached home:::');
        console.log(val);
        this._variations = val;
        this.products = val;
        if(val){
            this.generatePicklistValues();
            this.filterProducts([],false);
        }
        
    }
    get variations(){
        return this._variations;
    }

    
    products = [];
    filteredProducts = null;
    diameterOptions = [];
    profileOptions = [];
    lengthOptions = [];
    diameterValue = '';
    profileValue = '';
    lengthValue = '';
    @track filterattributes = [];
    @track attributesLable = [];
    pfilters=[];
    isFilterResult = true;
    @track filterProdExist = true;

    get qtyOptions()
    {
        let arr = [];
        for(let i = 0; i <= 10; i++) {
            arr.push({
                label: i.toString(),
                value: i.toString()
            });
        }
        return arr;
    }

    generatePicklistValues() {
        const diameters = new Set();
        const profiles = new Set();
        const lengths = new Set();
        console.log('this.products::::'+JSON.stringify(this.products));
        console.log(this.products);
        this.products?.forEach(product => {
            product.selectedAttributes.forEach(attribute => {
                if (attribute.apiName === 'Diameter__c') {
                    diameters.add(attribute.value);
                } else if (attribute.apiName === 'Emergency_Profile__c') {
                    profiles.add(attribute.value);
                } else if (attribute.apiName === 'Length__c') {
                    lengths.add(attribute.value);
                }
            });
        });


        this.filterattributes=[];
        
        this.products?.forEach(product => {
            product.selectedAttributes.forEach(attribute => {
                let filterattributesvalue={};
                let options=[];
                if(this.filterattributes.length == 0){
                    options.push({label: attribute.value, value: attribute.value});
                    filterattributesvalue.label = attribute.label;
                    filterattributesvalue.value = '';
                    filterattributesvalue.options=options;
                    filterattributesvalue.apiName = attribute.apiName;
                    this.filterattributes.push(filterattributesvalue);
                }
                else{
                    let option = [];
                    let filatri = [];
                    filatri = this.filterattributes.filter(result => (result.apiName == attribute.apiName));
                    console.log('here filatriout>>>'+JSON.stringify(filatri));
                    
                    if(filatri.length != 0){
                        option = filatri[0].options;
                        console.log('here filatri>>>'+JSON.stringify(filatri));
                        if(option.filter(op => op.value == attribute.value).length == 0){
                            option.push({label: attribute.value, value: attribute.value});
                            this.filterattributes.filter(result => (result.apiName == attribute.apiName))[0].options = option;
                        }
                       

                    }
                    else{
                        options.push({label: attribute.value, value: attribute.value});
                        filterattributesvalue.label = attribute.label;
                        filterattributesvalue.value = '';
                        filterattributesvalue.options=options;
                        filterattributesvalue.apiName = attribute.apiName;
                        this.filterattributes.push(filterattributesvalue);

                    }

                }
                
                
            });
        });
        console.log('filterattributes>>>>'+JSON.stringify(this.filterattributes));

        console.log('profiles values>>'+JSON.stringify(profiles));
        this.diameterOptions = Array.from(diameters).map(option => ({ label: option, value: option }));
        this.profileOptions = Array.from(profiles).map(option => ({ label: option, value: option }));
        this.lengthOptions = Array.from(lengths).map(option => ({ label: option, value: option }));
        console.log('profile options>>'+JSON.stringify(this.profileOptions));
    }

    filterProducts(prodfilters,isfilter) {
        /*let json1 = this.products?.filter(product =>
            (!this.diameterValue || product.selectedAttributes.some(attribute => attribute.apiName === 'Diameter__c' && attribute.value === this.diameterValue)) &&
            (!this.profileValue || product.selectedAttributes.some(attribute => attribute.apiName === 'Emergency_Profile__c' && attribute.value === this.profileValue)) &&
            (!this.lengthValue || product.selectedAttributes.some(attribute => attribute.apiName === 'Length__c' && attribute.value === this.lengthValue))
        );*/
        this.filterProdExist = true;
        this.attributesLable = [];
        this.filteredProducts = [];
        this.isFilterResult = false;
        let json1;
        if(isfilter){
            let res = [];
            
            for(let i= 0; i<this.products.length; i++){
                let ifexist = true;
                for(let j=0;j<prodfilters.length;j++){
                    if(this.products[i].selectedAttributes.filter(fil => (fil.apiName == prodfilters[j].apiname && fil.value == prodfilters[j].value)).length == 0){
                        ifexist = false;
                        break;
                    }
                }
                if(ifexist){
                    res.push(this.products[i]);
                }
            }
            json1= res;
            console.log('here json1>>>'+JSON.stringify(json1));
            
        }else{
             json1 = this.products;
        }
        
        let idSet = [];
        let json2;
        if(json1.length != 0){

        json1?.forEach(currentItem => {
            idSet.push(currentItem.productId);
        });

        fetchProductsFromApex({ records: idSet, communityId:communityId})
		.then(result => {
            console.log('result==='+result);
			json2 = JSON.parse(result);
            function compare( a, b ) {
                if(parseFloat(a.unitPrice) > parseFloat(b.unitPrice)){
                   return 1;
                }
                if(parseFloat(a.unitPrice) < parseFloat(b.unitPrice)){
                    return -1;
                }
                return 0;
            }
            json2.sort(compare);
            this.priceFirstRange = json2[0].unitPrice;
            this.priceLastRange = json2[json2.length -1].unitPrice;
            this.priceCurrency = json2[0].currencyCode;
            // Parse the JSON strings into objects
            const obj1 = json1;
            const obj2 = json2;

            // Create a new object to hold the combined data
            const combinedObjArr = [];
            
            console.log('obj1>>'+JSON.stringify(obj1));
            // Loop through each object in the first array
            obj1.forEach(item => {
                const combinedObj = {};
            // Get the productId from this object
            const productId = item.productId;
            
            // Create a new object to hold the attributes for this productId
            const attributes = {};

            // Loop through each attribute in the selectedAttributes array
            item.selectedAttributes.forEach(attr => {
                // Add the attribute to the attributes object
                attributes[attr.apiName] = attr.value;
            });

            // Loop through each object in the second array to find a matching Id
            obj2.forEach(item2 => {
                if (item2.prodId === productId) {
                // If we find a match, add the SKU and attributes to the combined object
                combinedObj['Id'] = productId;
                combinedObj['SKU'] = item2.StockKeepingUnit;
                combinedObj['attributes'] = item.selectedAttributes;//attributes;
                combinedObj['InStock'] = item2.InStock;
                combinedObj['Price']=item2.unitPrice;
                combinedObj['Currency']=item2.currencyCode;
                }
            });
            combinedObjArr.push(combinedObj);
            });
            
            this.filteredProducts = combinedObjArr;
            const jsonCombined = JSON.stringify(combinedObjArr);
            console.log(jsonCombined);
            console.log('here filteredProducts>>'+JSON.stringify(this.filteredProducts));
            this.filteredProducts.forEach(res =>{
                if(this.attributesLable.length == 0){
                    this.attributesLable = res.attributes;
                }
                if(this.attributesLable.length != 0 && this.attributesLable.length < res.attributes.length){
                    this.attributesLable = res.attributes;
                }
            })

			this.error = undefined;
            this.isFilterResult = true;
            if(this.filteredProducts.length == 0){
                this.filterProdExist = false;
            }
		})
		.catch(error => {
			this.error = error;
			json2 = undefined;
		})

    }
    else{
        this.isFilterResult = true;
            if(this.filteredProducts.length == 0){
                this.filterProdExist = false;
            }

    }
    }

    handleAttributeChange(event){
        console.log('attribute value>>>'+event.target.value);
        console.log('attribute id>>>'+event.target.dataset.id);
        console.log(event);
        this.isFilterResult = false;
        let api = event.target.dataset.id;
        let val = event.target.value;
        if(this.pfilters.length != 0){
            if(this.pfilters.filter(f => f.apiname == api).length !== 0){
                this.pfilters.filter(f => f.apiname == api)[0].value = val;
            }
            if(this.pfilters.filter(f => f.apiname == api).length == 0){
                let fil = {
                    apiname:api,
                    value:val
                }
                this.pfilters.push(fil);
            }

        }else{
            let fil = {
                apiname:api,
                value:val
            }
            this.pfilters.push(fil);
        }
        console.log('pfilters>>'+JSON.stringify(this.pfilters));
        
        
        if(this.filterattributes.filter(res=> res.apiName == event.target.dataset.id).length != 0){
            this.filterattributes.filter(res=> res.apiName == event.target.dataset.id)[0].value = event.target.value;
        }
        console.log('here after selection >>>'+JSON.stringify(this.filterattributes));
        this.filterProducts(this.pfilters,true);
    }

    handleDiameterChange(event) {
        this.diameterValue = event.target.value;
        this.filterProducts();
    }

    handleProfileChange(event) {
        this.profileValue = event.target.value;
        this.filterProducts();
    }

    handleLengthChange(event) {
        this.lengthValue = event.target.value;
        this.filterProducts();
    }        

    setVariantQty(event) {
          console.log('VariantQunatity=='+event.target.value);
         let prodId = event.target.dataset.id;
         let prodList = this.filteredProducts;
         prodList.forEach(currentItem => {
             if(currentItem.Id == prodId){
                 currentItem['selectedQty'] = event.target.value;
                console.log('VariantQunatity=='+event.target.value);
             }
         });
         this.filteredProducts = prodList;
    }

    goToLogin(){
        window.location.href=window.origin+'/Zimvievforcesite/login';
        //window.location.href=basePath+'vforcesite/login';
    }

    handleShowDesc(){
        this.showDesc = !this.showDesc;
        if(this.showDesc){
            this.descIcon = 'utility:chevronup';
        }else{
            this.descIcon = 'utility:chevrondown';
        }
    }
}