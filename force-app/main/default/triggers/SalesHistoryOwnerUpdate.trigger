/*****************************************************************************/
/* Trigger name: SalesHistoryOwnerUpdate                                     */
/* Author: Arun Kumar Singh                                                  */
/* Last modified: June 2011                                                  */
/* Purpose: Used to update Owner of SalesHistory as per the Account owner    */                                          
/*****************************************************************************/ 
// This trigger is fired after an Account Record is updated
// and checks to see if the owner has changed. If the owner has
// changed then we need to update the ownership on the related 
// Sales History records.
trigger SalesHistoryOwnerUpdate on Account (after update) {
/*  
    // Create Set of accounts with new owners
    Set<ID> AccountIDs = new Set<ID>();

    // Get the Dental Canada record type
    String dentalCanadaRecordType = '';
    //Code added by Arun on 24-June-2011
    // Get the Dental US and Non-US record type
    String dentalUSRecordType = '';
    String dentalNonUSRecordType = '';
    //Code addition ends here
    
    //List<RecordType> recordTypeList = [Select Id From RecordType Where SobjectType = 'Account' and DeveloperName = 'DN_CA_Account_Record_Type' LIMIT 1];
    List<RecordType> recordTypeList = [Select Id,DeveloperName From RecordType Where SobjectType = 'Account' and (DeveloperName = 'DN_CA_Account_Record_Type' or DeveloperName='Customers' or DeveloperName='Non_Customers')];
    for (RecordType recordType : recordTypeList) {
        //dentalCanadaRecordType = recordType.Id;
        //Code added by Arun on 24-June-2011
        if(recordType.DeveloperName == 'DN_CA_Account_Record_Type')
        {
            dentalCanadaRecordType = recordType.Id;
        }
        else if(recordType.DeveloperName == 'Customers')
        {
            dentalUSRecordType=recordType.Id;
        }
        else if(recordType.DeveloperName == 'Non_Customers')
        {
            dentalNonUSRecordType=recordType.Id;
        }
        //Code addition ends here
    }
    System.debug(' ---> Dental Canada Record Type in SalesHistoryOwnerUpdate : ' + dentalCanadaRecordType);
    System.debug(' ---> Dental US Record Type in SalesHistoryOwnerUpdate : ' + dentalUSRecordType);
    System.debug(' ---> Dental Non-US Record Type in SalesHistoryOwnerUpdate : ' + dentalNonUSRecordType);

    // This loop iterates over the triggers collection, and adds any that have new
    // owners Set.
    for (Integer i = 0; i < Trigger.new.size(); i++) {
        if ((Trigger.old[i].OwnerID != Trigger.new[i].OwnerID) && (dentalCanadaRecordType == Trigger.new[i].RecordTypeId))
        {
            AccountIDs.add(Trigger.new[i].id);
        }
        else if((Trigger.old[i].OwnerID != Trigger.new[i].OwnerID) && (dentalUSRecordType == Trigger.new[i].RecordTypeId))
        {
            AccountIDs.add(Trigger.new[i].id);
        }
        else if((Trigger.old[i].OwnerID != Trigger.new[i].OwnerID) && (dentalNonUSRecordType == Trigger.new[i].RecordTypeId))
        {
            AccountIDs.add(Trigger.new[i].id);
        }
    }

    // Are there any Accounts with new owners?
    if (AccountIDs.isEmpty()) {
        system.debug(' ---> No Accounts to update');
    } 
    else {
        // Since updates are not urgent (required immediately) and to
        // avoid governor limits, determine if we are going to run the 
        // the Sales History Owner update in batch or right now as part
        // of the triggers stream.  

        // Determine the number of Sales History rows this trigger event will update.
        integer x = [SELECT count() FROM Sales_History__c WHERE Account__c in :AccountIDs];
        system.debug(' ---> Sales History Rows to Update: ' + x);
        system.debug(' ---> DML Limit of this invocation: ' + limits.getLimitDmlRows());
        
        // Check if there are any rows to update.
        if (x == 0) {
            system.debug(' ---> No rows to update - Nothing to do');
        }
        else {
            // If Rows to update are greater than the DML Row limit of the current invocation
            // then do the update in batch, otherwise do it synchronously.
            // ** NOTE ** If Rows exceed 10,000 records then governor limit will be reached and batch will fail.
            // APEX will throw exception and notify system admninistrator. There is no recovery from governor limits
            // so no point catching it. 
            if (x > limits.getLimitDmlRows() ){
                system.debug(' ---> Sales History Owner Update submitted to batch');
                updsaleshistowner.OwnerUpdate(AccountIDs);  
            }
            else {
                system.debug(' ---> Sales History Owner Update executing synchronously (Within triggers stream)');
                updsaleshistownernow.OwnerUpdate(AccountIDs);
            }
        }
    }
*/
}