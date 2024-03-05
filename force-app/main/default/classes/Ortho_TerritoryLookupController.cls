/**
 * @author Appirio
 * @date Feb, 2020
 *
 * @description Contains various server side aura methods that are used in the orthoReassignOpportunity LWC
 */
public without sharing class Ortho_TerritoryLookupController {
    
    /**
    * @description Updates an existing opportunity with the Territory passed in
    * on the Territory2Id field.
    *
    * @param oppId Opportunity which will be updated
    * @param territoryId Id of the territoryId object attached to Territory2Id the  field.
    */
    @AuraEnabled
    public static void updateOpportunityWithTeam(Id oppId, Id territoryId) {
        List<UserRecordAccess> recordAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId = :UserInfo.getuserId() and RecordId = :oppId];
        if(recordAccess.size() > 0 && recordAccess[0].HasEditAccess){
            Opportunity newOpp = new Opportunity(Id = oppId, Territory2Id = territoryId);
            UPDATE newOpp;
        }else{
            throw new RecordAccessException(System.Label.Ortho_Opportunity_Access_Error);
        }
    }
    
    /**
    * @description It returns Opportunity record by Id
    *
    * @param oppId Opportunity which will be updated
    */
    @AuraEnabled
    public static Opportunity getOpportunityDetail(Id oppId) {
        Opportunity opp = [SELECT Id, Territory2Id FROM Opportunity WHERE Id = :oppId][0];
        return opp;
    }

    /**
    * @description Fetch the Territory2 objects under the given health care and current user
    *
    * @param oppId Opportunity for which teams need to be fetched
    */
    @AuraEnabled
    public static List<Territory2> fetchTeams(String oppId) {
        List<Territory2> terrList = new List<Territory2>();
        List<Opportunity> oppList = [SELECT Id, AccountId, Territory2Id FROM Opportunity WHERE ID = :oppId];
        Map<String, List<Territory2>> territory2MapByOppId = 
            OpportunityService.getTerritoriesForOpportunities(oppList, null);
        if(territory2MapByOppId != null && territory2MapByOppId.containsKey(oppId)){
            terrList = territory2MapByOppId.get(oppId);    
        }
        return terrList;
    }

    public class RecordAccessException extends Exception{}
}