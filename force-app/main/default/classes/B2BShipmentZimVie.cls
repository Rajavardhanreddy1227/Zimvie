// This must implement the sfdc_checkout.CartShippingCharges interface
// in order to be processed by the checkout flow for the "Shipping" integration
global class B2BShipmentZimVie implements sfdc_checkout.CartShippingCharges {
    global sfdc_checkout.IntegrationStatus startCartProcessAsync(sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
        sfdc_checkout.IntegrationStatus integStatus = new sfdc_checkout.IntegrationStatus();
        try {
            system.debug('startCartProcessAsync>>>>>>>>>>>>>');
            WebCart objCart = new WebCart();
            objCart = [Select AccountId,(SELECT Id,sku FROM CartItems where type = 'Product') from WebCart where Id=:cartId];
            List<User> lstUser = new List<User>();
            lstUser = [Select Id,Country from User where Contact.AccountId=:objCart.AccountId];
            System.debug('lstUser:: '+lstUser);
            System.debug([Select Id,Country,Contact.AccountId from User]);
            
            
            // In the Winter '21 release there should be two delivery groups per cart.
            // We need to get the ID of the cart delivery group in order to create the order delivery groups.
            Id cartDeliveryGroupId = [SELECT CartDeliveryGroupId FROM CartItem WHERE CartId = :cartId][0].CartDeliveryGroupId;

            CartDeliveryGroup cdg = [SELECT Id FROM CartDeliveryGroup WHERE Id = :cartDeliveryGroupId LIMIT 1];
            // Get the shipping options from an external service.
            // We're getting information like rates and carriers from this external service.
            String siteLanguage = jobInfo.siteLanguage;
            
            // Following line of code calls the live HTTP Heroku Service to retrieve mocked sample shipping methods.
            // If you need to bypass the live call, use getShippingOptionsAndRatesFromMockedService instead.
            // Both implementations are just samples returning hardcoded Shipping options and MUST not be used in production systems.
            ShippingOptionsAndRatesFromExternalService[] shippingOptionsAndRatesFromExternalService;
            if(!Test.isRunningTest()){
                shippingOptionsAndRatesFromExternalService = getShippingOptionsAndRatesFromExternalService(siteLanguage,lstUser[0].Country);
            }else{
                User u = [SELECT Id, Name, City, Country FROM User where Id=:UserInfo.getUserId()];
                String country = u.Country ;
                shippingOptionsAndRatesFromExternalService = getShippingOptionsAndRatesFromExternalService(siteLanguage,country);
            }
            // On re-entry of the checkout flow delete all previous CartDeliveryGroupMehods for the given cartDeliveryGroupId
            database.delete([SELECT Id FROM CartDeliveryGroupMethod WHERE CartDeliveryGroupId = :cartDeliveryGroupId],false);
            Boolean onlyLoyaltyProduct = false ;
            if(objCart.cartItems != null && objCart.cartItems.size() == 1 &&  (objCart.cartItems.get(0).sku == 'ELP1YR' || objCart.cartItems.get(0).sku == 'ELPRENEW')){
                onlyLoyaltyProduct = true ;

                shippingOptionsAndRatesFromExternalService = new List<ShippingOptionsAndRatesFromExternalService>{new ShippingOptionsAndRatesFromExternalService(
                    'N/A Shipping',
                    'N/A',
                    0,
                    0.0,
                    'N/A Shipping',
                    'USD'
                )} ;
            }
            // Create orderDeliveryMethods given your shipping options or fetch existing ones. 2 should be returned.
            List<Id> orderDeliveryMethodIds = onlyLoyaltyProduct ? new List<Id>{'2Dm8L000000CajuSAC'} :  getOrderDeliveryMethods(shippingOptionsAndRatesFromExternalService);

            // Create a CartDeliveryGroupMethod record for every shipping option returned from the external service
            Integer i = 0;
            for (Id orderDeliveryMethodId: orderDeliveryMethodIds) {
               populateCartDeliveryGroupMethodWithShippingOptions(shippingOptionsAndRatesFromExternalService[i],
                                                                cartDeliveryGroupId,
                                                                orderDeliveryMethodId,
                                                                cartId);
                i+=1;
            }
            // If everything works well, the charge is added to the cart and our integration has been successfully completed.
            integStatus.status = sfdc_checkout.IntegrationStatus.Status.SUCCESS;

        // For testing purposes, this example treats exceptions as user errors, which means they are displayed to the buyer user.
        // In production you probably want this to be an admin-type error. In that case, throw the exception here
        // and make sure that a notification system is in place to let the admin know that the error occurred.
        // See the readme section about error handling for details about how to create that notification.
        } catch (DmlException de) {
            // Catch any exceptions thrown when trying to insert the shipping charge to the CartItems
            system.debug('===='+de.getStackTraceString());
            Integer numErrors = de.getNumDml();
            String errorMessage = 'There were ' + numErrors + ' errors when trying to insert the charge in the CartItem: ';
            for(Integer errorIdx = 0; errorIdx < numErrors; errorIdx++) {
                errorMessage += 'Field Names = ' + de.getDmlFieldNames(errorIdx);
                errorMessage += 'Message = ' + de.getDmlMessage(errorIdx);
                errorMessage += ' , ';
            }
            return integrationStatusFailedWithCartValidationOutputError(
                integStatus,
                errorMessage,
                jobInfo,
                cartId
            );
        } catch(Exception e) {
            return integrationStatusFailedWithCartValidationOutputError(
                integStatus,
                'An exception occurred during Shipping Calculation.',
                jobInfo,
                cartId
            );
        }
        return integStatus;
    }

    /**
        This method provides a sample of how to call an external service to retrieve Shipping Options.
        The heroku servie called in this method is just a reference implementation that responds back with
        a sample response and MUST not be used in production systems.
     */
    @TestVisible
    private ShippingOptionsAndRatesFromExternalService[] getShippingOptionsAndRatesFromExternalService (String siteLanguage,String Country) {
        ShippingOptionsAndRatesFromExternalService[] shippingOptions = new List<ShippingOptionsAndRatesFromExternalService>();
        /*Http http = new Http();
        HttpRequest request = new HttpRequest();
        Integer SuccessfulHttpRequest = 200;
        // To access the service below, you may need to add endpoint = https://b2b-commerce-test.herokuapp.com in Setup | Security | Remote site settings.
        request.setEndpoint('https://b2b-commerce-test.herokuapp.com/calculate-shipping-rates-winter-21-with-lang?lang=' + siteLanguage);
        request.setMethod('GET');
        HttpResponse response = http.send(request);
        // If the request is successful, parse the JSON response.
        // The response looks like this:
        // [{"status":"calculated","rate":{"name":"Delivery Method 1","serviceName":"Test Carrier 1","serviceCode":"SNC9600","shipmentCost":11.99,"otherCost":5.99}},
        // {"status":"calculated","rate":{"name":"Delivery Method 2","serviceName":"Test Carrier 2","serviceCode":"SNC9600","shipmentCost":15.99,"otherCost":6.99}}]
        if (response.getStatusCode() == SuccessfulHttpRequest) {
           List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
           for (Object result: results) {
                Map<String, Object> subresult = (Map<String, Object>) result;
                Map<String, Object> providerAndRate = (Map<String, Object>) subresult.get('rate');
                shippingOptions.add( new ShippingOptionsAndRatesFromExternalService(
                    (String) providerAndRate.get('name'),
                    (String) providerAndRate.get('serviceCode'),
                    (Decimal) providerAndRate.get('shipmentCost'),
                    (Decimal) providerAndRate.get('otherCost'),
                    (String) providerAndRate.get('serviceName')
                ));
            }
            return shippingOptions;
        }
        else {
            throw new CalloutException ('There was a problem with the request. Error: ' + response.getStatusCode());
        }*/
        system.debug('getShippingOptionsAndRatesFromExternalService>>>>>>>>>>>>>');
        Country = Country != null ? Country : 'United States';
        system.debug('currentUsercountry'+Country);
        list<Checkout_Shipping_method__c> ship = new list<Checkout_Shipping_method__c>();
        
        ship = [SELECT id, Sku_Tax_Code__c ,Shipping_Charges__c,Display_Name__c ,CurrencyISOCode
               FROM 
               Checkout_Shipping_method__c 
               WHERE ShippingMethod_Country__c=:Country];
        for(Checkout_Shipping_method__c objShipMethod : ship){
            shippingOptions.add( new ShippingOptionsAndRatesFromExternalService(
                    objShipMethod.Display_Name__c,
                    objShipMethod.Sku_Tax_Code__c,
                    objShipMethod.Shipping_Charges__c,
                    0.0,
                    objShipMethod.Display_Name__c,
                    objShipMethod.CurrencyISOCode
                ));
        }
        return shippingOptions;
    }


    /**
        This method provides an alternative to retrieve Shipping Options if http call needs to be bypassed.
        This method uses a hardcoded sample response and MUST not be used in production systems.
     */
    /*private ShippingOptionsAndRatesFromExternalService[] getShippingOptionsAndRatesFromMockedService (String siteLanguage) {
        ShippingOptionsAndRatesFromExternalService[] shippingOptions = new List<ShippingOptionsAndRatesFromExternalService>();
        String responseBody = getShippingOptionsResponse(siteLanguage);
        List<Object> results = (List<Object>) JSON.deserializeUntyped(responseBody);
        for (Object result: results) {
            Map<String, Object> subresult = (Map<String, Object>) result;
            Map<String, Object> providerAndRate = (Map<String, Object>) subresult.get('rate');
            shippingOptions.add( new ShippingOptionsAndRatesFromExternalService(
                (String) providerAndRate.get('name'),
                (String) providerAndRate.get('serviceCode'),
                (Decimal) providerAndRate.get('shipmentCost'),
                (Decimal) providerAndRate.get('otherCost'),
                (String) providerAndRate.get('serviceName')
            ));
        }
        return shippingOptions;
    }

    private String getShippingOptionsResponse(String siteLanguage) {
        String name1, name2, serviceName1, serviceName2;
        if(siteLanguage == 'de') {
            name1 = 'Liefermethode 1';
            name2 = 'Liefermethode 2';
            serviceName1 = 'Testträger 1';
            serviceName2 = 'Testträger 2';
        } else if(siteLanguage == 'ja') {
            name1 = '配送方法1';
            name2 = '配送方法2';
            serviceName1 = 'テストキャリア1';
            serviceName2 = 'テストキャリア2';
        } else {
            name1 = 'Delivery Method 1';
            name2 = 'Delivery Method 2';
            serviceName1 = 'Test Carrier 1';
            serviceName2 = 'Test Carrier 2';
        }
        return '[{"status":"calculated","rate":{"name":"'+name1+'","serviceName":"'+serviceName1+'","serviceCode":"SNC9600","shipmentCost":11.99,"otherCost":5.99}},{"status":"calculated","rate":{"name":"'+name2+'","serviceName":"'+serviceName2+'","serviceCode":"SNC9600","shipmentCost":15.99,"otherCost":6.99}}]';
    }*/

    // Structure to store the shipping options retrieved from external service.
   public  Class ShippingOptionsAndRatesFromExternalService {
        private String name;
        private String provider;
        private Decimal rate;
        private Decimal otherCost;
        private String serviceName;
        private String currCode;

        public ShippingOptionsAndRatesFromExternalService() {
            name = '';
            provider = '';
            rate = 0.0;
            serviceName = '';
            otherCost = 0.0;
            currCode = 'USD';
        }

        public ShippingOptionsAndRatesFromExternalService(String someName, String someProvider, Decimal someRate, Decimal someOtherCost, String someServiceName, String someCurrCode) {
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
     @TestVisible
    // Create a CartDeliveryGroupMethod record for every shipping option returned from the external service
    private void populateCartDeliveryGroupMethodWithShippingOptions(ShippingOptionsAndRatesFromExternalService shippingOption,
                                                                  Id cartDeliveryGroupId,
                                                                  Id deliveryMethodId,
                                                                  Id webCartId){
        // When inserting a new CartDeliveryGroupMethod, the following fields have to be populated:
        // CartDeliveryGroupId: Id of the delivery group of this shipping option
        // DeliveryMethodId: Id of the delivery method for this shipping option
        // ExternalProvider: Unique identifier of shipping provider
        // Name: Name of the CartDeliveryGroupMethod record
        // ShippingFee: The cost of shipping for the delivery group
        // WebCartId: Id if the cart that the delivery group belongs to

        generateXMLBody(webCartId);

        CartDeliveryGroupMethod cartDeliveryGroupMethod = new CartDeliveryGroupMethod(
            CartDeliveryGroupId = cartDeliveryGroupId,
            DeliveryMethodId = deliveryMethodId,
            ExternalProvider = shippingOption.getProvider(),
            Name = shippingOption.getName(),
            ShippingFee = shippingOption.getRate(),
            WebCartId = webCartId,
            CurrencyIsoCode =shippingOption.getCurrCode()
);
 try{                                                               
        insert(cartDeliveryGroupMethod);
    }
catch(Exception ex){
    system.debug('Error On CART'+ex.getMessage());
                 }                                                      
                                                                  
                                                                  }
    private sfdc_checkout.IntegrationStatus integrationStatusFailedWithCartValidationOutputError(
        sfdc_checkout.IntegrationStatus integrationStatus, String errorMessage, sfdc_checkout.IntegrationInfo jobInfo, Id cartId) {
            integrationStatus.status = sfdc_checkout.IntegrationStatus.Status.FAILED;
            // In order for the error to be propagated to the user, we need to add a new CartValidationOutput record.
            // The following fields must be populated:
            // BackgroundOperationId: Foreign Key to the BackgroundOperation
            // CartId: Foreign key to the WebCart that this validation line is for
            // Level (required): One of the following - Info, Error, or Warning
            // Message (optional): Message displayed to the user
            // Name (required): The name of this CartValidationOutput record. For example CartId:BackgroundOperationId
            // RelatedEntityId (required): Foreign key to WebCart, CartItem, CartDeliveryGroup
            // Type (required): One of the following - SystemError, Inventory, Taxes, Pricing, Shipping, Entitlement, Other
            CartValidationOutput cartValidationError = new CartValidationOutput(
                BackgroundOperationId = jobInfo.jobId,
                CartId = cartId,
                Level = 'Error',
                Message = errorMessage.left(255),
                Name = (String)cartId + ':' + jobInfo.jobId,
                RelatedEntityId = cartId,
                Type = 'Shipping'
            );
            insert(cartValidationError);
            return integrationStatus;
    }
  @TestVisible
    private Id getShippingChargeProduct2Id(Id orderDeliveryMethodId) {
        // The Order Delivery Method should have a Product2 associated with it, because we added that in getDefaultOrderDeliveryMethod if it didn't exist.
        List<OrderDeliveryMethod> orderDeliveryMethods = [SELECT ProductId FROM OrderDeliveryMethod WHERE Id = :orderDeliveryMethodId];
        return orderDeliveryMethods[0].ProductId;
    }
    @TestVisible
    private List<Id> getOrderDeliveryMethods(List<ShippingOptionsAndRatesFromExternalService> shippingOptions) {
        //String defaultDeliveryMethodName = 'Order Delivery Method';
        Id product2IdForThisDeliveryMethod = getDefaultShippingChargeProduct2Id();

        // Check to see if a default OrderDeliveryMethod already exists.
        // If it doesn't exist, create one.
        List<Id> orderDeliveryMethodIds = new List<Id>();
        List<OrderDeliveryMethod> orderDeliveryMethods = new List<OrderDeliveryMethod>();
        Integer i = 1;
        for (ShippingOptionsAndRatesFromExternalService shippingOption: shippingOptions) {
            //String shippingOptionNumber = String.valueOf(i);
            //String name = defaultDeliveryMethodName + shippingOptionNumber;
            List<OrderDeliveryMethod> odms = [SELECT Id, ProductId, Carrier, ClassOfService FROM OrderDeliveryMethod WHERE Name = :shippingOption.name AND isActive = true];
            // This is the case in which an Order Delivery method does not exist.
            if (odms.isEmpty()) {
                OrderDeliveryMethod defaultOrderDeliveryMethod = new OrderDeliveryMethod(
                    Name = shippingOption.name,
                    Carrier = shippingOption.serviceName,
                    isActive = true,
                    ProductId = product2IdForThisDeliveryMethod,
                    ClassOfService = shippingOption.provider
                );
                insert(defaultOrderDeliveryMethod);
                orderDeliveryMethodIds.add(defaultOrderDeliveryMethod.Id);
            }
            else {
                // This is the case in which an Order Delivery method exists.
                // If the OrderDeliveryMethod doesn't have a Product2 associated with it, assign one
                // We can always pick the 0th orderDeliveryMethod since we queried based off the name.
                OrderDeliveryMethod existingodm = odms[0];
                // This is for reference implementation purposes only.
                // This is the if statement that checks to make sure that there is a product carrier and class of service
                // associated to the order delivery method.
                if (existingodm.ProductId == null || existingodm.Carrier == null || existingodm.ClassOfService == null) {
                    existingodm.ProductId = product2IdForThisDeliveryMethod;
                    existingodm.Carrier = shippingOption.serviceName;
                    existingodm.ClassOfService = shippingOption.provider;
                    update(existingodm);
                }
                orderDeliveryMethodIds.add(existingodm.Id);
            }
            i+=1;
        }
        return orderDeliveryMethodIds;
    }
  @TestVisible

    private Id getDefaultShippingChargeProduct2Id() {
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

    public static String generateXMLBody(String cartId){ 
        String randomGUID = (String) ((Map<String,Object>) JSON.deserializeUntyped(new Auth.JWT().toJSONString())).get('jti');
        String accId;
        WebCart cartObj = [SELECT Id, AccountId FROM WebCart WHERE Id = :cartId LIMIT 1];
        accId = cartObj.AccountId;
        Account accObj = [SELECT Id, Oracle_Address_ID__c FROM Account WHERE Id = :accId LIMIT 1];
        List<CartItem> cartItemList = [SELECT Id FROM CartItem WHERE cartId = :cartId];
        string strxml ='';
        // strxml ='<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' +
        //             '<PricingRequest TrackingGUID="' + randomGUID + '">' +  
        //                 '<OrderHeader HeaderID="' + cartId + '">' +                //'<OrderHeader HeaderID="184019">' +
        //                     '<OrderNumber>' + cartId + '</OrderNumber>' +          //'<OrderNumber>184019</OrderNumber>' +
        //                     '<CustomerID>' + cartObj.Account.Oracle_Address_ID__c + '</CustomerID>' +                                     //'<CustomerID>417054</CustomerID>' + 
        //                     '<CustomerNumber>' + cartObj.Account.Oracle_Address_ID__c + '</CustomerNumber>' +                             //'<CustomerNumber>418762</CustomerNumber>' +
        //                     // '<ShiptoName/>' +
        //                     // '<ShippingCarrier>FedEx</ShippingCarrier>' +
        //                     // '<CarrierService>FED1AM</CarrierService>' +
        //                     // '<ShippingCharge>31.00</ShippingCharge>' +
        //                     '<CurrencyCode>USD</CurrencyCode>' +
        //                     // '<ShiptoLocation LocationID="999999">' +
        //                     //     '<ERPReferenceID></ERPReferenceID>' +
        //                     //     '<Address1>26 wild rice dr</Address1>' +
        //                     //     '<Address2></Address2>' +
        //                     //     '<Address3></Address3>' +
        //                     //     '<Address4></Address4>' +		
        //                     //     '<City>Pawleys Island</City>' +
        //                     //     '<County>Georgetown</County>' +
        //                     //     '<State>SC</State>' +
        //                     //     '<PostalCode>29585</PostalCode>' +
        //                     //     '<CountryCode>US</CountryCode>' +
        //                     //     '<SiteNickname>SC Office</SiteNickname>' +
        //                     // '</ShiptoLocation>' +  
        //                 '</OrderHeader>' +
        //                 '<OrderLines>' +    
        //                     '<OrderLine>' +      //'<OrderLine LineID="25012">' +
        //                         //'<LineNumber>1</LineNumber>' +
        //                         //'<ItemID>12334</ItemID>' +
        //                         '<ItemNumber>' + cartItemToUpdate.Product2.ProductCode + '</ItemNumber>' +                    //'<ItemNumber>IOSS410</ItemNumber>' + 
        //                         '<PricingQuantity>' + cartItemToUpdate.Quantity + '</PricingQuantity>' +        //'<PricingQuantity>2</PricingQuantity>' + 
        //                         // '<QuantityUOMCode>EA</QuantityUOMCode>' +
        //                         '<UnitListPrice>' + cartItemToUpdate.ListPrice + '</UnitListPrice>' +      //'<UnitListPrice>34</UnitListPrice>' +
        //                     '</OrderLine>' +
        //                 '</OrderLines>' +
        //             '</PricingRequest>';
        return strxml;
    }
}