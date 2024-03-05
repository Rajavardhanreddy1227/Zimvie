public class Ortho_CommunicationsController {

    public class GroupMembership {
        @AuraEnabled
        public string GroupId {get; set;}

        @AuraEnabled
        public string Name {get; set;}

        @AuraEnabled
        public string Role {get; set;}

        public GroupMembership(CollaborationGroup cg){
            this.GroupId = cg.Id;
            this.Name = cg.Name;
            if(cg.GroupMembers.size() > 0){
                CollaborationGroupMember cgm = cg.GroupMembers[0];
                this.Role = cgm.CollaborationRole;
            }
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<GroupMembership> getGroups() {
        List<CollaborationGroup> groups = [select id, name,
                                           (Select ID, CollaborationRole from GroupMembers where MemberId =: UserInfo.getUserId())
                                           from CollaborationGroup where Id in (select CollaborationGroupId from CollaborationGroupMember where MemberId  =: UserInfo.getUserId())
                                           and Name in: Ortho_GroupsService.groupNames];

        List<GroupMembership> groupMembership = new List<GroupMembership>();

        for(CollaborationGroup cg : groups){
            groupMembership.add(new GroupMembership(cg));
        }
        return groupMembership;
    }

    @AuraEnabled(cacheable=true)
    public static List<ConnectApi.Announcement> getAnnouncements(){
        List<ConnectApi.Announcement> currentAnnouncements = new List<ConnectApi.Announcement>();

        for(GroupMembership gm : getGroups()){
            ConnectApi.AnnouncementPage announcementPage = ConnectApi.Announcements.getAnnouncements(null, gm.GroupId);
            for(ConnectApi.Announcement announcement : announcementPage.announcements){
                Date expirationDate = Date.valueOf(announcement.expirationDate);

                if(expirationDate >= Date.today()){
                    currentAnnouncements.add(announcement);
                }
            }
        }
        return currentAnnouncements;
    }

    @AuraEnabled(cacheable=true)
    public Static Boolean isGroupAdmin(String groupId){
        Boolean isAdmin = false;
        List<CollaborationGroupMember> cgm = Ortho_CollaborationGroupMemberSelector.selectCollaborationGroupMembersByMemberAndGroup(new Set<Id>{UserInfo.getUserId()}, new Set<Id>{groupId});
        if(cgm.size() > 0){
            CollaborationGroupMember member = cgm.get(0);
            if(member.CollaborationRole == 'Admin'){
                isAdmin = true;
            }
        }
        return isAdmin;
    }
}