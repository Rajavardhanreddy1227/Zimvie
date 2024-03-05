trigger GPLProfileAfterUpdate on GPL_Profile__c (after update) {

if(GPLProfileUpdateRecordHelper.hasAlreadyUpdatedGPLProfileRecord()==false)
{
    try
        {
    GPLProfileUpdateRecordHelper.setAlreadyUpdatedGPLProfileRecord();   
    list<Id> listGPLAccountId = new list<Id>(); 
    //List of Account Ids of updated GPL Records
    for(GPL_Profile__c gplRecord : [Select Id, Account__c, Account__r.IsPersonAccount from GPL_Profile__c where Id IN: trigger.new])
    {
        if(gplRecord.Account__c!=null && gplRecord.Account__r.IsPersonAccount)
        {  
            listGPLAccountId.add(gplRecord.Account__c);         
        }
    }   
    //List of Accounts of updated GPL Records
    list<Account> listGPLAccountstemp = [select id, Technique__c, Specialty_integration__c, Expertise_Integration_purpose__c,
             Languages__c, Memberships_Associations_Conferences__c, Awards_Honors_Patents__c,
             Publications_Presentations__c, Physician_Locator_Status__pc, Physicians_Locator__pc,
             Facebook_URL__c, Twitter_ID__c, LinkedInURL__c, Preferred_Name__c, IsPersonAccount, GPL_Profile__c, Distributor_Managed__pc from Account where Id IN : listGPLAccountId];


Map<ID,Account> listGPLAccounts = new Map<ID,Account>(listGPLAccountstemp);
    
   Map<ID, Account> accountList=new Map<ID,Account>();
   
   system.debug('before for loop');
    for(GPL_Profile__c gplRecord :[Select Id, Account__c, Contact__c, Account__r.IsPersonAccount,Devices__c,Specialties__c,Procedures__c,Languages__c,MedicalSchool__c,Fellowship__c,Residency__c,Facebook__c,Twitter__c, LinkedIn__c, Picture_Id__c,GPL_Physician_Locator__c, PreferredName__c, Inactive__c from GPL_Profile__c where Id IN: trigger.new])
    {
      //  for(Integer i=0;i<listGPLAccounts.size();i++) 
        
        system.debug(listGPLAccounts);
        for ( ID i : listGPLAccounts.keySet() )
               
        {
             system.debug('GPL Account I'+i);
           system.debug('GPL Account ID'+gplRecord.Account__c);
           system.debug('If Result-->'+listGPLAccounts.containsKey(gplRecord.Account__c));
           if(listGPLAccounts.containsKey(gplRecord.Account__c))
            {   
                Account accTemp = new Account();
                //Lead tmpLead = m.Get(oTask.WhoId);
                //accTemp.Id= listGPLAccountstemp.Get(gplRecord.Account__c);
               
                system.debug('Inside If loop' + i);
                system.debug('accTemp.Expertise_Integration_purpose__c' + accTemp.Expertise_Integration_purpose__c);
                             
                accTemp.Id = gplRecord.Account__c;            
                accTemp.Languages__c = gplRecord.Languages__c;
                accTemp.Expertise_Integration_purpose__c = gplRecord.Devices__c;
                accTemp.Technique__c=gplRecord.Procedures__c;
                accTemp.Specialty_integration__c = gplRecord.Specialties__c;
                accTemp.Expertise_Integration_purpose__c = gplRecord.Devices__c;
                accTemp.Languages__c = gplRecord.Languages__c;
                accTemp.Medical_School__c = gplRecord.MedicalSchool__c;
                accTemp.Fellowship__c = gplRecord.Fellowship__c;
                accTemp.Residency__c = gplRecord.Residency__c;
                accTemp.Facebook_URL__c = gplRecord.Facebook__c;
                accTemp.Twitter_ID__c = gplRecord.Twitter__c;
                accTemp.LinkedInURL__c = gplRecord.LinkedIn__c;
                accTemp.Account_Picture_Id__c = gplRecord.Picture_Id__c;        
                if(gplRecord.GPL_Physician_Locator__c==true)
                {                
                    accTemp.Physician_Locator_Status__pc='Locator Displayed';       
                }
                if(gplRecord.Inactive__c == false && accTemp.Distributor_Managed__pc == true)
                {                    
                    //gplRecord.GPL_Physician_Locator__c = true;
                    accTemp.Physician_Locator_Status__pc='Locator Displayed';
                }
               system.debug('Account List1'+accountList);
                //accountList.add(listGPLAccounts[i]);
               accountList.put(i,accTemp);
               system.debug('Account List2'+accountList);
                break;
  
            }
            
        }  
       
    }
    if(accountList.size()>0)
     update accountList.values();
   }
   catch(Exception e)
        {
            System.debug(e);
        }
    
    
}

}