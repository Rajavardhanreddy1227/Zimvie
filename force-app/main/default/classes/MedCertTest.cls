@isTest
public inherited sharing class MedCertTest {
    
    @testSetup
    public static void createTestData(){
        
        User utausr = TestUtilsLocal.createTestUser('utaTest', True);  
        
        /*acc = new Account();
        acc.RecordTypeId = '012800000002AW5AAM';//Healthcare Facility
        acc.Name = 'APEX SURGICAL(TEST)';
        acc.RVP__c = u.Id;
        insert acc;

        srgn = new Account();
        srgn.RecordTypeId = '012800000002C4gAAE';//Surgeon
        srgn.FirstName = 'John';
        srgn.LastName = 'Smith';
        insert srgn;

        Healthcare_Surgeon_Relationship__c hsr = new Healthcare_Surgeon_Relationship__c();
        hsr.City__c = 'Indianapolis';//Healthcare Facility
        hsr.Healthcare_Facility__c = acc.Id;
        hsr.Surgeon__c = srgn.Id;
        hsr.Territory_Number__c = '91';
        insert hsr;*/
    }

    @isTest
    public static void testCertificationSync()
    {
        //User utausr = TestUtilsLocal.createTestUser('utaTest28', True); 
        Datetime d = Datetime.now();
        d = d.addHours(+240);
        User usr = [SELECT Id FROM User WHERE Name = 'utaTest'];   
        //User usr1 = TestUtilsLocal.createTestSalesUser('utaTest1A', True);        
        //User usr2 = TestUtilsLocal.createTestSalesUser('utaTest2A', True);
        Test.startTest();        
        System.runAs(usr){
            
            Id HealthAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','HealthcareFacility');
        
            Account acc = new Account();
           // acc.RecordTypeId = '012800000002AW5AAM';//Healthcare Facility
            acc.RecordTypeId = HealthAccountTypeId;
            acc.Name = 'APEX SURGICAL(TEST)';
            acc.RVP__c = usr.Id;
            insert acc;

            List<Account> lstAccts  = new List<Account>();
			
            Id SurgeonAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Physician');
            
            for (Integer i =0; i< 3;i++) {
                Account srgn = new Account();
            //    srgn.RecordTypeId = '012800000002C4gAAE';//Surgeon
            	srgn.RecordTypeId = SurgeonAccountTypeId;
                srgn.FirstName = 'Walter_'+i;
                srgn.LastName = 'Smith';
                srgn.PersonMailingStreet = '123 ABC St';
                srgn.PersonMailingCity = 'Indianapolis';
                srgn.PersonMailingState = 'IN';
                srgn.PersonMailingCountry = 'US';
                srgn.Phone = '1234567891';
                srgn.PersonMailingPostalCode = '46214';
                insert srgn;
                lstAccts.add(srgn);
            }
            /*Account srgn1 = new Account();
            srgn1.RecordTypeId = '012800000002C4gAAE';//Surgeon
            srgn1.FirstName = 'Walter';
            srgn1.LastName = 'Smith';
            insert srgn1;

            Account srgn2 = new Account();
            srgn2.RecordTypeId = '012800000002C4gAAE';//Surgeon
            srgn2.FirstName = 'John';
            srgn2.LastName = 'Smith';
            insert srgn2;

            Account srgn3 = new Account();
            srgn3.RecordTypeId = '012800000002C4gAAE';//Surgeon
            srgn3.FirstName = 'Steven';
            srgn3.LastName = 'Walcott';
            insert srgn3;*/

            Healthcare_Surgeon_Relationship__c hsr1 = new Healthcare_Surgeon_Relationship__c();
            hsr1.City__c = 'Indianapolis';
            hsr1.Healthcare_Facility__c = acc.Id;
            hsr1.Surgeon__c = lstAccts[0].Id;
            hsr1.Territory_Number__c = 91;
            insert hsr1;

            Healthcare_Surgeon_Relationship__c hsr2 = new Healthcare_Surgeon_Relationship__c();
            hsr2.City__c = 'Indianapolis';
            hsr2.Healthcare_Facility__c = acc.Id;
            hsr2.Surgeon__c = lstAccts[1].Id;
            hsr2.Territory_Number__c = 91;
            insert hsr2;

            Healthcare_Surgeon_Relationship__c hsr3 = new Healthcare_Surgeon_Relationship__c();
            hsr3.City__c = 'Indianapolis';
            hsr3.Healthcare_Facility__c = acc.Id;
            hsr3.Surgeon__c = lstAccts[2].Id;
            hsr3.Territory_Number__c = 91;
            insert hsr3;

            List<Contact> lstCntcts = [Select Id, Name from Contact where AccountId in :lstAccts];
            
            //Create Certification for srgn1 and srgn2
            Certification__c c1 = new Certification__c(Certification__c = 'ROSA Knee', Effective_From__c = Date.newInstance(2016, 12, 9), Contact__c = lstCntcts[0].Id);
            Certification__c c2 = new Certification__c(Certification__c = 'ROSA Knee', Effective_From__c = Date.newInstance(2021, 2, 9), Contact__c = lstCntcts[1].Id);

            insert c1;
            insert c2;

            List<Certification__c> cl = new List<Certification__c>();
            cl.add(c1);
            MedCert_Util.syncMedCertifications(cl);

            //Test.startTest();
            SchedulableContext sc = null;
			MedCertSyncSchedulableJob testobj = new MedCertSyncSchedulableJob();
            testObj.execute(sc);
            
            MedCertDailySyncJob obj = new MedCertDailySyncJob();
            DataBase.executeBatch(obj); 
        }
        Test.stopTest();
    }
}