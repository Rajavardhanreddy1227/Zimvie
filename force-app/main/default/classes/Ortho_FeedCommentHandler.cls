public with sharing class Ortho_FeedCommentHandler {
    public static void onBeforeInsert(List<FeedComment> records){
        disableCommentsInCommunicationGroups(records);
    }

    public static void disableCommentsInCommunicationGroups(List<FeedComment> records){
       
        Set<Id> communicationGroupIds = new Set<Id>();

        for(CollaborationGroup cg : Ortho_GroupsService.communicationGroups){
            communicationGroupIds.add(cg.Id);
        }

        for(FeedComment fc : records){
            if(communicationGroupIds.contains(fc.ParentId)){
                fc.addError(Label.Ortho_Comment_Not_Allowed);
            }
        }
    }
  
}