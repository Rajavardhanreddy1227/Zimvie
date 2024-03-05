@isTest
public class b2B_checkoutAddressController_Test {
    @testSetup 
    static void makeData(){
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
    @isTest
    public static void testUpdateAddressOnCDG() { 
        // Create test data
        
        Account acc = new Account();
        acc.Name = 'Test Name';
        acc.Type = 'Customer';
        acc.Customer_Type__c = 'Pharmacy';
        acc.Account_eMail__c = 'lauren119@yopmail.com';
        acc.Email__c = 'neeta.galande@rafter.one';
        acc.ShippingCountry = 'United States';
        acc.ShippingState = 'Alabama';
        acc.ShippingPostalCode = '12345';
        insert acc;
        
        WebStore store = new WebStore (Name = 'test');
        insert store;
        
        WebCart testCart = new WebCart(WebStoreId = store.Id, AccountId = acc.id, Name = 'TestCart');
        insert testCart;
         
        CartDeliveryGroup deliverGroup = new CartDeliveryGroup();
        deliverGroup.DeliverToCity = 'Test City';
        deliverGroup.DeliverToCountryCode = 'US';
       
        deliverGroup.DeliverToPostalCode = '12345';
        deliverGroup.DeliverToStateCode = 'CA';
        deliverGroup.DeliverToStreet = 'Test Street';
        deliverGroup.DeliverToName = 'Test Name';
		deliverGroup.Name = 'test';
        deliverGroup.CartId = testCart.Id;
        
        insert deliverGroup;
        
        ContactPointAddress cpa = new ContactPointAddress();
        cpa.Name = 'Test CPA';
		cpa.ORAAddressId__c = 1234567890; 
        cpa.City = 'Baltimore';
        cpa.CountryCode = 'US';
        cpa.StateCode ='MD';
        cpa.PostalCode ='21201';
        cpa.Street ='23 street 56 in baltimore';
        cpa.ParentId =acc.id;
        insert cpa;

        //Call the method to be tested
       b2B_checkoutAddressController.updateAddressOnCDG(
            deliverGroup.Id,
            'New City',
            'US',
            '54321',
            'NY',
            'New Street',
            'New Name',
            cpa.Id,
            [SELECT Id FROM WebStore LIMIT 1]?.Id
        );
        
        b2B_checkoutAddressController.callShippingIntegration(deliverGroup.Id);
        b2B_checkoutAddressController.callTaxIntegrationCustom(testCart.Id);
        b2B_checkoutAddressController.getCDGID(testCart.Id);
        b2B_checkoutAddressController.callShippingIntegration(null);
        b2B_checkoutAddressController.callTaxIntegrationCustom(null);

        // Retrieve the updated record
        CartDeliveryGroup updatedDeliverGroup = [
            SELECT DeliverToCity, DeliverToCountryCode, DeliverToPostalCode,
                   DeliverToStateCode, DeliverToStreet, DeliverToName
            FROM CartDeliveryGroup
            WHERE Id = :deliverGroup.Id
        ];

        // Verify the updated values
        System.assertEquals('New City', updatedDeliverGroup.DeliverToCity);
    }
    @isTest
     static void fetchOrderDeliveryMethodsTest() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id,Type__c='RMA-ExchangeCart');
        insert cart;
        
        Product2 pro = new Product2(
            Name = 'Sort Material-450',
            IsActive = true,
            StockKeepingUnit = 'Sort-78',
            ProductCode ='PC-110'
        );
        insert pro;
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
            
            Name='originalCartItems', 
            CartDeliveryGroupId=cartDeliveryGroup.Id
        );
        Insert cartItem;
       
        Test.startTest();
        b2B_checkoutAddressController.fetchOrderDeliveryMethods(new List<String>{ordDeliveryMethod.id},cartDeliveryGroup.Id);
        b2B_checkoutAddressController.updateShippingCartItem(cart.id,10.0);
          b2B_checkoutAddressController.makeApiCallout(cart.id);
        Test.stopTest();
    }
   
    @isTest
    static void getShippingDiscountTest() {
       // Object Obj= new Object();
        Test.startTest();
        b2B_checkoutAddressController.getShippingDiscount(new Map<String,Object>{'commId'=>null});
        
        Test.stopTest();  
        
    }
   
    @isTest
    static void ifOrcaleAddIdTest() {
         Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        ContactPointAddress cpa = new ContactPointAddress();
        cpa.Name = 'Test CPA';
        cpa.City = 'Baltimore';
        cpa.CountryCode = 'US';
        cpa.StateCode ='MD';
        cpa.PostalCode ='21201';
        cpa.Street ='23 street 56 in baltimore';
        cpa.ParentId =testAccount.id;
        insert cpa;

       Map<String,Object> inputMap = new Map<String,Object>();
       
         inputMap.put('cpaId',cpa.id);
          inputMap.put('commId',cpa.id);
        Test.startTest();
        try{
        b2B_checkoutAddressController.ifOrcaleAddId(inputMap);
        }catch(Exception e){
            
        }
        Test.stopTest();  
        
    } 
    
    @isTest
    static void checkoutOrderSummaryDataTest() {
       // Object Obj= new Object();
        Test.startTest();
        b2B_checkoutAddressController.checkoutOrderSummaryData(new Map<String,Object>{'commId'=>null});
        
        Test.stopTest();  
        
    } 
    @isTest
    static void generateXML(){
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        CartItem cartItemId = [SELECT Id FROM CartItem WHERE CartId = :webCart.Id LIMIT 1];
        Test.startTest();
        b2B_checkoutAddressController.generateXMLBody(webCart.Id);
        Test.stopTest();
    }
}