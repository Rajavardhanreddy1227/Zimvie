Public Class ContactCustomMergeClass {
  //******************************************************************************************//
  // Author: Naveen Chugh
  // Date of last modification: 09/02/2011
  // Parameters:None
  // Purpose of this class: provides the ability to undelete the contact record that has just been 
  // deleted by standard merge functionality
  //******************************************************************************************//
  
    @future
    Public static void undelfunction(List<id> idList, string mid) 
    {
        /************************************************************************************************
          Purpose: To undelete the Contact that would have been deleted by standard Merge functionality
                   and to mark it as Inactive and populate its Refer To SFDC Unique ID field with the
                   Master record Id. 
          Parameters:  List containing the Id of the contact that has to be Undeleted denoted by idList
                       and string mid that contains the Id of the Master record to which the undeleted 
                       Contact would refer to.
          Returns: None
          ***********************************************************************************************/  

        List<contact> contactList = new List<contact>();
        
        //getting the list of all the Contacts that need to be undeleted
        contactList = [select id from contact where id in :idList all rows];
        for(contact b : contactList)
        {
        system.debug('the contact record that was undeleted is: ' +b.id);
        }
        try{
            undelete contactList;
        
        //Contact Master1 = [select Id,Contact.Account.MDM_SAP_ID__c from contact where id = :mid limit 1];
        //Selecting the Master Contact Record id
        Contact Master1 = [select Id from contact where id = :mid limit 1];

        for(contact a : ContactList)
         { 
            //a.Refer_To__c = Master1.MDM_SAP_ID__c;
            //Assinging the Refer To SFDC ID field with the Master Record Id
            a.Refer_To_SFDC_Id__c=Master1.Id;
            // Flaggin the Inactive field as true
            a.Inactive__c = TRUE;
                    
           if(a.Deactive_Date__c == NULL) 
               {
                  //Assignimg the De-Activate date to the undeleted Contact.
                  a.Deactive_Date__c = System.Today();
               }
            
            }
        update contactList;
 
        } catch (Exception e) {}
    }
}