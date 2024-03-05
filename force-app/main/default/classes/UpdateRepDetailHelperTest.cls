@isTest
public class UpdateRepDetailHelperTest {
@testSetup
    static void createdata(){
        String dnNameMktgRecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByDeveloperName().get('DN_NAM_MKTG').getRecordTypeId();
        List<DN_Zip_Code_Lookup__c> dNZipCodeLookupToInsert = new List<DN_Zip_Code_Lookup__c>();
        DN_Zip_Code_Lookup__c dNZipCodeLookup = new DN_Zip_Code_Lookup__c();
        dNZipCodeLookup.Name='10';
        dNZipCodeLookup.Zip_Code__c	='10';
        dNZipCodeLookup.Salesforce_Alias__c='test12';
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
    
    @isTest
    static void testvalidAliasDNZipupdate(){
        String profileId = [Select id from Profile where Name='System Administrator'].Id;
        User testUser1 = UpdateDNZipCodeRepNameTest.createTestempUser(profileId,'testF','testL','test_013');
        DN_Zip_Code_Lookup__c dnZipCoderecord = [Select id,Rep_Name__c,Salesforce_Alias__c from DN_Zip_Code_Lookup__c Where Name='10'];
        Insert testUser1;
        test.startTest();
        dnZipCoderecord.Salesforce_Alias__c = 'test_013';
        Update dnZipCoderecord;
        test.stopTest();
        DN_Zip_Code_Lookup__c recordAfterUpdate = [Select id,Rep_Name__c from DN_Zip_Code_Lookup__c Where Name='10'];
        Lead leadAfterUpdate = [Select Co_Owner__c,Secondary_Co_Owner__c from lead];
        System.assertEquals(testUser1.Id, recordAfterUpdate.Rep_Name__c);
        System.assertEquals(testUser1.Id, leadAfterUpdate.Co_Owner__c);
        System.assertEquals(null, leadAfterUpdate.Secondary_Co_Owner__c);
    }
    
    @isTest
    static void testInvalidAliasDNZipupdate(){
        String profileId = [Select id from Profile where Name='System Administrator'].Id;
        User testUser1 = UpdateDNZipCodeRepNameTest.createTestempUser(profileId,'testF','testL','test_013');
        DN_Zip_Code_Lookup__c dnZipCoderecord = [Select id,Rep_Name__c,Salesforce_Alias__c from DN_Zip_Code_Lookup__c Where Name='10'];
        Insert testUser1;
        test.startTest();
        dnZipCoderecord.Salesforce_Alias__c = 'test_013';
        Update dnZipCoderecord;
        dnZipCoderecord.Salesforce_Alias__c = 'test_01';
        Update dnZipCoderecord;
        test.stopTest();
        DN_Zip_Code_Lookup__c recordAfterUpdate = [Select id,Rep_Name__c,Salesforce_Alias__c from DN_Zip_Code_Lookup__c Where Name='10'];
        Lead leadAfterUpdate = [Select Co_Owner__c,Secondary_Co_Owner__c from lead];
        System.assertEquals(null, recordAfterUpdate.Rep_Name__c);
        //System.assertEquals(null, leadAfterUpdate.Co_Owner__c);
        System.assertEquals(null, leadAfterUpdate.Secondary_Co_Owner__c);
    }
}