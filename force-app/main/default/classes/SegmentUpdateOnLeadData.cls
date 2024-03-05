//***************************//
        // Developer  : Hardeep Brar
        // Version    : 1.0
        // Object     : Campaign Member
        // Trigger    : SegmentUpdateOnLead
        //***************************//

        public class SegmentUpdateOnLeadData {
            public static void campaignMemberData(List<CampaignMember> campMemberList ){ 
            System.debug('Camp Memeber List Size ' + campMemberList.size());
      
                    List<Lead> ldlist = new List<Lead>();
                    set<id> campaignIDs = new set<id>();
                    set<id> leadIDs = new set<id>();                    
                    for(CampaignMember cmm : campMemberList)
                    {                        
                    campaignIDs.add(cmm.CampaignID);                                            
                    }               
                    
                    Map<ID,Campaign> campaignMap = new Map<ID,Campaign>([Select id, Segment__c from Campaign Where id IN :campaignIDs]);
                                        
                    for(CampaignMember cmm : campMemberList){
                      if((cmm.CampaignId <>NULL) && (cmm.LeadId<>NULL)) {
                        if (campaignMap.get(cmm.CampaignID).Segment__c <>'NULL'){
                            Lead L =new Lead(id=cmm.LeadID, Campaign_Segment__c = campaignMap.get(cmm.CampaignID).Segment__c);      
                            ldlist.add(L);
                           }
                        }  
                    }
                    if(ldlist.size()>0){
                        update ldlist;
                    } 
                }                  
            }