@isTest
public class RetryableMockCallout_Test {
  @isTest
    static void testSuccessfulCallout() {
        // Create a mock HTTP response with a 200 status code and a sample response body
      

        // Create an instance of RetryableMockCallout
        RetryableMockCallout callout = new RetryableMockCallout();
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(200, '{"Message": "Success"}'));

        // Call the startJob method and assert the result
        JobResult result = callout.startJob();
    }
    @isTest
    static void testUnauthorizedCallout() {
       
        // Create an instance of RetryableMockCallout
        RetryableMockCallout callout = new RetryableMockCallout();
         Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(401, '{"Message": "Unauthorized"}'));

        // Call the startJob method and assert the result
        JobResult result = callout.startJob();
    }
    @isTest
    static void testRetryableCallout() {
        
        RetryableMockCallout callout = new RetryableMockCallout();
          Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(500, '{"Message": "Server Error"}'));

        // Call the startJob method and assert the result
        JobResult result = callout.startJob();
    }
  public class MockHttpResponseGenerator implements HttpCalloutMock {
    private Integer statusCode;
    private String responseBody;

    public MockHttpResponseGenerator(Integer statusCode, String responseBody) {
        this.statusCode = statusCode;
        this.responseBody = responseBody;
    }

    public HTTPResponse respond(HTTPRequest request) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(statusCode);
        res.setBody(responseBody);
        return res;
    }
}

}