public class MockHttpResponseTax implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public MockHttpResponseTax() {
            this.statusCode = 200;
            this.responseBody = '<?xml version="1.0" encoding="UTF-8"?><sampleResponse><RequestResult><Status>Success</Status><Message>Response received successfully</Message></RequestResult><OrderHeader HeaderID=\"0a68L000000CgtvQAC\"><CurrencyCode>USD</CurrencyCode><ShippingCarrier>Test</ShippingCarrier><CarrierService>Final carrier</CarrierService><ShippingTaxAmount>34</ShippingTaxAmount></OrderHeader><OrderLines><OrderLine LineID=\"1\"><UnitTaxAmount>32</UnitTaxAmount><AppliedRate>56</AppliedRate><TaxCode>USD</TaxCode> </OrderLine></OrderLines></sampleResponse>';
        }
        
        public MockHttpResponseTax(Integer statusCode, String responseBody) {
            this.statusCode = statusCode;
            this.responseBody = responseBody;
        }
        
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(statusCode);
            res.setBody(responseBody);
            return res;
        }
    }