public class MockHttpResponseOracle implements HttpCalloutMock {
        private Integer statusCode;
        private String responseBody;
        
        public MockHttpResponseOracle() {
            this.statusCode = 200;
            this.responseBody = '<?xml version="1.0" encoding="UTF-8"?><sampleResponse><RequestResult><Status>Success</Status><Message>Response received successfully</Message></RequestResult><OrderHeader HeaderID=\"0a68L000000CgtvQAC\"><CurrencyCode>USD</CurrencyCode><ShiptoLocation><ERPReferenceID>45.00</ERPReferenceID></ShiptoLocation></OrderHeader><OrderLines><OrderLine LineID=\"1\"><PricedQuantity>32.00</PricedQuantity><PricedListPrice>56.00</PricedListPrice><PricedSellingPrice>78.00</PricedSellingPrice><Discounts  DiscountID=\"1\"> <DiscountName> TestName</DiscountName><DiscountedAmount> 56</DiscountedAmount><DiscountedPercent> 589</DiscountedPercent></Discounts> </OrderLine></OrderLines></sampleResponse>';
        }
        
        public MockHttpResponseOracle(Integer statusCode, String responseBody) {
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