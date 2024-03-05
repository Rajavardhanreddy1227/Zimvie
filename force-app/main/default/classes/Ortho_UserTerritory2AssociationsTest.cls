/**
* @author Appirio Inc.
* @date March, 2020
*
* @group UserTerritory2Association
*
* @description Encapsulates all behaviour logic relating to the UserTerritory2Association object
*       For more guidelines and details see
*    https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer
*/
@isTest
public class Ortho_UserTerritory2AssociationsTest {
    @testSetup
    public Static void createTestData(){
        TestUtilsLocal.createCustomSetting('AddUsersToPSQueues Trigger',true);
    }
    @isTest
    public static void afterDelete()
    {
        User usr = TestUtilsLocal.createTestSalesUser('utaTest', True);    
        Test.startTest();        
        System.runAs(usr){
            Territory2Model newTerritoryModel = TestUtilsLocal.createTerritory2Model('Zimmer', 'Zimmer', true);
            Territory2Type t2t = [Select Id,DeveloperName from Territory2Type where MasterLabel ='US Ortho'];
            Territory2 tr = TestUtilsLocal.createTerritory2('Test Terr','TestTerr',newTerritoryModel,t2t,true);
            
            UserTerritory2Association uta = new UserTerritory2Association(RoleInTerritory2 = 'Sales Manager',
                                                                          UserId = usr.Id,
                                                                          Territory2Id = tr.Id);
            INSERT uta;
            
            uta.RoleInTerritory2 = 'Sales Manager?';
            
            update uta;
            
            UserTerritory2Association uta1 = [SELECT Id, RoleInTerritory2 FROM UserTerritory2Association WHERE User.Name ='utaTest'];
            DELETE uta1;
        }
        Test.stopTest();
    }
}