/**
* @author Appirio Inc.
* @date March, 2020
*
* @group User_Territory_Association__c
*
* @description Encapsulates all behaviour logic relating to the User_Territory_Association__c object
*       For more guidelines and details see
*    https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer
*/
@isTest
public class Ortho_UserTerritoryAssociationsTest {
    @testSetup
    public static void createCustomSetting(){
        
        TestUtilsLocal.createCustomSetting('AddUsersToPSQueues Trigger',true);
        
        User systemAdmin = TestUtilsLocal.createTestUser('systemAdmin', true);
    }
    public static User_Territory_Association__c createTestData(User usr){
        User testUser = [SELECT Id, Name FROM User WHERE Name = 'systemAdmin'];
        System.runAs(usr){
            
            Territory2Model newTerritoryModel = [Select Id from territory2Model where DeveloperName =: System.Label.Ortho_Territory_Model];
            Territory2Type t2t = [Select Id,DeveloperName from Territory2Type where MasterLabel ='US Ortho'];
            Territory2 testTerr = TestUtilsLocal.createTerritory2('TestTerr', 'TestTerr', newTerritoryModel, t2t, true);
            
            Account acc = TestUtilsLocal.createAccount('Test', false);
            acc.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'DN-Ghost Account'].Id;
            INSERT acc;
            
            TestUtilsLocal.createCustomSetting('BPTrigger_OpportunityAmountRollUp', true);
            Opportunity opp = TestUtilsLocal.createOpportunity(acc, 'TestOpp', false);
            opp.RecordTypeId = [SELECT Id, Name FROM RecordType WHERE Name = 'US OBT'].Id;
            opp.Territory2Id = testTerr.Id;
            INSERT opp;
            
            ObjectTerritory2Association ota = TestUtilsLocal.createObjectTerritory2Association(acc, testTerr, true);
            
            User_Territory_Association__c uta = new User_Territory_Association__c(Role__c = 'Extremities',
                                                                                  Territory__c = testTerr.Id,
                                                                                  Territory_Name__c = 'Test Terr',
                                                                                  User__c = testUser.Id);
            insert uta;
        }
        User_Territory_Association__c uta = [SELECT Role__c, Territory__c, Territory_Name__c, User__c FROM User_Territory_Association__c
                                             WHERE Role__c = 'Extremities'];
        return uta;
    }
    
    //Check when delete the user territory association
    @isTest
    public static void onAfterDelete(){        
        User usr = TestUtilsLocal.createTestSalesUser('oppTerrUser',true);
        User systemAdmin = [SELECT Id, Name FROM User WHERE Name = 'systemAdmin'];
        Test.startTest();
        System.runAs(systemAdmin){
            User_Territory_Association__c uta = createTestData(usr);
            DELETE uta;
        }
        Test.stopTest();
    }
}