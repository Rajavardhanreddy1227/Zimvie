/**
* @author Appirio Inc.
* @date Feb, 2020
*
* @group Opportunity
*
* @description Encapsulates all behaviour logic relating to the Opportunity object
*       For more guidelines and details see
*    https://developer.salesforce.com/page/Apex_Enterprise_Patterns_-_Domain_Layer

*/
public class Ortho_Opportunities extends Ortho_AppModel{

    public static void onAfterInsert(List<Opportunity> oppList){
        List<Opportunity> updatedOppList = new List<Opportunity>();
        Set<Id> terrIds = new Set<Id>();
        Map<Id,Id> oppTerrMap = new Map<Id,String>();

        for (Opportunity opp: oppList){
            if(opp.Territory2Id != null){
                updatedOppList.add(opp);
                terrIds.add(opp.Territory2Id);
                oppTerrMap.put(opp.Id, opp.Territory2Id);
            }
        }
        if(!updatedOppList.isEmpty()){
            createOpportunityTeamMembers(updatedOppList, terrIds, oppTerrMap, false);
        }
    }

    public static void onBeforeInsert(List<Opportunity> oppList){
        List<Opportunity> updatedOppList = new List<Opportunity>();
        if(!oppList.isEmpty()){
            assignTerritories(oppList);
        }
        for (Opportunity opp: oppList){
            if(opp.Territory2Id != null){
                updatedOppList.add(opp);
            }
        }
        if(!updatedOppList.isEmpty()){
            setDefaults(updatedOppList);
        }
    }

    public static void onAfterUpdate(List<Opportunity> oppList, Map<Id, Opportunity> oldMap){
         List<Opportunity> updatedOppList = new List<Opportunity>();
        List<Opportunity> updatedOppListForOwner = new List<Opportunity>();
        Set<Id> terrIds = new Set<Id>();
        Map<Id,Id> oppTerrMap = new Map<Id,String>();
        Set<Id> terrIdsForOwner = new Set<Id>();
        Map<Id,Id> oppTerrMapForOwner = new Map<Id,String>();

        for (Opportunity opp: oppList){
            if(opp.Territory2Id != null && (opp.Territory2Id != oldMap.get(opp.Id).Territory2Id || String.isBlank(oldMap.get(opp.Id).Territory2Id))) {
                updatedOppList.add(opp);
                terrIds.add(opp.Territory2Id);
                oppTerrMap.put(opp.Id, opp.Territory2Id);
            }
            //MV 5/20/2020
            if(opp.Territory2Id != null && opp.Territory2Id == oldMap.get(opp.Id).Territory2Id && String.isNotBlank(oldMap.get(opp.Id).Territory2Id)
               && opp.OwnerId != oldMap.get(opp.Id).OwnerId){
                updatedOppListForOwner.add(opp);
                terrIdsForOwner.add(opp.Territory2Id);
                oppTerrMapForOwner.put(opp.Id, opp.Territory2Id);
            }
        }
        
        if(!updatedOppList.isEmpty()){
            createOpportunityTeamMembers(updatedOppList, terrIds, oppTerrMap, false);
        }
        //MV 5/20/2020
        if(!updatedOppListForOwner.isEmpty()){            
            createOpportunityTeamMembers(updatedOppListForOwner, terrIdsForOwner, oppTerrMapForOwner, true);
        }
    }

    public static void onBeforeUpdate(List<Opportunity> oppList, Map<Id, Opportunity> oldMap){
        List<Opportunity> updatedOppList = new List<Opportunity>();
        for (Opportunity opp: oppList){
            if(opp.Territory2Id != null && opp.Territory2Id != oldMap.get(opp.Id).Territory2Id){
                updatedOppList.add(opp);
            }
        }

        if(!updatedOppList.isEmpty()){
            onValidate(updatedOppList);
            setDefaults(updatedOppList);
        }
    }

    /**
    * @description Creates Opportunity Team members on insert of Opportunity and
    * deletes old team members(except owner) on change of opportunity territory
    *
    * @param oppList Opportunities which will be updated
    * @param terrIdSet Ids of territories related to opportunities
    * @param oppTerrMap Map of Territories assigned to Opportunities
    */

    public static void createOpportunityTeamMembers(List<Opportunity> oppList, Set<Id> oppTerrIdSet, Map<Id,Id> oppTerrMap, Boolean isInsert){
        Set<Id> terrIdSet = new Set<Id>();
      

        map<String,OpportunityTeamMember> delTeamMembers = new map<String,OpportunityTeamMember>();
        map<String,OpportunityTeamMember> updateTeamMembersRole = new map<String,OpportunityTeamMember>();
        List<OpportunitySplit> oppSplitMembers = new List<OpportunitySplit>();
        map<String,OpportunitySplit> delSplitMembers = new map<String,OpportunitySplit>(); 

        List<String> oppTeamMemberRoles = Ortho_SettingsService.getGeneralSettingValueByName(Ortho_Constants.TEAM_MEMBER_ROLE).split(',');

        oppSplitMembers = [SELECT Id, SplitOwnerId,SplitOwner.Name,OpportunityId,Opportunity.Name,SplitPercentage
                            FROM OpportunitySplit WHERE OpportunityId IN :oppList];
        
        for(OpportunityTeamMember otm :[Select Id, OpportunityId,Opportunity.OwnerId, UserId from OpportunityTeamMember where OpportunityId IN :oppList
                          AND TeamMemberRole != :Ortho_Constants.OPP_OWNER_ROLE AND TeamMemberRole IN :oppTeamMemberRoles])
        {
            for(OpportunitySplit ops : oppSplitMembers)
            {
                if(ops.OpportunityId == otm.OpportunityId)
                {
                    if(ops.SplitOwnerId == otm.UserId )
                    {
                        if(ops.SplitOwnerId == otm.Opportunity.OwnerId){
                            otm.TeamMemberRole = Ortho_Constants.OPP_OWNER_ROLE;
                            updateTeamMembersRole.put(otm.Id,otm);
                        }
                        else{
                            delSplitMembers.put(ops.Id,ops); 
                            delTeamMembers.put(otm.Id,otm);
                        }
                    }
                }
            }
        }
            
        if(!updateTeamMembersRole.isEmpty()){

            update updateTeamMembersRole.values();
        }

		if(!delSplitMembers.isEmpty()){

            delete delSplitMembers.values();
        }
        
        if(!delTeamMembers.isEmpty()){

            delete delTeamMembers.values();
        }
        
        terrIdSet.addAll(oppTerrIdSet);
		
		Map<Id, List<Id>> opptyTerrMap = new Map<Id, List<Id>>();
		
        List<OpportunityTeamMember> otmList = new List<OpportunityTeamMember>();
        
        Set<Id> territoryHeadIds = new Set<Id>();
        for(Territory2 terr : [SELECT Id, ParentTerritory2Id, ParentTerritory2.ParentTerritory2Id FROM Territory2
            WHERE Id IN :oppTerrIdSet AND ParentTerritory2Id != NULL
            AND ParentTerritory2.ParentTerritory2Id != NULL]){
            terrIdSet.add(terr.ParentTerritory2Id);
            terrIdSet.add(terr.ParentTerritory2.ParentTerritory2Id);
            territoryHeadIds.add(terr.ParentTerritory2.ParentTerritory2Id);
			
			List<Id> tIds = new List<Id>();
			tIds.add(terr.Id);
            if (terr.ParentTerritory2Id !=null)
            {
				tIds.add(terr.ParentTerritory2Id);
                if (terr.ParentTerritory2.ParentTerritory2Id != null)
                	tIds.add(terr.ParentTerritory2.ParentTerritory2Id);
            }			
			
			opptyTerrMap.put(terr.Id, tIds);
			
            //Id[] territoryIds = new Id[]{Id, terr.ParentTerritory2Id, terr.ParentTerritory2.ParentTerritory2Id};
            		
        }
        
        Map<Id, Territory2> terrMap = new Map<Id, Territory2>(Ortho_TerritorySelector.selectAllTerritoriesByTerrId(terrIdSet));
        
        //System.debug(terrMap);
        //Map<Id, Territory2> terrMap = new Map<Id, Territory2>([SELECT Id, Name FROM Territory2 WHERE Id IN :terrIdSet]);

        Map<Id, List<UserTerritoryAssociation>> terrUserMap = Ortho_Util.getUserTerritoryAssociations(terrIdSet);
        List<UserTerritoryAssociation> utaList = new List<UserTerritoryAssociation>();
        OpportunityTeamMember otm;

        for(Opportunity opp : oppList){            
            for(Id tId : terrIdSet){
                // Following Condition was changed - Bulk Import of Opportunities Data Loader Issue
				if(tId != NULL && opptyTerrMap.get(opp.Territory2Id) != null && opptyTerrMap.get(opp.Territory2Id).contains(tId)) {                    
                //if(tId != NULL && terrUserMap.containsKey(tId)){
                    //System.debug('Oppty: '+opp.Id + ' has territory : '+tId + ' and will add '+utaList.size() + ' OT Mbrs');
                    utaList = terrUserMap.get(tId);
                    
                    if (utaList != null) {
                        for(UserTerritoryAssociation uta : utaList){
                            otm = OpportunityService.createOTM(opp, uta, territoryHeadIds);
                            if(otm.TeamMemberRole != NULL){
                                otmList.add(otm);
                            }
                        }
                    }
                    
                }
            }
        }

        if(!otmList.isEmpty()){
            insert otmList;
        }
    }



    /**
    * @description Sets default value of Ortho_Team__c field to assigned territory name.
    *
    * @param oppList Opportunities which will be updated
    */

    public static void setDefaults(List<Opportunity> oppList){
        Set<Id> terrIdSet = new Set<Id>();
        Map<Id, Territory2> terrMap = new Map<Id, Territory2>();
        for(Opportunity opp : oppList){
            if(opp.Territory2Id != NULL){
                terrIdSet.add(opp.Territory2Id);
            }
            opp.IsExcludedFromTerritory2Filter = true;
        }
        
        terrMap = new Map<Id, Territory2>(Ortho_TerritorySelector.selectAllTerritoriesByTerrId(terrIdSet));
        
        //terrMap = new Map<Id, Territory2>([SELECT Id, Name FROM Territory2 WHERE Id IN :terrIdSet]);

        for(Opportunity opp : oppList){
            if(opp.Territory2Id != null && terrMap != null && terrMap.containsKey(opp.Territory2Id)){
                opp.Ortho_Team__c = terrMap.get(opp.Territory2Id).Name;
            }
        }

        populateRegionOnOpportunity(oppList, terrIdSet);

    }

    /**
    * @description Populates region name on opportunity from territory hierarchy based on Opportunity territory.
    *
    * @param oppList Opportunities which will be updated
    * @param terrIdSet Ids of territories related to opportunities
    **/
    public static void populateRegionOnOpportunity(List<Opportunity> oppList, Set<Id> territoryIds){

        Map<Id,String> productRegionMap = new Map<Id,String>();
        
        List<Territory2> territoryList = Ortho_TerritorySelector.selectTerritoryById(territoryIds);
        
        /*List<Territory2> territoryList = new List<Territory2>([SELECT Id, Name, ParentTerritory2Id,
                                                             ParentTerritory2.ParentTerritory2Id,
                                                             ParentTerritory2.ParentTerritory2.ParentTerritory2.Name,
                                                             ParentTerritory2.ParentTerritory2.ParentTerritory2Id
                                                             FROM Territory2 WHERE Id IN: territoryIds
                                                             AND ParentTerritory2Id != NULL
                                                             AND ParentTerritory2.ParentTerritory2Id != NULL
                                                             AND ParentTerritory2.ParentTerritory2.ParentTerritory2Id != NULL]);*/
        for(Territory2 terr : territoryList){
            if(terr.ParentTerritory2Id != NULL && terr.ParentTerritory2.ParentTerritory2Id != NULL
                && terr.ParentTerritory2.ParentTerritory2.ParentTerritory2Id != NULL){
                productRegionMap.put(terr.Id, terr.ParentTerritory2.ParentTerritory2.ParentTerritory2.Name);
            }
        }

        for(Opportunity opp: oppList){
            if(productRegionMap.containsKey(opp.Territory2Id)){
                opp.US_Ortho_Region_Name__c = productRegionMap.get(opp.Territory2Id);
            }
        }
    }


    /**
    * @description Assign opportunity to territory based on Healthcare facility, surgeon and Opportunity record type.
    *
    * @param opps Opportunities which will be updated
    */
    public static void assignTerritories(List<Opportunity> opps){
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Set<Id>> accountsToTerritoryMap = new Map<Id,Set<Id>>();
        Map<String,String> oppRecTypeToNameMap = Ortho_Util.getUSOrthoOpptyRecordTypes();
        Set<Id> territoryIdsPerHospital = new Set<Id>();
        Set<Id> territoryIdsPerSurgeon = new Set<Id>();
        Set<Id> terrIdSet = new Set<Id>();
		
        
        Map<Id,Territory2> territoryIdToNameMap = new Map<Id,Territory2>(Ortho_TerritorySelector.selectAllTerritories());
        
        String commonTerritoryId, oppRecTypeName, territoryName;
        Integer matchCount = 0;

        for(Opportunity o:opps){
                accountIds.add(o.Surgeon_Name__c);
                accountIds.add(o.AccountId);
        }
        
        List<ObjectTerritory2Association> accounts2TerritoryList = Ortho_ObjTerr2AssociationSelector.selectObjectTerritory2AssociationById(AccountIds);

       for(ObjectTerritory2Association ota : accounts2TerritoryList){
            terrIdSet.add(ota.Territory2Id);
            if(!accountsToTerritoryMap.containsKey(ota.ObjectId)){
                accountsToTerritoryMap.put(ota.ObjectId, new Set<Id>());
            }
            accountsToTerritoryMap.get(ota.ObjectId).add(ota.Territory2Id);

        }


        Map<Id, List<UserTerritoryAssociation>> terrUserMap = Ortho_Util.getUserTerritoryAssociations(terrIdSet);
        List<UserTerritoryAssociation> utaList = new List<UserTerritoryAssociation>();

        for(Opportunity o : opps){
            matchCount = 0;
			territoryIdsPerHospital = new Set<Id>();
            territoryIdsPerSurgeon = new Set<Id>();
            if(accountsToTerritoryMap.containsKey(o.AccountId)){

                territoryIdsPerHospital = accountsToTerritoryMap.get(o.AccountId);

            }
            if(accountsToTerritoryMap.containsKey(o.Surgeon_Name__c)){
                territoryIdsPerSurgeon = accountsToTerritoryMap.get(o.Surgeon_Name__c);
            }

            for(Id i : territoryIdsPerHospital){
                if(territoryIdToNameMap.containsKey(i)){
                    Territory2 t = territoryIdToNameMap.get(i);
                    if(territoryIdsPerSurgeon.contains(i)){
                        if(terrUserMap.containsKey(i)){
                            for(UserTerritoryAssociation uta : terrUserMap.get(i)){
                                if(uta.role != NULL && Ortho_Constants.OPP_RECORD_TYPE_MAP_BY_PRODUCT.containsKey(o.RecordTypeId)
                                    && Ortho_Constants.OPP_RECORD_TYPE_MAP_BY_PRODUCT.get(o.RecordTypeId) == uta.role){
                                        CommonTerritoryId = t.Id;
                                        matchCount+=1;
                                        break;
                                }
                            }
                        }
                    }
                }

            }
            
            if(matchCount == 1 && o.AccountId != NULL && o.Surgeon_Name__c != NULL){
                o.Territory2Id = commonTerritoryId;
            }
        }

    }

    /**
    * @description Validates the new territory assigned to opportunity based on healthcare facility and logged in user.
    *
    * @param oppList Opportunities which will be updated
    */

    public static void onValidate(List<Opportunity> oppList){
        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()];
        if(!profileList.isEmpty() && !Ortho_Constants.SKIP_PROFILE_SET.contains(profileList.get(0).Name)){
            Map<String, List<Territory2>> territory2MapByOppId = OpportunityService.getTerritoriesForOpportunities(oppList, null);
            Boolean isTerrFound;
            List<Territory2> tempList;
            for(Opportunity opp : oppList){
                isTerrFound = false;
                if(territory2MapByOppId.containsKey(opp.Id) ){
                    tempList = territory2MapByOppId.get(opp.Id);
                    for(Territory2 terr : tempList){
                        if(terr.Id == opp.Territory2Id){
                            isTerrFound = true;
                            opp.Ortho_Team__c = terr.Name;
                            break;
                        }
                    }

                    if(!isTerrFound){
                        opp.addError(System.Label.Ortho_Invalid_Territory_Error_Message);
                    }

                }else{
                    opp.addError(System.Label.Ortho_No_Territory_Found);
                }
            }
        }

    }

}