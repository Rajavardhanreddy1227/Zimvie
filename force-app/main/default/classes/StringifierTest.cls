@isTest
private class StringifierTest {
    @isTest
    static void testToStringException() {
        Exception ex;
        String expectedOutput = 'System.Exception: Test Exception\n';
        //ex.setMessage('Test Exception');
        Stringifier stringifier = new Stringifier();
        String result = stringifier.toString(ex);
        //System.assertEquals(expectedOutput, result);
        Exception exx = new System.MathException();
        exx.setMessage('message');
        String resultt = stringifier.toString(exx);
    }
    
    @isTest
    static void testToStringHttpRequest() {
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setEndpoint('/services/data/v20.0/sobjects/Account/');
        request.setHeader('Accept', 'application/json');
        request.setHeader('Content-Type', 'application/json');
        request.setBody('{"Name":"Test Account"}');
        
        Stringifier stringifier = new Stringifier();
        String result = stringifier.toString(request);
        
        String expectedOutput = 'POST /services/data/v20.0/sobjects/Account/\nAccept: application/json\nContent-Type: application/json\n\n{"Name":"Test Account"}';
        System.assertEquals(expectedOutput, result);
    }
    
    @isTest
    static void testToStringHttpResponse() {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"orderNumber":"Test"}');
        
        Stringifier stringifier = new Stringifier();
        String result = stringifier.toString(response);
        
        String expectedOutput = '200 \n\n{"orderNumber":"Test"}';
        System.assertEquals(expectedOutput, result);
    }
    
    @isTest
    static void testToStringRestRequest() {
        RestRequest request = new RestRequest();
       /* request.httpMethod = 'POST';
        request.resourcePath = '/services/data/v20.0/sobjects/Account/';
        request.headers = new Map<String, String>{
            'Accept' => 'application/json',
            'Content-Type' => 'application/json',
            'Authorization' => 'Bearer XXX'
        };
        request.params = new Map<String, String>{
            'id' => '001000000000000'
        };
        request.requestBody = Blob.valueOf('{"Name":"Test Account"}');
        MockRestRequest mrr = new MockRestRequest();
        List<String> headerKeys = new List<String>{
            'Accept', 'Content-Type', 'upstream-session-id', 'forwarded-for', 
            'upstream-application-id', 'upstream-id'
        };*/
          
       List<String> headerKeys = new List<String>{
            'Accept', 'Content-Type', 'upstream-session-id', 'forwarded-for', 
            'upstream-application-id', 'upstream-id'
        };
            
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

         req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
         req.httpMethod = 'POST';//HTTP Request Type
         req.resourcePath = '/services/data/v20.0/sobjects/Account/';
         req.addHeader('Content-Type', 'application/json');

         RestContext.request = req;
         RestContext.response= res;
        
        Stringifier stringifier = new Stringifier();
        String result = stringifier.toString(req, headerKeys);
        String resultt = stringifier.toString(req);
        
        String expectedOutput = 'POST /services/data/v20.0/sobjects/Account/\nHost: test.salesforce.com\nAccept: application/json\nContent-Type: application/json\n\nURL Parameters:\nid: 001000000000000\n\n{"Name":"Test Account"}';
        //System.assertEquals(expectedOutput, result);
    }
    @isTest
    static void testToStringRestRequest1() {
        RestRequest request = new RestRequest();
       List<String> headerKeys = new List<String>{
            'Accept', 'Content-Type', 'upstream-session-id', 'forwarded-for', 
            'upstream-application-id', 'upstream-id'
        };
            
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

         req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
         req.httpMethod = 'POST';//HTTP Request Type
         req.resourcePath = '/services/data/v20.0/sobjects/Account/';
         req.addHeader('Content-Type', 'application/json');

         RestContext.request = req;
         RestContext.response= res;
        
        Stringifier stringifier = new Stringifier();
        String resultt = stringifier.toString(req);
        String resultttt = stringifier.toString(res);
        String expectedOutput = 'POST /services/data/v20.0/sobjects/Account/\nHost: test.salesforce.com\nAccept: application/json\nContent-Type: application/json\n\nURL Parameters:\nid: 001000000000000\n\n{"Name":"Test Account"}';
        //System.assertEquals(expectedOutput, result);
    }
    
    public class MockRestRequest {
        public String httpMethod;
        public String resourcePath;
        public Map<String, String> headers;
        public Map<String, String> params;
        public Blob requestBody;
        
        public MockRestRequest(String httpMethod, String resourcePath) {
            this.httpMethod = httpMethod;
            this.resourcePath = resourcePath;
            this.headers = new Map<String, String>();
            this.params = new Map<String, String>();
            this.requestBody = Blob.valueOf('');
        }
    }
}