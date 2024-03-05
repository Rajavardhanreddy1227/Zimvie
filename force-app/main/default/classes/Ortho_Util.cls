/**
 * @author Appirio
 * @date Feb, 2020
 *
 * @description Contains utility methods for generic use.
 */

public class Ortho_Util extends Ortho_AppModel{

    /**
    * @description Returns all the record types for Opportunity object.
    */
	public static Map<String,String> getUSOrthoOpptyRecordTypes(){
        Map<String, String> mapRecTypes = new Map<String,String>();

        List<String> recTypes = Ortho_SettingsService.getGeneralSettingValueByName('Opportunity_RecordTypes').split(',');
        for(RecordType rt: [SELECT Id, sObjectType, Name, DeveloperName
            FROM RecordType WHERE sobjectType = 'Opportunity' AND Name in : recTypes]){
            mapRecTypes.put(rt.Id, rt.Name);
        }
        return mapRecTypes;
    }

    /**
    * @description Returns all the leaf territories of given territiries
    */
    public static Set<Id> leafNodes(Id parentTerrId, Map<Id, Set<Id>> mapParentAndChildIds) {
        Set<Id> nodesToRet = new Set<Id>();
        if (mapParentAndChildIds.containsKey(parentTerrId)) {
            for (Id terrId : mapParentAndChildIds.get(parentTerrId)) {
                if (mapParentAndChildIds.containskey(terrId)) {
                    nodesToRet.addAll(leafNodes(terrId, mapParentAndChildIds));
                } else {
                    nodesToRet.add(terrId);
                }
            }
        } else {
            nodesToRet.add(parentTerrId);
        }
        return nodesToRet;

    }

    /**
    * @description Returns all the leaf territories of given territiries
    */
    public static Map<Id, List<UserTerritoryAssociation>> getUserTerritoryAssociations(Set<id> terrIdSet) {
        Map<Id, List<UserTerritoryAssociation>> terrUserMap = new Map<Id, List<UserTerritoryAssociation>>();

       List<UserTerritory2Association> utaList = Ortho_UserTerr2AssociationSelector.selectUtaByTerrId(terrIdSet);

        for(UserTerritory2Association uta2 : utaList){
            if(!terrUserMap.containsKey(uta2.Territory2Id)){
                terrUserMap.put(uta2.Territory2Id, new List<UserTerritoryAssociation>());
            }
            terrUserMap.get(uta2.Territory2Id).add(
                new UserTerritoryAssociation(uta2.UserId, uta2.Territory2Id, uta2.RoleInTerritory2));
        }

        List<User_Territory_Association__c> utaCustomList = Ortho_UserTerrAssociationSelector.selectUtaByTerrId(terrIdSet);

        for(User_Territory_Association__c uta : utaCustomList){
            if(!terrUserMap.containsKey(uta.Territory__C)){
                terrUserMap.put(uta.Territory__C, new List<UserTerritoryAssociation>());
            }
            terrUserMap.get(uta.Territory__C).add(
                new UserTerritoryAssociation(uta.User__c, uta.Territory__C, uta.Role__C));
        }

        return terrUserMap;
    }

    /**
    * @description Returns all the parent Child Territory Map
    */
    public static Map<Id, Set<Id>> getParentChildTerritoryMap(){
        Map<Id, Set<Id>> mapParentAndChildIds = new Map<Id, Set<Id>>();

        for (Territory2 terrObj : Ortho_TerritorySelector.selectAllTerritories()) {
            if (mapParentAndChildIds.containsKey(terrObj.ParentTerritory2Id) == false) {
                mapParentAndChildIds.put(terrObj.ParentTerritory2Id, new Set<Id>());
            }
            mapParentAndChildIds.get(terrObj.ParentTerritory2Id).add(terrObj.Id);
        }

        return mapParentAndChildIds;
    }
}