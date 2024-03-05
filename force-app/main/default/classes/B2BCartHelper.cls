public with sharing class B2BCartHelper {
    
   
    //TODO get cart from cart selector
    public static Map<String,Object> getCpnFromCart(Map<String,Object> mapParams){
        Map<String,Object> cartItemMap = new  Map<String,Object>();
        String cartId = (String)mapParams.get(B2BConstants.CART_ID);
        WebCart cartObj = [SELECT Id, (SELECT Id,Product2.DisplayUrl,Name,Sku,Quantity, ListPrice,TotalPrice FROM CartItems where type='Product') FROM WebCart WHERE Id=:cartId];
        if(cartObj != null){
            List<CartItem> cartItemList = cartObj.CartItems;
            cartItemMap.put('cartItem',cartItemList);
            // if(!cartItemList.isEmpty()){
            //     for(CartItem item : cartItemList){
            //         cartItemMap.put(item.Id, item);
            //     }
            // }
        }
        return cartItemMap;
    }
}