@isTest
private class B2BCybersourceRESTUtility_Test {
    @TestSetup
    public static void testSetupData()
    {
        B2B_TestUtils.initialStorefrontSetup();
        Account ac = [SELECT Id FROM Account LIMIT 1];
        B2B_TestUtils.createCartWithCartItemsWithAcc('ZimVieTest',ac.Id);

    }
    @isTest
    static void testCreateCustomerToken() {
        // Create test Account and Contact records as needed
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id,FirstName,LastName,Name FROM Contact LIMIT 1];
        
        // Call the method being tested
        Test.startTest();
        String customerToken = B2BCybersourceRESTUtility.createCustomerToken(testContact);
        Test.stopTest();
        
        // Add assertions to verify the logic based on your input data and expected behavior
        System.assertNotEquals(null, customerToken); 
    }

    // Create other test methods for different functionalities of your utility class
}