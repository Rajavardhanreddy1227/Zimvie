import { LightningElement,api,wire} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import ToastContainer from 'lightning/toastContainer';

export default class B2b_wishlistmodal extends LightningElement {
    @api communityId;
    @api effectiveAccountId;
    @api productId;

    loading = false;

    

    connectedCallback() {
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';
    }

    
    setWishlistId(event){
        let evtResponse = event.detail;
        this.selectedWishlist = evtResponse.selectedWishlist;
    }
    handleAddToWishlist(){
        if(!this.selectedWishlist){
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Warning',
                    message: 'Please select a wishlist.',
                    variant: 'warning',
                    mode: 'dismissable'
                })
            );
            return;
        }
        this.loading = true;
        console.log('add '+this.productId+' in wishlist with id = '+this.selectedWishlist);
        addItemToWishlist({wishlistId:this.selectedWishlist,accId:this.effectiveAccountId,storeId:this.communityId,prodId:this.productId})
            .then((data) => {
                this.loading = false;
                var selectedEvent = new CustomEvent('close', { detail:true});
                this.dispatchEvent(selectedEvent);
            })
            .catch((error) => {
                console.log('error='+JSON.stringify(error));
                this.loading = false;
                var selectedEvent = new CustomEvent('close', { detail:false});
                this.dispatchEvent(selectedEvent);
            });
        
    }
    handleManageWishlists(){
        window.location = window.origin + '/Zimvie/accountmanagement?c__page=list';
    }
    closeModal(){
        var selectedEvent = new CustomEvent('close', { detail:false});
        this.dispatchEvent(selectedEvent);
    }
}