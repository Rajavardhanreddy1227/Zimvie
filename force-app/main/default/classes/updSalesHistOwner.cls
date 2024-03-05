// This class takes as a parameter a SET of account IDs for which
// we want to update the Sales History ownership. Ownership of the
// related Sales History records is updated to that of the Account
// This process will run asynchronously (BATCH) seperately from 
// calling stream. 
// Update Sales History Owner in Batch Mode
global class updSalesHistOwner {
     
    @future
    public static void OwnerUpdate(Set<ID> AccountIDs) {
       /*
        // Build a map containing the account details of the IDs we want to replace.
        // We'll need to know the owner ID
        Map<Id,Account> acctsWithNewOwners = new Map<Id, Account>([select ID, OwnerID from account where ID in :accountids]);

        // Build list of sales history records that need to be updated    
        List<Sales_History__c> updatedSalesHistory = new List<Sales_History__c>();
        
        for (Sales_History__c c : [SELECT id, Account__c 
                      FROM Sales_History__c WHERE Account__c in :acctsWithNewOwners.keySet()]) {

            // Retrieve OwnerID from Account map and update the Sales History owner
            Account parentAccount = acctsWithNewOwners.get(c.account__c);
            //c.OwnerID = parentAccount.OwnerID;

            // Rather than insert the Sales History Recs. individually, add the
            // updates to a list and bulk update it prior to exiting class. 
            // Hopefully avoiding the governor limit on DML statements.
            updatedSalesHistory.add(c);
        }       
        // Bulk update the records
        update updatedSalesHistory;
        
    */
    }

}