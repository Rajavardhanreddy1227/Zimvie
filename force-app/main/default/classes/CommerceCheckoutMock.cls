// Mock class for simulating HTTP callouts
public class CommerceCheckoutMock implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        // Create a mock response here
        HTTPResponse res = new HTTPResponse();
        res.setStatusCode(200);
        res.setBody('{"mockResponseKey": "mockResponseValue"}');
        return res;
    }
}