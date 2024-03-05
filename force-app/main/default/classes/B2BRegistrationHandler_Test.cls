/**
 * @description       : Test Class
 * @author            : Ruby Gupta
**/

@isTest
public class B2BRegistrationHandler_Test 
{
    @TestSetup
    public static void testSetupData()
    {
        B2B_TestUtils.initialStorefrontSetup();
    }
    @isTest
    static void testRegisterUser() {
        // Create test data
        User testUser = [SELECT Id,FirstName FROM User LIMIT 1];
		System.runAs(testUser)
        {
        B2BRegistrationHandler.RegisterUserRequest request = new B2BRegistrationHandler.RegisterUserRequest();
        request.accountId = UserInfo.getOrganizationId();
        request.User = testUser;
        request.sendEmailToOwner = false;

        Test.startTest();
        List<B2BRegistrationHandler.RegisterUserResult> results = B2BRegistrationHandler.registerUser(new List<B2BRegistrationHandler.RegisterUserRequest>{request});
        Test.stopTest();

        // Assertions
        System.assertEquals(1, results.size());
        System.assertEquals(null, results[0].userId);
        }
    }

    @isTest
    static void testRegisterUserException() {
        B2BRegistrationHandler.RegisterUserRequest request = new B2BRegistrationHandler.RegisterUserRequest();
        request.accountId = UserInfo.getOrganizationId();
        request.User = new User(); // Empty User object
        request.sendEmailToOwner = false;

        Test.startTest();
        try {
            List<B2BRegistrationHandler.RegisterUserResult> results = B2BRegistrationHandler.registerUser(new List<B2BRegistrationHandler.RegisterUserRequest>{request});
            // This should not be reached
            System.assert(false, 'Exception was not thrown as expected.');
        } catch (Exception ex) {
            // Expected exception
            System.assertNotEquals(null, ex.getMessage());
        }
        Test.stopTest();
    }
}