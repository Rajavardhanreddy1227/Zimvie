trigger AssignmentRulesonCaseTrigger on Case (after insert) {
    List<Id> caseIds = new List<Id>{};
        
        if(trigger.IsAfter && trigger.isInsert){
            for (Case theCase:trigger.new){
                system.debug('-----CaseRecType---'+theCase.RecordTypeId);
               if(theCase.RecordTypeId == '0123b000000QfsYAAS'){
                caseIds.add(theCase.Id);
               }
            }
            List<Case> cases = new List<Case>{};
                for(Case c : [Select Id from Case where Id in :caseIds]) {
                    Database.DMLOptions dmo = new Database.DMLOptions();
                    dmo.assignmentRuleHeader.useDefaultRule = true;
                    
                    c.setOptions(dmo);
                    
                    cases.add(c);
                }
            Database.upsert(cases);
        }
}