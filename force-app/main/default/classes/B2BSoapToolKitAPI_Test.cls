@isTest
public class B2BSoapToolKitAPI_Test {
    @isTest
    static void testGetCCSoapXMLBody() {
        Map<String, String> params = new Map<String, String>{
            'userName' => 'testUser',
            'password' => 'testPassword'
        };
        
        List<CartItem> cartItems = new List<CartItem>{
            new CartItem(TotalLineAmount = 100),
            new CartItem(TotalLineAmount = 150)
        };
        
        //commercepayments.AuthorizationRequest authRequest = new commercepayments.AuthorizationRequest();
       
        
        Test.startTest();
       	String soapXmlBody ;//= B2BSoapToolKitAPI.getCCSoapXMLBody(params, cartItems,);
        Test.stopTest();
        
        System.assertNotEquals(null, soapXmlBody, 'SOAP XML body should not be null');
        System.assert(soapXmlBody.contains('<merchantID>'), 'SOAP XML should contain <merchantID> tag');
        // Add more assertions as needed
    }
    
    @isTest
    static void testGetCCSoapXMLTokenizeBody() {
        Map<String, String> params = new Map<String, String>{
            'userName' => 'testUser',
            'password' => 'testPassword'
        };
        
        List<CartItem> cartItems = new List<CartItem>{
            new CartItem(TotalLineAmount = 100),
            new CartItem(TotalLineAmount = 150)
        };
        
        commercepayments.PaymentMethodTokenizationRequest tokenizeRequest = new commercepayments.PaymentMethodTokenizationRequest();
        // Initialize tokenizeRequest with necessary data
        
        Test.startTest();
        String soapXmlBody = B2BSoapToolKitAPI.getCCSoapXMLTokenizeBody(params, cartItems, tokenizeRequest);
        Test.stopTest();
        
        System.assertNotEquals(null, soapXmlBody, 'SOAP XML body should not be null');
        System.assert(soapXmlBody.contains('<merchantID>'), 'SOAP XML should contain <merchantID> tag');
        // Add more assertions as needed
    }
    
    @isTest
    static void testChangeCardType() {
        Test.startTest();
        
        String visaCardType = B2BSoapToolKitAPI.changeCardType('Visa');
        System.assertEquals('001', visaCardType, 'Visa card type should be converted to 001');
        
        String masterCardType = B2BSoapToolKitAPI.changeCardType('MasterCard');
        System.assertEquals('002', masterCardType, 'MasterCard card type should be converted to 002');
        
        // Add more assertions for other card types
        
        Test.stopTest();
    }
}