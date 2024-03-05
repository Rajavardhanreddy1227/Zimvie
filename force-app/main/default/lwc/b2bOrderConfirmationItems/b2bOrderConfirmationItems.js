import { LightningElement, api ,wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
export default class B2bOrderConfirmationItems extends NavigationMixin(LightningElement) {

    @api orderLineItems;
    @api orderSummaryId;

    handleProductDetailNavigation(evt) {
        evt.preventDefault();
        const productId = evt.target.dataset.productid;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/product/' + productId
            }
        });
    }

   
}