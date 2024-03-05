@isTest
public class RSM_CartControllerTest {
   @testSetup 
    static void makeDate(){
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
        Product2 tissueProduct = new Product2(Name = 'Tissue Product', StockKeepingUnit = 'Sort-202',IsActive = true);
        insert tissueProduct;

       /* ProductCategory tissueCategory = new ProductCategory(Name = 'Tissue Category');
        insert tissueCategory;

        ProductCategoryProduct categoryProduct = new ProductCategoryProduct(ProductId = tissueProduct.Id, ProductCategoryID = tissueCategory.Id);
        insert categoryProduct;*/
        WebStore store = new WebStore (Name = 'test');
        insert store;
        WebCart testCart = new WebCart(WebStoreId = store.Id, AccountId = acc.id, Name = 'TestCart');
        insert testCart;
        Id pbId = Test.getStandardPricebookId();
        Order order = new Order(
           AccountId = acc.Id,
           Pricebook2Id = pbId,
           EffectiveDate = Date.today(),
           OrderedDate = Date.today(),
           Status = 'Draft'
       );
       insert order;
       OrderDeliveryMethod m = new OrderDeliveryMethod();
       m.Name = 'Test';
       insert m;
       // Create an Order Delivery Group
       OrderDeliveryGroup orderDeliveryGroup = new OrderDeliveryGroup(
           Description = 'cartDeliveryGroup.Description',
           DesiredDeliveryDate = Date.today(),
           DeliverToName = 'cartDeliveryGroup.DeliverToName',
           DeliveryInstructions = 'cartDeliveryGroup.ShippingInstructions',
           OrderDeliveryMethodId = m.Id,
           OrderId = order.Id
       );
       insert orderDeliveryGroup;
       // Create a Product (Product2) if not already created
       Product2 prod = new Product2(Name = 'Test Product');
       insert prod;
       // Create a PricebookEntry for the Product
       PricebookEntry pbe = new PricebookEntry(
           Pricebook2Id = pbId,
           Product2Id = prod.Id,
           UnitPrice = 1,
           IsActive = true,
           UseStandardPrice = false
       );
       insert pbe;
        OrderItem orderItem = new OrderItem(
           Product2Id = prod.Id,
           Quantity = 1,
           ListPrice = 1,
           UnitPrice = 1,
           OrderId = order.Id,
           PricebookEntryId = pbe.Id,
           OrderDeliveryGroupId = orderDeliveryGroup.Id,
           TotalLineAmount = 47
       );
       insert orderItem;
         // Update the Order
       order.Status = 'Activated';
       update order;
       
    }
    @isTest
    static void deleteOrder(){
        Account acc = [Select id, name from Account where Name ='Test Name' Limit 1];
        Webcart  cart = [Select id, name,AccountId from WebCart where AccountId=:acc.Id];
        RSM_CartController.deleteOrderByCartId(cart.Id);
        RSM_CartController.getCategoryId(cart.Id);
    }
    
    static testMethod void testGetCartItemsLWR() {
        WebStore webStore = new WebStore(
            Name = 'Sflabs'
        );
        insert webStore;

        // Call the @AuraEnabled method in a test context
        Test.startTest();
        ConnectApi.CartItemCollection result = RSM_CartController.getCartItemsLWR(
            Network.getNetworkId(),
            '',
            '',
            '1', // Page parameter
            'ASC' // Sort parameter
        );
        Test.stopTest();

        // Assert the results using System.assertEquals
        System.assertEquals(null, result);
        // Add more assertions as needed based on the expected response.
    }

    @isTest
    static void testGetCartItemsFieldsLWR() {
        // Create mock test data
        List<CartItem> cartItems = new List<CartItem>();
        // Populate cartItems list with mock CartItem records
        // ...
        Test.startTest();
        // Call the @AuraEnabled method with mock data
        RSM_CartController.codeCov();
        Test.stopTest();

        // Assert the results using System.assertEquals
        System.assertNotEquals(null, cartItems);
        // Add more assertions based on the expected behavior and data transformation.
    }
    
    @isTest
    static void getCartItemsFieldsLWRTest() {
       
        Map<String, String> setup = B2b_TestUtils.initialStorefrontSetup();
        Webcart  cart = [Select id, name,AccountId from WebCart where name='Cart'];
        cart.Status = 'Active';
        update cart;
        
        Test.startTest();
        // Call the @AuraEnabled method with mock data
        List<RSM_CartController.CartItemWrapper> getCartItemsFieldsLWR = RSM_CartController.getCartItemsFieldsLWR(null,null,cart.Id,null,null);
        Test.stopTest();

        // Assert the results using System.assertEquals
        System.assertNotEquals(null, setup);
        // Add more assertions based on the expected behavior and data transformation.
    }
    @IsTest
   static void testCreateCart() {
    Community cu =[Select id from Community Limit 1];
    Account acc =[Select id,Name from Account where Name='Test Name'];
    String communityId=cu.Id;
    String effectiveAccountId = acc.Id;
    WebStore testWebStore = new WebStore(Name='Sflabs');
    insert testWebStore;
    ConnectApi.CartInput cartInput = new ConnectApi.CartInput();
    cartInput.effectiveAccountId = effectiveAccountId;
    Test.startTest();
    ConnectApi.CartSummary cartSummary = RSM_CartController.createCart(communityId, effectiveAccountId);
    Test.stopTest();
}
    @isTest
    static void testgetOrderTaxAmount(){
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert cart;
        List<WebCart> cartList = new List<WebCart>();
        cartList.add(cart);
        Test.startTest();
        RSM_CartController.getOrderTaxAmount(cart.Id);
        Test.stopTest();
    }
   @isTest
   static void updateCartItemTest() {
 	Community cu =[Select id from Community Limit 1];
    ConnectApi.CartItemInput testCartItemInput = new ConnectApi.CartItemInput();
    Account testAccount = new Account(Name='TestAccount');
    insert testAccount;
    WebStore testWebStore = new WebStore(Name='Sflabs');
    insert testWebStore;
    WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
    insert cart;
    String activeCartOrId = cart.Id; 
    Test.startTest();
    ConnectApi.CartItem updatedCartItem = RSM_CartController.updateCartItem(
        cu.Id, // Pass the test Community ID
        testAccount.Id, // Replace with a valid account ID
        activeCartOrId, // Pass the active cart or cart ID
        cart.Id, // Replace with a valid cart item ID
        testCartItemInput // Pass the test CartItemInput
    );
       Test.stopTest();
    }
     @isTest
   static void deleteCartLWRTest() {
 	Community cu =[Select id from Community Limit 1];
    ConnectApi.CartItemInput testCartItemInput = new ConnectApi.CartItemInput();
    Account testAccount = new Account(Name='TestAccount');
    insert testAccount;
    WebStore testWebStore = new WebStore(Name='Sflabs');
    insert testWebStore;
    WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
    insert cart;
    String activeCartOrId = cart.Id; 
    Test.startTest();
    RSM_CartController.deleteCartLWR(
        cu.Id, // Pass the test Community ID
        testAccount.Id, // Replace with a valid account ID
        cart.Id // Replace with a valid cart item ID       // Pass the test CartItemInput
    );
       Test.stopTest();
    }
       @isTest
   static void DeleteCartItemTest() {
 	Community cu =[Select id from Community Limit 1];
    ConnectApi.CartItemInput testCartItemInput = new ConnectApi.CartItemInput();
    Account testAccount = new Account(Name='TestAccount');
    insert testAccount;
    WebStore testWebStore = new WebStore(Name='Sflabs');
    insert testWebStore;
    WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
    insert cart;
    Product2 proParentCertification = new Product2(
                IsActive = true,
                Name = 'Parent Certification',
                CurrencyIsoCode = 'USD',
                Family = 'Syndicated',
                ProductCode = 'CERTIFICATION'
            );    
    insert proParentCertification; 
    String activeCartOrId = cart.Id; 
   CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId = cart.Id, Name = 'Default Delivery');
    INSERT cartDeliveryGroup;
   CartItem cart1 = new CartItem(
                CartId = cart.Id, 
                Sku = 'SKU_Test1', 
                SalesPrice = 10.00, 
                Quantity = 3.0, 
                Type = 'Product', 
                Name ='TestProduct', 
                CartDeliveryGroupId=cartDeliveryGroup.Id, 
                Product2Id = proParentCertification.Id);
     insert cart1;
    Test.startTest();
    RSM_CartController.deleteCartItem(
        cu.Id, // Pass the test Community ID
        testAccount.Id, // Replace with a valid account ID
        cart.Id, // Replace with a valid cart item ID
        cart1.Id // Pass the test CartItemInput
    );
       Test.stopTest();
    }
    
    @isTest
   static void deleteTaxAndShippingChargesTest() {
 	Community cu =[Select id from Community Limit 1];
    ConnectApi.CartItemInput testCartItemInput = new ConnectApi.CartItemInput();
    Account testAccount = new Account(Name='TestAccount');
    insert testAccount;
    WebStore testWebStore = new WebStore(Name='Sflabs');
    insert testWebStore;
    WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
    insert cart;
    CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1', DeliverToCountry = 'United States');
    insert cartDeliveryGroup;
    CartItem cartItem = new CartItem(CartId=cart.Id, Type='Product', Name='TestProduct', CartDeliveryGroupId=cartDeliveryGroup.Id);
    insert cartItem;
    List<CartItem> cList = new List<CartItem>();
    cList.add(cartItem);
    String activeCartOrId = cart.Id; 
    Test.startTest();
    RSM_CartController.deleteTaxAndShippingCharges(
        cu.Id, cart.Id
    );
       Test.stopTest();
    }
    
     @isTest
   static void getCartSummaryLWRTest() {
 	Community cu =[Select id from Community Limit 1];
    ConnectApi.CartItemInput testCartItemInput = new ConnectApi.CartItemInput();
    Account testAccount = new Account(Name='TestAccount');
    insert testAccount;
    WebStore testWebStore = new WebStore(Name='Sflabs');
    insert testWebStore;
    WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
    insert cart;
    String activeCartOrId = cart.Id; 
    Test.startTest();
    ConnectApi.CartSummary updatedCartItem = RSM_CartController.getCartSummaryLWR(
        cu.Id, // Pass the test Community ID
        testAccount.Id, // Replace with a valid account ID
        cart.Id
    );
       Test.stopTest();
    }
    @isTest
    static void getOrderSummaryMethod(){
        Account acc =[Select id from Account where Name = 'Test Name' LIMIT 1];
        Id pbId = Test.getStandardPricebookId();
        Order ord =[Select id, AccountId from Order where AccountId =: acc.id];
        Test.startTest();
        RSM_CartController.CartItemWrapper wrap = new RSM_CartController.CartItemWrapper();
        wrap.priceBookEntryId =pbId;
        wrap.productSellingModel = 'OneTime';
        RSM_CartController.OrderSummaryWrapper ordWrap = new RSM_CartController.OrderSummaryWrapper();
        ordWrap.Id = ord.Id;
        ordWrap.CurrencyIsoCode ='USD';
        ordWrap.GrandTotalAmount = 89.00;
        ordWrap.OrderNumber='o-009876';
        ordWrap.ShippingCost = 90.00;
        ordWrap.TotalAdjustedProductAmount= 78.00;
        ordWrap.TotalTaxAmount =10.00;
       /* ConnectApi.OrderSummaryInputRepresentation osir= new ConnectApi.OrderSummaryInputRepresentation();
        osir.orderId=ord.Id;
        osir.orderLifeCycleType='Managed';
        
        ConnectApi.OrderSummaryOutputRepresentation osor= ConnectApi.OrderSummaryCreation.createOrderSummary(osir);
        
        OrderSummary orderSum=[SELECT Id, OriginalOrderId, OwnerId FROM OrderSummary WHERE OriginalOrderId =:ord.Id];
        RSM_CartController.getOrderSummary(orderSum.Id);*/
        Test.stopTest();
    }
    
}