import { LightningElement, wire,track } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import INDUSTRY_FIELD from '@salesforce/schema/Account.Industry';
import validateandSaveRMADetails from '@salesforce/apex/b2BOrderManagementController.validateandSaveRMADetails';
import getShipToAddressDetails from '@salesforce/apex/b2BOrderManagementController.getShipToAddressDetails';
import saveRmaAndRmaLine from '@salesforce/apex/b2BOrderManagementController.saveRmaAndRmaLine';
import getUserDetails from '@salesforce/apex/b2BOrderManagementController.getUserDetails';
import getProductMerchandizingDetails from '@salesforce/apex/b2BOrderManagementController.getProductMerchandizingDetails';
import getLotValidationAPIReponse from '@salesforce/apex/b2BOrderManagementController.getLotValidationAPIReponse';
import getShipmentDetails from '@salesforce/apex/b2BOrderManagementController.getShipmentDetails';
import addItemsToCartApex from '@salesforce/apex/b2BOrderManagementController.addItemsToCartApex';
import contextApi from 'commerce/contextApi';
import OrderItem_OBJECT from '@salesforce/schema/OrderItem';
import ProductId_FIELD from '@salesforce/schema/OrderItem.Product2Id';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ToastContainer from 'lightning/toastContainer';
import ExternalId from '@salesforce/schema/Product2.ExternalId';
import {addItemToCart,addItemsToCart} from 'commerce/cartApi';
import { CartSummaryAdapter } from "commerce/cartApi";
import { NavigationMixin } from 'lightning/navigation';
import {updateShippingAddress,loadCheckout,notifyCheckout,restartCheckout,CheckoutInformationAdapter} from 'commerce/checkoutApi';
import Zimvie_Policy_Text from '@salesforce/label/c.Zimvie_Policy_Text';
import Note_for_tissue from '@salesforce/label/c.Note_for_tissue';
import item from '@salesforce/label/c.item';
import QuantityLabel from '@salesforce/label/c.QuantityLabel';
import Lotnumber from '@salesforce/label/c.Lotnumber';
import Expiry_Date from '@salesforce/label/c.Expiry_Date';
import Ordernumb from '@salesforce/label/c.Ordernumb';
import In_Reselleable_Condition from '@salesforce/label/c.In_Reselleable_Condition';
import Reason from '@salesforce/label/c.Reason';
import Comments from '@salesforce/label/c.Comments';
import Return_Reason from '@salesforce/label/c.Return_Reason';
import Reorder_Item_no from '@salesforce/label/c.Reorder_Item_no';
import Reorder_Quantity from '@salesforce/label/c.Reorder_Quantity';
import Patient_ID from '@salesforce/label/c.Patient_ID';
import Event_date from '@salesforce/label/c.Event_date';
import Add_Row from '@salesforce/label/c.Add_Row';
import Delete_All from '@salesforce/label/c.Delete_All';
import Exchange from '@salesforce/label/c.Exchange';
import Return from '@salesforce/label/c.Return';
import Invoice_number from '@salesforce/label/c.Invoice_number';
import LightningAlert from 'lightning/alert';
import Courtesy_Implant_Replacement_Request from '@salesforce/label/c.Courtesy_Implant_Replacement_Request';


//import saveAccounts from '@salesforce/apex/LWCExampleController.saveAccounts'
export default class B2bOrderMangement  extends NavigationMixin(LightningElement)  {
labels = {
item,
QuantityLabel,
Zimvie_Policy_Text,
Note_for_tissue,
Lotnumber,
Expiry_Date,
Ordernumb,
In_Reselleable_Condition,
Reason,
Comments,
Return_Reason,
Reorder_Item_no,
Reorder_Quantity,
Patient_ID,
Event_date,
Add_Row,
Delete_All,
Exchange,
Return,
Courtesy_Implant_Replacement_Request,
Invoice_number
}
showLoader = false;
orderNumber;
cartId;
cartProductCount=0;
userId;
userDetails;
@track mapData=new Map();
@track mapProdData=new Map();
country;
accId;
contactId;
country;
@track filterList = [];
filterListExchange = [];
filterListCourtsey = [];
selectedTabId;
keyIndex = 0;
isSpinner = false;
disableFieldQuantity=true;
isValid = false;
isValidQuant = false;
isValidLot = false;
isValidExpDate = false;
isValidReturn = false;
isValidResell = false;
isValidRetQuant = false;
isValidEventDate=false;
isValidPatiendId=false;
isValidSKU = false;
isProdRequired = true;
isReqtoSave=true;
isReturnSave=false;
//Added by Deepak
AccountNumber;
OrgId;
isModalOpen = false;
AddressDetails;
@track tableData = [];
@track isEdit = false; // Track if in edit mode
editedRowIndex = -1; // Initialize to -1
isSubmitDisabled = true;
Quantity='';
Lot='';
Return='';
Resell='';
Comments='';
Expirydate='';
Invoice='';
ShipAddressId='';
AddressName='';
OracaleAddressId='';
Item='';
ItemSku='';
Rowid='';
ShippedDate='';
RecordId='';
PriceList='';
PreviousRMAQuantity='';
OrderType='';
OrderNumber='';
LotShipQuantity='';
LotNumber='';
LotExpiryDate='';
LineNumber='';
ItemNumber='';
ErrorMessage='';
DiscountFlag='';
isChecked=false;
handleRemoveFlag=false;
billingCountry;
rmaMerchandiseDetails;
dropdownOptions = [
    { label: 'Did not need', value: 'Did not need' },
    { label: 'Customer ordered incorrectly', value: 'Customer ordered incorrectly' },
    { label: 'Returned due to backorder', value: 'Returned due to backorder' }
];
dropdownOptionsCourtesy = [
    { label: 'Dropped during surgery', value: 'Dropped during surgery' },
    { label: 'Loss of Sterility', value: 'Loss of Sterility' },
    { label: 'Placed & removed immediately during surgery', value: 'Placed & removed immediately during surgery' },
    { label: 'Other', value: 'Other' }
];
dropdownOptionsExchange = [
    { label: 'Wrong Quantity', value: 'Wrong Quantity' },
    { label: 'Not Satisfied', value: 'Not Satisfied' },
    { label: 'Outdated', value: 'Outdated' },
    { label: 'Other', value: 'Other' }
];
    Item=ProductId_FIELD;

get loaderEnabled(){
    return this.showLoader;
}
@wire(CartSummaryAdapter)
setCartSummary({ data, error }) {
    if(!data){
    // alert('RMA Cart Id Not there');
    // console.log("RMA Cart Id Not there", data.cartId);
            return;
        }
    else if (data) {
        // alert('RMA Cart Id is there',data.cartId);
        console.log("RMA Cart Data", data);
        console.log("RMA Cart Id", data.cartId);
        console.log("Cart Product Count",this.cartProductCount);
        this.cartProductCount=data.totalProductCount;        
        this.cartId=data.cartId;
        if(this.cartId!=undefined &&this.selectedTabId!='Return' && this.isReqtoSave){
            this.isReqtoSave=false;
            //   alert('Hello');
            this.saveRmaDetails();
        }
        } else if (error) {
            console.error(error);
        //  alert('RMA Error');
    }
}
connectedCallback() {
    const toastContainer = ToastContainer.instance();
    toastContainer.maxShown = 5;
    toastContainer.toastPosition = 'top-center';

    //this.handleAddRow();
    console.log('i m in connectedcallback');
    const result = contextApi.getSessionContext();
    result.then((response) => {
        console.log("getSessionContext result");
        console.log(response);
        this.userId = response.userId;
        this.accId=response.effectiveAccountId;
        this.getUserInfo();
        this.getShipmentInfo()
        
        //}
    }).catch((error) => {
        console.log("getSessionContext result");
        console.log(error);
    });

}
async saveRmaDetails(){
    this.showLoader = true;
    let mapParams;
    if(this.selectedTabId=='Return'){
        console.log('Return Cart ID',this.cartId);
        this.isReturnSave=true;
        mapParams = {
        userId: this.userId,
        accId:this.accId,
        contactId:this.contactId,
        filterList: this.filterList,
        RMAType:this.selectedTabId,

            //Added by Deepak
            AccountNumber:this.AccountNumber,
            OrgId:this.OrgId,
        }
    }
    if(this.selectedTabId=='Exchange'){
        this.isReturnSave=false;
        console.log("Filter List Exchange" ,this.filterListExchange);
        if(this.cartProductCount==0){
        this.filterListExchange.forEach((productDetails)=>{
        console.log("added product to cart" ,productDetails.ReorderItem+'-----'+productDetails.ReorderQuantity);
        addItemToCart(productDetails.ReorderItem,productDetails.ReorderQuantity);
        });
    }
        
        console.log('Exchange Outer Cart Item Details-------',this.cartId);
            if(this.cartId!=undefined){
                this.isReturnSave=true;
            mapParams = {
                userId: this.userId,    
                accId:this.accId,
                contactId:this.contactId,
                filterList: this.filterListExchange,
                RMAType:this.selectedTabId,
                cartId:this.cartId,
                }  }
                }
    if(this.selectedTabId=='Courtesy'){
        this.isReturnSave=false;
        let cartItemInput = [];
        console.log("Filter List Courtesy" ,this.filterListCourtsey);
        if(this.cartProductCount==0){
        this.filterListCourtsey.forEach((productDetails)=>{
            console.log("added product to cart" ,productDetails.ReorderItem+'-----'+productDetails.ReorderQuantity);
            addItemToCart(productDetails.ReorderItem,productDetails.ReorderQuantity);
            });
            addItemToCart('01t8L00000189XTQAY',this.filterListCourtsey.length)
        }
            console.log('Courtesy Item Details-------',this.cartId);
            if(this.cartId!=undefined){
                this.isReturnSave=true;
        mapParams = {
            userId: this.userId,
            accId:this.accId,
            contactId:this.contactId,
            filterList: this.filterListCourtsey,
            RMAType:this.selectedTabId,
            cartId:this.cartId,
            
            }
        }
    }
    if(this.isReturnSave){
        this.isReqtoSave=false;
        console.log('mapParams',mapParams)
        validateandSaveRMADetails({
        mapParams: mapParams
        }) .then((result) => {
        if (result.isSuccess) {
            this.showLoader = false;
            
            if(this.selectedTabId=='Exchange'){
                // console.log("Filter List Exchange" ,this.filterListExchange);
                // this.filterListExchange.forEach((productDetails)=>{
                // console.log("added product to cart" ,productDetails.ReorderItem+'-----'+productDetails.ReorderQuantity);
                // addItemToCart(productDetails.ReorderItem,productDetails.ReorderQuantity);
                // });
            
                console.log('Cart Item Details-------',this.cartId);
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/cart/'
                    }
                });
            }
            if(this.selectedTabId=='Courtesy'){

                // let cartItemInput = [];
                // console.log("Filter List Courtesy" ,this.filterListCourtsey);
                
                // this.filterListCourtsey.forEach((productDetails)=>{
                // console.log("added product to cart" ,productDetails.ReorderItem+'-----'+productDetails.ReorderQuantity);
                
                // let tempObj = {};
                // tempObj['productId'] = productDetails.ReorderItem;
                // tempObj['quantity'] = productDetails.ReorderQuantity;
                // cartItemInput.push(tempObj)
                // });
                // cartItemInput.push({productId:'01t8L00000189XTQAY',quantity:this.filterListCourtsey.length});
                // console.log('cartItemInput===');
                // console.log(cartItemInput);

                // // Set Map Values
                // cartItemInput.forEach((element) => addItemToCart(element.productId, element.quantity));
                
                /*var result = cartItemInput.reduce(function(map, obj) {
                    map[obj.productId] = obj.quantity;
                    return map;
                }, {});
                
                console.log('result='+result);

                addItemsToCartApex({mapProdIds:result})
                .then((results) => {
                    console.log('Cart updated successfully.');
                    
                }).catch((error) => {
                    console.log('Error in updating cart');
                    console.log(error);
                });*/
                this[NavigationMixin.Navigate]({
                    type: 'standard__webPage',
                    attributes: {
                        url: '/cart/'
                    }
                });
            }
        
            console.log('SuccessResult',result);
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success!',
                    message: 'Record save Successfully',
                    variant: 'Success'
                })
            )
            this. removeAllRows();
        }
        })
        .catch((error) => {
        this.showLoader = false;
        console.log('saveRmaDetails catch error');
        console.log(error);
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error!',
                message: 'Something went wrong!',
                variant: 'error'
            })
        )
    })
    // await addItemsToCart(cartItemInput).then((fulfilled) => {
    //         console.log("added products to cart result");
    //         console.log(fulfilled);
    //     }).catch(error => {
    //         console.log('error in adding items to cart : ');
    //         console.log(error);
    //     });
    // console.log('items added');
}
}
getUserInfo(){
    getUserDetails({
        userId: this.userId
    }).then((results) => {
        console.log('getUserDetails',JSON.stringify(results));
        this.userDetails=JSON.parse(results);
        if(this.userDetails[0].Country=='United States'||this.userDetails[0].Country=='Canada'){
            this.country=true;
        }
        else{
            this.country=false;
        }
        this.contactId=this.userDetails[0].ContactId

        //Added by Deepak
        this.AccountNumber=this.userDetails[0].Account.AccountNumber;
        this.OrgId=this.userDetails[0].Account.Oracle_Operating_Unit__c;
         //Added by Nitesh
        this.billingCountry=this.userDetails[0].Account.BillingCountry
    }).catch((error) => {
        console.log('getUserDetails error');
        console.log(error);
    });

}

getShipmentInfo(){
    getShipmentDetails({
        accId: this.accId
    }).then((results) => {
        console.log('getShipmentDetailsParse',(results));

        for(var key in results){
            // this.mapData.push({value:results[key], key:key});
                this.mapData.set(key,results[key]);
            
        }
        console.log('getShipmentDetailsmapData',(this.mapData));
    }).catch((error) => {
        console.log('getShipmentDetails error');
        console.log('getShipmentDetails error'+error);
    });

}
get undefinedVal(){
    return undefined;
}
isSkuReturnable(){
    console.log('isSkuReturnable Value',this.Item);
    console.log('billingCountry Value',this.billingCountry);
    getProductMerchandizingDetails({
        itemId: this.Item,
        bCountry:this.billingCountry
    }).then((results) => {
        console.log('getProductMerchandizingDetails',JSON.stringify(results));
        this.rmaMerchandiseDetails=JSON.parse(results);
        console.log('rmaMerchandiseDetails',this.rmaMerchandiseDetails);
        // if(this.rmaMerchandiseDetails[0].Is_Returnable_or_Exchangeable__c=false){
        //     this.showToastMessage('error', 'SkU is not returnable for the country', 'Error');
        //     return;
        // }
        }).catch((error) => {
        console.log('getProductMerchandizingDetails error');
        console.log(error);
    });

}
handleValueSelectedOnRMA(event){
    if(this.selectedTabId=='Return'){
    let tempArray=this.filterList;
    this.Item = event.detail.value.id;
    console.log('handleValueSelectedOnRMA Value',this.Item);
    this.isSkuReturnable();
    //Added by Deepak
    this.ItemSku = event.detail.value.mainField;
    this.Rowid=new Date().getTime();
    this.filterList = JSON.parse(JSON.stringify(tempArray));
    console.log('this.filterList==');
    console.log(this.filterList);
    }
    if(this.selectedTabId=='Exchange'){
        let tempArray=this.filterListExchange;
        tempArray[event.detail.index].Item = event.detail.value.id;
        this.filterListExchange = JSON.parse(JSON.stringify(tempArray));
        console.log('this.filterListExchange==');
        console.log(this.filterListExchange);
        }
        if(this.selectedTabId=='Courtesy'){
            let tempArray=this.filterListCourtsey;
            tempArray[event.detail.index].Item = event.detail.value.id;
            this.filterListCourtsey = JSON.parse(JSON.stringify(tempArray));
            console.log('this.filterListCourtsey==');
            console.log(this.filterListCourtsey);
            }
}
//Added by Deepak
async handleValueSelectedOnShipTo(event){
    if(this.selectedTabId=='Return'){
        this.ShipAddressId = event.detail.value.id;
        this.AddressName = event.detail.value.mainField;
        this.OracaleAddressId = event.detail.value.subField;
    /*let tempArray=this.filterList;
    tempArray[event.detail.index].ShipAddressId = event.detail.value.id;
    tempArray[event.detail.index].AddressName = event.detail.value.mainField;
    tempArray[event.detail.index].OracaleAddressId = event.detail.value.subField;
    this.filterList = JSON.parse(JSON.stringify(tempArray));*/
    await getShipToAddressDetails({
        AddressId:event.detail.value.id
    }).then((results) => {
        console.log('Address Details',JSON.stringify(results));
        const Address=JSON.parse(results)[0];
        this.AddressDetails='Ship To Address: ';
        this.AddressDetails+=Address.Street?Address.Street+',':'';
        this.AddressDetails+=Address.City?Address.City+',':'';
        this.AddressDetails+=Address.State?Address.State+'-':'';
        this.AddressDetails+=Address.PostalCode?Address.PostalCode+',':'';
        this.AddressDetails+=Address.Country?Address.Country+'.':'';
    }).catch((error) => {
        console.log('getShipToAddressDetails error');
        console.log(error);
    });
    this.handleAlertOpen();
    }
    if(this.selectedTabId=='Exchange'){
        let tempArray=this.filterListExchange;
        tempArray[event.detail.index].Item = event.detail.value.id;
        this.filterListExchange = JSON.parse(JSON.stringify(tempArray));
        console.log('this.filterListExchange==');
        console.log(this.filterListExchange);
        }
        if(this.selectedTabId=='Courtesy'){
            let tempArray=this.filterListCourtsey;
            tempArray[event.detail.index].Item = event.detail.value.id;
            this.filterListCourtsey = JSON.parse(JSON.stringify(tempArray));
            console.log('this.filterListCourtsey==');
            console.log(this.filterListCourtsey);
            }
}
handleValueSelectedOnReturnRMA(event){
    
    if(this.selectedTabId=='Exchange'){
        let tempArray=this.filterListExchange;
        tempArray[event.detail.index].ReorderItem = event.detail.value.id;
        this.filterListExchange = JSON.parse(JSON.stringify(tempArray));
        console.log('this.filterListExchange==');
        console.log(this.filterListExchange);
        }
        if(this.selectedTabId=='Courtesy'){
            let tempArray=this.filterListCourtsey;
            tempArray[event.detail.index].ReorderItem = event.detail.value.id;
            this.filterListCourtsey = JSON.parse(JSON.stringify(tempArray));
            console.log('this.filterListCourtsey==');
            console.log(this.filterListCourtsey);
            }
}
handleValueRemovedOnRMA(event){
    if(this.selectedTabId=='Return'){
       this.Item = null;
       this.ItemSku = null;
    // let tempArray=this.filterList;
    // tempArray[event.detail].Item = null;
    // tempArray[event.detail].ItemSku = null;
    // this.filterList = JSON.parse(JSON.stringify(tempArray));
    console.log('this.filterList==');
    console.log(this.filterList);
    }
    if(this.selectedTabId=='Exchange'){
        let tempArray=this.filterListExchange;
        tempArray[event.detail].ReorderItem = null;
        this.filterListExchange = JSON.parse(JSON.stringify(tempArray));
        console.log('this.filterListExchange==');
        console.log(this.filterListExchange);
        }
        if(this.selectedTabId=='Courtesy'){
            let tempArray=this.filterListCourtsey;
            tempArray[event.detail].ReorderItem = null;
            this.filterListCourtsey = JSON.parse(JSON.stringify(tempArray));
            console.log('this.filterListCourtsey==');
            console.log(this.filterListCourtsey);
            }
}
//Added by Deepak
handleValueRemovedOnShipTo(event){
    if(this.selectedTabId=='Return'){
        if(this.tableData.length>0){
           this.showToastMessage('error', 'Please remove all the before changing the Ship To Address.', 'Error');
            return;
        }else{
            this.ShipAddressId = '';
            this.AddressName = '';
            this.OracaleAddressId = '';
        }
    
   
    /*this.filterList = JSON.parse(JSON.stringify(tempArray));
    console.log('this.filterList==');
    console.log(this.filterList);*/
    }
    if(this.selectedTabId=='Exchange'){
        let tempArray=this.filterListExchange;
        tempArray[event.detail].ReorderItem = null;
        this.filterListExchange = JSON.parse(JSON.stringify(tempArray));
        console.log('this.filterListExchange==');
        console.log(this.filterListExchange);
        }
        if(this.selectedTabId=='Courtesy'){
            let tempArray=this.filterListCourtsey;
            tempArray[event.detail].ReorderItem = null;
            this.filterListCourtsey = JSON.parse(JSON.stringify(tempArray));
            console.log('this.filterListCourtsey==');
            console.log(this.filterListCourtsey);
            }
}

handleValueRemovedOnReturnRMA(event){
    if(this.selectedTabId=='Exchange'){
        let tempArray=this.filterListExchange;
        tempArray[event.detail].Item = null;
        this.filterListExchange = JSON.parse(JSON.stringify(tempArray));
        console.log('this.filterListExchange==');
        console.log(this.filterListExchange);
        }
        if(this.selectedTabId=='Courtesy'){
            let tempArray=this.filterListCourtsey;
            tempArray[event.detail].Item = null;
            this.filterListCourtsey = JSON.parse(JSON.stringify(tempArray));
            console.log('this.filterListCourtsey==');
            console.log(this.filterListCourtsey);
            }
}
/* handleChange(event) {
        //const errornumberSet = /^[0-9]+$/;
    let index = event.target.dataset.id;
    let fieldName = event.target.name;
    let value = event.target.value;
    console.log('FieldName',fieldName);
    console.log('value',value);
        console.log((event));
    if(this.selectedTabId=='Return'){

    if (event.target.name == 'accQuantity') {
        
        this.filterList[event.currentTarget.dataset.index].Quantity = event.target.value;
        this.Quantity= event.target.value;
        //Added by Deepak
    }
    else if (event.target.name == 'accLot') {
        this.filterList[event.currentTarget.dataset.index].Lot = event.target.value;
        this.Lot= event.target.value;
        console.log(this.mapData);
        this.filterList[event.currentTarget.dataset.index].Rowid = this.keyIndex;
        if(this.mapData.has(event.target.value)){
        const myArray = this.mapData.get(event.target.value).split("-");
        console.log('this.myArray',myArray[1]);
        let tempArray=this.filterList
        tempArray[event.currentTarget.dataset.index].OrderId = myArray[0];
        tempArray[event.currentTarget.dataset.index].Order = myArray[1];
        this.filterList = JSON.parse(JSON.stringify(tempArray));
        
        }
        
        //this.filterList[event.currentTarget.dataset.index].Order = foundValue;
    }
    else if (event.target.name == 'accExpirydate') {
        this.filterList[event.currentTarget.dataset.index].Expirydate = event.target.value;
        this.Expirydate=event.target.value;
    }
    else if (event.target.name == 'accOrder') {

        // this.filterList[event.currentTarget.dataset.index].Order = event.target.value;

    }
    else if (event.target.name == 'accInvoice') {
        this.filterList[event.currentTarget.dataset.index].Invoice = 
        this.Invoice=event.target.value;
    }
    else if (event.target.name == 'accResell') {
        this.filterList[event.currentTarget.dataset.index].Resell = event.target.checked;
        this.Resell=event.target.checked;
    }
    else if (event.target.name == 'accReturn') {
        this.filterList[event.currentTarget.dataset.index].Return = event.target.value;
        this.Return=event.target.value;
    }
    else if (event.target.name == 'accComments') {
        this.filterList[event.currentTarget.dataset.index].Comments = event.target.value;
        this.Comments=event.target.value;
    }

        }
        /*--------------- Exchange -------------------
    if(this.selectedTabId=='Exchange'){

        if (event.target.name == 'accItem') {
    this.filterListExchange[event.currentTarget.dataset.index].Item = event.target.value;
    }
    else if (event.target.name == 'accQuantity') {
        this.filterListExchange[event.currentTarget.dataset.index].Quantity = event.target.value;
    }
    else if (event.target.name == 'accLot') {
        this.filterListExchange[event.currentTarget.dataset.index].Lot = event.target.value;
        console.log(this.mapData);
        if(this.mapData.has(event.target.value)){
        const myArray = this.mapData.get(event.target.value).split("-");
        console.log('this.myArray',myArray[1]);
        let tempExchangeArray=this.filterListExchange
        tempExchangeArray[event.currentTarget.dataset.index].OrderId = myArray[0];
        tempExchangeArray[event.currentTarget.dataset.index].Order = myArray[1];
        this.filterListExchange = JSON.parse(JSON.stringify(tempExchangeArray));


        }
    }
    else if (event.target.name == 'accExpirydate') {
        this.filterListExchange[event.currentTarget.dataset.index].Expirydate = event.target.value;
    }
    else if (event.target.name == 'accOrder') {
        this.filterListExchange[event.currentTarget.dataset.index].Order = event.target.value;
    }
    else if (event.target.name == 'accInvoice') {
        this.filterListExchange[event.currentTarget.dataset.index].Invoice = event.target.value;
    }
    else if (event.target.name == 'accResell') {
        this.filterListExchange[event.currentTarget.dataset.index].Resell = event.target.checked;
    }
    else if (event.target.name == 'accReturn') {
        this.filterListExchange[event.currentTarget.dataset.index].ReturnReason = event.target.value;
    }
    else if (event.target.name == 'accComments') {
        this.filterListExchange[event.currentTarget.dataset.index].Comments = event.target.value;
    }
        else if (event.target.name == 'accReorderItem') {
        this.filterListExchange[event.currentTarget.dataset.index].ReorderItem = event.target.value;
    }
    else if (event.target.name == 'accReorderQuantity') {
        this.filterListExchange[event.currentTarget.dataset.index].ReorderQuantity = event.target.value;
    }
        }
    if(this.selectedTabId=='Courtesy'){

        if (event.target.name == 'accItem') {
        this.filterListCourtsey[event.currentTarget.dataset.index].Item = event.target.value;
    }
    else if (event.target.name == 'accQuantity') {
        this.filterListCourtsey[event.currentTarget.dataset.index].Quantity =1 ;
    }
    else if (event.target.name == 'accLot') {
        this.filterListCourtsey[event.currentTarget.dataset.index].Lot = event.target.value;
        console.log(this.mapData);
        if(this.mapData.has(event.target.value)){
        const myArray = this.mapData.get(event.target.value).split("-");
            console.log('this.myArray',myArray[1]);
            let tempCourtesyArray=this.filterListCourtsey
            tempCourtesyArray[event.currentTarget.dataset.index].OrderId = myArray[0];
            tempCourtesyArray[event.currentTarget.dataset.index].Order = myArray[1];
            tempCourtesyArray[event.currentTarget.dataset.index].Quantity = 1;
            tempCourtesyArray[event.currentTarget.dataset.index].ReorderQuantity = 1;
            this.filterListCourtsey = JSON.parse(JSON.stringify(tempCourtesyArray));
        }
    }
    else if (event.target.name == 'accExpirydate') {
        this.filterListCourtsey[event.currentTarget.dataset.index].Expirydate = event.target.value;
    }
    else if (event.target.name == 'accOrder') {
        this.filterListCourtsey[event.currentTarget.dataset.index].Order = event.target.value;
    }
    else if (event.target.name == 'accInvoice') {
        this.filterListCourtsey[event.currentTarget.dataset.index].Invoice = event.target.value;
    }
    
    else if (event.target.name == 'accReturn') {
        if(event.target.value=='Other'){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error!',
                    message: 'Navigate to the EPER form to enter complaint/warranty claims',
                    variant: 'error'
                })
            )
            return;
        }
        else{
        this.filterListCourtsey[event.currentTarget.dataset.index].ReturnReasonCourtsey = event.target.value;}
    }
    else if (event.target.name == 'accComments') {
        this.filterListCourtsey[event.currentTarget.dataset.index].Comments = event.target.value;
    }
    else if (event.target.name == 'accReorderItem') {
        this.filterListCourtsey[event.currentTarget.dataset.index].ReorderItem = event.target.value;
    }
    else if (event.target.name == 'accReorderQuantity') {
        this.filterListCourtsey[event.currentTarget.dataset.index].ReorderQuantity =1;
    }
        else if (event.target.name == 'accPatientId') {
        this.filterListCourtsey[event.currentTarget.dataset.index].PatientId = event.target.value;
    }
    else if (event.target.name == 'accEventDate') {
        this.filterListCourtsey[event.currentTarget.dataset.index].EventDate = event.target.value;
    }
        }

}*/

handleAddRow(event) {
    console.log('===='+this.ShipAddressId);
    if(this.ShipAddressId==''){
        this.showToastMessage('error', 'Please select the Ship To Address first.', 'Error');
        return;
    }else if(this.OracaleAddressId=='')
    {
        this.showToastMessage('error', 'No Id attached. Please contact customer support.', 'Error');
        return;
    }
    this.isModalOpen = true;
    /*document.body.classList.add('no-scroll');
    console.log('Handle Add Row cartProductCount',this.cartProductCount);
    this.isSpinner = true;
    this.keyIndex=new Date().getTime();
    if(this.selectedTabId=='Return'){
    let objRow = {
        Item: '',
        Quantity: '',
        Lot: '',
        ExpiryDate: '',
        Order: '',
        Invoice: '',
        Resell: '',
        Return:'',
        Comments: '',
        Rowid:  this.keyIndex
    }
    this.filterList = [...this.filterList, Object.create(objRow)];
    console.log(this.filterList);
    }*/
    if(this.selectedTabId=='Exchange'){
        if(this.cartProductCount==0){
            
    let objRow = {
        Item: '',
        Quantity: '',
        Lot: '',
        ExpiryDate: '',
        Order: '',
        Invoice: '',
        Resell: '',
        Comments: '',
        ReturnReason: '',
        ReorderItem:'',
        ReorderQuantity:'',
        id: this.keyIndex
    }
    this.filterListExchange = [...this.filterListExchange, Object.create(objRow)];
}else{
    //event.preventDefault();
    this.dispatchEvent(
        new ShowToastEvent({
            title: 'Error!',
            message: 'Please clear the cart to proceed Exchange request.',
            variant: 'error'
        })
    )

    return;
}
    }
    if(this.selectedTabId=='Courtesy'){
        if(this.cartProductCount==0){
        
    let objRow = {
        Item: '',
        Quantity: '1',
        Lot: '',
        ExpiryDate: '',
        Order: '',
        Invoice: '',
        Comments: '',
        ReturnReasonCourtsey: '',
        ReorderItem:'',
        ReorderQuantity:'1',
        PatientId:'',
        EventDate:'',
        id: ++this.keyIndex
    }
    this.filterListCourtsey = [...this.filterListCourtsey, Object.create(objRow)];
    }
    else{
        // event.preventDefault();
        this.dispatchEvent(
            new ShowToastEvent({
                title: 'Error!',
                message: 'Please clear the cart to Proceed Courtesy Implant Replacement Request.',
                variant: 'error'
            })
        )
        
        return;
    }
}

}

handleRemoveRow(event) {
        if(this.selectedTabId=='Return'){
    this.filterList = this.filterList.filter((ele) => {
        return parseInt(ele.id) !== parseInt(event.currentTarget.dataset.index);
    });
        }
            if(this.selectedTabId=='Exchange'){
    this.filterListExchange = this.filterListExchange.filter((ele) => {
        return parseInt(ele.id) !== parseInt(event.currentTarget.dataset.index);
            });
    }
        if(this.selectedTabId=='Courtesy'){
    this.filterListCourtsey = this.filterListCourtsey.filter((ele) => {
        return parseInt(ele.id) !== parseInt(event.currentTarget.dataset.index);
            });
    }
    if (this.filterList.length == 0) {
        //this.handleAddRow();
    }
}
removeAllRows() {
    let filterList = [];
    if(this.selectedTabId=='Return'){
    this.tableData = filterList;
    this.handleRemoveFlag=false;
    }
        if(this.selectedTabId=='Exchange'){
    this.filterListExchange = filterList;
    }
        if(this.selectedTabId=='Courtesy'){
    this.filterListCourtsey = filterList;
    }
}

handleNavigatedesktop(event){
    this.selectedTabId = event.target.value;
    console.log('selectedTabId ==> ', this.selectedTabId);

}
async saveRows() {
    console.log('this.filterList => ', JSON.stringify(this.listOfAccounts));
    if(this.selectedTabId=='Return'){
    console.log('this.filterList => ', this.filterList);

    }
        if(this.selectedTabId=='Exchange'){
        console.log('this.filterListExchange => ', this.filterListExchange);
        }
        if(this.selectedTabId=='Courtesy'){
            console.log('this.filterListCourtsey => ', this.filterListCourtsey);
        }
        
        
    /*   let elements1 = this.template.querySelectorAll(`[data-name="accQuantity"]`);
        elements1.forEach(currentItem => {
        console.log('elements1',(Number(currentItem.value) > 0));
        if(currentItem.value!='' && Number(currentItem.value) > 0 ){
        this.isValidQuant = true;
            console.log('currentItem.value',currentItem.value);
            currentItem.focus();
            currentItem.setCustomValidity('');
            currentItem.blur();
        } else {
        this.isValidQuant = false;
            currentItem.focus();
            console.log('currentItem.value Else elements1',currentItem.value);
            currentItem.setCustomValidity('Quantity not zero,negative and empty');
            currentItem.blur();
        }
    });
    let elements = this.template.querySelectorAll(`[data-name="accLot"]`);
    // console.log(elements);
    elements.forEach(currentItem => {
    console.log('data.key',this.mapData.has(currentItem.value));
        if(this.mapData.has(currentItem.value)){
        this.isValidLot = true;
            console.log('currentItem.value',currentItem.value);
            currentItem.focus();
            currentItem.setCustomValidity('');
            currentItem.blur();
            return;             

        }
        else{
            this.isValidLot = false;
            currentItem.focus();
            console.log('currentItem.value',currentItem.value);
            currentItem.setCustomValidity('Lot No does not exist.');
            currentItem.blur();

        }
});
//        let elementsExpiryDate = this.template.querySelectorAll(`[data-name="accExpirydate"]`);
//          console.log(elementsExpiryDate);
//          elementsExpiryDate.forEach(currentItem => {
//       if(currentItem.value!='' ){
//         this.isValidExpDate = true;
//            console.log('currentItem.value',currentItem.value);
//            currentItem.focus();
//           currentItem.setCustomValidity('');
//            currentItem.blur();
//       } else {
//         this.isValidExpDate = false;
//           currentItem.focus();
//           console.log('currentItem.value Else',currentItem.value);
//          currentItem.setCustomValidity('Expiry Date Cannot blank.');
//           currentItem.blur();
//       }
//   });
    let elementsReturnReason = this.template.querySelectorAll(`[data-name="accReturn"]`);
        console.log('ReturnReason',elementsReturnReason);
        elementsReturnReason.forEach(currentItem => {
        console.log('currentItem.value Loop',currentItem.value);
        if(currentItem.value!=''&& currentItem.value!=undefined ){
        this.isValidReturn = true;
            console.log('currentItem.value',currentItem.value);
            currentItem.focus();
            currentItem.setCustomValidity('');
            currentItem.blur();
        } else {
        this.isValidReturn = false;
            currentItem.focus();
            console.log('currentItem Return Reason',currentItem.value);
            currentItem.setCustomValidity('Please select valid reason.');
            currentItem.blur();
        }
    });
    let elements4 = this.template.querySelectorAll(`[data-name="accResell"]`);
    console.log('elements4',elements4);
    elements4.forEach(currentItem => {
    if(currentItem.checked==true ){
    this.isValidResell = true;
        console.log('currentItem.value',currentItem.checked);
        currentItem.focus();
        currentItem.setCustomValidity('');
        currentItem.blur();
    } else {
    this.isValidResell = false;
        currentItem.focus();
        console.log('currentItem.value elements4 Else',currentItem.checked);
        currentItem.setCustomValidity('Please select the checkbox.');
        currentItem.blur();
    }
});
let elements6 = this.template.querySelectorAll(`[data-name="accReorderQuantity"]`);
    elements6.forEach(currentItem => {
    console.log('elements6',(Number(currentItem.value) > 0));
    if(currentItem.value!='' && Number(currentItem.value) > 0 ){
    this.isValidRetQuant = true;
        console.log('currentItem.value',currentItem.value);
        currentItem.focus();
        currentItem.setCustomValidity('');
        currentItem.blur();
} else {
    this.isValidRetQuant = false;
    currentItem.focus();
    console.log('currentItem.value Else elements6',currentItem.value);
    currentItem.setCustomValidity('Quantity not zero,negative and empty');
    currentItem.blur();
}
});
let elementsEventDate = this.template.querySelectorAll(`[data-name="accEventDate"]`);
console.log(elementsEventDate);
elementsEventDate.forEach(currentItem => {
if(currentItem.value!='' ){
this.isValidEventDate = true;
console.log('currentItem.value',currentItem.value);
currentItem.focus();
currentItem.setCustomValidity('');
currentItem.blur();
} else {
this.isValidEventDate = false;
currentItem.focus();
console.log('currentItem.value Else',currentItem.value);
currentItem.setCustomValidity('Event Date Cannot blank.');
currentItem.blur();
}
});
let elementsPatientId = this.template.querySelectorAll(`[data-name="accPatientId"]`);
console.log(elementsPatientId);
elementsPatientId.forEach(currentItem => {
if(currentItem.value!='' ){
this.isValidPatiendId = true;
console.log('currentItem.value',currentItem.value);
currentItem.focus();
currentItem.setCustomValidity('');
currentItem.blur();
} else {
this.isValidPatiendId = false;
currentItem.focus();
console.log('currentItem.value Else',currentItem.value);
currentItem.setCustomValidity('Patient Id Cannot blank.');
currentItem.blur();
}
});*/
    console.log('IsValid is Qual TO',this.isValid);
    if(this.isValidQuant && this.isValidLot  && this.isValidReturn &&
        this.isValidRetQuant && this.isValidPatiendId && this.isValidEventDate && 
        this.selectedTabId=='Courtesy'){
    console.log('Selected Tab Coutsey');
    this.saveRmaDetails();
    
    }
    if(this.isValidQuant && this.isValidLot && this.isValidReturn && 
    this.isValidResell){
    if(this.isValidRetQuant && this.selectedTabId=='Exchange'){
    console.log('Selected Tab Exchange');
    this.saveRmaDetails();
    
    }
    else{
    await this.saveRmaDetails();
    this.tableData = [];
    this.index=0;
    this.editIndex='';
    }
    }

}



showToastMessage(variant, message, title) {
    this.dispatchEvent(
        new ShowToastEvent({
            title: title,
            message: message,
            variant: variant
        })
    );
}

async addRow() {
    this.showLoader = true;
    console.log('this.filterList => ', JSON.stringify(this.listOfAccounts));
    if(this.selectedTabId=='Return'){
    console.log('this.filterList => ', this.filterList);

    }
        if(this.selectedTabId=='Exchange'){
        console.log('this.filterListExchange => ', this.filterListExchange);
        }
        if(this.selectedTabId=='Courtesy'){
            console.log('this.filterListCourtsey => ', this.filterListCourtsey);
        }
        
        
        let accQuanity = this.template.querySelector(`[data-name="accQuantity"]`);
        console.log('elements1',(Number(accQuanity.value) > 0));
        if(accQuanity.value!='' && Number(accQuanity.value) > 0 ){
            this.Quantity=accQuanity.value;
            this.isValidQuant = true;
            console.log('currentItem.value',accQuanity.value);
            accQuanity.focus();
            accQuanity.setCustomValidity('');
            accQuanity.blur();
        } else {
        this.isValidQuant = false;
            accQuanity.focus();
            console.log('currentItem.value Else elements1',accQuanity.value);
            accQuanity.setCustomValidity('Quantity not zero,negative and empty');
            accQuanity.blur();
        }

    let lotNumber = this.template.querySelector(`[data-name="accLot"]`);
        if(lotNumber.value!=undefined && lotNumber.value!=''){
            this.Lot=lotNumber.value;
            this.isValidLot = true;
            console.log('currentItem.value',lotNumber.value);
            lotNumber.focus();
            lotNumber.setCustomValidity('');
            lotNumber.blur();            
        }
        else{
            this.isValidLot = false;
            lotNumber.focus();
            console.log('currentItem.value',lotNumber.value);
            lotNumber.setCustomValidity('Lot No. should not blank.');
            lotNumber.blur();

        }

    let ReturnReason = this.template.querySelector(`[data-name="accReturn"]`);
        console.log('ReturnReason',ReturnReason);
        console.log('currentItem.value Loop',ReturnReason.value);
        if(ReturnReason.value!=''&& ReturnReason.value!=undefined ){
        this.isValidReturn = true;
        this.Return=ReturnReason.value;
            console.log('currentItem.value',ReturnReason.value);
            ReturnReason.focus();
            ReturnReason.setCustomValidity('');
            ReturnReason.blur();
        } else {
        this.isValidReturn = false;
        ReturnReason.focus();
        console.log('currentItem Return Reason',ReturnReason.value);
            ReturnReason.setCustomValidity('Please select valid reason.');
            ReturnReason.blur();
        }

    let ResaleCondition = this.template.querySelector(`[data-name="accResell"]`);
    console.log('elements4',ResaleCondition);
    if(ResaleCondition.checked==true ){
        this.isValidResell = true;
        this.Resell=ResaleCondition.checked;
        console.log('currentItem.value',ResaleCondition.checked);
        ResaleCondition.focus();
        ResaleCondition.setCustomValidity('');
        ResaleCondition.blur();
    } else {
        this.isValidResell = false;
        ResaleCondition.focus();
        console.log('currentItem.value elements4 Else',ResaleCondition.checked);
        ResaleCondition.setCustomValidity('Please select the checkbox.');
        ResaleCondition.blur();
    }
    let RMAComment = this.template.querySelector(`[data-name="accComments"]`);
    console.log('elements4RMAComment',RMAComment);
    if(RMAComment.value!='' && RMAComment.value!=undefined  ){
        this.Comments=RMAComment.value;
    }

    let RMAInvoice = this.template.querySelector(`[data-name="accInvoice"]`);
    console.log('elements4RMAInvoice',RMAInvoice);
    if(RMAInvoice.value!=''&& RMAInvoice.value!=undefined  ){
        this.Invoice=RMAInvoice.value;
    }
   let mapParams;
    mapParams = {
    OrgId: this.OrgId,
    Lot:this.Lot,
    ItemSku:this.ItemSku,
    AccountNumber: this.AccountNumber,
    OracaleAddressId:this.OracaleAddressId,
    RmaQuantity:this.Quantity
    //this.selectedTabId,
    }
await getLotValidationAPIReponse({
mapParams: mapParams
}).then((results) => {
    this.showLoader = false;
    console.log('====='+results);
    this.lotValidationParser(results);
}).catch((error) => {
    console.log('getLotValidationAPIReponse error');
    console.log(error);
});

    /*this.Quantity='';
    this.Lot='';
    this.Return='';
    this.Resell='';
    this.Comments='';
    this.Expirydate='';
    this.Invoice='';
    this.index+=1;*/
    //}
    }

async handleAlertOpen(){
await LightningAlert.open({
    message: this.AddressDetails,
    theme: 'success', 
    label: 'Address Details!', // this is the header text
});
//Alert has been closed
}

closeModal(){
this.isModalOpen = false;
this.reIntialiseVariables();
// this.isEdit = false; // Exit edit mode
// this.editedRowIndex = -1; // Reset editedRowIndex
// this.Quantity='';
// this.Lot='';
// this.Return='';
// this.Resell='';
// this.Comments='';
// this.Expirydate='';
// this.Invoice='';
}
deleteRow(event) {
const rowId = event.currentTarget.dataset.rowId;
const rowIndex = this.tableData.findIndex(row => row.id == rowId);

if (rowIndex !== -1) {
    this.tableData.splice(rowIndex, 1);
    if(this.tableData.length === 0){
    this.isSubmitDisabled = true;
    this.index=0;
    this.handleRemoveFlag=false;
    
}
}
}

lotValidationParser(Result){
    if(Result.hasOwnProperty('Success')){
        let successResult=JSON.parse(Result['Success']);
        this.ShippedDate=successResult.ShippedDate;
        this.RecordId=successResult.RecordId;
        this.PriceList=successResult.PriceList;
        this.PreviousRMAQuantity=successResult.PreviousRMAQuantity;
        this.OrderType=successResult.OrderType;
        this.OrderNumber=successResult.OrderNumber;
        this.LotShipQuantity=successResult.LotShipQuantity;
        this.LotNumber=successResult.LotNumber;
        this.LotExpiryDate=successResult.LotExpiryDate;
        this.LineNumber=successResult.LineNumber;
        this.ItemNumber=successResult.ItemNumber;
        this.ErrorMessage=successResult.ErrorMessage;
        this.DiscountFlag=successResult.DiscountFlag;
        this.generateTableValues();
    }else{
        this.showToastMessage('error', Result['Error'], 'Error');
    };
}
generateTableValues(){
    this.handleRemoveFlag=true;
    const newRow = {
        id:  this.Rowid,
        RMAType:this.selectedTabId,
        accountId : this.accId,
        userId: this.userId,
        itemSku: this.ItemSku,
        quantity:this.Quantity,
        lotNumber:this.Lot,
        returnReson:this.Return,
        resaleCondition:(this.Resell)?'Yes' : 'No', 
        AddressName:this.AddressName,
        Comments:this.Comments,
        Invoice:this.Invoice,
        Item:this.Item,
        OracaleAddressId:this.OracaleAddressId,
        ShipAddressId:this.ShipAddressId,
        ShippedDate:this.ShippedDate,
        RecordId:this.RecordId,
        PriceList:this.PriceList,
        PreviousRMAQuantity:this.PreviousRMAQuantity,
        OrderType:this.OrderType,
        OrderNumber:this.OrderNumber,
        LotShipQuantity:this.LotShipQuantity,
        oracleLotNumber:this.LotNumber,
        LotExpiryDate:this.LotExpiryDate,
        LineNumber:this.LineNumber,
        ItemNumber:this.ItemNumber,
        ErrorMessage:this.ErrorMessage,
        DiscountFlag:this.DiscountFlag
    };
    this.tableData.push(newRow);
    console.log('Table Data',JSON.stringify(this.tableData));
    this.isModalOpen = false;
    this.reIntialiseVariables();
}
async submitForSaveRMA(){
    if(this.tableData.length>0){
    this.showLoader = true;
    await saveRmaAndRmaLine({
        rmaAndRmaLine: this.tableData
        }).then((results) => {
            this.showLoader = false;
            this.removeAllRows();
            console.log(JSON.stringify(results));
        }).catch((error) => {
            console.log('submitForSaveRMA error');
            console.log(error);
        });
    }
}
reIntialiseVariables(){
    this.Rowid='';
    this.ItemSku='';
    this.Quantity='';
    this.Lot='';
    this.Return='';
    this.Resell='';
    this.Comments='';
    this.Invoice='';
    this.Item='';
    this.ShippedDate='';
    this.RecordId='';
    this.PriceList='';
    this.PreviousRMAQuantity='';
    this.OrderType='';
    this.OrderNumber='';
    this.LotShipQuantity='';
    this.LotNumber='';
    this.LotExpiryDate='';
    this.LineNumber='';
    this.ItemNumber='';
    this.ErrorMessage='';
    this.DiscountFlag=='';
}

}