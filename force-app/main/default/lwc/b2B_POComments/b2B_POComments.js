import { LightningElement,wire } from 'lwc';
import { CartSummaryAdapter } from "commerce/cartApi";
import savePoCommentsOnCart  from '@salesforce/apex/B2B_POCommentsController.savePoCommentsOnCart';
export default class B2B_POComments extends LightningElement {
    cartId;
    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
        if(!data){
            return;
        }
        else if (data) {
            console.log("order summary setCartSummary Cart data- ", data);
            this.cartId = data.cartId;
        } else if (error) {
            console.error(error);
        }
    }
    handlePOChangeAndSave(event){
        let pocomments = event.target.value;
        console.log('pocomments==' + pocomments);
        if(!pocomments || !this.cartId){
            return;
        }
        
        savePoCommentsOnCart({'cartId': this.cartId,'pocomments':pocomments})
            .then((result) => {
                console.log('po number saved successfully');
            })
            .catch((error) => {
                console.log(error);
            });
    }
}