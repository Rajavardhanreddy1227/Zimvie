public with sharing class Ortho_CollaborationGroupMemberSelector {
    public static List<String> fields = new List<String>{
        'Id', 
        'CollaborationGroupId', 
        'CollaborationRole',
        'MemberId',
        'NotificationFrequency'
    };

    public static List<CollaborationGroupMember> selectCollaborationGroupMembersByMemberAndGroup(Set<Id> memberIds, Set<Id> groupIds){
        String query = String.format('SELECT {0} FROM CollaborationGroupMember WHERE memberId in: memberIds and CollaborationGroupId in: groupIds', 
            new List<Object>{String.join(fields, ',')});
        return (List<CollaborationGroupMember>) Database.query(query);
    } 
}