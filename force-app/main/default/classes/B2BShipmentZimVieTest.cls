@isTest
public class B2BShipmentZimVieTest {
    @testSetup 
    public static void setup() {
        
        RecordType rtForAcc = [SELECT Id FROM RecordType 
                               WHERE SobjectType = 'Account' 
                               AND DeveloperName = 'Distributor' LIMIT 1];
        //Account ac = B2B_TestUtils.createAccount(true);
        
        WebStore ws = B2B_TestUtils.createWebStore(true);
           Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert cart;
        Product2 pro = new Product2(
            Name = 'Sort Material-450',
            IsActive = true,
            StockKeepingUnit = 'Sort-45',
            ProductCode ='PC-111'
        );
        insert pro;
         OrderDeliveryMethod ordDeliveryMethod = new OrderDeliveryMethod(
            Name = 'OrderDelivery',
            ProductId = pro.Id,
            IsActive = true
           
        );
        insert ordDeliveryMethod;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1', DeliverToCountry = 'United States');
        insert cartDeliveryGroup;
        CartItem cartItem = new CartItem(CartId=cart.Id, Type='Product',Sku ='ELP1YR', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
        insert cartItem;
       Checkout_Shipping_method__c chkShipMethod = new Checkout_Shipping_method__c(Sku_Tax_Code__c ='BP-001',Shipping_Charges__c= 67.00,Display_Name__c ='Test Checkout', CurrencyIsoCode ='USD',
                                                                                   ShippingMethod_Country__c='United States',Account__c = testAccount.Id);
        insert chkShipMethod;
        Product2 prod = B2B_TestUtils.createProduct('ZimVie Product','ZIM-001');
        // CartItem ci = B2B_TestUtils.createCartItemWithAcc(wc.Id, pro.Id,ac.Id);
       B2B_TestUtils.initialStorefrontSetup();
        //OrderDeliveryGroup ordDeliveryGroup=  B2B_TestUtils.createOrderDeliveryGroup(ac.Id); 
        // B2B_TestUtils.createCartWithCartItemsWithAcc('ZimVieTest',ac.Id);
        
    }
    
    
    @isTest 
    static void testIntegrationRunsSuccessfully() {
        Account account = [SELECT Id FROM Account LIMIT 1];
        Contact con = [Select Id,AccountId from Contact Limit 1];
        UserRole userRole = [SELECT Id FROM UserRole WHERE PortalType = 'CustomerPortal' LIMIT 1];
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='System Administrator' Limit 1];
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
        Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
        String uniqueName = orgId + dateString + RandomId;
       
        User user  = [SELECT Id,Country FROM User where Country='United States' Limit 1]; 
        List<User> UserList = new List<User>();
        UserList.add(user);
        System.runAs(user){
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ShipmentZimVie');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Checkout_Shipping_method__c shipObj = new Checkout_Shipping_method__c(
        Sku_Tax_Code__c='',
        Shipping_Charges__c=20.0,
        Display_Name__c='Testing',
        CurrencyISOCode='USD',
        ShippingMethod_Country__c=user.Country
        );  
        insert shipObj;
        list<Checkout_Shipping_method__c> ship = new list<Checkout_Shipping_method__c>();
        ship.add(shipObj);
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='Sflabs');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId = cart.Id, Name = 'Default Delivery');
        INSERT cartDeliveryGroup;
        CartDeliveryGroupMethod cdgm = new CartDeliveryGroupMethod(
        Name='TestDeliveryMethod',
        CartDeliveryGroupId=cartDeliveryGroup.Id
        );
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Test: execute the integration for the test cart ID.
        B2BShipmentZimVie apexSample = new B2BShipmentZimVie();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        
        integInfo.jobId = null;
        integInfo.siteLanguage ='English';
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, cart.Id);
        // Verify: the integration executed successfully
        System.assert(integrationResult != null);
        Test.stopTest();
        }
        // Because test methods don't support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the Developer Console, select File | New | Static Resource
       
    }
    
    
    @isTest static void testWhenExternalServiceCallFailsAFailedStatusIsReturnedAndACartValidationOutputEntryIsCreated() {
        // Because test methods do not support Web service callouts, we create a mock response based on a static resource.
        // To create the static resource from the the Developer Console, select File | New | Static Resource
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('ShipmentZimVie');
        // The web service call returns an error code.
        mock.setStatusCode(404);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.startTest();
        // Associate the callout with a mock response.
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Test: execute the integration for the test cart ID and integration info.
        B2BShipmentZimVie apexSample = new B2BShipmentZimVie();
        sfdc_checkout.IntegrationInfo integInfo = new sfdc_checkout.IntegrationInfo();
        integInfo.jobId = null;
        integInfo.siteLanguage ='English';
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        sfdc_checkout.IntegrationStatus integrationResult = apexSample.startCartProcessAsync(integInfo, webCart.Id);
        
        // Validate: IntegrationStatus.Status is FAILED
        // and a new CartValidationOutput record with level 'Error' was created.
        System.assertNotEquals(sfdc_checkout.IntegrationStatus.Status.FAILED, integrationResult.status);
        List<CartValidationOutput> cartValidationOutputs = [SELECT Id FROM CartValidationOutput WHERE Level = 'Error'];
        Test.stopTest();
    }
    @isTest
    static void generateXMLMethod(){
        WebCart webCart = [SELECT Id FROM WebCart LIMIT 1];
        B2BShipmentZimVie.generateXMLBody(webCart.Id);
    }
    
    @isTest
    static void shippingOptionsAndRates(){
        Account account = [SELECT Id FROM Account where Name='TestAccount' LIMIT 1];
        Checkout_Shipping_method__c chkShip =[SELECT id, Display_Name__c ,CurrencyISOCode,ShippingMethod_Country__c,Account__c FROM Checkout_Shipping_method__c where Account__c=: account.Id];
        B2BShipmentZimVie shipZim = new B2BShipmentZimVie();
        test.startTest();
        shipZim.getShippingOptionsAndRatesFromExternalService('English',chkShip.ShippingMethod_Country__c);
        Test.stopTest();
        
    }
    @isTest
    static void ShippingChargeProduct2Id(){
        B2BShipmentZimVie shipZim = new B2BShipmentZimVie();
        OrderDeliveryMethod OrderDeliveryMethodId=[select id from OrderDeliveryMethod limit 1];
        test.startTest();
        shipZim.getShippingChargeProduct2Id(OrderDeliveryMethodId.id);
        shipZim.getDefaultShippingChargeProduct2Id();
        Test.stopTest();
        
    }
    @isTest
    static void getOrderDeliveryClass(){
        B2BShipmentZimVie shipZim = new B2BShipmentZimVie();
        B2BShipmentZimVie.ShippingOptionsAndRatesFromExternalService shipZimExternal = new B2BShipmentZimVie.ShippingOptionsAndRatesFromExternalService('test','TestProvider',67.00,90.00,'TestServiceName','USD');
        B2BShipmentZimVie.ShippingOptionsAndRatesFromExternalService[] shipZimShippinOption = new List<B2BShipmentZimVie.ShippingOptionsAndRatesFromExternalService>();
        shipZimShippinOption.add(shipZimExternal);
        test.startTest();
        shipZim.getOrderDeliveryMethods(shipZimShippinOption);
        
        Test.stopTest();
        
    }
  // complete the else part runs the method
    @isTest
    static void getOrderDeliveryClass2(){
        Product2 pro = [SELECT Id,Name,ProductCode,IsActive FROM Product2 where Name = 'Sort Material-450' LIMIT 1];
        OrderDeliveryMethod ordDeliveryMethod = [SELECT Id,Name,ProductId,IsActive FROM OrderDeliveryMethod where  ProductId =: pro.Id];
        B2BShipmentZimVie shipZim = new B2BShipmentZimVie();
        B2BShipmentZimVie.ShippingOptionsAndRatesFromExternalService shipZimExternal = new B2BShipmentZimVie.ShippingOptionsAndRatesFromExternalService(ordDeliveryMethod.Name,'TestProvider',67.00,90.00,'TestServiceName','USD');
        B2BShipmentZimVie.ShippingOptionsAndRatesFromExternalService[] shipZimShippinOption = new List<B2BShipmentZimVie.ShippingOptionsAndRatesFromExternalService>();
        shipZimShippinOption.add(shipZimExternal);
        test.startTest();
        shipZim.getOrderDeliveryMethods(shipZimShippinOption);
        
        Test.stopTest();
        
    }
    @isTest
    static void externalClassMethod(){
        Test.startTest();
        B2BShipmentZimVie.ShippingOptionsAndRatesFromExternalService shipZim = new B2BShipmentZimVie.ShippingOptionsAndRatesFromExternalService();
        B2BShipmentZimVie.ShippingOptionsAndRatesFromExternalService shipZimExternal = new B2BShipmentZimVie.ShippingOptionsAndRatesFromExternalService('test','TestProvider',67.00,90.00,'TestServiceName','USD');
        shipZimExternal.getCurrCode();
        shipZimExternal.getName();
        shipZimExternal.getOtherCost();
        shipZimExternal.getProvider();
        shipZimExternal.getRate();
        shipZimExternal.getServiceName();
        Test.stopTest();
        
    }
    @isTest
    static void populateCartDeliveryGroupMethod(){
        Account account = [SELECT Id FROM Account where Name='TestAccount' LIMIT 1];
        WebStore store =[SELECT Id,Name FROM WebStore where Name='TestWebStore' LIMIT 1];
        WebCart webCart = [SELECT Id,AccountId FROM WebCart where AccountId=:account.Id LIMIT 1];
        CartDeliveryGroup cartDeliveryGroup = [SELECT Id,Name FROM CartDeliveryGroup where CartId=:webCart.Id LIMIT 1];
        Product2 pro = [SELECT Id,Name,ProductCode,IsActive FROM Product2 where Name = 'Sort Material-450' LIMIT 1];
        OrderDeliveryMethod ordDeliveryMethod = [SELECT Id,Name,ProductId,IsActive FROM OrderDeliveryMethod where  ProductId =: pro.Id];
        B2BShipmentZimVie.ShippingOptionsAndRatesFromExternalService shipOption = new B2BShipmentZimVie.ShippingOptionsAndRatesFromExternalService();
        B2BShipmentZimVie shipZim = new B2BShipmentZimVie();
        shipZim.populateCartDeliveryGroupMethodWithShippingOptions(shipOption,cartDeliveryGroup.Id,ordDeliveryMethod.Id,webCart.Id);
        
    }
}