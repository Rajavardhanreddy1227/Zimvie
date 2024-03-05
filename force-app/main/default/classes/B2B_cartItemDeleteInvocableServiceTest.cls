@isTest
public class B2B_cartItemDeleteInvocableServiceTest {
    
    
     @isTest
    static void deleteTissueProductToCartTest() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id,Type__c='RMA-ExchangeCart');
        insert cart;
        
        Product2 pro = new Product2(
            Name = 'Sort Material-450',
            IsActive = true,
            StockKeepingUnit = 'Sort',
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
        B2B_cartItemDeleteInvocableService.deleteTissueProductToCart(new List<CartItem>{cartItem});
        Test.stopTest();
    }
    
    @isTest
     static void deleteFutureTestException() {
        Test.startTest();
        B2B_cartItemDeleteInvocableService.deleteTissueProductToCart(null);
        Test.stopTest();
     }
    @isTest
     static void deleteFutureTest() {
         Account testAccount = new Account(Name='TestAccount');
         insert testAccount;
         WebStore testWebStore = new WebStore(Name='TestWebStore');
         insert testWebStore;
         WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id,Type__c='RMA-ExchangeCart');
         insert cart;
         
         Test.startTest();
         B2B_cartItemDeleteInvocableService.deleteFuture(cart.Id);
         Test.stopTest();
         
        // Clean up the test data
        delete testAccount;
        delete testWebStore;
        delete cart;
    }
}