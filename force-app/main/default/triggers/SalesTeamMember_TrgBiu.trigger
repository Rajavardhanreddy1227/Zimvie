trigger SalesTeamMember_TrgBiu on SalesTeamMember__c (before insert, before update) {
    if ( Trigger.isInsert ) {
        SalesTeamMemberHandler.beforeInsert(Trigger.new);
    } else if ( Trigger.isUpdate ) {
        SalesTeamMemberHandler.beforeUpdate(Trigger.old, Trigger.new);
    }
}