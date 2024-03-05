trigger AccountAfterUpdate on Account (after update){
//******************UpdateContactOwnerOnAcc Trigger Starts***************************//

/*
 List<Account> AccountIds= new list<Account>();
 //system.debug('Trigger.newMap.keySet()-->'+Trigger.newMap.keySet());
 AccountIds=[Select Id, OwnerId, IsPersonAccount, Owner.Isactive, RecordTypeId, (Select Id, OwnerId from Contacts) from Account where id IN :Trigger.newMap.keySet()];
 List<Contact> contactsToUpdate = new List<Contact>{};
 for(Account a: AccountIds){
 //system.debug('a.recordTypeId-->'+a.recordTypeId);
 if (a.IsPersonAccount == FALSE && a.Owner.Isactive == TRUE && (a.recordTypeId=='01280000000Q0kaAAC' || a.recordTypeId == '01280000000Q0kWAAS'||a.recordTypeId == '01280000000Q0kYAAS') ){
  for(Contact c: a.Contacts){
     if (a.OwnerId != c.OwnerId){
         c.OwnerId=a.OwnerId;
         contactsToUpdate.add(c);
   }     
  }
 }
}
update contactsToUpdate;
*/
//******************SalesHistoryOwnerUpdate Trigger Starts***************************//

/*

// Create Set of accounts with new owners
Set<ID> DentalAccountIDs = new Set<ID>();

// Get the Dental Canada record type
String dentalCanadaRecordType = '';

// Get the Dental US and Non-US record type
String dentalUSRecordType = '';
String dentalNonUSRecordType = '';

    
//List<RecordType> recordTypeList = [Select Id From RecordType Where SobjectType = 'Account' and DeveloperName = 'DN_CA_Account_Record_Type' LIMIT 1];
Map<Id,RecordType> recordTypeList = new Map<Id, RecordType>([Select Id,DeveloperName From RecordType Where SobjectType = 'Account' and (DeveloperName = 'DN_CA_Account_Record_Type' or DeveloperName='Customers' or DeveloperName='Non_Customers')]);


// This loop iterates over the triggers collection, and adds any that have new owners Set
for (Integer i = 0; i < Trigger.new.size(); i++){
    if(Trigger.old[i].OwnerID != Trigger.new[i].OwnerID){
      for(Id id : recordTypeList.keySet()){
         if(Trigger.new[i].RecordTypeId == id){
             DentalAccountIDs.add(Trigger.new[i].id);
         }
       }
     }
}

// Are there any Accounts with new owners?
if (DentalAccountIDs.isEmpty()) {
  system.debug(' ---> No Accounts to update');
} 
else {
// Since updates are not urgent (required immediately) and to avoid governor limits, determine if we are going to run the 
// the Sales History Owner update in batch or right now as part of the triggers stream

// Determine the number of Sales History rows this trigger event will update.
integer x = [SELECT count() FROM Sales_History__c WHERE Account__c in :DentalAccountIDs];
system.debug(' ---> Sales History Rows to Update: ' + x);
system.debug(' ---> DML Limit of this invocation: ' + limits.getLimitDmlRows());
        
// Check if there are any rows to update.
if (x == 0){
   system.debug(' ---> No rows to update - Nothing to do');
}
else{
// If Rows to update are greater than the DML Row limit of the current invocation
// then do the update in batch, otherwise do it synchronously.
// ** NOTE ** If Rows exceed 10,000 records then governor limit will be reached and batch will fail.
// APEX will throw exception and notify system admninistrator. There is no recovery from governor limits so no point catching it. 
if (x > limits.getLimitDmlRows() ){
    system.debug(' ---> Sales History Owner Update submitted to batch');
    updsaleshistowner.OwnerUpdate(DentalAccountIDs);  
}
else{
    system.debug(' ---> Sales History Owner Update executing synchronously (Within triggers stream)');
    updsaleshistownernow.OwnerUpdate(DentalAccountIDs);
}
}
}

*/
}