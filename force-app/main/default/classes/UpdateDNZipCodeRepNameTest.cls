@isTest
public class UpdateDNZipCodeRepNameTest {
    @testSetup
    static void createdata(){
        String dnNameMktgRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('DN_NAM_MKTG').getRecordTypeId();
        List<DN_Zip_Code_Lookup__c> dNZipCodeLookupToInsert = new List<DN_Zip_Code_Lookup__c>();
        DN_Zip_Code_Lookup__c dNZipCodeLookup = new DN_Zip_Code_Lookup__c();
        dNZipCodeLookup.Name='10';
        dNZipCodeLookup.Zip_Code__c	='10';
        dNZipCodeLookup.Salesforce_Alias__c='test_013';
        dNZipCodeLookupToInsert.add(dNZipCodeLookup);
        
        DN_Zip_Code_Lookup__c dNZipCodeLookup1 = new DN_Zip_Code_Lookup__c();
        dNZipCodeLookup1.Name='11';
        dNZipCodeLookup1.Zip_Code__c	='11';
        dNZipCodeLookup1.Salesforce_Alias__c='test1';
        
        dNZipCodeLookupToInsert.add(dNZipCodeLookup1);
        
        Insert dNZipCodeLookupToInsert;
        
        Lead lead = new Lead(
            RecordTypeId = dnNameMktgRecordTypeId,
            FirstName = 'First Name',
            LastName = 'Last Name',
            NPI__c = '7777777777',
            DN_Zip_Code_Lookup__c =dNZipCodeLookup.Id
        );
        insert lead;
    }
    public static User createTestempUser(Id profID, String fName, String lName,String alias) {  
        
        String orgId = UserInfo.getOrganizationId();  
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');  
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));  
        String uniqueName = orgId + dateString + randomInt;  
        User tempUser = new User(  FirstName = fName,  LastName = lName, email = uniqueName + '@test' + orgId + '.org',Username = uniqueName + '@test' + orgId + '.org',  EmailEncodingKey = 'ISO-8859-1',Alias = alias,TimeZoneSidKey = 'America/Los_Angeles',LocaleSidKey = 'en_US',LanguageLocaleKey = 'en_US',ProfileId = profId);  
        return tempUser;  
        
    }  
    
    
    @isTest
    static void testDNZipandLead(){
        String profileId = [Select id from Profile where Name='System Administrator'].Id;
        User testUser1 = createTestempUser(profileId,'testF','testL','test1');
        Insert testUser1;
        
        test.startTest();
        testUser1.Alias = 'test_013';
        Update testUser1;
        test.stopTest();
        DN_Zip_Code_Lookup__c recordAfterUpdate = [Select id,Rep_Name__c from DN_Zip_Code_Lookup__c Where Name='10'];
        DN_Zip_Code_Lookup__c recordAfterUpdate2 = [Select id,Salesforce_Alias__c,Rep_Name__c from DN_Zip_Code_Lookup__c Where Name='11'];
        Lead leadAfterUpdate = [Select Co_Owner__c,Secondary_Co_Owner__c from lead];
        System.assertEquals(testUser1.Id, recordAfterUpdate.Rep_Name__c);
        System.assertEquals(testUser1.Id, leadAfterUpdate.Co_Owner__c);
        System.assertEquals(null, leadAfterUpdate.Secondary_Co_Owner__c);
        System.assertEquals(null, recordAfterUpdate2.Rep_Name__c);
        //System.assertEquals(null, recordAfterUpdate2.Salesforce_Alias__c);
    }
    
     @isTest
    static void testmanagerUpdate(){
        String profileId = [Select id from Profile where Name='System Administrator'].Id;
        User testUser1 = createTestempUser(profileId,'testF','testL','test1');
        Insert testUser1;
        User testUser2 = createTestempUser(profileId,'testF1','testL1','test11');
        Insert testUser2;
        
        test.startTest();
        testUser2.Alias ='test_013';
        testUser2.managerId = testUser1.id;
        Update testUser2;
        test.stopTest();
        Lead leadAfterUpdate = [Select Co_Owner__c,Secondary_Co_Owner__c from lead];
        System.assertEquals(testUser2.Id, leadAfterUpdate.Co_Owner__c);
        System.assertEquals(testUser1.Id, leadAfterUpdate.Secondary_Co_Owner__c);
    }
    
    
}