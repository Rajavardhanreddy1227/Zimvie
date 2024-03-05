/**
* @author Appirio Inc.
* @date 7/24/2020
* @group UserTerritory2Associations
* @description Ortho_UTAService class that encapsulates general methods related
* to UserTerritory2Associations and User_Territory_Association__c
*/
public class Ortho_UTAService extends Ortho_AppModel{

    /**============================================================
    * @description It changes opportunity team members based on
                    territory changes of users and opportunities.
    *============================================================*/

    public static void alignOpportunityTeam(List<UserTerritoryAssociation> utaList, Boolean isInsert, Boolean isUpdate){
        Map<Id, Set<Id>> terrIdSetByUserIdMap = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> oppIdSetByTerritoryIdMap = new Map<Id, Set<Id>>();
        Map<Id, Opportunity> oppMap = new Map<Id, Opportunity>();
        Map<Id, Territory2> terrMap = new Map<Id, Territory2>();
        String UTKey = '';
        Set<String> processedUTSet = new Set<String>();

        Map<String, OpportunityTeamMember> otmMap = new Map<String, OpportunityTeamMember>();
        Map<Id, Set<Id>> mapParentAndChildIds = Ortho_Util.getParentChildTerritoryMap();
        String otmKey;
        Opportunity opp;
        OpportunityTeamMember otm;
        Set<Id> tIdSet = new Set<Id>();
        List<OpportunityTeamMember> oppTeamList = new List<OpportunityTeamMember>();
        Set<Id> territoryIdSet = new Set<Id>();

        List<String> lstTerrIds = new List<String>();
        for(UserTerritoryAssociation uta : utaList){
            lstTerrIds.add(uta.terrtoryId);
            territoryIdSet.add(uta.terrtoryId);
            if(!terrIdSetByUserIdMap.containsKey(uta.terrtoryId)){
                terrIdSetByUserIdMap.put(uta.terrtoryId, new Set<Id>());
            }
            tIdSet = Ortho_Util.leafNodes(uta.terrtoryId, mapParentAndChildIds);
            if(tIdSet.size() > 0){
                territoryIdSet.addAll(tIdSet);
                terrIdSetByUserIdMap.get(uta.terrtoryId).addAll(tIdSet);
            }
        }
        

        for(Opportunity sObjOpp : [SELECT Id, Territory2Id, OwnerId, RecordTypeId FROM Opportunity WHERE Territory2Id IN :territoryIdSet AND IsClosed = false]){
            oppMap.put(sObjOpp.Id, sObjOpp);
            if(!oppIdSetByTerritoryIdMap.containsKey(sObjOpp.Territory2Id)){
                oppIdSetByTerritoryIdMap.put(sObjOpp.Territory2Id, new Set<Id>());
            }
            oppIdSetByTerritoryIdMap.get(sObjOpp.Territory2Id).add(sObjOpp.Id);
        }

        List<String> oppTeamMemberRoles = Ortho_SettingsService.getGeneralSettingValueByName(Ortho_Constants.TEAM_MEMBER_ROLE).split(',');
        for(OpportunityTeamMember sObjOtm : [SELECT Id, UserId, OpportunityId
            FROM OpportunityTeamMember
            WHERE OpportunityId IN :oppMap.keySet() AND TeamMemberRole != :Ortho_Constants.OPP_OWNER_ROLE
                                                    AND TeamMemberRole IN :oppTeamMemberRoles]){
            otmKey = '' + sObjOtm.OpportunityId + '' + sObjOtm.UserId;
            if(String.isNotBlank(otmKey)){
                otmMap.put(otmKey, sObjOtm);
            }
        }

        for(UserTerritoryAssociation uta : utaList){
            if(uta.userId != NULL && terrIdSetByUserIdMap.containsKey(uta.terrtoryId)){
                for(String terrId : terrIdSetByUserIdMap.get(uta.terrtoryId)){
                    UTKey = ''+uta.userId + terrId;
                    if(!processedUTSet.contains(UTKey) && oppIdSetByTerritoryIdMap.containsKey(terrId)){
                        processedUTSet.add(UTKey);
                        for(String oppId : oppIdSetByTerritoryIdMap.get(terrId)){
                            otmKey = oppId + uta.userId;
                            opp = oppMap.get(oppId);
                            if(isInsert){
                                otm = OpportunityService.createOTM(opp, uta, null);
                                if(otm.TeamMemberRole != null){
                                    oppTeamList.add(otm);
                                }
                            }else if(isUpdate && otmMap.containsKey(otmKey)){
                                otm = OpportunityService.createOTM(opp, uta, null);
                                otm.Id = otmMap.get(otmKey).Id;
                                oppTeamList.add(otm);
                            }else if(otmMap.containsKey(otmKey)){
                                oppTeamList.add(otmMap.get(otmKey));
                            }

                        }

                    }
                }
            }
        }

        if(!oppTeamList.isEmpty()){

            String serializedList = JSON.serialize(oppTeamList);
            Ortho_UTAService.addRemoveOtm(serializedList, isInsert, isUpdate);

        }

        if (!lstTerrIds.isEmpty()) 
        {
            PO_Util.recreatePOSharesForTerritory(lstTerrIds);
        }
        
    }

@future
public static void addRemoveOtm(String teamlist, Boolean isInsert, Boolean isUpdate){

    List<OpportunityTeamMember> deserializedList =
        (List<OpportunityTeamMember>) JSON.deserialize(teamlist, List<OpportunityTeamMember>.Class);

    List<OpportunityTeamMember> nonDupOTMList = new List<OpportunityTeamMember>(new Set<OpportunityTeamMember>(deserializedList));
    if(isInsert){
        insert nonDupOTMList;
    }else if(isUpdate){
        update nonDupOTMList;
    }else{
        delete nonDupOTMList;
    }
}
}