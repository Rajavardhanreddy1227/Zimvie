public class MockHttpResponseGenerate implements HttpCalloutMock{
    
    // Implement the respond method to simulate responses from the external service
    public HttpResponse respond(HttpRequest req) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(200);
        res.setBody('{"TestPrinter1":1.00, "SKU_Test2":2.00}');
        return res;
    }
    
}