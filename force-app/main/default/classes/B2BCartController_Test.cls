@isTest
private class B2BCartController_Test {
    @isTest
    static void testGetCpnFromCart() {
        // Create test data
        
        Test.startTest();
        Map<String, Object> params = new Map<String, Object>();
        params.put('key', 'value'); // Set your test parameters
        Map<String, Object> result = B2BCartController.getCpnFromCart(params);
        Map<String, Object> result1 = B2BCartController.getCpnFromCart(null);
        Test.stopTest();
        
        // Add assertions to verify the expected behavior
        System.assertEquals(true, result.containsKey(B2BConstants.IS_SUCCESS), 'IS_SUCCESS key should be present');        // Add more assertions as needed
    }
    
    @isTest
    static void testGetEnrollStatus() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id,Type__c='RMA-ExchangeCart');
        insert cart;
        Test.startTest();
        Map<String, Object> params = new Map<String, Object>();
        params.put('effectiveAccountId', testAccount.Id);
        params.put('cartId',cart.Id);
        Boolean result = B2BCartController.getEnrollStatus(params);
        B2BCartController.getRMACartDetail(params);
        Test.stopTest();
        // Add assertions to verify the expected behavior
        System.assertEquals(false, result, 'Enroll status should be false');
        // Add more assertions as needed
    }
    
    @isTest
    static void testCalculateDiscountOnItem() {
        // Create test data
        
        Test.startTest();
        Map<String, Object> params = new Map<String, Object>();
        params.put('key', 'value'); // Set your test parameters
        Map<String, Object> result = B2BCartController.calculateDiscountOnItem(params);
        Test.stopTest();
        
        // Add assertions to verify the expected behavior
        System.assertEquals(true, result.containsKey(B2BConstants.IS_SUCCESS), 'IS_SUCCESS key should be present');
        // Add more assertions as needed
    }
     @isTest
    static void testCalculateDiscountOnCart() {
        // Create test data
        
        Test.startTest();
        Map<String, Object> params = new Map<String, Object>();
        params.put('key', 'value'); // Set your test parameters
        Map<String, Object> result = B2BCartController.calculateDiscountOnCart(params);
        Test.stopTest();
        
        // Add assertions to verify the expected behavior
        System.assertEquals(true, result.containsKey(B2BConstants.IS_SUCCESS), 'IS_SUCCESS key should be present');
        // Add more assertions as needed
    }
      @isTest
    static void deleteCartShippingAndTaxTest() {
        // Create test data
        
        Test.startTest();
        Map<String, Object> params = new Map<String, Object>();
        params.put('key', 'value'); // Set your test parameters
        Map<String, Object> result = B2BCartController.deleteCartShippingAndTax(params);
        Test.stopTest();
        
        // Add assertions to verify the expected behavior
        System.assertEquals(true, result.containsKey(B2BConstants.IS_SUCCESS), 'IS_SUCCESS key should be present');
        // Add more assertions as needed
    }
}