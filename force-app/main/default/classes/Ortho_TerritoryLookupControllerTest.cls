/****************************************************/
// @Author: Ayush Goyal
// @Date: 26/02/2020
/****************************************************/


@isTest
public class Ortho_TerritoryLookupControllerTest {
    
    @testSetup
    public static void createTestData(){
        
        User oppUser = TestUtilsLocal.createTestUser('oppTerrUser',true);
        Account acc = TestUtilsLocal.createAccount('Test',true);
        
        TestUtilsLocal.createCustomSetting('BPTrigger_OpportunityAmountRollUp', true);
        Opportunity opp = TestUtilsLocal.createOpportunity(acc,'TestOpp',false);
        
        opp.RecordTypeId=[Select Id From RecordType where sobjectType = 'Opportunity' and Name='US Knee'].Id;
        System.runAs(oppUser){
            Territory2Model newTerritoryModel = [Select Id from territory2Model where DeveloperName =: System.Label.Ortho_Territory_Model];
            Territory2Type t2t = [Select Id,DeveloperName from Territory2Type where MasterLabel ='US Ortho'];
            Territory2 testTerr = TestUtilsLocal.createTerritory2('Test','TestTerr',newTerritoryModel,t2t,true);
            ObjectTerritory2Association ota = TestUtilsLocal.createObjectTerritory2Association(acc,testTerr,true);
            UserTerritory2Association uta = new UserTerritory2Association(UserId=oppuser.Id,Territory2Id=testTerr.Id);
            insert uta;
        }
        insert opp;
    }
    
    @isTest
    static void testUpdateOpportunityWithTeam(){
        
        User u=[Select Id from User where name='oppTerrUser'];
        Territory2 t = [Select Id from Territory2 where Name='Test'];
        
        System.runAs(u){
            
            Test.startTest();
            Opportunity opp = [Select Id,Territory2Id from Opportunity where Name='TestOpp'];
            Ortho_TerritoryLookupController.updateOpportunityWithTeam(opp.Id,t.Id);
            Ortho_TerritoryLookupController.getOpportunityDetail(opp.Id);
            Test.stopTest();
        }
        
        Opportunity oppty = [Select Id,Territory2Id from Opportunity where Name='TestOpp'];
        System.assertEquals(t.Id,oppty.Territory2Id);
    }
    @isTest
    static void testFetchTeamDetails(){
        User u=[Select Id from User where name='oppTerrUser'];
        Territory2 t = [Select Id from Territory2 where Name='Test'];
        
        System.runAs(u){
            
            Test.startTest();
            Opportunity opp = [Select Id,Territory2Id from Opportunity where Name='TestOpp'];
            List<Territory2> terrList = Ortho_TerritoryLookupController.fetchTeams(opp.Id);
            system.debug('terrLIst is-->'+terrList);
            Test.stopTest();
            system.assertEquals(t.Id,terrList.get(0).Id);
        }
        
    }
    
}