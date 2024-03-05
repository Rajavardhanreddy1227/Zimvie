@isTest
public class MockHttpResponseGenere implements HttpCalloutMock {
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/xml');
        response.setStatusCode(200);
        response.setBody('<root><Body> <AcknowledgeOrder><ApplicationArea></ApplicationArea></AcknowledgeOrder></Body></root>');
        return response;
    }
}