@isTest
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
          // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('<?xml version="1.0" encoding="UTF-8" standalone="yes"?><RequestResult><Status><Message>null</Message></Status></RequestResult>');
        res.setStatusCode(200);
        return res;
    }
    }