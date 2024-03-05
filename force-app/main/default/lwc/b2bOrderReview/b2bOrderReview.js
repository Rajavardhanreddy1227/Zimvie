import { LightningElement, api,wire,track } from 'lwc';
import contextApi from 'commerce/contextApi';
import { CartSummaryAdapter } from "commerce/cartApi";
import { CartItemsAdapter } from 'commerce/cartApi';
import loading from '@salesforce/label/c.loading';
import SKUNO from '@salesforce/label/c.SKUNO';
import item from '@salesforce/label/c.item';
import qtyLabel from '@salesforce/label/c.qtyLabel';
// import getCpnFromCart from '@salesforce/apex/B2BCartController.getCpnFromCart';
import { NavigationMixin } from 'lightning/navigation';
import { resolve } from 'c/b2B2C_cmsResourceResolver';
export default class B2bOrderReview extends NavigationMixin(LightningElement) {
    labels = {
        loading,
        SKUNO,
        item,
        qtyLabel
    }
    @track cartItemMap =[];
    isLoading = false;
    @api webStoreId;
    // @wire(CartItemsAdapter, { webstoreId: '0ZE8L000000GnVKWA0', cartStateOrId: 'current' })
    // onGetCartItems(result) {
    //     console.log("CartItemsAdapter Id", result);
    //     console.log("CartItemsAdapter Id", result.data );
    //     console.log("cartItems Id", result.data.cartItems);

    //     this.cartItemMap = result.data.cartItems;
    //     console.log("cartItemMap", JSON.stringify(this.cartItemMap));
    // }

    @wire(CartSummaryAdapter)
    setCartSummary({ data, error }) {
      if(!data){
              return;
           }
       else if (data) {
            console.log("Cart Id", data.cartId);
            console.log("Cart data", data.webstoreId);
           this.webStoreId=data.webstoreId;
           // this.getCpnFromCart(data);
        } else if (error) {
            console.error(error);
        }
    }
    @wire(CartItemsAdapter, { webstoreId:this.webstoreId, cartStateOrId: 'current' })
    onGetCartItems(result) {
        if(!result){
              return;
           }
        console.log("CartItemsAdapter Id", result);
        console.log("CartItemsAdapter Id", result.data );
        const returnValArray = [];
        //console.log("cartItems Id", result.data.cartItems);
         if(result.data){
            console.log("cartItems Id", result.data.cartItems);
            const extensibleObject = { ...result.data };
            console.log(" extensibleObject cartItems Id", extensibleObject.cartItems);
            extensibleObject.cartItems.forEach((elm, index) => {
                if(Object.values(elm.cartItem.productDetails.variationAttributes).length > 0){
                    let attributeArray = [];
                    var str = '';
                    attributeArray = Object.values(elm.cartItem.productDetails.variationAttributes);
                    attributeArray.forEach(element => {
                        str += element.label + ": " + element.value + ", ";
                    });
                    str = str.substring(0, str.length - 2);

                    var resolvedImgUrl = resolve(
                        //item.ProductDetails.thumbnailImage.url
                        elm.cartItem.productDetails.thumbnailImage.url
                    );

                    //elm['varaiationArray'] = str;
                    //elm.varaiationArray = str;
                    //elm = {...elm,varaiationArray: str};
                    // Create a copy of elm, add varaiationArray, and replace the original object
                    const elmCopy = { ...elm, varaiationArray: str, resolvedImageUrl: resolvedImgUrl };

                    returnValArray.push(elmCopy);
                    //extensibleObject.cartItems[index] = elmCopy;
                }else{
                    var resolvedImgUrl = resolve(
                        //item.ProductDetails.thumbnailImage.url
                        elm.cartItem.productDetails.thumbnailImage.url
                    );
                    const elmCopy = { ...elm, resolvedImageUrl: resolvedImgUrl };

                    returnValArray.push(elmCopy);
                    //returnValArray.push(elm);
                }
            });
            //this.cartItemMap = result.data.cartItems;
            console.log("returnValArray", returnValArray);
            this.cartItemMap = returnValArray;
            console.log("cartItemMap", JSON.stringify(this.cartItemMap));
         }  
        
    }
    //  connectedCallback() {
    //       console.log('i m inconnectedcallback');
    //    // const result = contextApi.getSessionContext();
    //     console.log('Webstore ID',networkId);
      
    //  }
    getCpnFromCart(data){
        console.log('getCpnFromCart');
        let mapParams = {
            cartId : data.cartId
        }
        getCpnFromCart({
            mapParams: mapParams
        }).then((results) => {
            console.log('getCpnFromCart',JSON.stringify(results));
           this.cartItemMap = results.cartItemMap.cartItem;
        
        }).catch((error) => {
            console.log('getCpnFromCart error');
            console.log(error);
        });
    }
    handleProductDetailNavigation(evt) {
        evt.preventDefault();
        console.log(evt.target.dataset.productid);
        const productId = evt.target.dataset.productid;
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/product/' + productId
            }
        });
    }
}