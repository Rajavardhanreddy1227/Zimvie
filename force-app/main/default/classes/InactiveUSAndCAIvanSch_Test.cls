@isTest
public class InactiveUSAndCAIvanSch_Test {
    @testSetup static void setup() {
        
       US_CA_Ivan_Report_Recipient__c recp1 = new US_CA_Ivan_Report_Recipient__c();
        recp1.Name = 'Recipient 1';
        recp1.Email__c = 'mohit.gulati@zimmerbiomet.com';
        insert recp1;
    }
    
    public static testMethod void UnitTest01() {
        
        list<Contact>contList = new list<Contact>();
        
        //get sales contact record type Id
        Id salescontactrecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales Contact').getRecordTypeId();
        Id DistributerAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Distributor');
        
        Account acc= new Account();
       // acc.RecordTypeId = '012800000002ByT';//Distributor Account Rec Type
        acc.RecordTypeId = DistributerAccountTypeId;
        acc.Name = 'Test Account';
        insert acc;
        
        for(integer i=0;i<5;i++)
        {
            Contact con1 = new contact();
            con1.FirstName = 'Test';
            con1.LastName = 'Record-0'+i;
            con1.RecordTypeId = salescontactrecordtypeId;
            con1.Role_Classification__c = 'Sales Associate';
            con1.AD_Username__c = 'Record-0'+i;
            con1.AccountId = acc.Id;
            con1.Hire_Date__c = date.today().addDays(-180);
            con1.Term_Date__c = date.today().addDays(-7);
            con1.Term_Date_Changed__c = TRUE;
            con1.Is_Reported__c=FALSE;
            con1.Term_Date_Modified_On__c = date.today().addDays(-7);
            
            contList.add(con1);
        }
        insert contList;
        
         for(Contact c : [SELECT Id, Name,Term_Date__c,AccountId,Term_Date_Modified_On__c,CreatedDate,Term_Date_Changed__c,Is_Reported__c,Role_Classification__c from Contact WHERE AccountId=:acc.Id])
        { 
            system.debug('Contact TDM-1 :'+ c.Term_Date_Modified_On__c);
            system.debug('Contact CD-1 :'+ c.CreatedDate);
            system.debug('Contact TermDateChanged-1 :'+ c.Term_Date_Changed__c);
            system.debug('Contact IsReported-1 :'+ c.Is_Reported__c);
            system.debug('Contact RoleClassification-1 :'+ c.Role_Classification__c);
        }
        
        Test.startTest();
  
        InactiveUSAndCAIvan_Scheduler emailSch = new InactiveUSAndCAIvan_Scheduler();
        String sch = '0 0 7 * * ?'; 
        System.schedule('Test InactiveUSAndCAIvan Report', sch, emailSch);
        
        Test.stopTest(); 
    }
    
    public static testMethod void unitTest02()
    {
        list<Contact>contList = new list<Contact>();
        
        //get sales contact record type Id
        Id salescontactrecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales Contact').getRecordTypeId();
        Id DistributerAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Distributor');
        
        Account acc= new Account();
      //  acc.RecordTypeId = '012800000002ByT';//Distributor Account Rec Type
        acc.RecordTypeId = DistributerAccountTypeId;
        acc.Name = 'Test Account';
        insert acc;
        
        for(integer i=0;i<5;i++)
        {
            Contact con = new contact();
            con.FirstName = 'Test';
            con.LastName = 'Record-0'+i;
            con.RecordTypeId = salescontactrecordtypeId;
            con.Role_Classification__c = 'Sales Associate';
            con.AD_Username__c = 'Record-0'+i;
            con.AccountId = acc.Id;
            con.Hire_Date__c = date.today().addDays(-180);
            con.Term_Date__c = date.today().addDays(-20);
            con.Term_Date_Changed__c = TRUE;
            con.Is_Reported__c=FALSE;
            con.Term_Date_Modified_On__c = date.today().addDays(-9);
            
            contList.add(con);
        }
        insert contList;
        
        for(Contact c : [SELECT Id, Name,Term_Date__c,AccountId,Term_Date_Modified_On__c,Term_Date_Changed__c,Is_Reported__c,Role_Classification__c from Contact WHERE AccountId=:acc.Id])
        {
            system.debug('Contact TMD-2 :'+ c.Term_Date_Modified_On__c);
            system.debug('Contact TermDateChanged-2 :'+ c.Term_Date_Changed__c);
            system.debug('Contact IsReported-2 :'+ c.Is_Reported__c);
            system.debug('Contact RoleClassification-2 :'+ c.Role_Classification__c);
        }
        
        Test.startTest();
               
        InactiveUSAndCAIvan_Scheduler emailSch = new InactiveUSAndCAIvan_Scheduler();
        String sch = '0 0 7 * * ?'; 
        System.schedule('Test InactiveUSAndCAIvan Report', sch, emailSch);
        
        Test.stopTest(); 
    }
    
    public static testMethod void unitTest03()
    {
        list<Contact>contList = new list<Contact>();
        
        //get sales contact record type Id
        Id salescontactrecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales Contact').getRecordTypeId();
        Id DistributerAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Distributor');
        
        Account acc= new Account();
      //  acc.RecordTypeId = '012800000002ByT';//Distributor Account Rec Type
        acc.RecordTypeId = DistributerAccountTypeId;
        acc.Name = 'Test Account';
        insert acc;
        
        for(integer i=0;i<5;i++)
        {
            Contact con = new contact();
            con.FirstName = 'Test';
            con.LastName = 'Record-0'+i;
            con.RecordTypeId = salescontactrecordtypeId;
            con.Role_Classification__c = 'Sales Associate';
            //con.AD_Username__c = 'Record-0'+i;
            con.AccountId = acc.Id;
            con.Hire_Date__c = date.today().addDays(-180);
            con.Term_Date__c = date.today().addDays(-20);
            con.Term_Date_Changed__c = TRUE;
            con.Is_Reported__c=FALSE;
            con.Term_Date_Modified_On__c = date.today().addDays(-20);
            
            contList.add(con);
        }
        insert contList;
        
        for(Contact c : [SELECT Id, Name,Term_Date__c,AccountId,Term_Date_Modified_On__c,Term_Date_Changed__c,Is_Reported__c,Role_Classification__c from Contact WHERE AccountId=:acc.Id])
        {
			
            system.debug('Contact TMD-3 :'+ c.Term_Date_Modified_On__c);
            system.debug('Contact TermDateChanged-3 :'+ c.Term_Date_Changed__c);
            system.debug('Contact IsReported-3 :'+ c.Is_Reported__c);
            system.debug('Contact RoleClassification-3 :'+ c.Role_Classification__c);
        }
        
        Test.startTest();
        
        InactiveUSAndCAIvan_Scheduler emailSch = new InactiveUSAndCAIvan_Scheduler();
        String sch = '0 0 7 * * ?'; 
        System.schedule('Test InactiveUSAndCAIvan Report', sch, emailSch);
        
        Test.stopTest(); 
    }
}