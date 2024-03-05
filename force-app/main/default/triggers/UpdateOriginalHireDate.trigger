trigger UpdateOriginalHireDate on Contact (after insert, after update) {
if(OriginalHireDateUpdate.hasAlreadyLaunchedUpdateTrigger()==false)
    {
        OriginalHireDateUpdate.setAlreadyLaunchedUpdateTrigger();
        List<Contact> ContactIds= new list<Contact>();
        List<Contact> contactsToUpdate = new List<Contact>();
        ContactIds=[Select id,RecordTypeId, hire_date__c, original_hire_date__c,Set_Original_Hire_Date__c from Contact where id IN :Trigger.New];
                   
        For(Contact ContactId:ContactIds)
        {
           If(ContactId.Set_Original_Hire_Date__c == false &&(ContactId.RecordTypeId=='012800000002DoB'))
            {
                ContactId.original_hire_date__c=ContactId.hire_date__c;  
                ContactId.Set_Original_Hire_Date__c = true;   
                //update ContactIds;
                contactsToUpdate.add(ContactId);
            }               
        }
       update contactsToUpdate;
    }   
}