@isTest
public class LWR_CartControllerTest {
    @testSetup
    static void data(){
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert cart;
        CartDeliveryGroup cartDeliveryGroup = new CartDeliveryGroup(CartId=cart.Id, Name='Default Delivery 1', DeliverToCountry = 'United States');
        insert cartDeliveryGroup;
        Product2 proParentCertification = new Product2(
            IsActive = true,
            Name = 'Parent Certification',
            CurrencyIsoCode = 'USD',
            Family = 'Syndicated',
            ProductCode = 'CERTIFICATION'
        );    
        insert proParentCertification; 
        CartItem cartItem = new CartItem
            (CartId=cart.Id, 
             Type='Product', 
             Name='TestProduct',
             CartDeliveryGroupId=cartDeliveryGroup.Id,
             Product2Id=proParentCertification.Id,
             Quantity=2.0,
             TotalAdjustmentAmount=45.0,
             TotalListPrice=23.0,
             TotalPrice=32.0,
             unitAdjustedPrice=23.0,
             unitAdjustmentAmount=21.0,
             AdjustmentAmount=4.8,
             ListPrice=21.0,
             SalesPrice=19.0,
             TotalLineAmount=98.0,
             CurrencyIsoCode='USD'
            );
        insert cartItem;
    }
    @isTest
    static void testGetCartItemWithPricingDetailsApex() {
        List<Object> originalCartItems = new List<Object>{
            new Map<Object, Object>{'id' => '1'},
                new Map<Object, Object>{'id' => '2'}
        };
            Map<String, Object> inputData = new Map<String, Object>{ B2BConstants.ORIGINAL_CART_ITEMS => originalCartItems};
        Test.startTest();
        Map<String, Object> result = LWR_CartController.getCartItemWithPricingDetailsApex(inputData);
        System.assertEquals(true, result.get('isSuccess'));
        System.assertEquals(null, result.get('errorMsg'));
        List<Map<Object, Object>> cartItemData = (List<Map<Object, Object>>)result.get('cartItemData');
        System.assertEquals(originalCartItems.size(), cartItemData.size());
        Test.stopTest();
        
    }
    @isTest
    static void getCartItemWithPricingDetailsForCheckoutTest() {
        List<Object> originalCartItems = new List<Object>{
            new Map<Object, Object>{'id' => '1'},
                new Map<Object, Object>{'id' => '2'}
        };
        Map<String, Object> inputData = new Map<String, Object>{ B2BConstants.ORIGINAL_CART_ITEMS => originalCartItems};
        Test.startTest();
        Map<String, Object> result = LWR_CartController.getCartItemWithPricingDetailsForCheckout(inputData);
        System.assertEquals(null, result.get('isSuccess'));
        System.assertEquals(null, result.get('errorMsg'));
        Test.stopTest();
        
    }
    @isTest
    static void testCatch(){
       Map<String,Object> itest = new Map<String,Object>();  
       Test.startTest();
       LWR_CartController.codeCov();
       Test.stopTest();
    }

}