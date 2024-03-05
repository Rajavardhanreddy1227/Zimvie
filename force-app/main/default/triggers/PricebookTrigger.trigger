trigger PricebookTrigger on Pricebook2 (after insert, after update) {
    if (Trigger.isAfter && !Test.isRunningTest()) {
        if (Trigger.isInsert) {
            PricebookTriggerHandler.handlePricebookInsert(Trigger.new);
        } else if (Trigger.isUpdate) {
            PricebookTriggerHandler.handlePricebookUpdate(Trigger.new, Trigger.oldMap);
        }
    }
}