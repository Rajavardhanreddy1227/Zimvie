import { LightningElement,api,wire} from 'lwc';
import cartApi from 'commerce/cartApi';
import { NavigationMixin } from 'lightning/navigation';
//import B2BContinueShopping from '@salesforce/label/c.B2BContinueShopping';
//import B2BViewCart from '@salesforce/label/c.B2BViewCart';
//import B2BCartHref from '@salesforce/label/c.B2BCartHref';
//import B2BAddToCartText from '@salesforce/label/c.B2BAddToCartText';
import {publish, MessageContext} from 'lightning/messageService'
import B2BCartChanged from '@salesforce/messageChannel/B2BCartChanged__c';
import loading from '@salesforce/label/c.loading';
import Cancelandclose from '@salesforce/label/c.Cancelandclose';
import ViewCart from '@salesforce/label/c.ViewCart';
import ContinueShopping from '@salesforce/label/c.ContinueShopping';
import AddtoCartLabel from '@salesforce/label/c.AddtoCartLabel';
//import { applicationLogging, consoleLogging } from 'c/b2bUtil';
export default class B2BCartUtils extends NavigationMixin(LightningElement)
{

    labels = 
    {
        loading,
        Cancelandclose,
        ViewCart,
        ContinueShopping,
        AddtoCartLabel
    }
    B2BCartHref
    showAddToCartPopup = false;
    isLoading = false;

    @wire(MessageContext)
    messageContext;

    @api addToCart(productId , productQuantity)
    {
       this.isLoading = true;
       this.handleAddToCart(productId , productQuantity);
    }

    async handleAddToCart(productId , productQuantity) {
        if (productId && productQuantity) {
            const result = await cartApi.addItemToCart(productId,productQuantity);
            consoleLogging(result);
            if(result && result.cartItemId)
            {
                this.showAddToCartPopup = true;
                this.doPublishCartChange();
            }
        }
        this.isLoading = false;
    }

    handleClose()
    {
        this.showAddToCartPopup = false;
    }

    handleViewCart()
    {
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
                attributes: {
                    url: this.B2BCartHref
                }
        });
    }

    /*
    Updates the item quantity in the cart.
    */

    @api updateCartItem(itemId , quantity)
    {
       this.updateItemInCart(itemId , quantity);
    }

    updateItemInCart(itemId , quantity) {
        this.isLoading = true;
        const result = cartApi.updateItemInCart(itemId,quantity);
        result.then((response) => {
            consoleLogging("updateItemInCart result");
            consoleLogging(response);
        }).catch((error) => {
            consoleLogging("updateItemInCart result");
            consoleLogging(error);
        });
        this.doPublishCartChange();
        this.isLoading = false;
    }

    /*
    Deletes an item from the cart.
    */

    @api deleteCartItem(cartItemId)
    {
       this.deleteItemFromCart(cartItemId);
    }

    deleteItemFromCart(cartItemId) {
        this.isLoading = true;
        const result = cartApi.deleteItemFromCart(cartItemId);
        result.then((response) => {
            consoleLogging("deleteItemFromCart result");
            consoleLogging(response);
        }).catch((error) => {
            consoleLogging("deleteItemFromCart result");
            consoleLogging(error);
        });
        this.doPublishCartChange();
        this.isLoading = false;
    }

    /*
    Deletes an active/current cart. 
    */

    @api ClearCurrentCart()
    {
       this.deleteCurrentCart();
    }

    deleteCurrentCart() {
        this.isLoading = true;
        const result = cartApi.deleteCurrentCart();
        result.then((response) => {
            consoleLogging("deleteCurrentCart result");
            consoleLogging(response);
        }).catch((error) => {
            consoleLogging("deleteCurrentCart result");
            consoleLogging(error);
        });
        this.doPublishCartChange();
        this.isLoading = false;
    }

    doPublishCartChange()
    {
        let message = {updateCartCount: true};
        publish(this.messageContext, B2BCartChanged, message);
    }

    /*
    Applies a coupon to the cart.
    */

    @api applyCoupon(couponCode)
    {
       this.applyCouponToCart(couponCode);
    }

    applyCouponToCart(couponCode) {
        this.isLoading = true;
        const result = cartApi.applyCouponToCart(couponCode);
        result.then((response) => {
            consoleLogging("applyCouponToCart result");
            consoleLogging(response);
        }).catch((error) => {
            consoleLogging("applyCouponToCart result");
            consoleLogging(error);
            this.template.querySelector('c-b2b-show-toast-message').showToast('Invalid Coupon Code','error');
        });
        this.doPublishCartChange();
        this.isLoading = false;
    }

    /*
    Deletes an applied coupon from the cart.
    */

    @api deleteCoupon(couponId)
    {
       this.deleteCouponFromCart(couponId);
    }

    deleteCouponFromCart(couponId) {
        this.isLoading = true;
        const result = cartApi.deleteCouponFromCart(couponId);
        result.then((response) => {
            consoleLogging("deleteCouponFromCart result");
            consoleLogging(response);
        }).catch((error) => {
            consoleLogging("deleteCouponFromCart result");
            consoleLogging(error);
        });
        this.doPublishCartChange();
        this.isLoading = false;
    }
}