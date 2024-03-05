@isTest
private class CommerceCheckoutTest {
    @isTest
    static void testGetSessionId() {
        // Create a test user
        profile[] UserProfile1 = [Select Id, Name From Profile where name = 'Custom - Data Administrator' limit 1];
        system.debug(' check profile' +UserProfile1[0].Id);
        User u1 = new user (Username = ' test@key.net', FirstName = 'FirstTest', LastName ='LastTest', alias = 'FLast', 
                            email='test@key.net', communityNickname='test0101019', TimeZoneSidKey='America/Indiana/Indianapolis',
                            LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', ProfileId=UserProfile1[0].Id ,
                            LanguageLocaleKey='en_US',Region__c='AM', Geography__c='US', Business_Division__c='DN');
        insert u1;
        System.runAs(u1) {
            String sessionId = CommerceCheckout.getSessionId();
            // Add your assertions here to verify the sessionId value
        }
    }
    @isTest
    static void testGetCommerceCheckout() {
        Test.startTest();
        Map<String, String> Data = B2BTestFactory.initialStorefrontSetup();
        String communityId = '0DM8c000000sxg1';
        String mockResponse = '{"checkoutId": "12345", "status": "active"}';
        
        // Mock the HTTP callout response
        HttpCalloutMock mock = new MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the getCommerceCheckout method
        String response = CommerceCheckout.getCommerceCheckout(communityId);
        
        // Check if the response is as expected
        System.assertEquals(mockResponse, response);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCommerceCheckout() {
        Test.startTest();
        String communityId = '0DM8c000000sxg1';
        String payload = '{"desiredDeliveryDate": "2023-08-17", "shippingInstructions": "Handle with care"}';
        String mockResponse = '{"message": "Checkout updated successfully"}';
        
        // Mock the HTTP callout response
        HttpCalloutMock mock = new MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the updateCommerceCheckout method
        String response = CommerceCheckout.updateCommerceCheckout(communityId, payload);
        
        // Check if the response is as expected
        System.assertEquals(mockResponse, response);
        Test.stopTest();
    }
    
    @isTest
    static void testUpdateCommerceDeliveryMethodCheckout() {
        Test.startTest();
        String communityId = '0DM8c000000sxg1';
        String payload = '{"deliveryMethodId": "54321"}';
        String mockResponse = '{"message": "Delivery method updated successfully"}';
        
        // Mock the HTTP callout response
        HttpCalloutMock mock = new MockHttpResponseGenerator(mockResponse);
        Test.setMock(HttpCalloutMock.class, mock);
        
        // Call the updateCommerceDeliveryMethodCheckout method
        CommerceCheckout.updateCommerceDeliveryMethodCheckout(communityId, payload);
        
        // No need to check the response in this case
        Test.stopTest();
    }
    
    // Mock implementation of HttpCalloutMock to generate mock responses
    private class MockHttpResponseGenerator implements HttpCalloutMock {
        String response;
        
        public MockHttpResponseGenerator(String response) {
            this.response = response;
        }
        
        public HttpResponse respond(HttpRequest req) {
            HttpResponse res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(response);
            return res;
        }
    }
}