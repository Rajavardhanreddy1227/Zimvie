/**
 * @description       : 
 * @author            : asood@rafter.one
 * @group             : 
 * @last modified on  : 09-02-2023
 * @last modified by  : asood@rafter.one
**/
public class B2b_ShippingMethod {
    @AuraEnabled
    public static String findShippingMethodByCountry(CartDeliveryGroup objCDG) {
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            if(objCDG.DeliverToCountry == '' || objCDG.DeliverToCountry == null){
                return null;
            }
            WebCart objCart = new WebCart();
            objCart = [Select AccountId,(SELECT Id,sku FROM CartItems where type = 'Product') from WebCart where Id=:objCDG.CartId];

            List<ShippingOptionsAndRatesWrapper> lstWrap = getShippingOptionsAndRatesWrapper(objCDG.DeliverToCountry);

            // On re-entry of the checkout flow delete all previous CartDeliveryGroupMehods for the given cartDeliveryGroupId
            database.delete([SELECT Id FROM CartDeliveryGroupMethod WHERE CartDeliveryGroupId = :objCDG.Id],false);
            Boolean onlyLoyaltyProduct = false ;
            if(objCart.cartItems != null && objCart.cartItems.size() == 1 &&  (objCart.cartItems.get(0).sku == 'ELP1YR' || objCart.cartItems.get(0).sku == 'ELPRENEW')){
                onlyLoyaltyProduct = true ;

                lstWrap = new List<ShippingOptionsAndRatesWrapper>{new ShippingOptionsAndRatesWrapper(
                    'N/A Shipping',
                    'N/A',
                    0,
                    0.0,
                    'N/A Shipping',
                    'USD'
                )} ;
            }
            // Create orderDeliveryMethods given your shipping options or fetch existing ones. 2 should be returned.
            Set<Id> orderDeliveryMethodIds = new Set<Id>();

            List<OrderDeliveryMethod> lstODM = new List<OrderDeliveryMethod>();
            if(onlyLoyaltyProduct == true){
                lstODM = [Select Id,Name,Carrier,isActive,ProductId,ClassOfService from OrderDeliveryMethod where Id='2Dm8L000000CajuSAC'];
            } else {
                lstODM = getOrderDeliveryMethods(lstWrap);
            }
            if(lstODM != null && lstODM.size() > 0){
                for(OrderDeliveryMethod objODM: lstODM){
                    orderDeliveryMethodIds.add(objODM.Id);
                }
            }

            // Create CartDeliveryGroupMethod record for every shipping option returned from the external service

            List<CartDeliveryGroupMethod> lstCDGM = new List<CartDeliveryGroupMethod>();
            Integer i = 0;
            for (Id orderDeliveryMethodId: orderDeliveryMethodIds) {
                CartDeliveryGroupMethod cartDeliveryGroupMethod = new CartDeliveryGroupMethod(
                    CartDeliveryGroupId = objCDG.Id,
                    DeliveryMethodId = orderDeliveryMethodId,
                    ExternalProvider = lstWrap[i].getProvider(),
                    Name = lstWrap[i].getName(),
                    ShippingFee = lstWrap[i].getRate(),
                    WebCartId = objCDG.CartId,
                    CurrencyIsoCode =lstWrap[i].getCurrCode()
                );
                lstCDGM.add(cartDeliveryGroupMethod);
                i+=1;
            }

            if(!lstCDGM.isEmpty()){
                insert lstCDGM;
            }
            return JSON.serialize(lstODM);
        } 
        catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
        return null;
    }

    private static ShippingOptionsAndRatesWrapper[] getShippingOptionsAndRatesWrapper (String Country) {
        ShippingOptionsAndRatesWrapper[] shippingOptions = new List<ShippingOptionsAndRatesWrapper>();
        system.debug('getShippingOptionsAndRatesWrapper>>>>>>>>>>>>>');
        Country = Country != null ? Country : 'United States';
        system.debug('currentUsercountry'+Country);
        list<Checkout_Shipping_method__c> ship = new list<Checkout_Shipping_method__c>();
        
        ship = [SELECT id, Sku_Tax_Code__c ,Shipping_Charges__c,Display_Name__c ,CurrencyISOCode, Shipping_Carrier__c
               FROM 
               Checkout_Shipping_method__c 
               WHERE ShippingMethod_Country__c=:Country];
        for(Checkout_Shipping_method__c objShipMethod : ship){
            shippingOptions.add( new ShippingOptionsAndRatesWrapper(
                    objShipMethod.Display_Name__c,
                    objShipMethod.Sku_Tax_Code__c,
                    objShipMethod.Shipping_Charges__c,
                    0.0,
                    //objShipMethod.Display_Name__c,
                    objShipMethod.Shipping_Carrier__c,      //changes made for https://rafterone.atlassian.net/browse/ZIM-541
                    objShipMethod.CurrencyISOCode
                ));
        }
        return shippingOptions;
    }

    // Structure to store the shipping options retrieved from external service.
    public Class ShippingOptionsAndRatesWrapper {
        private String name;
        private String provider;
        private Decimal rate;
        private Decimal otherCost;
        private String serviceName;
        private String currCode;

        public ShippingOptionsAndRatesWrapper() {
            name = '';
            provider = '';
            rate = 0.0;
            serviceName = '';
            otherCost = 0.0;
            currCode = 'USD';
        }

        public ShippingOptionsAndRatesWrapper(String someName, String someProvider, Decimal someRate, Decimal someOtherCost, String someServiceName, String someCurrCode) {
            name = someName;
            provider = someProvider;
            rate = someRate;
            otherCost = someOtherCost;
            serviceName = someServiceName;
            currCode = someCurrCode;
        }

        public String getProvider() {
            return provider;
        }

        public Decimal getRate() {
            return rate;
        }

        public Decimal getOtherCost() {
            return otherCost;
        }

        public String getServiceName() {
            return serviceName;
        }

        public String getName() {
            return name;
        }

        public String getCurrCode(){
            return currCode;
        }
    }

    private static List<OrderDeliveryMethod> getOrderDeliveryMethods(List<ShippingOptionsAndRatesWrapper> shippingOptions) {
        Set<String> shippingOptionNames = new Set<String>();
        for(ShippingOptionsAndRatesWrapper shipobj : shippingOptions){
            shippingOptionNames.add(shipobj.name);
        }
        Id product2IdForThisDeliveryMethod = getDefaultShippingChargeProduct2Id();

        // Fetch existing OrderDeliveryMethods
        Map<String, OrderDeliveryMethod> existingOrderDeliveryMethods = new Map<String, OrderDeliveryMethod>();
        for (OrderDeliveryMethod existingOdm : [SELECT Id, Name, ProductId, Carrier, ClassOfService FROM OrderDeliveryMethod WHERE Name IN :shippingOptionNames AND isActive = true]) {
            existingOrderDeliveryMethods.put(existingOdm.Name, existingOdm);
        }

        List<OrderDeliveryMethod> methodsToUpdate = new List<OrderDeliveryMethod>();
        List<OrderDeliveryMethod> methodsToInsert = new List<OrderDeliveryMethod>();
        List<OrderDeliveryMethod> updatedOrInsertedMethods = new List<OrderDeliveryMethod>();
        
        for (ShippingOptionsAndRatesWrapper shippingOption : shippingOptions) {
            if (!existingOrderDeliveryMethods.containsKey(shippingOption.name)) {
                // Create a new OrderDeliveryMethod if it doesn't exist
                OrderDeliveryMethod defaultOrderDeliveryMethod = new OrderDeliveryMethod(
                    Name = shippingOption.name,
                    Carrier = shippingOption.serviceName,
                    isActive = true,
                    ProductId = product2IdForThisDeliveryMethod,
                    ClassOfService = shippingOption.provider
                );
                methodsToInsert.add(defaultOrderDeliveryMethod);
                updatedOrInsertedMethods.add(defaultOrderDeliveryMethod);
            } else {
                OrderDeliveryMethod existingOdm = existingOrderDeliveryMethods.get(shippingOption.name);

                if (existingOdm.ProductId == null || existingOdm.Carrier == null || existingOdm.ClassOfService == null) {
                    existingOdm.ProductId = product2IdForThisDeliveryMethod;
                    existingOdm.Carrier = shippingOption.serviceName;
                    existingOdm.ClassOfService = shippingOption.provider;
                    methodsToUpdate.add(existingOdm);
                    updatedOrInsertedMethods.add(existingOdm);
                } else {
                    updatedOrInsertedMethods.add(existingOdm);
                }
            }
        }
        
        // Perform DML outside the loop
        if (!methodsToInsert.isEmpty()) {
            insert methodsToInsert;
        }
        if (!methodsToUpdate.isEmpty()) {
            update methodsToUpdate;
        }
        
        return updatedOrInsertedMethods;
    }


    private static Id getDefaultShippingChargeProduct2Id() {
        // In this example we will name the product representing shipping charges 'Shipping Charge for this delivery method'.
        // Check to see if a Product2 with that name already exists.
        // If it doesn't exist, create one.
        String shippingChargeProduct2Name = 'Shipping Charge for this delivery method';
        List<Product2> shippingChargeProducts = [SELECT Id FROM Product2 WHERE Name = :shippingChargeProduct2Name];
        if (shippingChargeProducts.isEmpty()) {
            Product2 shippingChargeProduct = new Product2(
                isActive = true,
                Name = shippingChargeProduct2Name
            );
            insert(shippingChargeProduct);
            return shippingChargeProduct.Id;
        }
        else {
            return shippingChargeProducts[0].Id;
        }
    }
    @AuraEnabled
    public static string getSelectedDeliveryMethod(String cartId){
        String selectedDeleveryMethodId = '';
        try {
            if(String.isNotBlank(cartId)){
                CartDeliveryGroup cartDeliveryGroup = [Select Id,CartId,DeliveryMethodId,DeliveryMethod.Name from CartDeliveryGroup where CartId=: cartId];
               if(cartDeliveryGroup != null && cartDeliveryGroup.DeliveryMethodId != null){
                    selectedDeleveryMethodId = cartDeliveryGroup.DeliveryMethod.Name == 'Default Delivery Method' ? null : cartDeliveryGroup.DeliveryMethodId;
               } else {
                   selectedDeleveryMethodId = null;
               }
            }

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return selectedDeleveryMethodId;
    }
}