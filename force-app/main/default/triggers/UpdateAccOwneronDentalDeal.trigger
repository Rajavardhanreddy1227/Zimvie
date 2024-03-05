trigger UpdateAccOwneronDentalDeal on dental_Deal__c(after insert,after update) 
{
   // Avoid recurive trigger
            If(TriggerMonitor.ExecutedTriggers.contains('DentalDealOwnerUpdated'))
                return;
            TriggerMonitor.ExecutedTriggers.add('DentalDealOwnerUpdated');
    
        
        List<dental_Deal__c> DNIds= new list<dental_Deal__c>();
        List<dental_Deal__c> DNToUpdate = new List<dental_Deal__c>();
        DNIds=[Select OwnerId, Account__r.OwnerId from dental_Deal__c where id IN :Trigger.New];
        
           
       For(dental_Deal__c DNId : DNIds)
       {
                DNId.OwnerId=DNId.Account__r.OwnerId;     
                
                DNToUpdate.add(DNId);
                  
       }
      update DNToUpdate;
}