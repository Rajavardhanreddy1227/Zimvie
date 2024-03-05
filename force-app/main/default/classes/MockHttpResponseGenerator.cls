@IsTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a mock HTTP response with a status code of 200
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('{"id":"mockUserId","_links":{"deactivate":{"href":"mockDeactivateLink"}}}');
        return res;
    }
}