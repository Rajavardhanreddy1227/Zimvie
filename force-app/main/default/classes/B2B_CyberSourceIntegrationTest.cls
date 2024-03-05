@isTest
public class B2B_CyberSourceIntegrationTest {

    // Mock class for HTTP callouts
    public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HttpResponse respond(HttpRequest request) {
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{"access_token": "mocked_access_token"}');
            response.setStatusCode(200);
            return response;
        }
    }

    @isTest
    static void testFetchToken() {
        // Set up the mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());

        // Start a test context
        Test.startTest();

        // Call the fetchToken method from your class
        String token = B2B_CyberSourceIntegration.fetchToken();

        // Add assertions to validate the token or any other expected behavior
        System.assertNotEquals(null, token);

        // Stop the test context
        Test.stopTest();
    }

    // Similar setup for testFetchJWK with mock callout
}