/**
 * @description       : 
 * @author            : Mayank Srivastava
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
**/

@isTest
public class B2BAccountManagementControllerTest 
{
    @TestSetup
    public static void testSetupData()
    {
        B2B_TestUtils.initialStorefrontSetup();   
    }
    @isTest
    static void testFetchAddresses() {
        // Create test data
        Account testAccount = [SELECT Id FROM Account LIMIT 1];

        // Call the method to test
        Test.startTest();
        String result = B2BAccountManagementController.fetchAddresses(testAccount.Id);
        Test.stopTest();

        // Perform assertions
        System.assertNotEquals(null, result,'wrong output'); // Update assertion based on expected output
    }

    // Add similar test methods for other controller methods...

    @isTest
    static void testRetrieveLoyalty() {
        // Create test data
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        
        testAccount.Expiration_Date__c = Date.today() + 20;
        update testAccount;

        // Call the method to test
        Test.startTest();
        String result = B2BAccountManagementController.retrieveLoyalty(testAccount.Id);
        Test.stopTest();

        // Perform assertions
        // Update assertions based on expected output
        System.assertNotEquals(null, result);
        System.assertNotEquals('', result);
    }
     @isTest
    static void testFetchOrderDetails() {
        // Create test data
        User testUser = [SELECT Id FROM User LIMIT 1];

        // Call the method to test
        Test.startTest();
        String result = B2BAccountManagementController.fetchOrderDetails(testUser.Id);
        Test.stopTest();

        // Perform assertions
        // Update assertions based on expected output
        System.assertNotEquals(null, result,'wrong output');
        System.assertNotEquals('', result,'wrong output');
    }
    @isTest
    static void testRetrieveWallet() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account');
        insert testAccount;

        // Call the method to test
        Test.startTest();
        String result = B2BAccountManagementController.retrieveWallet(testAccount.Id);
        Test.stopTest();

        // Perform assertions
        // Update assertions based on expected output
        System.assertNotEquals(null, result);
        System.assertNotEquals('', result);
    }
        @isTest
    static void testFetchConditions() {
        // Create test data
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        User testUser = [SELECT Id FROM User LIMIT 1];

        // Call the method to test
        Test.startTest();
        String result = B2BAccountManagementController.fetchConditions(testAccount.Id);
        Test.stopTest();

        // Perform assertions
        // Update assertions based on expected output
        System.assertNotEquals(null, result,'wrong output');
    }
    
        @IsTest
    	static void testGetCartId() {
        // Test data
        String communityId = [SELECT Id FROM Network LIMIT 1].Id;
        String effectiveAccountId = [SELECT Id FROM Account LIMIT 1].Id;
        
        Test.startTest();
        
        String cartId = B2BAccountManagementController.getCartId(communityId, effectiveAccountId);
        
        Test.stopTest();
        
        System.assertEquals(null, cartId); 
    }
    
    
 
    @isTest
    static void testUpdateLoyaltyOnCart() 
    {
        // Test data
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        String communityId = [SELECT Id FROM Network LIMIT 1].Id;
        B2B_TestUtils.createCartWithCartItemsWithAcc('ZimvieTest', testAccount.Id);
        WebCart testCart = [SELECT Id FROM Webcart LIMIT 1];
        
        
        
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('coordinatorName', 'John Doe');
        mapParams.put('coordinatorPhone', '123-456-7890');
        mapParams.put('coordinatorEmail', 'john.doe@example.com');
        mapParams.put('communityId', communityId);
        mapParams.put('effectiveAccountId', testAccount.Id);
        
        Test.startTest();
        Map<String, Object> result = B2BAccountManagementController.updateLoyaltyOnCart(mapParams);
        Map<String, Object> resultNull = B2BAccountManagementController.updateLoyaltyOnCart(null);
        Test.stopTest();
        System.assertNotEquals(null, result,'Wrong Output');       

	}
    @isTest
    static void testFetchConditionsV2() {
        
        Test.startTest();
      String result =  B2BAccountManagementController.fetchConditions(null);
        Test.stopTest();
        
        System.assertEquals(null, result);
    }
     @isTest
    static void testFetchAddressesV2() {
        
        Test.startTest();
      String result =  B2BAccountManagementController.fetchAddresses(null);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
     @isTest
    static void fetchOrderDetailsV2() {
        
        Test.startTest();
      String result =  B2BAccountManagementController.fetchOrderDetails(null);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    } 
    @isTest
    static void retrieveLoyaltyV2() {
        
        Test.startTest();
      String result =  B2BAccountManagementController.retrieveLoyalty(null);
        Test.stopTest();
        
        System.assertNotEquals(null, result);
    }
    @isTest
    static void getRmaStatusesV2() {
        Test.startTest();
            System.assertNotEquals(null, B2BAccountManagementController.getRmaStatuses());
        Test.stopTest();
    }
    @isTest
    static void getRmaTypesV2() {
        Test.startTest();
            System.assertNotEquals(null, B2BAccountManagementController.getRmaTypes());
        Test.stopTest();
    }
    @isTest
    static void retrieveRMAStatusV2() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        User testUser = [SELECT Id FROM User LIMIT 1];
        B2B_TestUtils.createRMA(testAccount.Id,testContact.Id,testUser.Id);
        Test.startTest();
        Date pastDate = System.today().addDays(-13);
        Date futureDate = System.today().addDays(13);
        String result =  B2BAccountManagementController.retrieveRMAStatus(testAccount.Id,5,'0.0',false,pastDate,futureDate,'Return','Submitted');
        Test.stopTest();
        System.assertNotEquals(null, result);
    }
    @isTest
    static void getRMAStatusDetailV2() {
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        Contact testContact = [SELECT Id FROM Contact LIMIT 1];
        User testUser = [SELECT Id FROM User LIMIT 1];
        RMA__c rmaRecord = B2B_TestUtils.createRMA(testAccount.Id,testContact.Id,testUser.Id);
        Test.startTest();
        Map<String,Object> result =  B2BAccountManagementController.getRMAStatusDetail(rmaRecord.Id);
        Test.stopTest();
        System.assertNotEquals(null, result);
    }

}