trigger ContactBeforeInsertUpdate on Contact (before insert, before update)
{
    List<Contact> contacts = Trigger.new;
    
    /* Fetching details of the Account that are related with the Contacts in Trigger.new */
    Set<Id> accountIds = new Set<Id>();
    for (Contact cont : contacts) {
        accountIds.add(cont.AccountId);
    }

    Map<Id, Account> mapAccount = new Map<Id, Account>([SELECT Id, OwnerId ,Owner.IsActive FROM Account WHERE Id IN :accountIds]);
   
    for(Contact cont : contacts)
    {
    
        if(trigger.isInsert)
        {    
        
            /* UpdatePlannedZimmerSalesContactName Trigger starts here */                         
            if(cont.RecordTypeId == '012C0000000QCaw')
            {
                cont.FirstName = 'First Name';
                cont.LastName = 'Last Name';
            }
            
            /* UpdatePlannedZimmerSalesContactName Trigger ends here */
        
        }
        
        if(trigger.isUpdate)
        {
            if((cont.HCP_Country_Access_Code_Contact__c!=Null) && ((cont.HCP_Country_Access_Code_Contact__c == 'DE') || (cont.HCP_Country_Access_Code_Contact__c == 'IT')))
            
            {
                    List<String> sortedvalue = new List<String>();
                    Integer status=0;
    
                    if(cont.HCP_Country_Access__c!=Null)
                    {
                        String s =cont.HCP_Country_Access__c;
                        sortedvalue = s.split(';');
                 
                        system.debug('the size of sorted value is:'+sortedvalue);
    
                        for(Integer i=0; i<sortedvalue.size();i++)
                        {
                            system.debug('the sorted value is:'+sortedvalue[i]);
    
                            if(sortedvalue[i]==cont.HCP_Country_Access_Code_Contact__c)
                            {
                                system.debug('the status flag2 is:'+status);
                                status=1;
                                cont.HCP_Country_Access_Code_Contact__c=Null;
                                //cont.RecordTypeId = '012C0000000Q7mz';
                            }
                        }
    
                        if(status==0)
                        {
                            string s1 =+cont.HCP_Country_Access__c+';'+cont.HCP_Country_Access_Code_Contact__c;
                            system.debug('the s1 is:'+s1);
                             
                            cont.HCP_Country_Access__c = s1;
                            system.debug('the access code is:'+cont.HCP_Country_Access__c);
    
                            cont.HCP_Country_Access_Code_Contact__c=Null;
                        }
                    }
            }
        }
        
        if(((cont.HCP_Country_Access_Code_Contact__c!=Null) && ((cont.HCP_Country_Access_Code_Contact__c == 'DE') || (cont.HCP_Country_Access_Code_Contact__c == 'IT'))) && cont.HCP_Country_Access__c==Null)
        { 
                System.debug('HCP_Country_Access__c is null');
                
                cont.HCP_Country_Access__c = cont.HCP_Country_Access_Code_Contact__c;
                cont.HCP_Country_Access_Code_Contact__c=Null;
                cont.RecordTypeId = '012C0000000Q7mz';
             
                System.debug('Record type changed successfully');       
        }
        
         /* UpdateContactOwner Trigger starts here */
        if(mapAccount.size()>0)
        {
            if(cont.AccountId!=null)
            {
                if(mapAccount.get(cont.AccountId).Owner.IsActive == TRUE &&(cont.RecordTypeId=='01280000000Q0l6' || cont.RecordTypeId=='01280000000Q0l8' ))
                {
                    cont.OwnerId=mapAccount.get(cont.AccountId).OwnerId;     
                }
             }
        }
        
        /* UpdateContactOwner Trigger ends here */
        
        
        /* UpdateOriginalHireDate Trigger starts here */        
        if(cont.Set_Original_Hire_Date__c == false &&(cont.RecordTypeId=='012800000002DoB'))
        {
            cont.original_hire_date__c=cont.hire_date__c;  
            cont.Set_Original_Hire_Date__c = true;
        }   
        
        /* UpdateOriginalHireDate Trigger ends here */

    }
}