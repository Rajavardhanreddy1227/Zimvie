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
public class Ortho_UserTerritoryAssociations extends Ortho_AppModel{

    public static void onAfterInsert(List<User_Territory_Association__c> cObjUTAList){
        List<UserTerritoryAssociation> utaList = new List<UserTerritoryAssociation>();
        for(User_Territory_Association__c uta : cObjUTAList){
            utaList.add(new UserTerritoryAssociation((Object)uta));
        }
        Ortho_UTAService.alignOpportunityTeam(utaList, true, false);
    }

    public static void onAfterDelete(List<User_Territory_Association__c> cObjUTAList){

        List<UserTerritoryAssociation> utaList = new List<UserTerritoryAssociation>();
        for(User_Territory_Association__c uta : cObjUTAList){
            utaList.add(new UserTerritoryAssociation((Object)uta));
        }

        Ortho_UTAService.alignOpportunityTeam(utaList, false, false);
    }

    public static void setDefaults(List<User_Territory_Association__c> newList, Map<Id, User_Territory_Association__c> oldMap){
        List<User_Territory_Association__c> utaList = new List<User_Territory_Association__c>();
        Map<Id, Territory2> terrMap = new Map<Id, Territory2>();
        Set<Id> terrIdSet = new Set<Id>();
        for(User_Territory_Association__c uta : newList){
            if(oldMap == null || oldMap.get(uta.id).Territory__c != uta.Territory__c){
              utaList.add(uta);
              terrIdSet.add(uta.Territory__c);
            }
        }

        terrMap = new Map<Id, Territory2>(Ortho_TerritorySelector.selectAllTerritoriesByTerrId(terrIdSet));
        if(!utaList.isEmpty()){
            for(User_Territory_Association__c uta : utaList){
                if(terrMap != null && terrMap.containsKey(uta.Territory__c)){
                    uta.Territory_Name__c = terrMap.get(uta.Territory__c).Name;
                }
            }
        }
    }

    public static void onAfterUpdate(List<User_Territory_Association__c> newList, Map<Id, User_Territory_Association__c> oldMap){
        List<UserTerritoryAssociation> updatedUTAList = new List<UserTerritoryAssociation>();
        for(User_Territory_Association__c uta : newList){
            if(oldMap != NULL && oldMap.get(uta.id).Role__c != uta.Role__c){
                updatedUTAList.add(new UserTerritoryAssociation((Object)uta));
            }
        }
        if(!updatedUTAList.isEmpty()){
            Ortho_UTAService.alignOpportunityTeam(updatedUTAList, false, true);
        }
    }

}