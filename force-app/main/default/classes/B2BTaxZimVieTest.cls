@isTest
public class B2BTaxZimVieTest {

     @testSetup static void setup() {
        Account account = new Account(Name='TestAccount');
        insert account;
        WebStore webStore = new WebStore(Name='TestWebStore');
        insert webStore;
          Product2 pro = new Product2(
            Name = 'Sort Material-450',
            IsActive = true,
            StockKeepingUnit = 'Sort',
           ProductCode ='PC-110'
        );
        insert pro;
         ContactPointAddress contactAddress = new ContactPointAddress( Name='Billing');
         insert contactAddress;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=webStore.Id, AccountId=account.Id,Selected_Contact_Point_Address__c = contactAddress.Id);
        insert cart;
       
        
        
        
        OrderDeliveryMethod ordDeliveryMethod = new OrderDeliveryMethod(
            Name = 'OrderDelivery',
            ProductId = pro.Id,
            IsActive = true
        );
        insert ordDeliveryMethod;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
            CartId = cart.Id,
            DeliveryMethodId = ordDeliveryMethod.Id,
            Name = 'OrderDeliveryGroup',
            DeliverToName = 'OrderDeliver'

        );
        insert cartDeliveryGroup;
        CartItem cartItem = new CartItem(
            CartId=cart.Id, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Product',
            CurrencyIsoCode = 'USD',
            ListPrice = 10.89,
            TotalPrice = 30,
            Product2Id= pro.Id,
            
            Name='TestProduct', 
            CartDeliveryGroupId=cartDeliveryGroup.Id
        );
        insert cartItem;
         CartItem cartItem2 = new CartItem(
            CartId=cart.Id, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Charge', 
            Name='TestProduct', 
             TotalPrice = 30,
            CartDeliveryGroupId=cartDeliveryGroup.Id
        );
        insert cartItem2;
     
    }
    
    @isTest static void testCartTaxForCartItemSuccessfullyInserted() {
        // Because test methods don't support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TaxZimvie');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Test: execute the integration for the test cart ID.
        B2BTaxZimVie apexSample = new B2BTaxZimVie();
        Id webCartId = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1].Id;
        Id cartItemId = [SELECT Id FROM CartItem WHERE CartId = :webCartId LIMIT 1].Id;
        sfdc_checkout.IntegrationInfo testJobInfo = new sfdc_checkout.IntegrationInfo();
        testJobInfo.jobId = null;
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(testJobInfo, webCartId);
        Test.stopTest();
        System.assert(integrationResult != null);
    }
    
    @isTest static void testWhenExternalServiceCallFailsAFailedStatusIsReturnedAndACartValidationOutputEntryIsCreated() {
        // Because test methods don't support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TaxZimvie');
        // The web service call returns an error code.
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Test: execute the integration for the test cart ID and integration info.
        B2BTaxZimVie apexSample = new B2BTaxZimVie();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        
        // Validate: IntegrationStatus.Status is FAILED
        // and a new CartValidationOutput record with level 'Error' was created.
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(1, cartValidationOutputs.size());
        Test.stopTest();
    }

    @isTest static void testProductsWithNoSkuHasError() {
        Test.startTest();

        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        List<CartDeliveryGroup> cartDeliveryGroups = [SELECT Id FROM CartDeliveryGroup WHERE CartId = :webCart.Id LIMIT 1];

        // Insert a cart item without a SKU
        CartItem cartItemWithNoSku = new CartItem(
            CartId=webCart.Id,
            Quantity=1.0,
            Type='Product',
            Name='TestProductNoSku',
            CartDeliveryGroupId=cartDeliveryGroups.get(0).Id
        );
        insert cartItemWithNoSku;

        B2BTaxZimVie apexSample = new B2BTaxZimVie();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);

        // Validate: IntegrationStatus.Status is FAILED.
        // and a new CartValidationOutput record with level 'Error' was created.
        System.assertEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id, Message FROM CartValidationOutput WHERE Level = 'Error'];
        System.assertEquals(1, cartValidationOutputs.size());
        
        // Validate: The sample text that a product SKU is missing is returned as the failure output 
        System.assertEquals('The SKUs for all products in your cart must be defined.', cartValidationOutputs.get(0).Message);
        Test.stopTest();

        // Remove the invalid cart item
        delete cartItemWithNoSku;
    }
    @isTest
    static void startCustomTax(){
         WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        Test.startTest();
        B2BTaxZimVie tax = new B2BTaxZimVie();
        tax.startCustomTaxIntegration(webCart.Id);
        Test.stopTest();
    }
  @isTest static void testCartTaxForCartItemSuccessfullyInsertedV2() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('TaxZimvie');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Test: execute the integration for the test cart ID.
        B2BTaxZimVie apexSample = new B2BTaxZimVie();
        Id webCartId = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1].Id;
        CartItem cartItemId = [SELECT Id FROM CartItem WHERE CartId = :webCartId LIMIT 1];
        cartItemId.Type='Charge';
        update cartItemId;
        sfdc_checkout.IntegrationInfo testJobInfo = new sfdc_checkout.IntegrationInfo();
        testJobInfo.jobId = null; 
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(testJobInfo, webCartId);
        
        // Verify: the integration executed successfully
        // and the new CartTax record is inserted.
       
       Test.stopTest();
       System.assert(integrationResult != null);
    }
    @isTest
    static void startCustomTaxV2(){
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        CartItem cartItemId = [SELECT Id FROM CartItem WHERE CartId = :webCart.Id LIMIT 1];
        cartItemId.Type='Charge';
        update cartItemId;
        Test.startTest();
        B2BTaxZimVie tax = new B2BTaxZimVie();
        tax.startCustomTaxIntegration(webCart.Id);
        Test.stopTest();
    }
   /* @isTest
    static void generateXMLTest(){
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        CartItem cartItemId = [SELECT Id FROM CartItem WHERE CartId = :webCart.Id LIMIT 1];
        Test.startTest();
        B2BTaxZimVie.generateXMLBody(webCart.Id);
        Test.stopTest();
    }*/
    @isTest
    static void getTaxFromOracleTest(){
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        CartItem cartItemId = [SELECT Id FROM CartItem WHERE CartId = :webCart.Id LIMIT 1];
        Test.startTest();
        B2BTaxZimVie tax = new B2BTaxZimVie();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseTax());
        tax.getTaxFromOracle(webCart.Id);
       
        
        Test.stopTest();
    }

}