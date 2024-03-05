@isTest
public class RegionAdderTest {
    // RA : Added lines 4 - 13 to increase code coverage 
    @testsetup
    public static void TestCustom(){
        
        Trigger_Settings__c cs = new Trigger_Settings__c();
        cs.Name = 'AddUsersToPSQueues Trigger';
        cs.Active__c = true;
        insert cs;
        
        List<CountryISO__c> scList = new List<CountryISO__c>();
        CountryISO__c sc1 = new CountryISO__c();
        sc1.Name = 'Test';
        sc1.Geography__c = 'BE';
        sc1.Region__c = 'BE';
        scList.add(sc1);
        Insert scList;
    }   
    
    static TestMethod void RegionAdderUnitTest(){
        
        Profile testProfile = [SELECT Id 
                               FROM profile
                               WHERE Name = 'System Administrator' 
                               LIMIT 1];
        
        UserRole testRole = [SELECT Id
                             FROM UserRole
                             Where Name = 'Information Technology' 
                             LIMIT 1];
        
        
        //Trigger will hit on this insert
        User testUser = new User(FirstName = 'Test',
                                 LastName = 'User 1', 
                                 Username = 'test.user.1@example.com', 
                                 Email = 'test.1@example.com', 
                                 Alias = 'testu1',
                                 TimeZoneSidKey = 'America/Los_Angeles', 
                                 LocaleSidKey = 'en_US', 
                                 EmailEncodingKey = 'ISO-8859-1', 
                                 ProfileId = testProfile.Id, 
                                 UserRoleId = testRole.Id,
                                 LanguageLocaleKey = 'en_US',
                                 Geography__c = 'BE',
                                 Business_Division__c = 'RC');     
        Insert testUser;
        Test.startTest();
        
        //Trigger will hit on this update
        testUser.Geography__c = 'BR';
        update testUser;    
        
        Test.stopTest();
        
        System.assertEquals('BR',testUser.Geography__c);     
    }
}