public with sharing class LWR_CartHelper {

    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.LWR_CART_HELPER);

    public LWR_CartHelper() {

    }
    
    public class CartItemWrapper {
        @AuraEnabled
        public String id {get;set;}
        @AuraEnabled
        public String cartId {get;set;}
        @AuraEnabled
        public String product2Id {get;set;}
        @AuraEnabled
        public String product2Name {get;set;}
        @AuraEnabled
        public Decimal quantity {get;set;}
        @AuraEnabled
        public Decimal totalAdjustmentAmount {get;set;}
        @AuraEnabled
        public Decimal cartTotalAdjustmentAmount {get;set;}
        @AuraEnabled
        public Decimal totalAmount {get;set;}
        @AuraEnabled
        public Decimal TotalListPrice {get;set;}
        @AuraEnabled
        public Decimal TotalPrice {get;set;}
        @AuraEnabled
        public String type {get;set;}
        @AuraEnabled
        public Decimal unitAdjustedPrice {get;set;}
        @AuraEnabled
        public Decimal unitAdjustmentAmount {get;set;}
        @AuraEnabled
        public Decimal adjustmentAmount {get;set;}
        @AuraEnabled
        public String priceBookEntryId {get;set;}
        @AuraEnabled
        public Decimal listPrice {get;set;}
        @AuraEnabled
        public Decimal salesPrice {get;set;}
        @AuraEnabled
        public Decimal totalLineAmount {get;set;}
        @AuraEnabled
        public String productSellingModel {get;set;}
        @AuraEnabled
        public Decimal cartTotalProductAmount {get;set;}
        @AuraEnabled
        public Decimal cartTotalPromoAdjustmentAmount {get;set;}
        @AuraEnabled
        public Decimal cartTotalChargeAmount {get;set;}
        @AuraEnabled
        public Decimal cartTotalTaxAmount {get;set;}
        @AuraEnabled
        public Decimal cartGrandTotalAmount {get;set;}
        @AuraEnabled
        //public Decimal cartTotalListAmount {get;set;}
        public Decimal cartTotalListAmount = 0;
        @AuraEnabled
        public Boolean inStock {get;set;}
        @AuraEnabled
        public String currencyIsoCodeValue {get;set;}
    }

    public static Map<String,Object> getCartItemWithPricingDetailsApex(Map<String,Object> inputData){
        Map<String,Object> respData = new Map<String,Object>();
        try {
            System.debug('inputData--- '+inputData);
            List<Object> cartItemIdsSet = new List<Object>();
            List<Map<String,Object>> cartData = new List<Map<String,Object>>();
            List<String> cartItemIdsList = new List<String>();
            Map<String,Object> itemIdVsItemMap = new Map<String,Object>();
            if(!inputData.isEmpty()){
                if(inputData.get(B2BConstants.ORIGINAL_CART_ITEMS) != NULL){
                    cartItemIdsSet = (List<Object>) inputData.get(B2BConstants.ORIGINAL_CART_ITEMS);
                    List<Map<Object, Object>> data = new List<Map<Object, Object>>();
                    for (Object instance : (List<Object>)inputData.get(B2BConstants.ORIGINAL_CART_ITEMS)){
                        data.add((Map<Object, Object>)instance); 
                    }
                    for(Map<Object, Object> m : data){
                        cartItemIdsList.add((String)m.get('id'));
                    }
                    System.debug('cartItemIdsList--- '+cartItemIdsList);
                    List<CartItemWrapper> cartItemsFieldsData = getCartItemsFieldsLWR(cartItemIdsList);
                    for(CartItemWrapper wrap : cartItemsFieldsData){
                        itemIdVsItemMap.put(wrap.id,wrap);
                    }
                    for(Map<Object, Object> m : data){
                        m.put('data', itemIdVsItemMap.get((String)m.get('id')) );
                    }
                    respData.put('cartItemData', data);
                    respData.put('isSuccess', true);
                    respData.put('errorMsg', Null);
                }
            }else{
                respData.put('isSuccess', false);
                respData.put('errorMsg', 'inputData is empty');
            }
        } catch (Exception e) {
            logger.error(e);
        }finally {
            logger.flush();
       }
        return respData;
    }

    public static Map<String,Object> getCartItemWithPricingDetailsForCheckout(Map<String,Object> inputData){
        Map<String,Object> respData = new Map<String,Object>();
        try {
            System.debug('inputData--- '+inputData);
            List<Object> cartItemIdsSet = new List<Object>();
            List<Map<String,Object>> cartData = new List<Map<String,Object>>();
            List<String> cartItemIdsList = new List<String>();
            Map<String,Object> itemIdVsItemMap = new Map<String,Object>();
            if(!inputData.isEmpty()){
                if(inputData.get(B2BConstants.ORIGINAL_CART_ITEMS) != NULL){
                    cartItemIdsSet = (List<Object>) inputData.get(B2BConstants.ORIGINAL_CART_ITEMS);
                    List<Map<Object, Object>> data = new List<Map<Object, Object>>();
                    for (Object instance : (List<Object>)inputData.get(B2BConstants.ORIGINAL_CART_ITEMS)){
                        data.add((Map<Object, Object>)instance); 
                    }
                    for(Map<Object, Object> m : data){
                        Map<Object,Object> cartItemMap = (Map<Object,Object>)m.get('cartItem');
                        System.debug('cartItemMap------ '+JSON.serialize(cartItemMap));
                        cartItemIdsList.add((String)cartItemMap.get('cartItemId'));
                    }
                    System.debug('cartItemIdsList--- '+cartItemIdsList);
                    List<CartItemWrapper> cartItemsFieldsData = getCartItemsFieldsLWR(cartItemIdsList);
                    for(CartItemWrapper wrap : cartItemsFieldsData){
                        itemIdVsItemMap.put(wrap.id,wrap);
                    }
                    for(Map<Object, Object> m : data){
                        Map<Object,Object> cartItemMap = (Map<Object,Object>)m.get('cartItem');
                        cartItemMap.put('data', itemIdVsItemMap.get((String)cartItemMap.get('cartItemId')) );
                    }
                    inputData.put(B2BConstants.ORIGINAL_CART_ITEMS, data);
                    //respData.put('cartItemData', data);
                    respData.put('cartItemData', inputData);
                    respData.put('isSuccess', true);
                    respData.put('errorMsg', Null);
                }
            }else{
                respData.put('isSuccess', false);
                respData.put('errorMsg', 'inputData is empty');
            }
        } catch (Exception e) {
            logger.error(e);
        } finally {
            logger.flush();
       }
        return respData;
    }


    public static List<CartItemWrapper> getCartItemsFieldsLWR( List<String> cartItemIds ) {
        List<CartItemWrapper> result = new List<CartItemWrapper>();
        try {
            List<CartItem> cartitems = [
            SELECT Id, cartId, Product2Id, Product2.Name, Quantity, TotalAdjustmentAmount, TotalAmount, /*B2B_PriceBookEntry_Id__c,*/ TotalListPrice, TotalPrice, 
            /*ProductSellingModel__c,*/ Type, unitAdjustedPrice, unitAdjustmentAmount, AdjustmentAmount, ListPrice, SalesPrice, TotalLineAmount,
            Cart.TotalProductAmount, Cart.TotalPromoAdjustmentAmount, Cart.TotalChargeAmount, Cart.TotalTaxAmount, Cart.GrandTotalAmount, Cart.TotalAdjustmentAmount,
            Cart.TotalListAmount, CurrencyIsoCode
            FROM CartItem
            WHERE Id =: cartItemIds AND Type != 'Charge'
            ];
            Decimal totalListPriceDummy = 0;
            for(CartItem item : cartItems) {
                totalListPriceDummy += item.TotalLineAmount;
            }
            for(CartItem item : cartItems) {
                Boolean inventoryStatus = B2BGetInfo.checkProductIsInStock(item.Product2Id);
                CartItemWrapper resultItem = new CartItemWrapper();

                resultItem.id = item.Id;
                resultItem.cartId = item.cartId;
                resultItem.product2Id = item.Product2Id;
                resultItem.product2Name = item.Product2.Name;
                resultItem.quantity = item.Quantity;
                resultItem.totalAdjustmentAmount = item.TotalAdjustmentAmount;
                resultItem.cartTotalAdjustmentAmount = item.Cart.TotalAdjustmentAmount;
                resultItem.totalAmount = item.TotalAmount;
                resultItem.TotalListPrice = item.TotalListPrice;
                resultItem.TotalPrice = item.TotalPrice;
                resultItem.type = item.Type;
                resultItem.unitAdjustedPrice = item.unitAdjustedPrice;
                resultItem.unitAdjustmentAmount = item.unitAdjustmentAmount;
                resultItem.adjustmentAmount = item.AdjustmentAmount;
                //resultItem.priceBookEntryId = item.B2B_PriceBookEntry_Id__c;
                resultItem.listPrice = item.ListPrice;
                resultItem.salesPrice = item.SalesPrice;
                resultItem.totalLineAmount = item.TotalLineAmount;
                //resultItem.productSellingModel = item.ProductSellingModel__c;
                resultItem.cartTotalProductAmount = item.Cart.TotalProductAmount;
                resultItem.cartTotalPromoAdjustmentAmount = item.Cart.TotalPromoAdjustmentAmount;
                resultItem.cartTotalChargeAmount = item.Cart.TotalChargeAmount;
                resultItem.cartTotalTaxAmount = item.Cart.TotalTaxAmount;
                resultItem.cartGrandTotalAmount = item.Cart.GrandTotalAmount;
                //resultItem.cartTotalListAmount= item.Cart.TotalListAmount;
                resultItem.cartTotalListAmount = totalListPriceDummy;
                resultItem.inStock = inventoryStatus;
                resultItem.currencyIsoCodeValue = item.CurrencyIsoCode;
                result.add(resultItem);
            }
            System.debug('getCartItemsFields--- '+result);
        } catch (Exception e) {
            logger.error(e);
        } finally {
            logger.flush();
       }
        return result; 
    }
}