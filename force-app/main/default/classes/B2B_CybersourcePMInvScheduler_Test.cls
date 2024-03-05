@isTest
public class B2B_CybersourcePMInvScheduler_Test {

    @testSetup
    static void SetupTest() {
        RecordType rt = [SELECT Id FROM RecordType 
                 WHERE SobjectType = 'Account' 
                 AND DeveloperName = 'Vendor' LIMIT 1];
        
        Account account  = new Account(Name='Test Account ',
                                       RecordTypeId = rt.Id,
                                       ShippingCountry = 'United States');
       
            insert account;
         RecordType rt1 = [SELECT Id FROM RecordType 
                 WHERE SobjectType = 'Contact' 
                 AND DeveloperName = 'Zimmer_Standard_Contact' LIMIT 1];
        
        Contact contact  = new Contact(FirstName='Test',
                                       Lastname = 'Name',
                                       AccountId = account.Id,
                                       RecordTypeId = rt1.Id,
                                       Email = 'test.contact123@yopmail.com');
         insert contact;
        UserRole userRole = [SELECT Id FROM UserRole WHERE Name = 'mdata Customer Person Account' LIMIT 1];
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
                               ContactId =null
                              );
            insert uu;
         Id pbId = Test.getStandardPricebookId();
       // Create an Order
       Order order = new Order(
           AccountId = account.Id,
           Pricebook2Id = pbId,
           EffectiveDate = Date.today(),
           OrderedDate = Date.today(),
           Status = 'Draft'
       );
       insert order;
    }

 /*   @isTest
   static void SchedulerTest() {
        Account testAccount=[Select id from Account where Name='Test Account'];
        User uu = [Select id from User where firstname='ABC'];
        Test.startTest();
       
        B2B_CybersourcePMInvScheduler.getTransactionDetails(
            'TestPaymentId',
            'TestPayAuthId',
            'TestCardholderName',
            'TestCardholderNickName',
            'TestCardType',
            uu.Id,
            'TestReceiptId',
            'TestPONumber',
            'TestPMStreet',
            'TestPMCity',
            'TestPMState',
            'TestPMCountry',
            'TestPMPostalCode',
            'TestCurrencyCode',
            false, // Set isTemporary to false for this test
            testAccount.Id,
            null,
            'testuser@example.com',
            '12', // Set expirationMonth and expirationYear as needed
            '25'
        );
        Test.stopTest();
    }*/
    @isTest
    static void deleteOtherMethod(){
        Test.startTest();
        B2B_CybersourcePMInvScheduler.deleteOtherPendingJobs();
        Test.stopTest();
    }
    @isTest
    static void updateToken(){
        Account testAccount = new Account(Name = 'TestAccount');
        insert testAccount;
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'Contact';
        con.Email = 'test@test.com';
        con.AccountId = testAccount.Id;
        insert con; 
        DigitalWallet testDigitalWallet = new DigitalWallet(
            IsDefault__c = true,
            Card_Type__c = 'Visa',
            Display_Card_Number__c = '************1234',
            Contact__c = con.Id,
            ExpiryYear__c = 2025,
            ExpiryMonth__c = 12,
            CardHolderName__c = 'John Doe',
            NickName = 'My Wallet',
            Status = 'Active',
            ProcessingMode='External'
        );
        insert testDigitalWallet;
        Test.startTest();
            B2B_CybersourcePMInvScheduler.updateTokenOnOrder('orderId', testDigitalWallet.Id);
       Test.stopTest();
    }
    @isTest
static void testGetTransactionDetails() {
    // Create a test User and Account for data references
    Account testAccount = new Account(Name = 'TestAccount');
    insert testAccount;
    Contact con = new Contact();
    con.FirstName = 'test';
    con.LastName = 'Contact';
    con.Email = 'test@test.com';
    con.AccountId = testAccount.Id;
    insert con;  
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
                       CommunityNickname = 'nickName',
                       IsActive = True,
                       ProfileId = pf.Id,
                       ContactId = null
                      );
    insert uu;
    

    // Set up test data
    String paymentId = 'TestPaymentId';
    String payAuthId = 'TestPayAuthId';
    String cardholderName = 'John Doe';
    String cardholderNickName = 'My Nickname';
    String cardType = 'Visa';
    String userId = uu.Id;
    String receiptId = 'TestReceiptId';
    String PONumber = 'PO123';
    String PMStreet = '123 Main St';
    String PMCity = 'City';
    String PMState = 'State';
    String PMCountry = 'Country';
    String PMPostalCode = '12345';
    String currencyCode = 'USD';
    Boolean isTemporary = false;
    String accountId = testAccount.Id;
    String contactId = con.Id;
    String email = 'john.doe@example.com';
    String expirationMonth = '12';
    String expirationYear = '2025';
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
    // Call the getTransactionDetails method
     B2B_CybersourcePMInvScheduler.getTransactionDetails(
        paymentId, payAuthId, cardholderName, cardholderNickName, cardType,
        userId, receiptId, PONumber, PMStreet, PMCity, PMState, PMCountry, 
        PMPostalCode, currencyCode, isTemporary, accountId, contactId, 
        email, expirationMonth, expirationYear
    );
    Test.stopTest();
}
}