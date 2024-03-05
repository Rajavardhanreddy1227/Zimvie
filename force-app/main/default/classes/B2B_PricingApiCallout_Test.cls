// Mock class to simulate HTTP callout response

@isTest
private class B2B_PricingApiCallout_Test {

    @isTest static void testPricingApiCallout() {
        // Test data setup
        String mockBody = '<sampleResponse></sampleResponse>';
        String mockEndpointUrl = 'https://mock.endpoint.url';
        Map<String,Object> reqBodyMap = new Map<String,Object>();  
        List<B2BCartService.OrderLine> respOrderLineList = new List<B2BCartService.OrderLine>();
        Test.setMock(HttpCalloutMock.class, new B2B_PricingApiCallout_MockCallout_Test());

        // Test method invocation
        Test.startTest();
        B2B_PricingApiCallout callout = new B2B_PricingApiCallout(mockBody, mockEndpointUrl,reqBodyMap,respOrderLineList);
        callout.startJob();
       // B2B_PricingApiCallout callout1 = new B2B_PricingApiCallout(null, null);
       // callout1.startJob();
        Test.stopTest();

      
    }
}