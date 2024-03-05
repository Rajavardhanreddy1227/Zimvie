trigger Up_ServiceContractTrigger on ServiceContract (after update) {
    
    Up_ServiceContractTrigger_Handler handler = new Up_ServiceContractTrigger_Handler();
    
    /* After Update */
    if(Trigger.isUpdate && Trigger.isAfter){
        system.debug(Logginglevel.ERROR, '*** Up_ServiceContractTrigger After Update ***');
        handler.OnAfterUpdate(Trigger.oldMap, Trigger.new);
    }    

}