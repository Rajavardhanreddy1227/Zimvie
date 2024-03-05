@isTest
public class B2BCartHelper_Test {
 @isTest
    static void testGetCpnFromCart() {
        // Create test data
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart testCart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert testCart;

        Product2 testProduct = new Product2(Name = 'Test Product');
        insert testProduct;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=testCart.Id, Name='Default Delivery');
        insert cartDeliveryGroup;

        CartItem testCartItem = new CartItem(
            Product2Id = testProduct.Id,
            Quantity = 2,
            Name='TestProduct',
            ListPrice = 100,
            TotalPrice = 200,
            CartId = testCart.Id,
            CartDeliveryGroupId=cartDeliveryGroup.Id
        );
        insert testCartItem;
        Map<String, Object> testParams = new Map<String, Object>{
            B2BConstants.CART_ID => testCart.Id
        };

        Test.startTest();

        // Call the method under test
        Map<String, Object> result = B2BCartHelper.getCpnFromCart(testParams);

        Test.stopTest();
         System.assert(result != null);
      }
}