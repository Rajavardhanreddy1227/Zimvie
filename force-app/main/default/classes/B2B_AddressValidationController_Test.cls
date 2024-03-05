@IsTest
public class B2B_AddressValidationController_Test {
    
    @testSetup
    public static void setup(){
        Account testAccount = new Account(Name = 'Test Account', BillingCountry = 'United States', BillingCountryCode = 'US');
        insert testAccount;
    }
    
    @IsTest
    public static void testAddressValidationWrapper() {
        // Create test data
        B2B_AddressValidationWrapper wrapper = new B2B_AddressValidationWrapper();
        wrapper.enableUspsCass = true;
        
        B2B_AddressValidationWrapper.RequestAddress address = new B2B_AddressValidationWrapper.RequestAddress();
        address.regionCode = 'CA';
        address.locality = 'San Francisco';
        address.administrativeArea = 'CA';
        address.postalCode = '94107';
        address.addressLines = new List<String>{'123 Main St', 'Apt 4'};
            wrapper.address = address;
        
        // Verify data
        System.assertEquals(true, wrapper.enableUspsCass);
        System.assertEquals('CA', wrapper.address.regionCode);
        System.assertEquals('San Francisco', wrapper.address.locality);
        System.assertEquals('CA', wrapper.address.administrativeArea);
        System.assertEquals('94107', wrapper.address.postalCode);
        System.assertEquals(new List<String>{'123 Main St', 'Apt 4'}, wrapper.address.addressLines);
    }
    
    // Create a mock HTTP response class
    public class MockHttpResponse implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'application/json');
            if (req.getEndpoint().contains('success')) {
                res.setStatusCode(200);
                res.setBody('{"status": "Success", "message": "Address validated successfully"}');
            } else {
                res.setStatusCode(400);
                res.setBody('{"status": "Error", "message": "Invalid address"}');
            }
            return res;
        }
    }
    
    @isTest
    static void testValidAddress() {
        // Set up test data
        Account testAccount = [select id from Account where Name = 'Test Account'];//new Account(Name = 'Test Account', BillingCountry = 'United States', BillingCountryCode = 'US');
        //insert testAccount;
        
        // Set up the HTTP mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Call the method under 
        Test.startTest();
        Map<String, Object> result = B2B_AddressValidationController.validateAddress(
            'San Francisco', 'US', 'CA', '94105', '123 Main St', testAccount.Id
        );
        Test.stopTest();
        
        // Assert the results
        System.assertEquals('United States', result.get('billingCountry'));
    }
    
    @isTest
    static void testInvalidAddress() {
        // Set up test data
        Account testAccount = [select id from Account where Name = 'Test Account'];//new Account(Name = 'Test Account', BillingCountry = 'United States', BillingCountryCode = 'US');Account testAccount = new Account(Name = 'Test Account', BillingCountry = 'Canada', BillingCountryCode = 'CA');
        //insert testAccount;
        
        // Set up the HTTP mock response
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
        // Call the method under test
        Test.startTest();
        Map<String, Object> result = B2B_AddressValidationController.validateAddress(
            'Invalid City', 'US', 'CA', '94105', '456 Elm St', testAccount.Id
        );
        Test.stopTest();
        
        // Assert the results
        System.assertEquals('United States', result.get('billingCountry'));
    }
    
    @isTest
    static void testInvalidAddress2() {
        // Set up test data
        Account testAccount = [select id from Account where Name = 'Test Account'];//new Account(Name = 'Test Account', BillingCountry = 'United States', BillingCountryCode = 'US');Account testAccount = new Account(Name = 'Test Account', BillingCountry = 'Canada', BillingCountryCode = 'CA');
        //insert testAccount;
        try{
            Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
            
            // Call the method under test
            Test.startTest();
            Map<String, Object> result = B2B_AddressValidationController.validateAddress(
                'Invalid City', 'US', 'CA', '94105', '456 Elm St', null
            );
            Test.stopTest();
            
            // Assert the results
            System.assertEquals('United States', result.get('billingCountry'));
        }Catch(Exception e){
            System.debug('exception-- '+e);
        }
    }
    
    @isTest
    static void updateContactAddressTest(){
        try{
         	ContactPointAddress cpa = new ContactPointAddress(
            	name = 'cpaTest'
            );
            insert cpa;
            Test.startTest();
            Map<String, Object> result = B2B_AddressValidationController.updateContactAddress('Invalid City', 'US');
            Test.stopTest();  
            System.assertEquals(null, result);
        }Catch(Exception e){
            System.debug('exception-- '+e);
        }
    }
    
    @isTest
    static void updateContactAddressTest2(){
        try{
         	ContactPointAddress cpa = new ContactPointAddress(
            	name = 'cpaTest'
            );
            insert cpa;
            Test.startTest();
            Map<String, Object> result = B2B_AddressValidationController.updateContactAddress(cpa.Id, '12304');
            Test.stopTest(); 
            System.assertNotEquals(null, result);
        }Catch(Exception e){
            System.debug('exception-- '+e);
        }
    }
    
    @isTest
    static void deleteContactPointAddressTest(){
        try{
         	ContactPointAddress cpa = new ContactPointAddress(
            	name = 'cpaTest'
            );
            insert cpa;
            Test.startTest();
            Map<String, Object> result = B2B_AddressValidationController.deleteContactPointAddress('Invalid City');
            Test.stopTest();  
            System.assertEquals(null, result);
        }Catch(Exception e){
            System.debug('exception-- '+e);
        }
    }
    @isTest
    static void deleteContactPointAddressTest2(){
        try{
         	ContactPointAddress cpa = new ContactPointAddress(
            	name = 'cpaTest'
            );
            insert cpa;
            Test.startTest();
            Map<String, Object> result = B2B_AddressValidationController.deleteContactPointAddress(cpa.Id);
            Test.stopTest(); 
            System.assertNotEquals(null, result);
        }Catch(Exception e){
            System.debug('exception-- '+e);
        }
    }
    
    @isTest
    static void validateNickNameTest(){
        try{
            Account testAccount = [select id from Account where Name = 'Test Account'];//new Account(Name = 'Test Account', BillingCountry = 'United States', BillingCountryCode = 'US');Account testAccount = new Account(Name = 'Test Account', BillingCountry = 'Canada', BillingCountryCode = 'CA');
            Map<String, Object> inp = new Map<String, Object>();
            inp.put('accId',(String)testAccount.Id);
            inp.put('nickName','nickname');
         	ContactPointAddress cpa = new ContactPointAddress(
            	name = 'cpaTest',
                ParentId = testAccount.Id
            );
            insert cpa;
            Test.startTest();
            Map<String, Object> result = B2B_AddressValidationController.validateNickName(inp);
            Test.stopTest(); 
            System.assertNotEquals(null, result);
        }Catch(Exception e){
            System.debug('exception-- '+e);
        }
    }
    
    @isTest
    static void validateNickNameTest2(){
        try{
            Account testAccount = [select id from Account where Name = 'Test Account'];//new Account(Name = 'Test Account', BillingCountry = 'United States', BillingCountryCode = 'US');Account testAccount = new Account(Name = 'Test Account', BillingCountry = 'Canada', BillingCountryCode = 'CA');
            Map<String, Object> inp = new Map<String, Object>();
            string testAccId = testAccount.Id;
            if(testAccId.Length() == 18){
                testAccId = testAccId.substring(0,testAccId.length()-3);
            }
            inp.put('accId',(String)testAccId);
            inp.put('nickName','cpaTest');
         	ContactPointAddress cpa = new ContactPointAddress(
            	name = 'cpaTest',
                ParentId = testAccId
            );
            insert cpa;
            Test.startTest();
            Map<String, Object> result = B2B_AddressValidationController.validateNickName(inp);
            Test.stopTest(); 
            System.assertNotEquals(null, result);
        }Catch(Exception e){
            System.debug('exception-- '+e);
        }
    }
    
    @isTest
    static void validateNickNameTest3(){
        try{
            Account testAccount = [select id from Account where Name = 'Test Account'];//new Account(Name = 'Test Account', BillingCountry = 'United States', BillingCountryCode = 'US');Account testAccount = new Account(Name = 'Test Account', BillingCountry = 'Canada', BillingCountryCode = 'CA');
            Map<String, Object> inp = new Map<String, Object>();
            inp.put('accId',null);
            inp.put('nickName','nickname');
         	ContactPointAddress cpa = new ContactPointAddress(
            	name = 'cpaTest',
                ParentId = testAccount.Id
            );
            insert cpa;
            Test.startTest();
            Map<String, Object> result = B2B_AddressValidationController.validateNickName(inp);
            Test.stopTest(); 
            System.assertNotEquals(null, result);
        }Catch(Exception e){
            System.debug('exception-- '+e);
        }
    }
    
    @isTest
    static void generateXMLBodyTest(){
        Account testAccount = [select id from Account where Name = 'Test Account'];
        WebCart cart = B2b_TestUtils.createCartWithCartItemsWithAcc('cartName', testAccount.Id);
        Test.startTest();
        String result = B2B_AddressValidationController.generateXMLBody(cart.Id, testAccount.Id, 'city', 'countryCode', 'stateCode', 'postalCode', 'street', 'nickName');
        Test.stopTest(); 
        System.assertNotEquals(null, result);
    }
    
    @isTest
    static void generateXMLBodyTest2(){
        Account testAccount = [select id from Account where Name = 'Test Account'];
        WebCart cart = B2b_TestUtils.createCartWithCartItemsWithAcc('cartName', testAccount.Id);
        Test.startTest();
        String result = B2B_AddressValidationController.generateXMLBody(null, testAccount.Id, 'city', 'countryCode', null, 'postalCode', 'street', 'nickName');
        Test.stopTest(); 
        System.assertNotEquals(null, result);
    }
     @isTest
    static void makeApiCalloutTest1(){
        Account testAccount = [select id from Account where Name = 'Test Account'];
        WebCart cart = B2b_TestUtils.createCartWithCartItemsWithAcc('cartName', testAccount.Id);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseOracleTaxApi());
        Test.startTest();
        try{
       B2B_AddressValidationController.makeApiCallout(cart.id, testAccount.Id, 'Baltimore', 'USD', 'MD', '21201', 'street', 'nickName','addressId');
        }catch(exception e){
            
        }
            Test.stopTest(); 
        
    }
}