@isTest

Private Class SurgeonPortalExtensionTest{

    public Static ApexPages.StandardController surgeonController;
    public Static SurgeonPortalExtension surgeon;
    public Static SurgeonPortalDetailExtension surgeonDetail;
    public Static SurgeonPortalDetailExtension surgeonDetail1;
    public Static GPL_Profile__c gpl_Profile;  
    public Static GPL_Location__c gpl_Location;
    public Static GPL_Location__c gpl_Location1;
    public Static Account accountContact;
    public Static Account personAccount;
    public Static Contact contact1;
    public Static Profile adminProfile;
    
    public Static void createSampleData(){
    
    personAccount = new Account();
    ID recordTypeId3 = [select id from RecordType where SObjectType = 'Account' and IsActive = true and Name = 'Physician'].id;
    personAccount.LastName='Account Attendee 1 Test';
    personAccount.AcctInactive__c= false;
    personAccount.FirstName='Test';
    personAccount.RecordTypeId=recordTypeId3;
    personAccount.MDM_SAP_ID__c='7865';
    personAccount.PersonMailingCountry='US';
    personAccount.PersonMailingState='CA';
    personAccount.PersonMailingStreet='Test1 Line1'+'\n'+'Mailing line2'+'\n'+'Mailing line3';
    personAccount.PersonMailingCity='LA';
    personAccount.PersonMailingPostalCode='10106';
    personAccount.Specialty_integration__c='Anterior Approach Hip';
    personAccount.Technique__c= 'Kinectiv';
    personAccount.Expertise_Integration_purpose__c='Shoulder';
    personAccount.Languages__c='English';
    personAccount.Memberships_Associations_Conferences__c='qqqq';
    personAccount.Awards_Honors_Patents__c='aaaa';
    personAccount.Publications_Presentations__c='bbbb';
    
    insert personAccount;
    
    accountContact = new Account();
    ID recordTypeId6 = [select id from RecordType where SObjectType='Account' and Name='Distributor'].id;
    accountContact.Name='Test Account'; 
    accountContact.RecordTypeId=recordTypeId6;
    accountContact.BillingCountry='US';
    accountContact.BillingState='CA';
    accountContact.BillingStreet='Test Line1'+'\n'+'Mailing line2'+'\n'+'Mailing line3';
    accountContact.Distributor_Name__c='Test Distributor Name';
    accountContact.Territory_Number__c='9999';
    insert accountContact;
    
    contact1 = new Contact();
    ID recordTypeId2=[select id from RecordType where SObjectType='Contact' and Name='Sales Contact'].id;
    contact1.LastName='Contact Attendee 2';
    contact1.recordtypeid=recordTypeId2;
    contact1.AccountId=accountContact.id;
    insert contact1;
    
    gpl_Profile = new gpl_Profile__c();
    gpl_Profile.Account__c = personAccount.id;
    //gpl_Profile.Contact__c
    gpl_Profile.Specialties__c = 'Anterior Approach Hip';
    gpl_Profile.Procedures__c = 'Shoulder';
    insert gpl_Profile;
    
    gpl_Location = new gpl_Location__c();
    gpl_Location.GPL_Profile__c = gpl_Profile.id;
    gpl_Location.Name__c = 'LA';
    gpl_Location.City__c = 'Warsaw';
    gpl_Location.Country__c = 'US';
    gpl_Location.PostalCode__c = '154785';
    gpl_Location.State__c = 'CA';
    gpl_Location.Street__c = '1800 W A street';
    insert gpl_Location; 
    
    }

    public static User userAdmin1
    
    {
        get{
            if (userAdmin1 == null )
            {
                adminProfile = [Select Id, Name From Profile where name = 'System Admin' limit 1];
                userAdmin1  = new user (Username = ' test@key.net', FirstName = 'FirstTest', LastName ='LastTest', alias = 'FLast', 
                            email='test@key.net', communityNickname='test0101019', TimeZoneSidKey='America/Indianapolis',
                            LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', ProfileId=adminProfile.Id ,
                            LanguageLocaleKey='en_US',Region__c='AM', Geography__c='US', Business_Division__c='DN', ContactId=contact1.Id);
                insert userAdmin1;             
             }
             return userAdmin1;
            }
        set;
    }
    
    public static User userAdmin2
    
    {
        get{
            if (userAdmin2 == null )
            {
                adminProfile = [Select Id, Name From Profile where name = 'System Admin' limit 1];
                userAdmin2  = new user (Username = ' test@key.net', FirstName = 'FirstTest', LastName ='LastTest', alias = 'FLast', 
                            email='test@key.net', communityNickname='test0101019', TimeZoneSidKey='America/Indianapolis',
                            LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', ProfileId=adminProfile.Id ,
                            LanguageLocaleKey='en_US',Region__c='AM', Geography__c='US', Business_Division__c='DN', ContactId=personAccount.PersonContactId);
                insert userAdmin2;             
             }
             return userAdmin2;
            }
        set;
    }
    
    private Static Void initSurgeonPortalExtension()
    {
        
         createSampleData();         
         surgeonController = new ApexPages.StandardController(gpl_Profile);
         surgeon = new SurgeonPortalExtension(surgeonController); 
         //system.assertEquals(expenseTest1.HCP_Status__c,'Not Submitted');
    }
    
    private Static Void initSurgeonPortalDetailExtension()
    {
        
         createSampleData();         
         surgeonController = new ApexPages.StandardController(gpl_Location);
         surgeonDetail = new SurgeonPortalDetailExtension(surgeonController); 
         //system.assertEquals(expenseTest1.HCP_Status__c,'Not Submitted');
    }
    
    public Static testmethod void surgeonPortalTest(){
    
    test.startTest();
    
    initSurgeonPortalExtension();
    ApexPages.currentPage().getParameters().put('SurgeonId', contact1.Id);
    surgeon.loadSurgeonData(contact1.Id);
    surgeon.doAction();
    ApexPages.currentPage().getParameters().put('returnURL', 'http://apex');
    surgeon.edit();
    surgeon.save();
    surgeon.newLocation();
    
    Id b;
    for(Account a : [select PersonContactId from Account where id=:personAccount.id] )
    {
        b= a.PersonContactId;
    }
    
    system.assertNotEquals(b, Null );
    surgeon.loadSurgeonData(b);
    
    GPLProfileAccountRecordHelper.hasAlreadyUpdatedGPLProfile ();
    
    personAccount.Specialty_integration__c='MIS Mini';
    personAccount.Technique__c= 'Alloclasic';
    personAccount.Expertise_Integration_purpose__c='Knee';
    personAccount.Languages__c='Spanish';
    personAccount.Memberships_Associations_Conferences__c='www';
    personAccount.Awards_Honors_Patents__c='bbbb';
    personAccount.Publications_Presentations__c='ccc';
    update personAccount;
    
    
    gpl_Location__c gpl_Location2= new gpl_Location__c();
    gpl_Location2.GPL_Profile__c = gpl_Profile.id;
    gpl_Location2.Name__c = 'LA';
    gpl_Location2.City__c = 'Warsaw';
    gpl_Location2.Country__c = 'US';
    gpl_Location2.PostalCode__c = '154785';
    gpl_Location2.State__c = 'CA';
    gpl_Location2.Street__c = '1800 W A street';
    insert gpl_Location2; 
        
    //surgeon.deleteLocation();
    
    //ApexPages.currentPage().getParameters().put('locationid', gpl_Location.id);
    //SurgeonPortalExtension sp = new SurgeonPortalExtension(); 
    //Apexclasses.put('SelectedLocationId', gpl_Location.id);
    
    surgeon.deleteLocation();
    surgeon.UploadPhoto();
    surgeon.getLt();
    surgeon.getGt();
    
    test.stopTest();
    
    }
    
     public Static testmethod void surgeonPortalDetailTest()
     {
     
     test.startTest();
     initSurgeonPortalDetailExtension();
     ApexPages.currentPage().getParameters().put('returnURL', 'http://apex');
     surgeonDetail.edit();
     surgeonDetail.save();
     surgeonDetail.doClose();
     
     gpl_Location1 = new gpl_Location__c();
     gpl_Location1.GPL_Profile__c = gpl_Profile.id;
     gpl_Location1.Name__c = 'LA';
     gpl_Location1.City__c = 'Warsaw';
     gpl_Location1.Country__c = 'US';
     gpl_Location1.PostalCode__c = '154785';
     gpl_Location1.State__c = 'CA';
     gpl_Location1.Street__c = '1800 W A street';
     gpl_Location.Fax__c='(111)111-1111';
     gpl_Location.Phone__c='(222)222-2222';
     gpl_Location.PostalCode__c='12as';
     update gpl_Location;
     
     surgeonDetail.save();
     
     surgeonController = new ApexPages.StandardController(gpl_Location1);
     surgeonDetail1 = new SurgeonPortalDetailExtension(surgeonController);
     surgeonDetail1.save();
     test.stoptest();
     
     }        
}