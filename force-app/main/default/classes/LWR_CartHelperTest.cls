@isTest
public class LWR_CartHelperTest {
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
   static void getCartItemsFieldsLWRTest(){
         WebCart cart =[Select id,Name from WebCart where Name='Cart'];
         CartDeliveryGroup cdg =[Select id,Name from CartDeliveryGroup where Name='Default Delivery 1'];
         Product2 prd =[Select id,Name from Product2 where Name='Parent Certification'];
         CartItem cartItem = new CartItem
            (CartId=cart.Id, 
             Type='Product', 
             Name='TestProduct',
             CartDeliveryGroupId=cdg.Id,
             Product2Id=prd.Id,
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
        List<Object> originalCartItems = new List<Object>{
        new Map<Object, Object>{'id' => '1'},
        new Map<Object, Object>{'id' => '2'}
        };
        Map<String, Object> inputData = new Map<String, Object>{ B2BConstants.ORIGINAL_CART_ITEMS => originalCartItems};
        List<String> cartId = new List<String>();
        cartId.add(cartItem.Id); 
        Test.startTest();
        LWR_CartHelper.getCartItemsFieldsLWR(cartId);
        Test.stopTest();       
    }
    @isTest
    static void testGetCartItemWithPricingDetailsApex() {
        List<Object> originalCartItems = new List<Object>{
        new Map<Object, Object>{'id' => '1'},
        new Map<Object, Object>{'id' => '2'}
        };
        Map<String, Object> inputData = new Map<String, Object>{ B2BConstants.ORIGINAL_CART_ITEMS => originalCartItems};
        Test.startTest();
        Map<String, Object> result = LWR_CartHelper.getCartItemWithPricingDetailsApex(inputData);
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
        Map<String, Object> result = LWR_CartHelper.getCartItemWithPricingDetailsForCheckout(inputData);
        System.assertEquals(null, result.get('isSuccess'));
        System.assertEquals(null, result.get('errorMsg'));
    Test.stopTest();
    
    }
  /*  
   @isTest
    static void testGetCartItemWithPricingDetailsForCheckout() {
        // Create test data
        List<Object> originalCartItems = new List<Object>{
            new Map<Object, Object>{
                'cartItem' => new Map<Object, Object>{
                    'cartItemId' => '1'
                        }
            },
                new Map<Object, Object>{
                    'cartItem' => new Map<Object, Object>{
                        'cartItemId' => '2'
                            }
                }
            // Add more test data as needed
        };
            
            Map<String, Object> inputData = new Map<String, Object>{
                B2BConstants.ORIGINAL_CART_ITEMS => originalCartItems
                    };
                        
                        // Call the method to be tested
                        Map<String, Object> result = LWR_CartHelper.getCartItemWithPricingDetailsForCheckout(inputData);
        
        // Verify the results
        System.assertEquals(true, result.get('isSuccess'));
        System.assertEquals(null, result.get('errorMsg'));
        Map<String, Object> cartItemData = (Map<String, Object>)result.get('cartItemData');
        List<Map<Object, Object>> cartItems = (List<Map<Object, Object>>)cartItemData.get(B2BConstants.ORIGINAL_CART_ITEMS);
        System.assertEquals(originalCartItems.size(), cartItems.size());
        // Add more assertions as needed
    }
    
    @isTest
    static void testGetCartItemsFieldsLWR() {
        // Create test data
        List<String> cartItemIds = new List<String>{
            '1', '2' // Add more test data as needed
                };
                    
                    // Call the method to be tested
                    List<LWR_CartHelper.CartItemWrapper> result = LWR_CartHelper.getCartItemsFieldsLWR(cartItemIds);
        
        // Verify the results
        System.assertEquals(cartItemIds.size(), result.size());
        // Add more assertions as needed
    }*/
}