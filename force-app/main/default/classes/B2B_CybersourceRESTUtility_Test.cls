@isTest
private class B2B_CybersourceRESTUtility_Test {

    @isTest static void testCreateCustomerToken() {
        // Test data setup
        Contact testContact = new Contact(FirstName = 'Test', LastName = 'Contact');
        insert testContact;

        // Test method invocation
        Test.startTest();
        B2B_CybersourceRESTUtility.createCustomerToken(testContact);
        Test.stopTest();

        // Perform assertions
        testContact = [SELECT B2B_CYBS_Customer_Token__c FROM Contact WHERE Id = :testContact.Id];
        System.assertEquals(true, String.isNotBlank(testContact.B2B_CYBS_Customer_Token__c));
    }

    @isTest static void testGetCYBSConfiguration() {
        // Test data setup
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Test method invocation
        Test.startTest();
        B2B_CybersourceRESTUtility.getCYBSConfiguration(testAccount.Id);
        Test.stopTest();

        // Perform assertions
        System.assertEquals(true, String.isNotBlank(B2B_CybersourceRESTUtility.HOST));
        System.assertEquals(true, String.isNotBlank(B2B_CybersourceRESTUtility.MERCHANT_ID));
        System.assertEquals(true, String.isNotBlank(B2B_CybersourceRESTUtility.KEY_ID));
        System.assertEquals(true, String.isNotBlank(B2B_CybersourceRESTUtility.PRIVATE_KEY));
        // ... Add more assertions for other fields if needed
    }

    // Add similar test methods for other public methods in B2B_CybersourceRESTUtility class
}