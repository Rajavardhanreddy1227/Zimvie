public with sharing class b2b_AddressDetailsController {
    public b2b_AddressDetailsController() {

    }
    private static final List<String> CART_FIELDS = new List<String>{
        'DR_Checkout_Type__c'
    };

    private static final List<String> CART_ITEMS_FIELDS = new List<String>{
        'CartDeliveryGroup.DeliverToCountry',
        'CartDeliveryGroup.DeliverToState',
        'CartDeliveryGroup.DeliverToPostalCode',
        'CartDeliveryGroup.DeliverToCity',
        'CartDeliveryGroup.DeliverToStreet'
    };
    @AuraEnabled
    public static String getAddressesDetails(Id CartId) {
        String result;
        
        try {
            Map<String, object> response = new Map<String, object>();
            WebCart cart = getCartWithItemsById(cartId, CART_FIELDS, CART_ITEMS_FIELDS);
            CartDeliveryGroup deliveryGroup = (CartDeliveryGroup) cart.CartItems.get(0).getSObject(CartItem.CartDeliveryGroupId);
            response.put(
                'billingAddress', getById(CartId, new Set<String>{ 'BillingAddress' })?.BillingAddress
            );
            response.put(
                'shippingAddress', deliveryGroup
            );

            result = JSON.serialize(response);
        } catch (Exception e) {
         //   logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
           // logger.flush();
        }
        return result;
    }
    public static WebCart getCartWithItemsById(String cartId, List<String> cartFields, List<String> cartItemFields) {
        return getCartWithItemsByIds(new Set<String>{ cartId }, cartFields, cartItemFields).get(0);
    }
    public static List<WebCart> getCartWithItemsByIds(
        Set<String> cartId,
        List<String> cartFields,
        List<String> cartItemFields
    ) {
        return (List<WebCart>) new DCM_Query('WebCart')
            .selectFields(cartFields)
            .addSubquery('CartItems', cartItemFields)
            .addConditionEq('Id', cartId)
            .debug()
            .setLimit(2000)
            .run();
    }

    public static WebCart getById(Id cartId, Set<String> fields) {
        return (WebCart) new DCM_Query('WebCart')
            .selectFields(new List<String>(fields))
            .addConditionEq('Id', cartId)
            .run()[0];
    }
}