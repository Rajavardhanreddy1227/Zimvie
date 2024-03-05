@isTest
private class CommerceCheckoutCalloutTest {
@isTest
    static void testCreateRequestSuccess() {
        // Create a mock HTTP response with success status
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"message": "Success"}');

        // Set up a mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        // Call the createRequest method
        String response = CommerceCheckoutCallout.createRequest('mockURL', 'POST', 'mockSessionId', '{"data": "example"}');

        // Check if the response is as expected
        System.assertEquals('{"message": "Success"}', response);
    }

    @isTest
    static void testCreateRequestError() {
        // Create a mock HTTP response with error status
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(400);
        mockResponse.setStatus('Bad Request');
        mockResponse.setBody('{"error": "Invalid input"}');

        // Set up a mock HTTP callout
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(mockResponse));

        // Call the createRequest method and expect an exception
        try {
            CommerceCheckoutCallout.createRequest('mockURL', 'POST', 'mockSessionId', '{"data": "example"}');
            System.assert(false, 'Expected exception was not thrown.');
        } catch (CommerceCheckoutCallout.CommerceException ex) {
            System.assertEquals('Failed to update checkout: 400 Bad Request - {"error": "Invalid input"}', ex.getMessage());
        }
    }

    // Mock implementation of HttpCalloutMock to generate mock responses
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        HttpResponse response;

        public MockHttpResponseGenerator(HttpResponse response) {
            this.response = response;
        }

        public HttpResponse respond(HttpRequest req) {
            return response;
        }
    }
}