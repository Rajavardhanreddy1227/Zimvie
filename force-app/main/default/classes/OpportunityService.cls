/**
* @author Appirio Inc.
* @date 7/24/2020
* @group Opportunity
* @description OpportunityService class that encapsulates general methods related to Opportunity
*/
public class OpportunityService extends Ortho_AppModel{

   /**============================================================
	* @description It returns Team (territory) that is assigned to both the
	*	Healthcare facility and the logged-in user
	*============================================================*/
    public static Map<String, List<Territory2>> getTerritoriesForOpportunities(List<Opportunity> oppList, Set<Id> accIdSet){
        Map<Id, Set<Id>> mapParentAndChildIds = Ortho_Util.getParentChildTerritoryMap();
        Set<Id> userTerritoryIdSet = new Set<Id>();
        Set<Id> territoryIdSet = new Set<Id>();
        Set<Id> tIdSet = new Set<Id>();
        Map<String, List<Territory2>> territory2MapByOppId = new Map<String, List<Territory2>>();
        if(accIdSet == null || accIdSet.isEmpty()){
            accIdSet = new Set<Id>();
            for(Opportunity opp : oppList){
            	accIdSet.add(opp.AccountId);
            }
        }
        
        List<UserTerritory2Association> lstUTAssociationList = Ortho_UserTerr2AssociationSelector.selectUtaByUser();
        
    
        for(UserTerritory2Association uta : lstUTAssociationList){
        	userTerritoryIdSet.add(uta.Territory2Id);
        }

        for(Id tId : userTerritoryIdSet){
            tIdSet = Ortho_Util.leafNodes(tId, mapParentAndChildIds);
            if(tIdSet.size() > 0){
                territoryIdSet.addAll(tIdSet);
            }
        }

        userTerritoryIdSet.addAll(territoryIdSet);

        
        List<ObjectTerritory2Association> otaList = Ortho_ObjTerr2AssociationSelector.selectOtaByObjAndTerrId(accIdSet,userTerritoryIdSet);
        
        
        for(ObjectTerritory2Association ota : otaList){
                 for(Opportunity opp : oppList){
                     if(!territory2MapByOppId.containsKey(opp.Id)){
                     	territory2MapByOppId.put(opp.Id, new List<Territory2>());
                     }
                     territory2MapByOppId.get(opp.Id).add(new Territory2(Id = ota.Territory2Id,
                         											   Name = ota.Territory2.Name));
                 }
        }
        return territory2MapByOppId;

    }


    /**
	* @description It returns filtered list of opportunities based
	*	on field names.
	**/
    public static List<Opportunity> filterOpportunities(List<Opportunity> oppList, String fieldName, Set<String> values){
        List<Opportunity> fOppList = new List<Opportunity>();
        for(Opportunity opp : oppList){
            if(values.contains((String)opp.get(fieldName))){
                fOppList.add(opp);
            }
        }
        return fOppList;
    }

    /**
    * @description It creates opportunity team members on opportunity record
    *                
    **/
    public static OpportunityTeamMember createOTM(Opportunity opp, UserTerritoryAssociation uta, Set<Id> territoryHeadIds){
        OpportunityTeamMember otm = new OpportunityTeamMember();
        otm.UserId = uta.UserId;
        otm.OpportunityId = opp.Id;
        if(uta.role != null && opp.OwnerId != uta.UserId){
                if(uta.role.equalsIgnoreCase(Ortho_Constants.SALES_MANAGER)){
                    otm.TeamMemberRole = Ortho_Constants.US_ORTHO +' - '+ Ortho_Constants.SALES_MANAGER;
                    otm.OpportunityAccessLevel = 'Edit';
                }
                else if(uta.role.equalsIgnoreCase(Ortho_Constants.TEAM_LEAD)){
                    otm.TeamMemberRole = Ortho_Constants.US_ORTHO +' - '+ Ortho_Constants.TEAM_LEAD;
                    otm.OpportunityAccessLevel = 'Edit';
                }
                else if(uta.role.equalsIgnoreCase(Ortho_Constants.NON_SENIOR_REP)){

                        otm.TeamMemberRole = Ortho_Constants.US_ORTHO +' - '+Ortho_Constants.NON_SENIOR_REP;
                        otm.OpportunityAccessLevel = 'Read';

                }
                else if(uta.role.equalsIgnoreCase(Ortho_Constants.SENIOR_REP)){

                        otm.TeamMemberRole = Ortho_Constants.US_ORTHO +' - '+ Ortho_Constants.SENIOR_REP;
                        otm.OpportunityAccessLevel = 'Read';

                }
                else if(uta.role != null && Ortho_Constants.OPP_RECORD_TYPE_MAP_BY_PRODUCT.containsKey(opp.RecordTypeId)){
                    if(Ortho_Constants.OPP_RECORD_TYPE_MAP_BY_PRODUCT.get(opp.RecordTypeId) == uta.role){
                        otm.TeamMemberRole = Ortho_Constants.US_ORTHO +' - '+ Ortho_Constants.PRODUCT_SPECIALIST;
                        otm.OpportunityAccessLevel = 'Edit';
                    }
                }    
        }else if(opp.OwnerId != uta.UserId && territoryHeadIds != NULL && territoryHeadIds.contains(uta.terrtoryId)){
            otm.TeamMemberRole = Ortho_Constants.US_ORTHO +' - '+ Ortho_Constants.TERRITORY_LEAD;
            otm.OpportunityAccessLevel = 'Edit';
        }
        return otm;
    }

}