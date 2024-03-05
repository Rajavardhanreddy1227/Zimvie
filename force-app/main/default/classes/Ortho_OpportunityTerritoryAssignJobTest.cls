@isTest
public class Ortho_OpportunityTerritoryAssignJobTest {
    @testSetup
    public static void createTestData(){
        TestUtilsLocal.createCustomSetting('BPTrigger_OpportunityAmountRollUp',true);
        User oppUser = TestUtilsLocal.createTestUser('oppTerrUser',true);
        Account acc = TestUtilsLocal.createAccount('Test',true);
        Account surgeon = TestUtilsLocal.createPhysicianAccount('Test','Surgeon',true);
       
        Opportunity opp = TestUtilsLocal.createOpportunity(acc,'TestOppValidate',false);
        opp.RecordTypeId=[Select Id From RecordType where sobjectType = 'Opportunity' and Name='US Knee'].Id;
        opp.Surgeon_Name__c = surgeon.Id;
        insert opp;
        Territory2 testTerr = new Territory2();
        //Territory2 testTerr = [Select Id from Territory2 where Name='ZB Mid Ohio Team Ace Opportunities'];
        System.runAs(oppUser){
            Territory2Model newTerritoryModel = [Select Id from territory2Model where DeveloperName =: System.Label.Ortho_Territory_Model];
            Territory2Type t2t = [Select Id,DeveloperName from Territory2Type where MasterLabel ='US Ortho'];
            testTerr = TestUtilsLocal.createTerritory2('TestTerr', 'TestTerr', newTerritoryModel, t2t, true);
        }
        User_Territory_Association__c  uta = new User_Territory_Association__c (User__c=oppUser.Id, Territory__c=testTerr.Id);
        uta.Role__c  ='Knees';
        insert uta;
       
        System.runAs(oppUser){
            UserTerritory2Association uta1 = new UserTerritory2Association(UserId=oppUser.Id, Territory2Id=testTerr.Id);
            insert uta1;
            ObjectTerritory2Association ota = TestUtilsLocal.createObjectTerritory2Association(acc,testTerr,true);
            ObjectTerritory2Association ota2 = TestUtilsLocal.createObjectTerritory2Association(surgeon,testTerr,true);
        }
       
    }
   
    @isTest
    static void testAssignTerritories(){
        
        User u = [Select Id,Name from User where LastName='oppTerrUser'];
        Territory2 t = [Select Id,Name from Territory2 where Name='TestTerr'];
        system.runAs(u){
            Test.startTest();
            Ortho_OpportunityTerritoryAssignJob batch = new Ortho_OpportunityTerritoryAssignJob();
            Database.executeBatch(batch);
            Test.stopTest();
        }
        
        Opportunity opp = [Select Id,Territory2Id from Opportunity where Name='TestOppValidate'];
        system.assertEquals(t.Id, opp.Territory2Id);
    }
}