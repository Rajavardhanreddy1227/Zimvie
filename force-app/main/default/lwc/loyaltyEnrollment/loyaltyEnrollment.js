import { LightningElement, api, wire } from 'lwc';
import communityId from '@salesforce/community/Id';
import { CartItemsAdapter } from 'commerce/cartApi';
import { getSessionContext } from 'commerce/contextApi';
import updateLoyaltyOnCart from '@salesforce/apex/B2BAccountManagementController.updateLoyaltyOnCart';
export default class LoyaltyEnrollment extends LightningElement {
coordinatorName= '';
coordinatorPhone= '';
coordinatorEmail= '';
isLoading = false;
@api effectiveAccountId;
@api webStoreId;
handleNameChange(event){
    this.coordinatorName = event.target.value;
}

handlePhoneChange(event){
    this.coordinatorPhone = event.target.value;
}

handleEmailChange(event){
    this.coordinatorEmail = event.target.value;
}

saveLoyaltyData(event){
    const isInputsCorrect = [...this.template.querySelectorAll('input')]
    .reduce((validSoFar, inputField) => {
        inputField.reportValidity();
        return validSoFar && inputField.checkValidity();
    }, true);
    if (!isInputsCorrect) {
        return false;
    }
    this.isLoading = true;
    let mapParams = {
        coordinatorName : this.coordinatorName,
        coordinatorPhone : this.coordinatorPhone,
        coordinatorEmail : this.coordinatorEmail,
        communityId : communityId,
        effectiveAccountId : this.effectiveAccountId
    }
    updateLoyaltyOnCart({
        mapParams: mapParams
    }).then((results) => {
        console.log('updateLoyaltyOnCart results');
        console.log(results);
        this.isLoading = false;
    }).catch((error) => {
        console.log('updateLoyaltyOnCart error');
        console.log(error);
        this.isLoading = false;
    });
}
async getAccountId()

    {
        const result = await getSessionContext();
        if(result && result.effectiveAccountId)
        {
            this.effectiveAccountId = result.effectiveAccountId;
        }
    }

    connectedCallback(){
        this.getAccountId();
    }

    showComponent = false;
    @wire(CartItemsAdapter, { webstoreId: '$webStoreId', cartStateOrId: 'current' })
    onGetCartItems(result) {
        this.isLoading = false;
        if(result && result.data){
            if (result.data && result.data.cartSummary && result.data.cartItems.length > 0) {
                let cartItems = result.data.cartItems;
                cartItems.forEach(ele => {
                    if(ele.cartItem.productDetails && ele.cartItem.productDetails.sku && 
                        ele.cartItem.productDetails.sku == 'ELP1YR'){
                            this.showComponent = true;
                    }
                });
            }
            else{
                this.showComponent = false;
            }
        }
    }
}