@isTest
public class B2B_PaymentHelper_Test {
    @TestSetup
    public static void testSetupData()
    {
        
        B2B_TestUtils.initialStorefrontSetup();
        Account ac = B2B_TestUtils.createAccount(true);
        B2B_TestUtils.createCartWithCartItemsWithAcc('ZimVieTest',ac.Id);

    }
    @isTest
    static void testSetPayment() {
        // Create test data as needed
        Map<String,Object>dataMap = new Map<String,Object>();
        dataMap.put(B2BConstants.PAYMENT_TYPE,'card');
        Webcart cart = [SELECT Id FROM Webcart LIMIT 1];
        dataMap.put(B2BConstants.CART_ID,cart.Id);
        dataMap.put(B2BConstants.CUSTOMER_TOKEN,'TESTTOKEN');
        

        // Call the method being tested
        Test.startTest();
        	B2B_PaymentHelper.setPayment(dataMap);
        Test.stopTest();
        // Perform assertions based on the expected outcomes
        //System.assertNotEquals(null, res,'res is null');
    }
    
    @isTest
    static void testSetPaymentThroughWallet() {
         // Create test data as needed
        B2b_TestUtils.createWallet();
        // Call the method being tested
        Map<String, Object> testDataMap = new Map<String, Object>();
        DigitalWallet dg = [SELECT Id FROM DigitalWallet LIMIT 1];
        testDataMap.put(B2BConstants.DIGITAL_WALLET_ID, dg.Id);
        Webcart cart = [SELECT Id FROM Webcart LIMIT 1];
        testDataMap.put(B2BConstants.CART_ID,cart.Id);
        // Set other necessary data in the testDataMap
        
        Test.startTest();
        B2B_PaymentHelper.setPaymentThroughWallet(testDataMap);
        Test.stopTest();
        
        // Perform assertions based on the expected outcomes
    }
    
    @isTest
    static void testGetPaymentGatewayId() {
        // Create test data as needed
        
        // Call the method being tested
        
        // Perform assertions based on the expected outcomes
    }
    
    @isTest
    static void testGetCardPaymentMethod() {
        // Create test data as needed
        
        // Call the method being tested
        
        // Perform assertions based on the expected outcomes
    }
    
    @isTest
    static void testGetAddress() {
        // Create test data as needed
        
        // Call the method being tested
        
        // Perform assertions based on the expected outcomes
    }
    
    // Add test methods for other helper methods
    
    // Overall test to cover the main methods
    @isTest
    static void testMainMethods() {
        // Create test data as needed
        
        // Call the methods being tested
        
        // Perform assertions based on the expected outcomes
    }
}