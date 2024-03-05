@isTest
public class UpdateSalesContactOnUser_Scheduler_Test {  
    
    @testSetup static void setup() {
      //  List<Contact_To_User_Contact_Record_Types__c> CRType_List = new list<Contact_To_User_Contact_Record_Types__c>();
        List<Contact_To_User_Profiles__c> uProfile_List = new list<Contact_To_User_Profiles__c>();
        List<Trigger_Settings__c> tsList = new List<Trigger_Settings__c>();
       
        Contact_To_User_Batch_Recipient__c rec = new Contact_To_User_Batch_Recipient__c();
        rec.Name = 'Recipient 1';
        rec.Email__c = 'mohit.gulati@zimmerbiomet.com';
        insert rec;
        
        Contact_To_User_Profiles__c usrProfile = new Contact_To_User_Profiles__c();
        usrProfile.Name = 'AM-US- Surgeon Maintenance Users';
        usrProfile.Profile_Id__c = '00eC0000001Skq9';
        uProfile_List.add(usrProfile);
        
        Contact_To_User_Profiles__c usrProfile1 = new Contact_To_User_Profiles__c();
        usrProfile1.Name = 'AM-US-Sales Management';
        usrProfile1.Profile_Id__c = '00eC0000001SrVA';
        uProfile_List.add(usrProfile1);
        
        Contact_To_User_Profiles__c usrProfile2 = new Contact_To_User_Profiles__c();
        usrProfile2.Name = 'Custom-Zimmer Sales';
        usrProfile2.Profile_Id__c = '00e80000000tnIn';
        uProfile_List.add(usrProfile2);
        
        Contact_To_User_Profiles__c usrProfile3 = new Contact_To_User_Profiles__c();
        usrProfile3.Name = 'US Ortho SF Platform User';
        usrProfile3.Profile_Id__c = '00e3b000001TRWw';
        uProfile_List.add(usrProfile3);
        
        insert uProfile_List;
        
        Trigger_Settings__c cs = new Trigger_Settings__c();
        cs.Name = 'AddUsersToPSQueues Trigger';
        cs.Active__c = true;
        tsList.add(cs);
        
        //CreateUserAccountfromContact Trigger
        Trigger_Settings__c cs1 = new Trigger_Settings__c();
        cs1.Name = 'CreateUserAccountfromContact Trigger';
        cs1.Active__c = true;
        tsList.add(cs1);
        
        insert tsList;
        
        Error_Notification_Recipient__c errorNotify = new Error_Notification_Recipient__c();
        errorNotify.Name = 'Recp 1';
        errorNotify.Email__c = 'mohit.gulati@zimmerbiomet.com';
        insert errorNotify;
            
            Date dt = date.today().addDays(-7);
            
            list<Contact> contList = new list<Contact>();
            list<User> insertusers = new list<User>();
            
            //get sales contact record type Id
            Id salescontactrecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales Contact').getRecordTypeId();
            
            system.debug(' checking on contact recordtype:' +salescontactrecordtypeId);
            Id DisAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Distributor');
            
            Account acc= new Account();
            acc.RecordTypeId = DisAccountTypeId;
         //   acc.RecordTypeId = '012800000002ByT';//Distributor Account Rec Type
            acc.Name = 'Test Account';
            acc.Distributor_Specialties__c = 'Reconstructive';
            insert acc;
            
            system.debug(' checking on account:' +acc);
            
            for(integer i=0;i<5;i++) {
                Contact con = new contact();
                con.FirstName = 'Test';
                con.LastName = 'Record-0'+i;
                con.RecordTypeId = salescontactrecordtypeId;
                con.Role_Classification__c = 'Sales Associate';
                con.AD_Username__c = 'Record-0'+i;
                con.AccountId = acc.Id;
                con.Hire_Date__c = date.today().addDays(-7);
                con.Email = 'Test_Trigger'+i+'@gmail.com';
                con.Sales_Assoc_ID__c = '5555'+i;
                con.Sales_Specialty__c = 'Sports';
                con.Employee_Non_Employee__c = 'No';
                
            system.debug('checking on contact' +con);
                
               contList.add(con);
            }
            system.debug('checking on contact' +contList);
            insert contList;
        
        system.debug(' checking out');
    }
     
    public static testMethod void UnitTest01() {
        system.debug('checking I am in unit01');
        Test.startTest();
		system.debug('checking I am in unit1');
        
        Account a = [Select Id, Name from Account Where Name=:'Test Account' Limit 1];
        
        system.debug(' check account:' +a.ID);
        
        Contact c = [Select Id, Name, Email, AccountId from Contact Where AccountId=:a.Id Limit 1];
        
         system.debug(' check contact:' +c.ID);
        
        User u1 = [Select Id, Name , Email, Contact_to_user__c,ProfileId,IsActive From User
                   Where Email=:c.Email Limit 1];
        u1.Contact_to_user__c = '';
        update u1;
        
        
        UpdateSalesContactOnUser_Scheduler emailSch = new UpdateSalesContactOnUser_Scheduler();
        String sch = '0 0 7 * * ?'; 
        System.schedule('Test UpdateSalesContactOnUser', sch, emailSch);
        
        Test.stopTest(); 
        
    }
    
     public static testMethod void UnitTest02() {
        system.debug('checking I am in unit02');
        Test.startTest();
        
        UpdateSalesContactOnUser_Scheduler emailSch = new UpdateSalesContactOnUser_Scheduler();
        String sch = '0 0 7 * * ?'; 
        System.schedule('Test UpdateSalesContactOnUser', sch, emailSch);
        
        Test.stopTest(); 
        
    }
    
    public static testMethod void UnitTest03() {
        system.debug('checking I am in unit03');
        Test.startTest();
        
        Map<String, Contact_To_User_Profiles__c> csMap = Contact_To_User_Profiles__c.getAll();
        List<Contact_To_User_Profiles__c> csList = csMap.values();
        
        delete csList;
        
        Account a = [Select Id, Name from Account Where Name=:'Test Account' Limit 1];
        
        Contact c = [Select Id, Name, Email, AccountId from Contact Where AccountId=:a.Id Limit 1];
        
        User u1 = [Select Id, Name , Email, Contact_to_user__c,ProfileId,IsActive From User
                   Where Email=:c.Email Limit 1];
        u1.Contact_to_user__c = '';
        update u1;
        
        UpdateSalesContactOnUser_Scheduler emailSch = new UpdateSalesContactOnUser_Scheduler();
        String sch = '0 0 7 * * ?'; 
        System.schedule('Test UpdateSalesContactOnUser', sch, emailSch);
        
        Test.stopTest(); 
        
    }
}