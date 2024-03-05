@istest
public class OppTerrAssignDefaultLogicFilterTest{
    
    final static Id ACC_HF_RT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Healthcare Facility').getRecordTypeId();
    
    @testSetup
    static void setup() {
        
        Account acc = TestUtilsLocal.createAccount('Test Account', false);
        acc.RecordTypeId = ACC_HF_RT; 
        insert acc;
        
        
        
        User usr = [Select id from User where Id = :UserInfo.getUserId()];
        
        System.RunAs(usr) {
            
            //insertTestTerritory(acc);
            
            List<Territory2Type> terriType   = [SELECT id, DeveloperName from Territory2Type where DeveloperName = 'US_Surgical'];
            
            if(terriType.size() > 0) {            
                
                List<Territory2Model> t2mList = [SELECT Id,Name,State FROM Territory2Model WHERE State = 'Active'];
                
                Territory2Model t2mLatest;
                
                if(t2mList.size() > 0) {
                    
                    for(Territory2Model t2ml : t2mList) {
                        t2mLatest = t2ml;
                        System.debug('t2ml.Id: ' + t2ml.Id + ' t2ml.Name: ' + t2ml.Name + ' t2ml.State: ' + t2ml.State);
                        
                    } 
                    
                } 
                
                
                
                Territory2 tr = TestUtilsLocal.createTerritory2('Arizona North Test', 'Arizona_North_Test', t2mLatest, terriType.get(0), false);  
                insert tr;
                
                ObjectTerritory2Association o2a = TestUtilsLocal.createObjectTerritory2Association(acc, tr, false);
                insert o2a;
                
            }
            
        }
        
        
        
    }
    
    @isTest
    private static void insertTestTerritory() { 
        Trigger_Settings__c cs = new Trigger_Settings__c();
        cs.Name = 'BPTrigger_OpportunityAmountRollUp';
        cs.Active__c = true;
        insert cs;
        Account acc = [SELECT Id, Name FROM Account];
        
        ObjectTerritory2Association o2a = [SELECT ObjectId, Territory2Id FROM ObjectTerritory2Association WHERE ObjectId =: acc.Id];
        
        //Opportunity opp = [SELECT Id, Name, Territory2Id FROM Opportunity];
        
        List<Id> opportunityIds = new List<Id>();
        
        Opportunity opp = TestUtilsLocal.createOpportunity(acc, 'Test Opportunity', false);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('US Surgical').getRecordTypeId(); // Only for Surgical Records Types
        insert opp;
        
        opportunityIds.add(opp.Id);
        
        Opportunity opp2 = TestUtilsLocal.createOpportunity(acc, 'Test Opportunity2', false);
        opp2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('US Trauma').getRecordTypeId();
        insert opp2;
        
        opportunityIds.add(opp2.Id);
        
        Opportunity opp3 = TestUtilsLocal.createOpportunity(acc, 'Test Opportunity2', false);
        opp3.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('US Surgical').getRecordTypeId();
        opp3.Territory2Id = o2a.Territory2Id;
        insert opp3;
        
        opportunityIds.add(opp3.Id);
     /*   
        Test.startTest();
        OppTerrAssignDefaultLogicFilter oppFilter = new OppTerrAssignDefaultLogicFilter();
        Map<Id,Id> OppIdTerriIdMap = oppFilter.getOpportunityTerritory2Assignments(opportunityIds);
        Test.stopTest();
        
        Id terriId = OppIdTerriIdMap.get(opp.Id);
        Id terriId2 = OppIdTerriIdMap.get(opp2.Id);
        Id terriId3 = OppIdTerriIdMap.get(opp3.Id);
        
        System.debug('o2a.Territory2Id: ' + o2a.Territory2Id);
        System.debug('terriId: ' + terriId);
        System.debug('terriId2: ' + terriId2);
        
        System.assertEquals(o2a.Territory2Id, terriId);
        System.assertEquals(null, terriId2);
        System.assertEquals(o2a.Territory2Id, terriId3); */
        
    }
    
}