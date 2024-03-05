public with sharing class B2B_cartItemDeleteInvocableService {
    @InvocableMethod(label='Delete Tissue Product' description='Delete Tissue Product to the cart' category='Commerce')
    public static void deleteTissueProductToCart(List<CartItem> cartItems) {
     DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
    try{
        deleteFuture(cartItems.get(0).cartId);
        
        }
        catch (Exception e){
            logger.error(e);
        }
        
    }

    @future
    public static void deleteFuture(String cartId){
        Set<Id> prodIds = new Set<Id>();
        String tissueId;
        List<WebCart> storeIdList = [Select Id, WebStoreId, AccountId From WebCart Where Id =:cartId];
        String webstoreId = storeIdList.get(0).WebStoreId;
        String accountId = storeIdList.get(0).AccountId;
        List<CartItem> deleteTissueFeeCartItem = new List<CartItem>();
        for(CartItem cartItem : [Select Id, Product2Id, Product2.StockKeepingUnit  From CartItem Where cartId =:cartId]){
            prodIds.add(cartItem.Product2Id);
            if(cartItem.Product2.StockKeepingUnit=='TBHF'){
                deleteTissueFeeCartItem.add(cartItem);
            }
        }
        //List<ProductCategoryProduct> productCategories = [Select Id From ProductCategoryProduct Where ProductId IN:prodIds AND ProductCategory.Is_Tissue__c = true Limit 1];
        List<Product2> productList = [Select Id From Product2 Where Id IN:prodIds AND Apply_TBHF_Fee__c = true Limit 1];
        if(productList.isEmpty() && !deleteTissueFeeCartItem.isEmpty()){
           delete deleteTissueFeeCartItem;
        }
    }
    
}