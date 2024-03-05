Public Class aaaSurgeonMergeClass {
  //******************************************************************************************//
  // Author: Saikishore Aengareddy
  // Date of last modification: 10/22/2010
  // Purpose of this class: provides the ability to undelete the account record 
  //******************************************************************************************//
  
    @future
    Public static void undelfunction(List<id> idList, string mid) {
        List<Account> accList = new List<Account>();
        accList = [select id, External_ID__c, Refer_To__c, Deactive_Date__c from account where id in :idList all rows];
        try{
            undelete accList;

        Account Master1 = [select Id, External_ID__c, MDM_SAP_ID__c from account where id = :mid limit 1];
        for(account a : accList) { 
            a.Refer_To__c = Master1.MDM_SAP_ID__c;
            //Code Added by Naveen Chugh for HCP Expense Extension - CUSTOM MERGE FUNCTIONALITY
            a.Refer_To_SFDC_Id__c=Master1.Id;
            //Code Addition Ends Here
            a.Inactive__pc = TRUE;
            a.AcctInactive__c = TRUE;
            
            //system.debug('Refer to:' +a.Refer_To__c);
            //system.debug('Refer to SFDC ID:' +a.Refer_To_SFDC_Id__c);
            //system.debug('Inactive:' +a.AcctInactive__c);
                   
            if(a.Deactive_Date__c == NULL) {
                a.Deactive_Date__c = System.Today();
               }
            }
        update accList;
 
        }
        catch (Exception e) {}
    }
}