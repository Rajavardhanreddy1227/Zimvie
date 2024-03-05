trigger UpdateContactOwnerOnAcc on Account (After Update) {
If(ContactOwnerUpdateAccount.hasAlreadyLaunchedUpdateTrigger()==false )
{        
ContactOwnerUpdateAccount.setAlreadyLaunchedUpdateTrigger();       
 List<Account> AccountIds= new list<Account>();             
 AccountIds=[Select Id, OwnerId, IsPersonAccount, Owner.Isactive, RecordTypeId, (Select Id, OwnerId from Contacts) from Account where id IN :Trigger.newMap.keySet()];
 List<Contact> contactsToUpdate = new List<Contact>{};
 for(Account a: AccountIds){
 If ( a.IsPersonAccount == FALSE && a.Owner.Isactive == TRUE && (a.recordTypeId == '01280000000Q0ka'|| a.recordTypeId == '01280000000Q0kW'||a.recordTypeId == '01280000000Q0kY') )
 {
  For(Contact c: a.Contacts)
  {
     If (a.OwnerId != c.OwnerId)
     {
         c.OwnerId=a.OwnerId;
         contactsToUpdate.add(c);
     }
     //contactsToUpdate.add(c);
  }
 }

 }
 update contactsToUpdate;
 }
}