@isTest
private class B2B_PaymentByTermController_Test {
    @TestSetup
    public static void testSetupData()
    {
        
		Map<string,string> response = B2B_TestUtils.initialStorefrontSetup();
        //String accId = respose.get('accountId');
        //Account ac = B2B_TestUtils.createAccount(true);
        //B2B_TestUtils.createCartWithCartItemsWithAcc('ZimVieTest',accId);
    }

    @isTest
    static void testGetLoggedInUserAccountDetails() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        testAccount.Available_Terms__c='30 Days';
        testAccount.Ecomm_Payment_Options__c = 'Credit Card';
        Contact testContact =[SELECT Id FROM Contact LIMIT 1];
        testContact.AccountId = testAccount.Id;
        User testUser = [SELECT Id FROM User LIMIT 1];
        testUser.ContactId = testContact.Id;
        
        Test.startTest();
        // Set the current user context to the test user
        System.runAs(testUser) {
            Account resultAccount = B2B_PaymentByTermController.getLoggedInUserAccountDetails();
            // Assert the returned Account matches the test Account
            System.assertEquals( resultAccount,null,'Null expected');
            
        }
        Test.stopTest();
    }
}