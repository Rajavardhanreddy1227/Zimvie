/**
* @author Appirio Inc.
* @date FMarch, 2020
*
* @group Opportunity
*
* @description This is a batch job which required to run one time to
* assign territory to existing opportunity records
*/
global class Ortho_OpportunityTerritoryAssignJob implements
    Database.Batchable<sObject> {

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Map<String, String> recordTypeMap = Ortho_Util.getUSOrthoOpptyRecordTypes();
        Set<String> orthoRecordTypeSet = recordTypeMap.keySet();

        return Database.getQueryLocator(
            'SELECT Id, Surgeon_Name__c, AccountId, Territory2Id, ' +
            'RecordTypeId FROM Opportunity ' +
            'Where RecordTypeId IN :orthoRecordTypeSet AND Territory2Id = NULL AND IsClosed = false ' +
            'AND AccountId != NULL AND Surgeon_Name__c != NULL'
        );
    } 

    global void execute(Database.BatchableContext bc, List<Opportunity> scopeOppList){
        // process each batch of records
        List<Opportunity> oppList = new List<Opportunity>();
            
        if(!scopeOppList.isEmpty()){
            
            Ortho_Opportunities.assignTerritories(scopeOppList);
            for(Opportunity opp : scopeOppList){
                if(opp.Territory2Id != NULL){
                    oppList.add(opp);
                }
            }
            if(!oppList.isEmpty()){    
            	Database.update(oppList, true);
            }
        }
    }
        

    global void finish(Database.BatchableContext bc){
        System.debug('Opportunity Territory Assignment Job Completed.');
    }
}