import { LightningElement,wire,api } from 'lwc';
import LightningPrompt from 'lightning/prompt';
import fetchWishlists from '@salesforce/apex/B2BGetInfo.fetchWishlists';
import createWishlist from '@salesforce/apex/B2BGetInfo.createWishlist';
import deleteWishlist from '@salesforce/apex/B2BGetInfo.deleteWishlist';
import fetchWishlistSummary from '@salesforce/apex/B2BGetInfo.fetchWishlistSummary';
import removeItem from '@salesforce/apex/B2BGetInfo.removeItem';
import updateWishlist from '@salesforce/apex/B2BGetInfo.updateWishlist';
import addWishlistToCart from '@salesforce/apex/B2BGetInfo.addWishlistToCart';
import { refreshApex } from "@salesforce/apex";
import contextApi from 'commerce/contextApi';
import ToastContainer from 'lightning/toastContainer';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import LightningConfirm from 'lightning/confirm';
import {addItemToCart} from 'commerce/cartApi';
import {refreshCartSummary} from 'commerce/cartApi';
import calculateDiscountOnItem from '@salesforce/apex/B2BCartController.calculateDiscountOnItem';
import My_Lists from '@salesforce/label/c.My_Lists';
import Edit from '@salesforce/label/c.Edit';
import Delete from '@salesforce/label/c.Delete';
import SKULabel from '@salesforce/label/c.SKULabel';
import Remove_from_list from '@salesforce/label/c.Remove_from_list';
import ADD_ALL_TO_CART from '@salesforce/label/c.ADD_ALL_TO_CART';
import Select_Wishlist from '@salesforce/label/c.Select_Wishlist';
import Start_New_List from '@salesforce/label/c.Start_New_List';
import AddtoCartLabel from '@salesforce/label/c.AddtoCartLabel';
import B2B_AddToCart_SpinnerMessage from '@salesforce/label/c.B2B_AddToCart_SpinnerMessage';
import B2B_CalculateDiscount_SpinnerMessage from '@salesforce/label/c.B2B_CalculateDiscount_SpinnerMessage';
import B2B_Loading_Message from '@salesforce/label/c.B2B_Loading_Message';
import B2B_Wishlist_Warning_Msg from '@salesforce/label/c.B2B_Wishlist_Warning_Msg';
import B2B_Warning_Label from '@salesforce/label/c.B2B_Warning_Label';
import B2B_Wishlist_Msg from '@salesforce/label/c.B2B_Wishlist_Msg';
import B2B_wishlist_Name_Msg from '@salesforce/label/c.B2B_wishlist_Name_Msg';
import B2B_Wishlist_Delete_Success_Msg from '@salesforce/label/c.B2B_Wishlist_Delete_Success_Msg';
import B2B_Success_Label from '@salesforce/label/c.B2B_Success_Label';
import B2B_WishList_Error from '@salesforce/label/c.B2B_WishList_Error';
import B2B_Error_Msg_Label from '@salesforce/label/c.B2B_Error_Msg_Label';
import B2B_Add_To_Cart_Success_Msg from '@salesforce/label/c.B2B_Add_To_Cart_Success_Msg';

export default class B2b_wishlist extends LightningElement {
    @api selection = "false";
    @api communityId;
    @api effectiveAccountId;
    labels = {
        My_Lists,
        Edit,
        Delete,
        SKULabel,
        Remove_from_list,
        ADD_ALL_TO_CART,
        Select_Wishlist,
        Start_New_List,
        AddtoCartLabel,
        B2B_CalculateDiscount_SpinnerMessage,
        B2B_AddToCart_SpinnerMessage,
        B2B_Loading_Message,
        B2B_Wishlist_Warning_Msg,
        B2B_Warning_Label,
        B2B_Wishlist_Msg,
        B2B_wishlist_Name_Msg,
        B2B_Wishlist_Delete_Success_Msg,
        B2B_Success_Label,
        B2B_WishList_Error,
        B2B_Error_Msg_Label,
        B2B_Add_To_Cart_Success_Msg
    }
    wishlistsDataResult;
    wishlists;

    get showcheckboxes(){
        return this.selection == "true";
    }

    messageState = B2B_Loading_Message;
    connectedCallback() {
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';

        const result = contextApi.getSessionContext();
        result.then((response) => {
            this.effectiveAccountId = response.effectiveAccountId == '000000000000000' || response.effectiveAccountId == undefined ? '0018L00000GssWnQAJ' : response.effectiveAccountId;
            this.fetchData(this.effectiveAccountId);
        }).catch((error) => {
            console.log("getSessionContext error");
            console.log(error);
        });

        /*const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';*/
    } 

    fetchData(accId){
        this.loading = true;
        fetchWishlists({accId:accId})
        .then((res) => {

            let  datarec = res;
            datarec?.forEach(element => {
                element['CustomName'] = element.Name + ' ('+element.WishlistProductCount+' Items)';
                element['productAvailable'] = element.WishlistProductCount > 0 ? true : false;
            });
            this.wishlists = datarec;


            this.loading = false;
        }).catch(error => {
            console.log('error' ,JSON.stringify(error));
        });
    }
    
    async handleAdd() {
        LightningPrompt.open({
            //message: 'Please enter new wishlist name',
            //theme defaults to "default"
            label: this.labels.B2B_wishlist_Name_Msg, // this is the header text
            defaultValue: 'my list', //this is optional
        }).then((result) => {
            console.log('result=');
            console.log(result);
            if(!result){
                return;
            }
            
            createWishlist({Name:result,accId:this.effectiveAccountId,storeId:this.communityId})
            .then((data) => {
                this.fetchData(this.effectiveAccountId);
            })
            .catch((error) => {
                console.log('error='+JSON.stringify(error));
            });
        });
    }
    handleWishlistSelection(event){
        this.showNewWishlistInput = false;
        let params = {selectedWishlist:event.target.dataset.id};
        this.dispatchEvent(
            new CustomEvent('rowselect', {
                detail : params
            })
        );
    }
    showNewWishlistInput = false;
    handleNewWishlistCreation(){
        this.showNewWishlistInput = true;
    }
    setWishlistNameFunc(){
        let result = this.template.querySelector('.newwishlistinput').value;
        if(result && result.length > 0){
            createWishlist({Name:result,accId:this.effectiveAccountId,storeId:this.communityId})
            .then((data) => {
                //this.showNewWishlistInput = false;
                this.fetchData(this.effectiveAccountId);
            })
            .catch((error) => {
                console.log('error='+JSON.stringify(error));
            });
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.B2B_Warning_Label,
                    message:this.labels.B2B_Wishlist_Warning_Msg,
                    variant: 'warning',
                    mode: 'dismissable'
                })
            );
        }
        
    }
    currentPageToken;
    nextPageToken;
    previousPageToken;
    loading = false;
    showWishlistSummary = false;
    selectedWishlist;
    wishlistSummaryData;
    viewDetails(event){
        console.log('navigate to '+event.target.dataset.id);
    }

    handleToggleSection(event){
        console.log(event);
        this.wishlistSummaryData = undefined;
        this.loading = true;
        this.selectedWishlist = event.detail.openSections;
        //this.selectedWishlistName = event.target.dataset.name;
        this.fetchSummary();
    }

    async handleEditClick(event) {
        const recordId = event.target.dataset.recordId;
        console.log('edit '+recordId);
        this.loading = true;
        this.selectedWishlist = recordId;
        this.selectedWishlistName = event.target.dataset.name;
        this.fetchSummary();
    }
    gobackToWishlistPage(){
        this.fetchData(this.effectiveAccountId);
        this.showWishlistSummary = false;
    }
    fetchSummary(){
        if(!this.selectedWishlist){
            this.loading = false;
            return;
        }
        fetchWishlistSummary(
            {
                pageSize : 25,
                pageParam : this.currentPageToken,
                accId : this.effectiveAccountId,
                wishlistId : this.selectedWishlist
            }
            )
            .then((data) => {
                //console.log('wishlist summary data = ');
                //console.log(data);
                let  datarec = JSON.parse(data);
                datarec.items.forEach(element => {
                    element.productSummary.thumbnailImage.url = '/Zimvie/sfsites/c' + element.productSummary.thumbnailImage.url;
                });
                this.wishlistSummaryData = datarec;
                console.log('this.wishlistSummaryData=='+JSON.stringify(this.wishlistSummaryData));
                this.showWishlistSummary = true;
                this.loading = false;
            })
            .catch((error) => {
                console.log('error='+JSON.stringify(error));
            });
    }
    editedWishlistName;
    editedWishlistId;
    showWishlistEditNameModal = false;
    async handleEditName(event){
        const recordId = event.target.dataset.recordId;
        const existingName = event.target.dataset.name;
        this.editedWishlistName = existingName;
        this.editedWishlistId = recordId;
        this.showWishlistEditNameModal = true;
        /*LightningPrompt.open({
            //message: 'Please enter new wishlist name',
            //theme defaults to "default"
            label: 'Please enter new name for wishlist', // this is the header text
            defaultValue: existingName, //this is optional
        }).then((result) => {
            console.log('result=');
            console.log(result);
            if(!result){
                return;
            }
            
            
        });*/
    }

    closeModal(){
        this.showWishlistEditNameModal = false;
    }

    setWishlistName(event){
        this.editedWishlistName = event.target.value;
    }

    saveNewWishlistName(){
        updateWishlist({wishlistId:this.editedWishlistId,newName:this.editedWishlistName})
            .then((data) => {
                this.fetchData(this.effectiveAccountId);
                this.closeModal();
            })
            .catch((error) => {
                console.log('error='+JSON.stringify(error));
            });
    }

    async handleDeleteClick(event) {
        const recordId = event.target.dataset.recordId;
        console.log('delete '+recordId);
        const result = await LightningConfirm.open({
            message: this.labels.B2B_Wishlist_Msg,
            variant: 'headerless',
            theme: 'alt-inverse'
        });
        if(result){
            deleteWishlist({wishlistId:recordId})
            .then((data) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.labels.B2B_Success_Label,
                        message: this.labels.B2B_Wishlist_Delete_Success_Msg,
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
                this.fetchData(this.effectiveAccountId);
            })
            .catch((error) => {
                console.log('error='+JSON.stringify(error));
            });
        }
    }
    async handleRemove(event){
        const recordId = event.target.dataset.id;
        console.log('remove this wishlist '+recordId);
        this.loading = true;
        removeItem({accId:this.effectiveAccountId,wishlistId:this.selectedWishlist,itemId:recordId})
            .then((data) => {
                this.fetchData(this.effectiveAccountId);
                this.fetchSummary();
            })
            .catch((error) => {
                console.log('error='+JSON.stringify(error));
            });
    }
    handleAddToCart(event){
        const recordId = event.target.dataset.id;
        console.log('add this product to cart '+recordId);
        this.messageState = B2B_AddToCart_SpinnerMessage;
        this.loading = true;
        addItemToCart(recordId,1).then((fulfilled) => {
            console.log("added product to cart" ,fulfilled);
            //this.calculateDiscount(fulfilled);
            this.loading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.B2B_Success_Label,
                    message: this.labels.B2B_Add_To_Cart_Success_Msg,
                    variant: 'success',
                    mode: 'dismissable'
                })
            );
        }).catch(error => {
            console.log('error' ,error);
            this.loading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.B2B_Error_Msg_Label,
                    message:this.labels.B2B_WishList_Error,
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
        });
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
                    this.loading = false;
                    this.retryAttempt = 0;
                    console.log('there was some error in calculating discount--', results);
                }
            }else{
                this.loading = false;
                this.retryAttempt = 0;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.labels.B2B_Success_Label,
                        message: this.labels.B2B_Add_To_Cart_Success_Msg,
                        variant: 'success',
                        mode: 'dismissable'
                    })
                );
            }
        }).catch((error) => {
            console.log('calculateDiscount error');
            console.log(error);
            this.loading = false;
            this.retryAttempt = 0;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.B2B_Error_Msg_Label,
                    message:this.labels.B2B_WishList_Error,
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
        });
    }

    addFullWishlist(){
        
        this.loading = true;
        addWishlistToCart({wishlistId:this.selectedWishlist,accId:this.effectiveAccountId})
        .then((fulfilled) => {
            console.log("Added full wishlist to cart" ,fulfilled);
            this.loading = false;
            refreshCartSummary();
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.B2B_Success_Label,
                    message: this.labels.B2B_Add_To_Cart_Success_Msg,
                    variant: 'success',
                    mode: 'dismissable'
                })
            );
        }).catch(error => {
            console.log('error' ,error);
            this.loading = false;
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.labels.B2B_Error_Msg_Label,
                    message:this.labels.B2B_WishList_Error,
                    variant: 'error',
                    mode: 'dismissable'
                })
            );
        });
    }
    navigateToProduct(event){
        window.location = window.origin+'/Zimvie/product/'+event.target.dataset.id;
    }
}