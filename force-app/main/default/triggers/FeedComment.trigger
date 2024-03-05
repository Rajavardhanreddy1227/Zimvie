trigger FeedComment on FeedComment (before insert) {
    if(!Ortho_TriggerSettings.isTriggerDisabled('FeedComment')){
        if(Trigger.isInsert){
            if(Trigger.isBefore){
                Ortho_FeedCommentHandler.onBeforeInsert(Trigger.new);
            }
            if(Trigger.isAfter){}

        }
        if(Trigger.isUpdate){
            if(Trigger.isBefore){ }
            if(Trigger.isAfter){}
        }
    }
}