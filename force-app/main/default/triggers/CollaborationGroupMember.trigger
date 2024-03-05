trigger CollaborationGroupMember on CollaborationGroupMember (before insert, before update) {
    if(!Ortho_TriggerSettings.isTriggerDisabled('CollaborationGroupMember')){
        if(Trigger.isInsert){
            if(Trigger.isBefore){
                Ortho_CollaborationGroupMemberHandler.onBeforeInsert(Trigger.new);
            }
            if(Trigger.isAfter){}

        }
        if(Trigger.isUpdate){
            if(Trigger.isBefore){
                Ortho_CollaborationGroupMemberHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
            }
            if(Trigger.isAfter){}
        }
    }
}