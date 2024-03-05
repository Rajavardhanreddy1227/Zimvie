trigger Up_FCO_Trigger on SM_FCO__c (before update) {
    
    Up_FCO_Trigger_Handler handler = new Up_FCO_Trigger_Handler();

    /* Before Update */
    if(Trigger.isUpdate && Trigger.isBefore){
        system.debug(Logginglevel.ERROR, '*** Up_FCO_Trigger Before Update ***');
        handler.OnBeforeUpdate(Trigger.oldMap, Trigger.new);
    }
}