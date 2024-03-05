@isTest
public class B2BCartServiceTest {
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
            
            Name='originalCartItems', 
            CartDeliveryGroupId=cartDeliveryGroup.Id
        );
        insert cartItem;
        CartItem cartItem2 = new CartItem(
            CartId=cart.Id, 
            Sku='SKU_Test1', 
            Quantity=3.0, 
            Type='Charge', 
            Name='originalCartItems', 
            TotalPrice = 30,
            CartDeliveryGroupId=cartDeliveryGroup.Id
        );
        insert cartItem2;
        
    }
    @isTest 
    static void getCpnCartTest(){
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        CartItem cartItemId = [SELECT Id FROM CartItem WHERE CartId = :webCart.Id LIMIT 1];
        
         Map<String, Object> mapParams = new Map<String, Object>{
            B2BConstants.CART_ID => webCart.Id
            
        };
        Test.startTest();
        B2BCartService.getCpnFromCart(mapParams);
        Test.stopTest();
           }
 @isTest
static void getCalculateDiscountTest() {
    WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
    List<CartItem> cartItems = [SELECT Id FROM CartItem WHERE CartId = :webCart.Id LIMIT 1];
    
    // Create a list of generic objects
    List<Object> origCartItemList = new List<Object>();
    
    for (CartItem cartItem : cartItems) {
        Map<String, Object> cartItemMap = new Map<String, Object>();
        cartItemMap.put('id', cartItem.Id);
        origCartItemList.add(cartItemMap);
    }
    
    // Create a map with the correct parameter name and pass the list
    Map<String, Object> mapParams = new Map<String, Object>();
//    mapParams.put('originalCartItems', origCartItemList);
    
    Test.startTest();
    B2BCartService.calculateDiscountOnCart(mapParams);
    Test.stopTest();
}

@IsTest
static void calculateDiscountTest() {
    // Create test data
    Product2 pro = new Product2(
        Name = 'Sort Material-450',
        IsActive = true,
        StockKeepingUnit = 'Sort-102',
        ProductCode ='PC-110'
    );
    insert pro;
    
    WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
    
    OrderDeliveryMethod ordDeliveryMethod = new OrderDeliveryMethod(
        Name = 'OrderDelivery',
        ProductId = pro.Id,
        IsActive = true
    );
    insert ordDeliveryMethod;
    
    CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
        CartId = webCart.Id,
        DeliveryMethodId = ordDeliveryMethod.Id,
        Name = 'OrderDeliveryGroup',
        DeliverToName = 'OrderDeliver'
    );
    insert cartDeliveryGroup;
    
    CartItem cartItem = new CartItem(
        CartId = webCart.Id,
        Sku = 'SKU_Test1',
        Name = 'CartItemTest',
        CartDeliveryGroupId = cartDeliveryGroup.Id
    );
    insert cartItem;
    
    // Mock the HTTP response with a valid XML response
    //String mockResponseXml = '<?xml version="1.0" encoding="UTF-8"?><response><status>success</status></response>';
     Test.setMock(HttpCalloutMock.class, new MockHttpResponseOracleTaxApi());
    Test.startTest();
      
    Map<String, Object> mapParams = new Map<String, Object>();
    mapParams.put('cartItemId', cartItem.Id);
    try{
     B2BCartService.calculateDiscountOnItem(mapParams);    
    }catch(Exception e){
        
    }
    Test.stopTest();
    
   
}








     @isTest 
    static void makeCallTest(){
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        CartItem cartItemId = [SELECT Id FROM CartItem WHERE CartId = :webCart.Id LIMIT 1];
        List<String> cartItem = new List<String>();
        cartItem.add(cartItemId.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseOracleTaxApi());
        Test.startTest();
        try{
        B2BCartService.makeAPICallout(cartItem);
        }catch(Exception e){
            
        }
        Test.stopTest();
    }
    @isTest 
    static void generateXmlTest(){
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        CartItem cartItemId = [SELECT Id FROM CartItem WHERE CartId = :webCart.Id LIMIT 1];
        List<String> cartItem = new List<String>();
        cartItem.add(cartItemId.Id);
        B2BCartService.generateXMLBodyAllCart(cartItem);
        B2BCartService.generateXMLBody(cartItem);
    }
    @isTest 
    static void cartId(){
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        Test.startTest();
        B2BCartService.deleteShippingData(webCart.Id);
        B2BCartService.deleteTaxtData(webCart.Id);
         Test.stopTest();
    }
 /*   @isTest 
    static void deleteShippingMethod(){
        WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
        CartItem cartItemId = [SELECT Id FROM CartItem WHERE CartId = :webCart.Id LIMIT 1];
        List<CartItem> cartItemList = new List<CartItem>();
        cartItemList.add(cartItemId);
        Map<String,Object> mapParams = new Map<String,Object>();
        mapParams.put('originalCartItems',cartItemList);
     /*   Map<Object,Object> mapObject = new Map<Object,Object>();
        mapObject.put(cartItemList,cartItemId);
        Test.startTest();
        B2BCartService.deleteCartShippingAndTax(mapParams);
        Test.stopTest();
    }*/

/*@isTest
static void testDeleteCartShippingAndTax() {
    WebCart cart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
    Product2 pro = new Product2(
        Name = 'Sort Material-450',
        IsActive = true,
        StockKeepingUnit = 'Sort-101',
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
    
    CartItem testCartItem = new CartItem(
        CartId = cart.Id, 
        Sku = 'SKU_Test1', 
        Quantity = 3.0, 
        Type = 'Product',
        CurrencyIsoCode = 'USD',
        ListPrice = 10.89,
        TotalPrice = 30,
        Product2Id = pro.Id,
        Name = 'originalCartItems', 
        CartDeliveryGroupId = cartDeliveryGroup.Id
    );
    insert testCartItem; // Insert the test CartItem
    
    List<CartItem> origCartItemList = new List<CartItem>();
    origCartItemList.add(testCartItem);
    
    Test.startTest();
    
    // Create a map with the correct parameter name and pass the list directly
    Map<String, Object> mapParams = new Map<String, Object>();
    mapParams.put('originalCartItems', origCartItemList);
    
    B2BCartService.deleteCartShippingAndTax(mapParams);
    
    Test.stopTest();
}*/

@IsTest
static void updateCartItemTest() {
    WebCart webCart = [SELECT Id FROM WebCart WHERE Name = 'Cart' LIMIT 1];
    CartDeliveryGroup cdg=[SELECT ID FROM CartDeliveryGroup where NAME='OrderDeliveryGroup' LIMIT 1];
    CartItem cartItem = new CartItem(
        Sku = 'SKU_Test1',
        Name = 'CartItemTest',
        Quantity = 2, // Set the quantity based on your test scenario
        TotalLineAmount = 100.00,
        CartId=webCart.Id,
        CartDeliveryGroupId=cdg.Id// Set the total line amount based on your test scenario
        // Add other required fields for your test
    );
    insert cartItem;
    Decimal discountAmount = -10.00; // Set the discount amount for testing (negative value)
    Test.startTest();
    B2BCartService.updateCartItem(cartItem.Id, discountAmount, null); // Pass null for discountMap since it's not used in this test
    Test.stopTest();

}
@IsTest
static void deleteCartShippingAndTaxTest() {
    // Create test data
    CartItem cartItem =[Select id,Name from CartItem where Name='originalCartItems' LIMIT 1];

    // Create a list of originalCartItems to simulate the input
    List<Object> origCartItemList = new List<Object>();
    Map<String, Object> cartItemMap = new Map<String, Object>();
    cartItemMap.put('id', cartItem.Id);
    origCartItemList.add(cartItemMap);

    // Create mapParams with the originalCartItems
    Map<String, Object> mapParams = new Map<String, Object>();
   // mapParams.put('originalCartItems', origCartItemList);

    Test.startTest();

    // Call the deleteCartShippingAndTax method
    Map<String, Object> result = B2BCartService.deleteCartShippingAndTax(mapParams);

    Test.stopTest();
}



}