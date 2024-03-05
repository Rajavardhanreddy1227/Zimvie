@isTest
public class MockHttpResponseGenereTest {

    @isTest
    static void testRespond() {
        // Create an instance of your mock HTTP response generator
        MockHttpResponseGenere mockResponseGenerator = new MockHttpResponseGenere();

        // Create an HTTP request (you can customize this request as needed)
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://example.com'); // Replace with your endpoint URL
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/xml');

        // Start Test
        Test.startTest();

        // Call the respond method of your mock response generator
        HttpResponse response = mockResponseGenerator.respond(request);

        // End Test
        Test.stopTest();

        // Add debug statements to troubleshoot
        System.debug('Response Status Code: ' + response.getStatusCode());
        System.debug('Response Content Type: ' + response.getHeader('Content-Type'));
        System.debug('Response Body: ' + response.getBody());

        // Assert that the response matches your expectations
        System.assertEquals(200, response.getStatusCode());
        System.assertEquals('application/xml', response.getHeader('Content-Type'));
        System.assertEquals('<root><Body> <AcknowledgeOrder><ApplicationArea></ApplicationArea></AcknowledgeOrder></Body></root>', response.getBody());
    }
}