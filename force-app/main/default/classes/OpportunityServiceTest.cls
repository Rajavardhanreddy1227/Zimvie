@isTest
public class OpportunityServiceTest {
    @testSetup
    public static void createTestData(){
        
        User utausr = TestUtilsLocal.createTestUser('utaTest', True);    
        Account acc = TestUtilsLocal.createAccount('TestAcc', true);
        User oppUser = TestUtilsLocal.createTestUser('oppUser', true);
        
        System.runAs(oppUser){
            TestUtilsLocal.createCustomSetting('BPTrigger_OpportunityAmountRollUp', true);
            Opportunity opp = TestUtilsLocal.createOpportunity(acc, 'TestOpp', false);
            
            Territory2Model newTerritoryModel = [Select Id from territory2Model where DeveloperName = 'Zimmer_Biomet'];
            Territory2Type t2t = [Select Id,DeveloperName from Territory2Type where MasterLabel ='US Ortho'];
            Territory2 tr = TestUtilsLocal.createTerritory2('Test Terr','TestTerr',newTerritoryModel,t2t,true);
            
          //  insert tr;
            System.debug(' check terr id' +tr.Id);
            
            opp.Territory2Id = tr.Id;
            INSERT opp;
            
            ObjectTerritory2Association objTerr = TestUtilsLocal.createObjectTerritory2Association(acc, tr, true);
        }
    }
    
    @isTest
    public static void getTerritoriesForOpportunitiesTest(){
        User usr = [SELECT Id FROM User WHERE Name = 'utaTest'];
        System.runAs(usr){
            Test.startTest();
            Territory2 tr = [SELECT Id, Name FROM Territory2 WHERE Name = 'Test Terr'];
            UserTerritory2Association uta = new UserTerritory2Association(RoleInTerritory2 = 'Sales Manager',
                                                                          UserId = usr.Id,
                                                                          Territory2Id = tr.Id);
            INSERT uta;
            
            Opportunity opp = [SELECT Id, Name, accountId, RecordTypeId FROM Opportunity WHERE Name = 'TestOpp'];
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(opp);
            
            Set<Id> accIdSet = new Set<Id>();
            
            OpportunityService.getTerritoriesForOpportunities(oppList, accIdSet);
            Test.stopTest();
        }
    }
    
    @isTest
    public static void filterOpportunitiesTest(){
        User usr = [SELECT Id FROM User WHERE Name = 'oppUser'];
        System.runAs(usr){
            Test.startTest();
            Opportunity opp = [SELECT Id, Name, accountId, RecordTypeId FROM Opportunity WHERE Name = 'TestOpp'];
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(opp);
            
            OpportunityService.filterOpportunities(oppList, 'RecordTypeId', Ortho_Util.getUSOrthoOpptyRecordTypes().keySet());
            Test.stopTest();
        }
    }
    
    // @isTest(SeeAllData = false)
    // public static void createOTMTest(){
    //     User usr = [SELECT Id FROM User WHERE Name = 'oppUser'];
    //     System.runAs(usr){
    //         Test.startTest();
    //         Opportunity opp = [SELECT Id, Name, OwnerId, accountId, RecordTypeId FROM Opportunity WHERE Name = 'TestOpp'];
    //         List<UserTerritory2Association> uta = [SELECT Id, RoleInTerritory2, UserId, Territory2Id FROM UserTerritory2Association WHERE RoleinTerritory2 = 'Sales Manager'];
    //         system.debug('uta' +uta);
    //         Territory2 trr = [SELECT Id, Name FROM Territory2 WHERE Name = 'Test Terr'];
            
    //         String userId = usr.Id;
    //         String TerritoryId = trr.Id;
    //         String role = uta[0].RoleInTerritory2;
            
    //         Ortho_AppModel.UserTerritoryAssociation appModel = new Ortho_AppModel.UserTerritoryAssociation(userId, TerritoryId, role);
    //         OpportunityService.createOTM(opp, appModel, null);
    //         Test.stopTest();
    //     }
    // }
    
    @isTest 
    public Static void forTeamLeadRole(){
        User usr = [SELECT Id FROM User WHERE Name = 'utaTest'];
        Test.startTest();
        Opportunity opp = [SELECT Id, Name, accountId, RecordTypeId, OwnerId FROM Opportunity WHERE Name = 'TestOpp'];
        Territory2 tr = [SELECT Id, Name FROM Territory2 WHERE Name = 'Test Terr'];
        Set<Id> territoryIdHeads = new Set<Id>();
        territoryIdHeads.add(tr.Id);
        UserTerritory2Association uta = new UserTerritory2Association(RoleInTerritory2 = 'Team Lead',
                                                                      UserId = usr.Id,
                                                                      Territory2Id = tr.Id);
        INSERT uta;
        String userId = usr.Id;
        String TerritoryId = tr.Id;
        String role = uta.RoleInTerritory2;
        Ortho_AppModel.UserTerritoryAssociation appModel = new Ortho_AppModel.UserTerritoryAssociation(userId, TerritoryId, role);
        OpportunityService.createOTM(opp, appModel, territoryIdHeads);
        Test.stopTest();
    }
    
    @isTest 
    public Static void forNonSeniorRepRole(){
        User usr = [SELECT Id FROM User WHERE Name = 'utaTest'];
        Test.startTest();
        Opportunity opp = [SELECT Id, Name, accountId, RecordTypeId, OwnerId FROM Opportunity WHERE Name = 'TestOpp'];
        Territory2 tr = [SELECT Id, Name FROM Territory2 WHERE Name = 'Test Terr'];
        Set<Id> territoryIdHeads = new Set<Id>();
        territoryIdHeads.add(tr.Id);
        UserTerritory2Association uta = new UserTerritory2Association(RoleInTerritory2 = 'Non-Senior Rep',
                                                                      UserId = usr.Id,
                                                                      Territory2Id = tr.Id);
        INSERT uta;
        String userId = usr.Id;
        String TerritoryId = uta.Territory2Id;
        String role = uta.RoleInTerritory2;
        Ortho_AppModel.UserTerritoryAssociation appModel = new Ortho_AppModel.UserTerritoryAssociation(userId, TerritoryId, role);
        OpportunityService.createOTM(opp, appModel, null);
        Test.stopTest();
    }
    
    @isTest 
    public Static void forSeniorRepRole(){
        User usr = [SELECT Id FROM User WHERE Name = 'utaTest'];
        Test.startTest();
        Opportunity opp = [SELECT Id, Name, accountId, RecordTypeId, OwnerId FROM Opportunity WHERE Name = 'TestOpp'];
        Territory2 tr = [SELECT Id, Name FROM Territory2 WHERE Name = 'Test Terr'];
        Set<Id> territoryIdHeads = new Set<Id>();
        territoryIdHeads.add(tr.Id);
        UserTerritory2Association uta = new UserTerritory2Association(RoleInTerritory2 = 'Senior Rep',
                                                                      UserId = usr.Id,
                                                                      Territory2Id = tr.Id);
        INSERT uta;
        String userId = usr.Id;
        String TerritoryId = uta.Territory2Id;
        String role = uta.RoleInTerritory2;
        Ortho_AppModel.UserTerritoryAssociation appModel = new Ortho_AppModel.UserTerritoryAssociation(userId, TerritoryId, role);
        OpportunityService.createOTM(opp, appModel, territoryIdHeads);
        Test.stopTest();
    }
    
}