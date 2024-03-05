@isTest
public class USReconAndCAIvanSch_Test 
{    

     @testSetup static void setup() {
        
        US_CA_Ivan_Report_Recipient__c recp1 = new US_CA_Ivan_Report_Recipient__c();
        recp1.Name = 'Recipient 1';
        recp1.Email__c = 'mohit.gulati@zimmerbiomet.com';
        insert recp1;
    }
    
    public static testMethod void UnitTest01() {
        
        Date dt = date.today().addDays(-7);
        
        list<Contact>contList = new list<Contact>();
        
        //get sales contact record type Id
        Id salescontactrecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales Contact').getRecordTypeId();
        Id DisAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Distributor');
        
        Account acc= new Account();
         acc.RecordTypeId = DisAccountTypeId;
     //   acc.RecordTypeId = '012800000002ByT';//Distributor Account Rec Type
        acc.Name = 'Test Account';
        insert acc;
        
        for(integer i=0;i<10;i++)
        {
            Contact con = new contact();
            con.FirstName = 'Test';
            con.LastName = 'Record-0'+i;
            con.RecordTypeId = salescontactrecordtypeId;
            con.Role_Classification__c = 'Sales Associate';
            con.AD_Username__c = 'Record-0'+i;
            con.AccountId = acc.Id;
            con.Hire_Date__c = date.today().addDays(-7);
            
            contList.add(con);
        }
        
        insert contList;
        
        Account acct = [select Id,Name from Account where Name=:'Test Account'];
        for(Contact c : [select Id,LastName from Contact where AccountId=:acct.Id])
        {
            system.debug('--c--'+c.LastName);
            Test.setCreatedDate(c.Id, DateTime.newInstance(dt.year(),dt.month(),dt.day()));
        }   
        
        Test.startTest();
        
        USReconAndCAIvan_Scheduler emailSch = new USReconAndCAIvan_Scheduler();
        String sch = '0 0 7 * * ?'; 
        System.schedule('Test USReconAndCAIvan Report', sch, emailSch);
        
        Test.stopTest(); 
        
    }
    
    public static testMethod void UnitTest02() {
        
        Date dt = date.today().addDays(-15);
        
        list<Contact>contList = new list<Contact>();
        
        //get sales contact record type Id
        Id salescontactrecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales Contact').getRecordTypeId();
        
        Id DisAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Distributor');
        Account acc= new Account();
         acc.RecordTypeId = DisAccountTypeId;
      // acc.RecordTypeId = '012800000002ByT';//Distributor Account Rec Type
        acc.Name = 'Test Account';
        insert acc;
        
        for(integer i=0;i<10;i++)
        {
            Contact con = new contact();
            con.FirstName = 'Test';
            con.LastName = 'Record-0'+i;
            con.RecordTypeId = salescontactrecordtypeId;
            con.Role_Classification__c = 'Sales Associate';
            con.AD_Username__c = 'Record-0'+i;
            con.AccountId = acc.Id;
            con.Hire_Date__c = date.today().addDays(-15);
            
            contList.add(con);
        }
        
        insert contList;
        
        Account acct = [select Id,Name from Account where Name=:'Test Account'];
        for(Contact c : [select Id,LastName from Contact where AccountId=:acct.Id])
        {
            system.debug('--c--'+c.LastName);
            Test.setCreatedDate(c.Id, DateTime.newInstance(dt.year(),dt.month(),dt.day()));
        }   
        
        Test.startTest();
        
        USReconAndCAIvan_Scheduler emailSch = new USReconAndCAIvan_Scheduler();
        String sch = '0 0 7 * * ?'; 
        System.schedule('Test USReconAndCAIvan Report', sch, emailSch);
        
        Test.stopTest(); 
        
    }
}