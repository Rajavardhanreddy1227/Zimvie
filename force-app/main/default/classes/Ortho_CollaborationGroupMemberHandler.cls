public class Ortho_CollaborationGroupMemberHandler {
    public static void onBeforeInsert(List<CollaborationGroupMember> records){
        setDigestFrequencyForCommunicationGroups(records);
    }
    public static void onBeforeUpdate(List<CollaborationGroupMember> records, Map<Id, CollaborationGroupMember> oldMap){
        setDigestFrequencyForCommunicationGroups(records);
    }
    
    public static void setDigestFrequencyForCommunicationGroups(List<CollaborationGroupMember> records){
        Set<Id> communicationGroupIds = new Set<Id>();

        for(CollaborationGroup cg : Ortho_GroupsService.communicationGroups){
            communicationGroupIds.add(cg.Id);
        }
        for(CollaborationGroupMember cgm : records){
            System.debug('Adding Member Notification Frequency :'+cgm);
            if(communicationGroupIds.contains(cgm.CollaborationGroupId) && cgm.NotificationFrequency <> 'P'){
                System.debug('Setting the Notification Frequency to P for Group and Member : '+cgm.CollaborationGroupId+' - ' + cgm.MemberId);
                //cgm.NotificationFrequency = 'P';
            }
        }
    }


}