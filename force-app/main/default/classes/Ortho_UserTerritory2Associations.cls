/**
* @author Appirio Inc.
* @date March, 2020
*
* @group UserTerritory2Associations
*
* @description Encapsulates all behaviour logic relating to the UserTerritory2Association object
*       For more guidelines and details see
*    https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer
*/
public class Ortho_UserTerritory2Associations extends Ortho_AppModel{

    public static void onAfterInsert(List<UserTerritory2Association> sObjUTAList){
        List<UserTerritoryAssociation> utaList = new List<UserTerritoryAssociation>();
        for(UserTerritory2Association uta : sObjUTAList){
            utaList.add(new UserTerritoryAssociation((Object)uta));
        }
        Ortho_UTAService.alignOpportunityTeam(utaList, true, false);
    }

    public static void onAfterDelete(List<UserTerritory2Association> sObjUTAList){
        List<UserTerritoryAssociation> utaList = new List<UserTerritoryAssociation>();
        for(UserTerritory2Association uta : sObjUTAList){
            utaList.add(new UserTerritoryAssociation((Object)uta));
        }
        Ortho_UTAService.alignOpportunityTeam(utaList, false, false);
    }

    public static void onAfterUpdate(List<UserTerritory2Association> newList, Map<Id, UserTerritory2Association> oldMap){
        List<UserTerritoryAssociation> updatedUTAList = new List<UserTerritoryAssociation>();
        for(UserTerritory2Association uta : newList){
            if(oldMap != NULL && oldMap.get(uta.id).RoleInTerritory2 != uta.RoleInTerritory2){
                updatedUTAList.add(new UserTerritoryAssociation((Object)uta));
            }
        }
        if(!updatedUTAList.isEmpty()){
            Ortho_UTAService.alignOpportunityTeam(updatedUTAList, false, true);
        }
    }

}