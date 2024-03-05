@IsTest
public class OktaUserCreation_Test {
    @IsTest
    public static void testSendUserCreation() {
        // Create test data
        Account testAccount = new Account(Name = 'Test Account', Customer_Number__c = '12345');
        Contact testContact = new Contact(FirstName = 'John', LastName = 'Doe', Email = 'john.doe@example.com', MobilePhone = '1234567890');
        insert testAccount;
        insert testContact;
        
        OktaUserCreation.OktaUserCreationRequest testRequest = new OktaUserCreation.OktaUserCreationRequest();
        testRequest.account = testAccount;
        testRequest.contact = testContact;
        
        // Mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        // Start test context
        Test.startTest();
        
        // Call the method to be tested
        List<OktaUserCreation.OktaUserCreationResponse> results = OktaUserCreation.sendUserCreation(new List<OktaUserCreation.OktaUserCreationRequest>{ testRequest });
        
        // Stop test context
        Test.stopTest();
        
        // Verify results
        System.assertEquals(1, results.size());
        OktaUserCreation.OktaUserCreationResponse result = results[0];
        System.assertEquals(true, result.isSucesss);
        System.assertEquals(null, result.exceptionMsg);
        System.assertNotEquals(null, result.oktaUserId);
        System.assertNotEquals(null, result.deactivateLink);
    }
}