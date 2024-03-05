@isTest
public class TestContactTriggerHandler {
    //Changing hardcoded profile from US Ortho SF Platform User to US Rosa Sales and Service

    @testSetup static void setup() {
        
        Trigger_Settings__c cs = new Trigger_Settings__c();
        cs.Name = 'AddUsersToPSQueues Trigger';
        cs.Active__c = true;
        insert cs; 
        
        //CreateUserAccountfromContact Trigger
        Trigger_Settings__c cs1 = new Trigger_Settings__c();
        cs1.Name = 'CreateUserAccountfromContact Trigger';
        cs1.Active__c = true;
        insert cs1;         
        
        Error_Notification_Recipient__c enr1 = new Error_Notification_Recipient__c();
        enr1.Name = 'Recipient1';
        enr1.Email__c = 'mohit.gulati@zimmerbiomet.com';
        insert enr1; 
        
        Error_Notification_Recipient__c enr2 = new Error_Notification_Recipient__c();
        enr2.Name = 'Recipient2';
        enr2.Email__c = 'mohitgulati41@gmail.com';
        insert enr2; 
        
        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName=uniqueUserName);
        
        system.runAs(u){
            
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            
            Profile p1 = [SELECT ID FROM profile WHERE name='US Rosa Sales and Service'];
            
            User u1 = new User(Alias ='ZB05', Email='TestContactTriggerHandler@zb3.com', IsActive=FALSE,
                               EmailEncodingKey='UTF-8', LastName='ZBUser', LanguageLocaleKey='en_US', 
                               LocaleSidKey='en_US', ProfileId = p1.Id, 
                               TimeZoneSidKey='America/Los_Angeles', UserName=uniqueName+'@test'+ orgId+'.com');
            insert u1;
        }
        
    }
    
    public static testMethod void TestUserCreationWithContact()
    {
        test.startTest();
        
        Id devRecordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Distributor').getRecordTypeId();
        Account acc = new Account(Name = 'testAccount',RecordTypeId =devRecordTypeId1,Distributor_Specialties__c = 'Reconstructive');
        insert acc;
        
        
        Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales Contact').getRecordTypeId();
        list<Contact> conList = new List<contact>();
        
        for(Integer i=1; i<=5; i++){
            Contact cont =  new Contact(FirstName= 'test',LastName='Contact'+i,Email='TestContactTriggerHandler@zimmerbiometrohit.com'+i,
                                        RecordTypeId=devRecordTypeId,
                                        Sales_Assoc_ID__c='ROH09',
                                        AccountID = acc.ID,
                                        Hire_Date__c=System.today(),
                                        AD_Username__c = 'test',
                                        Role_Classification__c ='Distributor'); 
            conList.add(cont);
        }
        
        Contact cont1 =  new Contact(FirstName= 'test',LastName='Contact2',Email='TestContactTriggerHandler@zimmerbiometrohit.com2',
                                     RecordTypeId=devRecordTypeId,
                                     Sales_Assoc_ID__c='ROH09',
                                     AccountID = acc.ID,
                                     Hire_Date__c=System.today(),
                                     AD_Username__c = 'test',
                                     Role_Classification__c ='Sales Manager with accounts'); 
        conList.add(cont1);
        
        Contact cont3 =  new Contact(FirstName= 'test',LastName='Contact3',Email='TestContactTriggerHandler@zb3.com',
                                     RecordTypeId=devRecordTypeId,
                                     Sales_Assoc_ID__c='ZB05',
                                     AccountID = acc.ID,
                                     Hire_Date__c=System.today().addDays(-7),
                                     AD_Username__c = 'ZB',
                                     Role_Classification__c ='Sales Manager with accounts'); 
        conList.add(cont3);
        
        
        insert conList;
        
        
        test.stopTest();                       
    }     
}