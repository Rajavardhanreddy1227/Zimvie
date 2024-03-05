@isTest
public class OktaServiceHelperTest {

    // Define a mock response class
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest request) {
            // Create a mock response
            HttpResponse response = new HttpResponse();
            response.setStatusCode(200);
            response.setStatus('OK');
            response.setBody('{"status": "success"}');
            return response;
        }
    }

    @isTest
    static void testToggleUserActivation() {
        // Create test data or parameters
        

        // Create a test user
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User']; // Replace 'Standard User' with the appropriate profile name
        User testUser = new User(
            Alias = 'testUser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Test',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            isActive = true,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser12@example.com'
        );
        insert testUser;
        Map<String, Object> requestParam = new Map<String, Object>();
        requestParam.put('userId',testUser.Id);
        requestParam.put('deactivateLink', 'https://example.com/deactivate');
        requestParam.put('action', 'deactivate');
        requestParam.put('action', 'activate');
        // Set up a mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());

        // Start Test
        Test.startTest();

        // Run the code as the test user
        System.runAs(testUser) {
          OktaServiceHelper.toggleUserActivation(requestParam);
        }

        // End Test
        Test.stopTest();

    }
}