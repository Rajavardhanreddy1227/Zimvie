/****************************************************/
// @Author: Ayush Goyal
// @Date: 24/02/2020
/****************************************************/

@isTest
public class Ortho_OpportunitiesTest { 
    
    @testSetup
    public static void createTestData(){
        
        TestUtilsLocal.createCustomSetting('BPTrigger_OpportunityAmountRollUp', true);
        List<Opportunity> oppList = new List<Opportunity>();
        List<User_Territory_Association__c> utaList = new List<User_Territory_Association__c>();
        
        User oppUser = TestUtilsLocal.createTestUser('oppTerrUser',true);
        User ZimmerSalesUser = TestUtilsLocal.createTestUser('ZimmerUser',false);
        User oppParentTerrUser = TestUtilsLocal.createTestUser('oppTerrUserParent',true);
        
        system.debug('check oppuser ready' +oppUser);
        system.debug('check ZimmerSalesUser ready' +ZimmerSalesUser);
        system.debug('check oppParentTerrUser ready' +oppParentTerrUser);
        
        System.runAs(oppUser){
            Profile customZimmerSales = [SELECT Id FROM Profile WHERE Name='Custom-Zimmer Sales']; 
            ZimmerSalesUser.ProfileId = customZimmerSales.Id;
            insert ZimmerSalesUser;
        }
        
        Account acc = TestUtilsLocal.createAccount('Test',true);
        Account surgeon = TestUtilsLocal.createPhysicianAccount('Test','Surgeon',true);
        
        Opportunity opp = TestUtilsLocal.createOpportunity(acc,'TestOppValidate',false);
        opp.RecordTypeId=[Select Id From RecordType where sobjectType = 'Opportunity' and Name='US Knee'].Id;
        opp.Surgeon_Name__c = surgeon.Id;
        
        Opportunity opp1 = TestUtilsLocal.createOpportunity(acc,'TestOppValidateNegative',false);
        opp1.RecordTypeId=[Select Id From RecordType where sobjectType = 'Opportunity' and Name='US Knee'].Id;
        opp1.Surgeon_Name__c = surgeon.Id;
        opp1.OwnerId = ZimmerSalesUser.Id;
        
        System.runAs(oppUser){
            Territory2Model newTerritoryModel = [Select Id from territory2Model where DeveloperName =: System.Label.Ortho_Territory_Model];
            Territory2Type t2t = [Select Id,DeveloperName from Territory2Type where MasterLabel ='US Ortho'];
            Territory2 testTerr = TestUtilsLocal.createTerritory2('Test Knee','TestTerr',newTerritoryModel,t2t,true);
            Territory2 testTerr1 = TestUtilsLocal.createTerritory2('Test Territory1','TestTerr1',newTerritoryModel,t2t,true);
            Territory2 testTerr2 = TestUtilsLocal.createTerritory2('Test Territory2','TestTerr2',newTerritoryModel,t2t,true);
            ObjectTerritory2Association ota = TestUtilsLocal.createObjectTerritory2Association(acc,testTerr,true);
            ObjectTerritory2Association ota2 = TestUtilsLocal.createObjectTerritory2Association(surgeon,testTerr,true);
            //ObjectTerritory2Association ota3 = TestUtilsLocal.createObjectTerritory2Association(acc,testTerr1,true);
            //ObjectTerritory2Association ota4 = TestUtilsLocal.createObjectTerritory2Association(surgeon,testTerr1,true);
            //UserTerritory2Association uta = new UserTerritory2Association(UserId=ZimmerSalesUser.Id,Territory2Id=testTerr.Id);
            //UserTerritory2Association uta1 = new UserTerritory2Association(UserId=oppUser.Id,Territory2Id=testTerr.Id);
            //insert uta;
            //insert uta1;
        }
        
        oppList.add(opp);
        oppList.add(opp1);
        
        Territory2 testTerr = [Select Id,Name from Territory2 where Name='Test Knee'];
        Territory2 testTerr1 = [Select Id,Name from Territory2 where Name='Test Territory1'];
        User_Territory_Association__c utaCustom= new User_Territory_Association__c(Role__c='Knees',Territory__c=testTerr.Id,User__c=oppUser.Id);
        User_Territory_Association__c utaCustom1= new User_Territory_Association__c(Role__c='Knees',Territory__c=testTerr1.Id,User__c=ZimmerSalesUser.Id);
        User_Territory_Association__c utaCustom2= new User_Territory_Association__c(Role__c='Knees',Territory__c=testTerr.Id,User__c=ZimmerSalesUser.Id);
        utaList.add(utaCustom);
        utaList.add(utaCustom1);
        utaList.add(utaCustom2);
        insert utaList;        
        
        System.runAs(oppUser){
            insert oppList;
            
        }
        
        utaCustom2.Role__c = 'Hips';
        update utaCustom2;
    }
    
    @isTest
    static void testOnValidatePositive(){
        
        
        User u=[Select Id from User where name='oppTerrUser'];
        Territory2 t = [Select Id,Name from Territory2 where Name='Test Knee'];
        String terrName = t.Name;
        
        System.runAs(u){
            
            Test.startTest();
            
            Opportunity opp = [Select Id,Territory2Id,Ortho_Team__c from Opportunity where Name='TestOppValidate'];
            system.debug('check opp' +opp.Ortho_Team__c);
            opp.Territory2Id = t.Id;
            update opp;
            Test.stopTest();
        }
        
        Opportunity oppty = [Select Id,Ortho_Team__c from Opportunity where Name='TestOppValidate'];
        System.assertEquals(oppty.Ortho_Team__c, terrName);
    }
    
    @isTest
    static void testOnValidateNegative(){
        
        User u=[Select Id from User where name='ZimmerUser'];
        Test.startTest();
        Opportunity opp = [Select Id,Territory2Id from Opportunity where Name='TestOppValidateNegative'];
        system.debug('already existing territory2ID'+opp.Territory2Id);
        Territory2 t = [Select Id,Name from Territory2 where Name='Test Territory2'];
        system.debug('new territory2ID'+t.Id);
        String tName = t.Name;
        System.runAs(u){
            try{
                opp.Territory2Id = t.Id;
                update opp;
            }catch(Exception ex){
                system.debug('catch message->'+ex.getMessage());
                Boolean expectedExceptionThrown =  ex.getMessage().contains('The Opportunity can\'t be assigned to selected Territory. Please select a relevant Territory.') ? true : false;
                //System.assertEquals(true, expectedExceptionThrown);
            }
        }
        Test.stopTest();
        Opportunity oppty = [Select Id,Ortho_Team__c from Opportunity where Name='TestOppValidate'];
        System.assertEquals('Test Knee',oppty.Ortho_Team__c);
    }
    
    @isTest
    static void testAssignTerritories(){
        Territory2 t = [Select Id,Name from Territory2 where Name='Test Knee'];
        Opportunity opp = [Select Id,Territory2Id from Opportunity where Name='TestOppValidate'];
        system.assertEquals(t.Id, opp.Territory2Id);
        
        //Update Territory Id to diff value
        Territory2 t1 = [Select Id,Name from Territory2 where Name='Test Territory1'];
        opp.Territory2Id = t1.Id;
        update opp;
    }

    @isTest
    static void testMobileOpptyFilter() {
        List<User> u=[Select Id from User where name='ZimmerUser'];
        Test.startTest();

        List<Account> accList = MobileOpptyFilterController.findRecords('Test', 'Account', '');
        System.debug(accList);

        List<Account> srgnList = MobileOpptyFilterController.findRecords('Test', 'Surgeon', '');
        System.debug(srgnList);

        List<User> uList = MobileOpptyFilterController.findRecords('Zimm', 'User', '');
        System.debug(uList);

        List<Territory2> tList = MobileOpptyFilterController.findRecords('T2', 'Territory2ForOpportunity', '');
        System.debug(tList);

        List<String> orthoRecIds = MobileOpptyFilterController.getUSOrthoRecordTypeIds();
        if (orthoRecIds != null) {
            System.debug('There are '+orthoRecIds.size()+ ' US Ortho record types');
        }
        System.assert(orthoRecIds.size() > 0, 'Ortho Record Types were fetched');
        Opportunity opp = [Select Id,Territory2Id from Opportunity where Name='TestOppValidateNegative'];
        List<Account> a = [Select Id,Name from Account where Name='Test' and RecordTypeId = '012800000002AW5AAM'];
        List<Account> s = [Select Id,Name from Account where Name='Test Surgeon' and RecordTypeId = '012530000000BTdAAM'];
        Territory2 testTerr = [Select Id,Name from Territory2 where Name='Test Knee'];

        System.debug('lst2');
    //    List<Opportunity> lst = MobileOpptyFilterController.searchOpportunities((String)a[0].Id,(String)s[0].Id, '"'+orthoRecIds[0]+'"', testTerr.Id, '', (String)u[0].Id, true, true);

     //   System.debug('lst'+lst.size());
      //  System.assertEquals(lst.size(), 0);

        //Test Instrument Request
        Instrument_Request__c IR = new Instrument_Request__c();

        IR.Opportunity__c = opp.Id;
        IR.SNAP_KIT_ID__c = opp.Id + '-' + '123456';
        IR.Requested_Qty__c = 2;
        IR.Status__c = 'Shipped';

        insert IR;

        Instrument_Request__c IR1 = [Select Id, Record_Number__c, Name from Instrument_Request__c where Opportunity__c = :opp.Id];

        if (IR1 != null) {
            IR1.Status__c = 'New';

            update IR1;
        }

        System.assertEquals(IR1.Record_Number__c, 1);
        Test.stopTest();
        
    }


}