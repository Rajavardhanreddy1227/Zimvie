@IsTest
public class B2B_CYBSPaymentContoller_Test {
   /* @TestSetup
    public static void testSetupData()
    {
		Map<string,string> response = B2B_TestUtils.initialStorefrontSetup();
        String conId = response.get('contactId');
        String accId = response.get('accountId');
        
        ContactPointAddress con_point_billing = new ContactPointAddress(Id = response.get('con_point_billingId'));
        con_point_billing.IsDefault=true;
        con_point_billing.Street = 'demo street';
        update con_point_billing;
        Profile pf = [SELECT Id FROM Profile WHERE Name = 'B2B Lightning Community Plus' LIMIT 1];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
            Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
            String uniqueName = orgId + dateString + RandomId;
            
            User uu = new User(firstname = 'ABC',
                               lastName = 'XYZ',
                               email = uniqueName + '@test' + orgId + '.org',
                               Username = uniqueName + '@test' + orgId + '.org',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias = uniqueName.substring(18, 23),
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               CommunityNickname = 'nick',
                               IsActive = True,
                               ProfileId = pf.Id,
                               ContactId = conId,
                               PortalRole = 'Manager'
                              );
            insert uu;
        
        
        System.runAs(uu){ 
            WebCart wc = B2B_TestUtils.createCartWithCartItemsWithAcc('Test CART', accId);
            WebCart newWc = new WebCart(Id=wc.Id);
            newWc.Status = 'Checkout';
            newWc.BillingStreet = 'demo street';
            newWc.BillingCity = 'Goleta';
            newWc.BillingState = 'California';
            newWc.BillingPostalCode = '93117-3084';
            newWc.BillingCountry = 'United States';
            update newWc;
}
    }*/


    @IsTest
    public static void testGetMerchant() {
      //  User newUser = [select Id, name from user where Username= 'john.doe8222023@example.com' Limit 1];
       // System.runAs(newUser){
            Test.startTest();
            Boolean result = B2B_CYBSPaymentContoller.is3Dsecure();
        	Test.stopTest();
        
        //System.assertNotEquals(null, result, 'Merchant should not be null');
    }
    @isTest()
    static void isShippingAddSelectedTest(){
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert cart;
        Test.startTest();
        B2B_CYBSPaymentContoller.isShippingAddSelected(cart.Id);
        Test.stopTest();     
        
    }
   
        @isTest()
    static void getShippingAddressTest(){
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert cart;
        Test.startTest();
        B2B_CYBSPaymentContoller.getShippingAddress(cart.Id);
        Test.stopTest();     
        
    }
     public class MockHttpResponseGenerator implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            // Create a mock HTTP response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody('{"example": "mocked response"}');
            res.setStatusCode(200);
            return res;
        }
    }

    @isTest
    static void getTokenTest() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert cart;
        String cartId=cart.Id;
        HttpCalloutMock mock = new MockHttpResponseGenerator();
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mock);
 		B2B_CYBSPaymentContoller.getAddress(cartId);
        Test.stopTest();

    }
   
    @isTest
    static void getStoredWalletTest(){
        String contactId = [SELECT ContactId FROM User WHERE Id=:userInfo.getuserId()].ContactId;
         DigitalWallet testDigitalWallet = new DigitalWallet(
            IsDefault__c = true,
            Card_Type__c = 'Visa',
            Display_Card_Number__c = '************1234',
            Contact__c = contactId,
            ExpiryYear__c = 2025,
            ExpiryMonth__c = 12,
            CardHolderName__c = 'John Doe',
            NickName = 'My Wallet',
            Status = 'Active',
            ProcessingMode='External'
        );
        insert testDigitalWallet;
        Test.startTest();
        B2B_CYBSPaymentContoller.getStoredWallet();
        Test.stopTest();
    }
      @isTest
    static void checkoutUsingStoredPaymentTest(){
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert cart;
        String contactId = [SELECT ContactId FROM User WHERE Id=:userInfo.getuserId()].ContactId;
         DigitalWallet testDigitalWallet = new DigitalWallet(
            IsDefault__c = true,
            Card_Type__c = 'Visa',
            Display_Card_Number__c = '************1234',
            Contact__c = contactId,
            ExpiryYear__c = 2025,
            ExpiryMonth__c = 12,
            CardHolderName__c = 'John Doe',
            GatewayToken='0190502152701111',
            CardLastFour__c =1111,
            NickName = 'My Wallet',
            Status = 'Active',
            ProcessingMode='External'
        );
        insert testDigitalWallet;
        Test.startTest();
        B2B_CYBSPaymentContoller.checkoutUsingStoredPayment(
        'OrderId',
         testWebStore.Id,
         cart.Id,
         testDigitalWallet.Id,
         'receiptId'
        );
        Test.stopTest();
    }
    @IsTest
    public static void testGetMerchantNonUser() {
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert cart;
        Test.startTest();
        B2B_CYBSPaymentContoller.isPoOrCreditCart('');
        Test.stopTest();
    }
    @isTest
    static void getTokenasTest(){
        String samplePayload = '{"sub":"1234567890","name":"John Doe","iat":1516239022}';
        Blob payloadBlob = Blob.valueOf(samplePayload);
        String base64EncodedPayload = EncodingUtil.base64Encode(payloadBlob);
        String sampleJwtToken = 'header.' + base64EncodedPayload + '.signature';
        Test.startTest();
        B2B_CYBSPaymentContoller.getJTiToken(sampleJwtToken);
        Test.stopTest();
    }
    @isTest
    static void testGetMaskedCardValue() {
    // Create a sample JWT token body with the expected structure
    String sampleJwtTokenBody = '{"content": {"paymentInformation": {"card": {"number": {"maskedValue": "maskedCardValueHere"}}}}}';

    // Encode the JWT token body as base64
    Blob payloadBlob = Blob.valueOf(sampleJwtTokenBody);
    String base64EncodedPayload = EncodingUtil.base64Encode(payloadBlob);

    // Create a sample JWT token with a valid body
    String sampleJwtToken = 'header.' + base64EncodedPayload + '.signature';

    Test.startTest();
    B2B_CYBSPaymentContoller.getMaskedCardValue(sampleJwtToken);
    Test.stopTest();
}
  /*  @isTest
static void testGenrateZeroAmountAuthorizationRequest() {
    // Create a sample JWT token for testing
    String sampleJwtToken = 'your_sample_jwt_token_here';
    Profile pf = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
    String orgId = UserInfo.getOrganizationId();
    String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
    Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
    String uniqueName = orgId + dateString + RandomId;
 /*  Account acc = new Account();
    acc.Name = 'Test Name';
    acc.CurrencyIsoCode='USD';
    insert acc;
    String accountId = [SELECT Id,AccountId,Account.CurrencyIsoCode FROM User WHERE Id=:UserInfo.getUserId()].AccountId;
    Contact con = new Contact();
    con.FirstName = 'test';
    con.LastName = 'Contact';
    con.Email = 'test@test.com';
    con.AccountId = accountId;
    insert con;  
    User uu = new User(firstname = 'ABC',
                       lastName = 'XYZ',
                       email = uniqueName + '@test' + orgId + '.org',
                       Username = uniqueName + '@test' + orgId + '.org',
                       EmailEncodingKey = 'ISO-8859-1',
                       Alias = uniqueName.substring(18, 23),
                       TimeZoneSidKey = 'America/Los_Angeles',
                       LocaleSidKey = 'en_US',
                       LanguageLocaleKey = 'en_US',
                       CommunityNickname = 'nick',
                       IsActive = True,
                       ProfileId = pf.Id,
                       ContactId = null
                      );
    insert uu;
    
    ContactPointAddress testCpa = new ContactPointAddress(
        Name='TestingContactPointAddress',
        ParentId = accountId,
        AddressType = 'Billing',
        IsDefault = true,
        Street = '123 Main St',
        City = 'Brandon',
        State = 'North Carolina',
        PostalCode = '12345',
        Country = 'United States'
    );
    insert testCpa;
    Test.startTest();
    B2B_CYBSPaymentContoller.genrateZeroAmountAuthorizationRequest(sampleJwtToken);
    Test.stopTest();
}*/
    
    @isTest
    static void genrateEnrollmentRequestTest(){
        Account acc = new Account();
        acc.Name = 'Test Name';
        acc.CurrencyIsoCode='USD';
        insert acc;
        WebStore webStr = new WebStore();
        webStr.Name = 'Mkf Store';
        webStr.PricingStrategy = 'LowestPrice';
        insert webStr;
         Profile pf = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ', '').replace(':', '').replace('-', '');
            Integer RandomId = Integer.valueOf(Math.rint(Math.random() * 1000000));
            String uniqueName = orgId + dateString + RandomId;
            
            User uu = new User(firstname = 'ABC',
                               lastName = 'XYZ',
                               email = uniqueName + '@test' + orgId + '.org',
                               Username = uniqueName + '@test' + orgId + '.org',
                               EmailEncodingKey = 'ISO-8859-1',
                               Alias = uniqueName.substring(18, 23),
                               TimeZoneSidKey = 'America/Los_Angeles',
                               LocaleSidKey = 'en_US',
                               LanguageLocaleKey = 'en_US',
                               CommunityNickname = 'nick',
                               IsActive = True,
                               ProfileId = pf.Id,
                               ContactId = null,
                               PortalRole = 'Manager'
                              );
            insert uu;
        WebCart cart = new WebCart(Name = 'current', WebStoreId = webStr.Id, AccountId = acc.Id , Status = 'Active', OwnerId = uu.Id);
        INSERT cart;
        ContactPointAddress testCpa = new ContactPointAddress(
        Name='TestingContactPointAddress',
        ParentId = acc.Id,
        AddressType = 'Billing',
        IsDefault = true,
        Street = '123 Main St',
        City = 'Brandon',
        State = 'North Carolina',
        PostalCode = '12345',
        Country = 'United States'
    );
    insert testCpa;
        Test.startTest();
        B2B_CYBSPaymentContoller.genrateEnrollmentRequest(cart.Id,'testToken',
            null,
            'reference123',
            null);
        Test.stopTest();
        
    }
     @isTest
    static void deletePaymentMethodTest(){
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert cart;
        String contactId = [SELECT ContactId FROM User WHERE Id=:userInfo.getuserId()].ContactId;
         DigitalWallet testDigitalWallet = new DigitalWallet(
            IsDefault__c = true,
            Card_Type__c = 'Visa',
            Display_Card_Number__c = '************1234',
            Contact__c = contactId,
            ExpiryYear__c = 2025,
            ExpiryMonth__c = 12,
            CardHolderName__c = 'John Doe',
            GatewayToken='0190502152701111',
            CardLastFour__c =1111,
            NickName = 'My Wallet',
            Status = 'Active',
            ProcessingMode='External'
        );
        insert testDigitalWallet;
        Test.startTest();
        B2B_CYBSPaymentContoller.deletePaymentMethod('StoredPaymentId');
        Test.stopTest();
    }
      @isTest
    static void updateWalletInfoTest(){
        Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        WebCart cart = new WebCart(Name='Cart', WebStoreId=testWebStore.Id, AccountId=testAccount.Id);
        insert cart;
        String contactId = [SELECT ContactId FROM User WHERE Id=:userInfo.getuserId()].ContactId;
         DigitalWallet testDigitalWallet = new DigitalWallet(
            IsDefault__c = true,
            Card_Type__c = 'Visa',
            Display_Card_Number__c = '************1234',
            Contact__c = contactId,
            ExpiryYear__c = 2025,
            ExpiryMonth__c = 12,
            CardHolderName__c = 'John Doe',
            GatewayToken='0190502152701111',
            CardLastFour__c =1111,
            NickName = 'My Wallet',
            Status = 'Active',
            ProcessingMode='External'
        );
        insert testDigitalWallet;
        Test.startTest();
        B2B_CYBSPaymentContoller.updateWalletInfo(testDigitalWallet.Id);
        Test.stopTest();
    }



    @isTest
    static void testSaveNewCardForInv() {
    // Set up test data
    String token = 'your_jwt_token_here'; // Replace with a valid JWT token
    String expirationMonth = '12';
    String expirationYear = '25';
    String cardholderName = 'John Doe';
    String cardholderNickName = 'My Card';
    String cardType = 'Visa';
    String isJWT = 'true';
    String receiptId = 'receipt123';

    // Call the saveNewCardForInv method
    Test.startTest();
    B2B_CYBSPaymentContoller.saveNewCardForInv(
        token, 
        expirationMonth, 
        expirationYear, 
        cardholderName, 
        cardholderNickName, 
        cardType, 
        isJWT, 
        receiptId
    );
    Test.stopTest();

}
    @isTest(SeeAllData=true)
       static void testRetrieveCommunityId() {
      /*  ConnectApi.CommunityPage communityPage = new ConnectApi.CommunityPage();
        ConnectApi.Community community = new ConnectApi.Community();
        community.id = 'CommunityId123';
        community.templateName = 'YourTemplateName'; // Replace with your desired template name
        communityPage.communities = new List<ConnectApi.Community>{community};

    // Call the retrieveCommunityId method*/
    Test.startTest();
    B2B_CYBSPaymentContoller.retrieveCommunityId();
    Test.stopTest();

}
 @isTest
    static void createPaymentMethod(){
       Account testAccount = new Account(Name='TestAccount');
       insert testAccount;
       String request ='Request';
       String responseBody ='response';
       Map<String, Object> response =  new Map<String, Object>();
       Map<String,String> data = new Map<String,String>();
        data.put('amount','128');
        data.put('accountId',testAccount.Id);
        Test.startTest();
       B2B_CYBSPaymentContoller.createPaymentAuthRecord(request,responseBody,response,data);
        Test.stopTest();
        
    }
    @isTest
    static void deactiveMethod(){
         String contactId = [SELECT ContactId FROM User WHERE Id=:userInfo.getuserId()].ContactId;
         DigitalWallet testDigitalWallet = new DigitalWallet(
            IsDefault__c = true,
            Card_Type__c = 'Visa',
            Display_Card_Number__c = '************1234',
            Contact__c = contactId,
            ExpiryYear__c = 2025,
            ExpiryMonth__c = 12,
            CardHolderName__c = 'John Doe',
            GatewayToken='0190502152701111',
            CardLastFour__c =1111,
            NickName = 'My Wallet',
            Status = 'Active',
            ProcessingMode='External'
        );
        insert testDigitalWallet;
         Test.startTest();
        B2B_CYBSPaymentContoller.deactivatePaymentMethod(testDigitalWallet.Id);
        Test.stopTest();
    }

    @isTest
    static void ZeroAmountAuthor(){
        Test.startTest();
        B2B_CYBSPaymentContoller.ZeroAmountAuthorizationAPI('test','Lauren','Lau','Visa');
        Test.stopTest();
    }
     @isTest
    static void ZeroAmount(){
        Test.startTest();
        B2B_CYBSPaymentContoller.genrateZeroAmountAuthorizationRequest('mockJwtToken');
        Test.stopTest();
    }
/*static void testRetrieveCommunityId() {
    // Create a mock community page object
    ConnectApi.CommunityPage communityPageObject = new ConnectApi.CommunityPage();
    
    // Create a mock community object with the expected template name
    ConnectApi.Community communityObj = new ConnectApi.Community();
    communityObj.id = 'CommunityId123'; // Replace with the expected community ID
    communityObj.templateName = B2BConstants.COMMUNITY_TEMPLATE_NAME;
    
    // Add the community object to the community page object
    communityPageObject.communities = new List<ConnectApi.Community>{communityObj};
    
    // Mock the Communities class and the getCommunities method
   // Test.setMock(ConnectApi.Communities.class, new YourMockClass(communityPageObject));
    
    // Call the retrieveCommunityId method
    Test.startTest();
    String communityId = B2B_CYBSPaymentContoller.retrieveCommunityId();
    Test.stopTest();
    
    // Perform assertions to verify the expected result
    System.assertEquals('CommunityId123', communityId); // Replace with the expected community ID
}*/







  /*  @isTest
    static void testGenerateJsonString() {
        // Create mock data for testing
    String jwtToken = 'your_jwt_token_here'; // Replace with a valid JWT token
    String legacyToken = 'legacyToken123';
    String transactionId = 'transactionId123';
    Map<String, String> liabilityShift = new Map<String, String>{
        'eciRaw' => 'eciRaw123',
        'paresStatus' => 'paresStatus123'
            };
        CommercePayments.AddressRequest adr = new CommercePayments.AddressRequest();
        adr.street = '123 Main St';
        adr.city = 'City';
        adr.state = 'State';
        adr.postalCode = '12345';
        adr.country = 'Country';

    Test.startTest();
    B2B_CYBSPaymentContoller.generateAuthorizationRequest(
        'cartId123',
        jwtToken,
        legacyToken,
        transactionId,
        liabilityShift,
        'USD', // Replace with the appropriate currency code
        adr
    );
    Test.stopTest();

   }*/
    
    /*
    @IsTest
    static void testIsPoOrCreditCard() {
        User newUser = [select Id, name from user where Username= 'john.doe8222023@example.com' Limit 1];
        WebCart testCart = [Select Id from WebCart Where name='Test CART' Limit 1];
        System.runAs(newUser){
        	Map<String, String> result = B2B_CYBSPaymentContoller.isPoOrCreditCart(testCart.Id);
        }
    }
    @IsTest
    static void testIsPoOrCreditCardNonUser() {
        WebCart testCart = [Select Id from WebCart Limit 1];
        	Map<String, String> result = B2B_CYBSPaymentContoller.isPoOrCreditCart(testCart.Id);
    }
    
    
    
    @IsTest
    static void testGetComponentSetup() {
		User newUser = [select Id, name from user where Username= 'john.doe8222023@example.com' Limit 1];
        WebCart testCart = [Select Id from WebCart Where name='Test CART' Limit 1];
        
        HttpCalloutMock mockResponse = new B2B_CYBSPaymentContoller_TestMock();
        
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, mockResponse);
        System.runAs(newUser){
        	Map<String, Object> result = B2B_CYBSPaymentContoller.getComponentSetup(testCart.Id);
        }
        Test.stopTest();
    }
    @IsTest
    static void testGetComponentSetupNoCallout() {
		User newUser = [select Id, name from user where Username= 'john.doe8222023@example.com' Limit 1];
        WebCart testCart = [Select Id from WebCart Where name='Test CART' Limit 1];
        
        
        Test.startTest();
        System.runAs(newUser){
        	Map<String, Object> result1 = B2B_CYBSPaymentContoller.getComponentSetup(null);
        } 
        Test.stopTest();
    }
    
    
     @IsTest
    static void testHandle3DSecurePayerSetUp() {
		User newUser = [select Id, name from user where Username= 'john.doe8222023@example.com' Limit 1];
        WebCart testCart = [Select Id from WebCart Where name='Test CART' Limit 1];
        String mockToken = 'eyJhbGciOiJSUzI1NiIsImtpZCI6IjEifQ.eyJzdWIiOiIzIiwiaXNzIjoiaHR0cDovL2xvY2FsaG9zdDo4MDgwIiwianRpIjoiMjNiZDZlNzUtMWZlYi00ZjY2LTlkNTQtYzExMzg3YWE0YTc4IiwiYXVkIjoiNWU1NDI1ZjBjZDhhMzIzMDUzOTczNzMyIiwiaWF0IjoxNjMyMDg1MjA0LCJleHAiOjE2MzIwODY4MDR9.PiThNY7exk7OLgRBDzFBluLwACga8Q2q96OS83m68X1sKMBq-0fhceYzJjyNHk4w4Z5ck8j_mW87nGwUhPq1Vk9m2Q6rqMwuHj0iWKVQ0oTTOeIhJqS6i76fWxJ3-2J8E7FntSMjsyKolUVKHjEXxXnU6bTDqj6Q71YpydUW2CDvSHeqvmECzWgPZBlK0wHPOYchAuyCVZMpyh--dImvXszcPhQbDMZ8-gfVXw4ScP1mI-fxbEx9YNzXAWWhby1XtdYjQgWLMaXU3MQ5AsQwWEHxtLr99aT-4Yjpuzm9GsDpuXYYbZWUrDL6--eD8w7g6YgJwvDE00DoMSTiKbw';
        HttpCalloutMock mockResponse = new B2B_CYBSPaymentContoller_TestMock();
        
        Test.startTest();
        System.runAs(newUser){
            Test.setMock(HttpCalloutMock.class, mockResponse);
        	Map<String, String> result = B2B_CYBSPaymentContoller.handle3DSecurePayerSetUp(mockToken, testCart.Id, null);
        }
        Test.stopTest();
    }
    @IsTest
    static void testHandle3DSecurePayerSetUpWithLegecy() {
		User newUser = [select Id, name from user where Username= 'john.doe8222023@example.com' Limit 1];
        WebCart testCart = [Select Id from WebCart Where name='Test CART' Limit 1];        
        Test.startTest();
        System.runAs(newUser){
        	Map<String, String> result = B2B_CYBSPaymentContoller.handle3DSecurePayerSetUp(null, testCart.Id, 'mockContent');
        }
        Test.stopTest();
    }
    
    
    @IsTest
    static void testCheckoutStoredPayment3DSecurePayerSetUp() {
        // Prepare test data
        String mockStoredPaymentId = 'mockStoredPaymentId';
        String mockCartId = 'mockCartId';
        
        // Call the method to be tested
        Test.startTest();
        Map<String, String> result = B2B_CYBSPaymentContoller.checkoutStoredPayment3DSecurePayerSetUp(mockStoredPaymentId, mockCartId);
        Test.stopTest();
        
        // Perform assertions to verify the behavior
        // You might need to modify assertions based on your actual implementation
        // For example, if you are testing the actual method, you could verify specific keys in the responseMap
        System.assertEquals(result.get('error'),null, 'should be null');
    }
    
    @IsTest
    static void testhandle3DEnrollmentWithAutorization() {    
        User newUser = [select Id, name from user where Username= 'john.doe8222023@example.com' Limit 1];
        WebCart testCart = [Select Id from WebCart Where name='Test CART' Limit 1];  
        HttpCalloutMock mockResponse = new B2B_CYBSPaymentContoller_TestMock();
        Test.startTest();
        System.runAs(newUser){
            Test.setMock(HttpCalloutMock.class, mockResponse);
        	Map<String, String> result = B2B_CYBSPaymentContoller.handle3DEnrollmentWithAutorization('mockJwtToken', 'mockLegacyToken', testCart.Id, 'mockReferenceId');
        }
        Test.stopTest();
    }
    @IsTest
    static void testhandle3DEnrollmentWithAutorizationLegecyNull() {    
        User newUser = [select Id, name from user where Username= 'john.doe8222023@example.com' Limit 1];
        WebCart testCart = [Select Id from WebCart Where name='Test CART' Limit 1];  
        HttpCalloutMock mockResponse = new B2B_CYBSPaymentContoller_TestMock();
        Test.startTest();
        System.runAs(newUser){
            Test.setMock(HttpCalloutMock.class, mockResponse);
        	Map<String, String> result = B2B_CYBSPaymentContoller.handle3DEnrollmentWithAutorization('mockJwtToken', null, testCart.Id, 'mockReferenceId');
        }
        Test.stopTest();
    }
    @IsTest
    static void testhandle3DEnrollmentWithAutorizationWithoutUser() {    
        Test.startTest();
        	Map<String, String> result = B2B_CYBSPaymentContoller.handle3DEnrollmentWithAutorization('mockJwtToken', 'mockLegacyToken', 'mockCartId', 'mockReferenceId');
        Test.stopTest();
    }
    
    
    @IsTest
    static void testcheckoutStoredPayment3DSecureEnrollment() {    
        Test.startTest();
        	Map<String, String> result = B2B_CYBSPaymentContoller.checkoutStoredPayment3DSecureEnrollment('mockJwtToken', 'mockLegacyToken', 'mockCartId');
        Test.stopTest();
    }*/
}