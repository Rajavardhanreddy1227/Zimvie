@isTest
public inherited sharing class POServiceTest {
  
    @testSetup
    public static void createTestData(){
        
        User utausr = TestUtilsLocal.createTestUser('utaTest', True);    
        

        /*Territory2Model newTerritoryModel = TestUtilsLocal.createTerritory2Model('Zimmer', 'Zimmer', true);
        Territory2Type t2t = [Select Id,DeveloperName from Territory2Type where MasterLabel ='US Ortho'];
        Territory2 tr = TestUtilsLocal.createTerritory2('Test Terr','TestTerr',newTerritoryModel,t2t,true);

        // Add User to Territory
        UserTerritory2Association uta = new UserTerritory2Association(RoleInTerritory2 = 'Sales Manager',
                                                                          UserId = oppUser.Id,
                                                                          Territory2Id = tr.Id);*/

        
    }


    @isTest
    public static void afterDelete()
    { 
        User usr = [SELECT Id FROM User WHERE Name = 'utaTest'];
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

    @isTest
    public static void createPurchaseOrder()
    {
        //User utausr = TestUtilsLocal.createTestUser('utaTest28', True); 
        User usr = [SELECT Id FROM User WHERE Name = 'utaTest'];   
        User usr1 = TestUtilsLocal.createTestSalesUser('utaTest1A', True);        
        User usr2 = TestUtilsLocal.createTestSalesUser('utaTest2A', True);
        Test.startTest();        
        System.runAs(usr){
            //Territory2Model newTerritoryModel = TestUtilsLocal.createTerritory2Model('Zimmer', 'Zimmer', true);
            Territory2Model newTerritoryModel = [Select Id from territory2Model where DeveloperName =: System.Label.Ortho_Territory_Model];
            
            Territory2Type t2t = [Select Id,DeveloperName from Territory2Type where MasterLabel ='US Ortho'];
            Territory2 tr = TestUtilsLocal.createTerritory2('Test Terr','TestTerr',newTerritoryModel,t2t,true);
            
            UserTerritory2Association uta = new UserTerritory2Association(RoleInTerritory2 = 'Sales Manager',
                                                                          UserId = usr1.Id,
                                                                          Territory2Id = tr.Id);
            UserTerritory2Association uta2 = new UserTerritory2Association(RoleInTerritory2 = 'Sales Manager',
                                                                          UserId = usr2.Id,
                                                                          Territory2Id = tr.Id);
            INSERT uta;
            Insert uta2;
            
            Purchase_Order__c po = new Purchase_Order__c();
            po.Bill_ID__c = '123456';
            po.ERP_Account_ID__c = '004910';
            po.ERP_Account_Name__c = 'BEAUFORT MEML HOSPITAL';
            po.ERP_Order__c = 'EE2283';
            po.PO_Status__c = '3';
            po.PO_Subtotal__c = 4000;
            po.Region__c = 'MIDWEST';
            po.Territory2_ID__c = tr.id;
            po.Territory2_Name__c = tr.Name;
        
            //Territory_Name__c
            //Territory_Name__c
            insert po;

            List<Purchase_Order__c> lstPOs = new List<Purchase_Order__c>();
            lstPOs.add(po);

            PO_Util.createPOSharesForPurchaseOrders(lstPOs);    

            po.Region__c = 'NORTHEAST';
            update po;

            List<Purchase_Order__c> ul = new List<Purchase_Order__c>();
            ul.add(po);
            PO_Util.createPOSharesForPurchaseOrders(ul);

            //Test.startTest();
            SchedulableContext sc = null;
			POCreateShareSchedulableJob testobj = new POCreateShareSchedulableJob();
            testObj.execute(sc);
            
            
            
            PODailyCreateShareJob obj = new PODailyCreateShareJob();
            DataBase.executeBatch(obj); 
            
            //DataBase.executeBatch(obj); 
            //Test.stopTest();
            
            //UserTerritory2Association uta1 = [SELECT Id, RoleInTerritory2 FROM UserTerritory2Association WHERE User.Name ='utaTest'];
            //DELETE uta1;
        }
        Test.stopTest();
    }
}