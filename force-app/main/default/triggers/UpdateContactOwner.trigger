trigger UpdateContactOwner on Contact (after insert,after update) 
{
    if(ContactOwnerUpdate.hasAlreadyLaunchedUpdateTrigger()==false)
    {
        ContactOwnerUpdate.setAlreadyLaunchedUpdateTrigger();
        List<Contact> ContactIds= new list<Contact>();
        List<Contact> contactsToUpdate = new List<Contact>();
        ContactIds=[Select OwnerId, Account.OwnerId, Account.Owner.IsActive, RecordTypeId from Contact where id IN :Trigger.New];
        
           
       For(Contact ContactId:ContactIds)
       {
           If(ContactId.Account.Owner.IsActive == TRUE &&(ContactId.RecordTypeId=='01280000000Q0l6' || ContactId.RecordTypeId=='01280000000Q0l8' ))
            {
                ContactId.OwnerId=ContactId.Account.OwnerId;     
                //update ContactIds;
                contactsToUpdate.add(ContactId);
            }       
        }
      update contactsToUpdate;
     }
}