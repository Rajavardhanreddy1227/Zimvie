/**
* @author Appirio Inc.
* @date March, 2020
*
* @group Opportunity
*
* @description Test Class for Ortho_OpportunityComponentController
*/
@isTest
public class Ortho_OpportunityComponentControllerTest {
    @testSetup 
    public Static void TestSetup1(){
        TestUtilsLocal.createCustomSetting('AddUsersToPSQueues Trigger',true);
    }
    
    @isTest
    public static void getOpp(){        
        User usr = TestUtilsLocal.createTestSalesUser('Ortho_user',true);
        Test.startTest();
        System.runAs(usr){
            Account acc = TestUtilsLocal.createAccount('Test', false);
            acc.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'DN-Ghost Account'].Id;
            INSERT acc;
            
            TestutilsLocal.createCustomSetting('BPTrigger_OpportunityAmountRollUp', true);
            
            Opportunity opp = TestUtilsLocal.createOpportunity(acc, 'TestOpp', false);
            opp.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'US OBT'].Id;
            INSERT opp;
            
            Ortho_OpportunityComponentController.getOpportunity(opp.Id);
            Ortho_OpportunityComponentController.getBaseURL();
        }
        Test.stopTest();
        System.assertEquals(True, Ortho_OpportunityComponentController.flag);
    }
}