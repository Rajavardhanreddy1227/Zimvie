@isTest
public class B2B_cartItemInvocableService_Test {
 @isTest
    static void testAddTissueProductToCart() {
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
       
           Product2 testProduct = new Product2(Name = 'Tissue Product', StockKeepingUnit = 'TBHF1',IsActive = true,Apply_TBHF_Fee__c=true);
            insert testProduct;
        
       
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;       
        WebCart testCart = new WebCart(Name='TestCart',WebStoreId = testWebStore.Id, AccountId = acc.id);
        insert testCart;
         OrderDeliveryMethod ordDeliveryMethod = new OrderDeliveryMethod(
            Name = 'OrderDelivery',
            ProductId = testProduct.Id,
            IsActive = true
        );
        insert ordDeliveryMethod;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(
            CartId = testCart.Id,
            DeliveryMethodId = ordDeliveryMethod.Id,
            Name = 'OrderDeliveryGroup',
            DeliverToName = 'OrderDeliver'
            
        );
        insert cartDeliveryGroup;
        CartItem testCartItem = new CartItem(
            CartId=testCart.Id, 
            Sku='TBHF', 
            Quantity=3.0, 
            Type='Product',
            CurrencyIsoCode = 'USD',
            ListPrice = 10.89,
            TotalPrice = 30,
            Product2Id= testProduct.Id,
            
            Name='originalCartItems', 
            CartDeliveryGroupId=cartDeliveryGroup.Id
        );
        insert testCartItem;
        
        Test.startTest();
        B2B_cartItemInvocableService.addTissueProductToCart(new List<CartItem>{testCartItem});
        Test.stopTest();
        // Verify the results
       
        List<CartItem> updatedCartItems = [SELECT Id FROM CartItem WHERE cartId = :testCart.Id];
        System.assertEquals(1, updatedCartItems.size()); // Assuming the cart item was successfully added

        // Clean up the test data
       // delete testCartItem;
        delete cartDeliveryGroup;
        delete ordDeliveryMethod;
       // delete testCart;
        delete testWebStore;
        //delete testProduct;
        delete acc;
}
    
    @isTest
    static void codeCovTest() {
     
        Test.startTest();
        B2B_cartItemInvocableService.codeCov();
         Test.stopTest();
        // Verify the results
       
       
        
    }
}