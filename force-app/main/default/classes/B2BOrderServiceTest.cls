@isTest
private class B2BOrderServiceTest {
    @isTest
    static void testOrderSync() {
        B2BOrderService.orderRequest mockOrderRequest = new B2BOrderService.orderRequest();
        mockOrderRequest.orderId = 'a00100000000001'; // Replace with a valid Order Id
        Test.startTest();
        Test.setMock(WebServiceMock.class, new MyMockWebService());
        B2BOrderService.orderSync(new List<B2BOrderService.orderRequest>{ mockOrderRequest });
        Test.stopTest();
    }
    @isTest
    static void testEmail(){
        //B2BOrderService.sendSingleEmailMethod('This is test email');
        B2BOrderService.generateJSON('a00100000000001');
    }
    // Mocking the WebServiceMock for testing
    public class MyMockWebService implements WebServiceMock {
        public void doInvoke(Object stub, Object request, Map<String, Object> response,String endpoint, String soapAction,String requestName,
            String responseNS, 
            String responseName, 
            String responseType) {
                response.put('response_x', 'Success');
                response.put('response_y', 'Data');
            }
    }
}