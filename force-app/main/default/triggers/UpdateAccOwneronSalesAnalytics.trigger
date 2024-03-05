trigger UpdateAccOwneronSalesAnalytics on DN_Account_Sales_Analytics__c(after insert,after update) 
{
   // Avoid recurive trigger
            If(TriggerMonitor.ExecutedTriggers.contains('OwnerUpdated'))
                return;
            TriggerMonitor.ExecutedTriggers.add('OwnerUpdated');
    
        
        List<DN_Account_Sales_Analytics__c> DNIds= new list<DN_Account_Sales_Analytics__c>();
        List<DN_Account_Sales_Analytics__c> DNToUpdate = new List<DN_Account_Sales_Analytics__c>();
        DNIds=[Select OwnerId, Account__r.OwnerId from DN_Account_Sales_Analytics__c where id IN :Trigger.New];
        
           
       For(DN_Account_Sales_Analytics__c DNId : DNIds)
       {
                DNId.OwnerId=DNId.Account__r.OwnerId;     
                
                DNToUpdate.add(DNId);
                  
        }
      update DNToUpdate;
}