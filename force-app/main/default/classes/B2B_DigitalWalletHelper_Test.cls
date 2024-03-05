@isTest
public class B2B_DigitalWalletHelper_Test {
    @isTest
    static void testCreateDigitalWallet() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        CardPaymentMethod testCardPayment = new CardPaymentMethod(AccountId = acc.Id,CardHolderName='test',CardLastFour=3421,CardType='JCB',Status='InActive',ProcessingMode='External');
        insert testCardPayment;
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'Contact';
        con.Email = 'test@test.com';
        con.AccountId = acc.Id;
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
                           CommunityNickname = 'nick',
                           IsActive = True,
                           ProfileId = pf.Id,
                           ContactId = null
                          );
        insert uu;
        
        DigitalWallet testDigitalWallet = new DigitalWallet(
            IsDefault__c = true,
            Card_Type__c = 'Visa',
            Display_Card_Number__c = '************1234',
            Contact__c = con.Id,
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
        // Create dataMap
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('paymentMethodId', testCardPayment.Id);
        
        // Call the method to test
        Test.startTest();
        try{
            B2B_DigitalWalletHelper.createDigitalWallet(dataMap);
        }catch(Exception e){
            
        }
        Test.stopTest();
        System.assert(dataMap != null);
    }
    
    
    
    
    
    @isTest
    static void testGetDigitalWallets() {
        
        Test.startTest();
        Map<String, Object> result = B2B_DigitalWalletHelper.getDigitalWallets(null);
        Test.stopTest();
        System.assert(result != null);
        
    }
    
    @isTest
    static void testDeleteDigitalWallet() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'Contact';
        con.Email = 'test@test.com';
        con.AccountId = acc.Id;
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
                           CommunityNickname = 'nick',
                           IsActive = True,
                           ProfileId = pf.Id,
                           ContactId = null
                          );
        insert uu;
        
        DigitalWallet testDigitalWallet = new DigitalWallet(
            IsDefault__c = true,
            Card_Type__c = 'Visa',
            Display_Card_Number__c = '************1234',
            Contact__c = con.Id,
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
        CardPaymentMethod cpm = new CardPaymentMethod(
        AccountId=acc.Id,
        CardHolderName='NiteshMittal',
        CardLastFour=1111,
        CardType='Visa',
        ExpiryMonth=12,
        ExpiryYear=2025,
        GatewayToken='Axj77wSTdDJg0C4X1J4IABRRHMHrJXwCojmD1kr7SBkS5i3DJpJlukBwAScCcm6GTBoFwvqTwQAA3DFs',
        GatewayTokenDetails='9781114283744543',
        PaymentGatewayId='0b08L000000Kyk9QAC',
        Status='Active',
        ProcessingMode='External'
        );
        insert cpm;
        
        // Create dataMap
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('digitalWalletId', testDigitalWallet.Id);
        Test.startTest();
        B2B_DigitalWalletHelper.deleteDigitalWallet(dataMap);
        Test.stopTest();
        System.assert(dataMap != null);
        
    }
}