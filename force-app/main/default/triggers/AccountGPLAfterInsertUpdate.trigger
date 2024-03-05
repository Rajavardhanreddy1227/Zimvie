trigger AccountGPLAfterInsertUpdate on Account (after insert, after update) {

if(GPLProfileAccountRecordHelper.hasAlreadyUpdatedGPLProfile()==false)
{
GPLProfileAccountRecordHelper.setAlreadyUpdatedGPLProfile();    
    
list<Account> acc = new list<Account>();
list<Account> accountlist = new list<Account>();
list<GPL_Profile__c> gpl = new list<GPL_Profile__c>();
list<GPL_Profile__c> activeGPLList = new list<GPL_Profile__c>();
      
acc=[SELECT Id, IsPersonAccount, Salutation, FirstName, LastName, Inactive__pc, Medical_Degree__c,
     Medical_School__c, Med_Grad_Date__c, Residency__c, Residency_Completion_Date__c,
     Fellowship__c, Fellowship_Completion_Date__c, Awards_Honors_Patents__c, Technique__c,
     Specialty_Integration__c, Expertise_Integration_Purpose__c, Languages__c, Account_Picture_Id__c,
     Memberships_Associations_Conferences__c,Publications_Presentations__c, Physicians_Locator__pc,
     Physicians_Locator__c, Physician_Locator_Status__pc, RecordTypeId, Facebook_URL__c, Twitter_ID__c,
     LinkedInURL__c, Preferred_Name__c, Surgeon_Managed__pc,Distributor_Managed__pc, SurgeonOrDistributorManaged__pc,
     PhysicianLocatorUpdated__pc, Middle_Name__c, PersonLeadSource FROM Account where id IN : trigger.New];

map<Id, Id> mapAccountGplId = new map<Id, Id>();
    // code commented as we currently donot want to automatically creata a gpl record when an account is created
/*if(trigger.isInsert)
{  
 system.debug('Inside isInsert---->');     
   for(Account a1 : acc)
    {
         
         //Added Consumer Record Type in the criteria for Call Center Team
         system.debug('Outside For Loop---->'+a1.RecordTypeId);
         if(a1.RecordTypeId == '012800000003YfK' && a1.PersonLeadSource=='Physician Locator')
         {
             //a1.RecordTypeId='012800000002C4gAAE';
             a1.Physician_Locator_Status__pc='Locator Pending';
             system.debug('Inside For Loop---->'+a1.RecordTypeId);
         }
         
         if(a1.RecordTypeId == '012800000002C4gAAE' || a1.RecordTypeId== '012800000003YRmAAM' || a1.RecordTypeId== '012800000003YRcAAM' || a1.RecordTypeId == '012800000003YRrAAM' || a1.RecordTypeId == '012800000003YRhAAM' || a1.RecordTypeId == '012800000003YRnAAM' || a1.RecordTypeId == '012800000003YfK')
         //if(a1.RecordTypeId == '012800000002C4gAAE' || a1.RecordTypeId== '012800000003YRmAAM' || a1.RecordTypeId== '012800000003YRcAAM' || a1.RecordTypeId == '012800000003YRrAAM' || a1.RecordTypeId == '012800000003YRhAAM' || a1.RecordTypeId == '012800000003YRnAAM')
         {
            if((a1.Physician_Locator_Status__pc=='Locator Pending' && a1.Physicians_Locator__pc==True) || (a1.Physician_Locator_Status__pc=='Locator Pending' && a1.Physicians_Locator__pc==False && ((a1.Surgeon_Managed__pc==True)||(a1.Distributor_Managed__pc==True))))
             {                  
                GPL_Profile__c GPLProfile = new GPL_Profile__c();                   
                GPLProfile = SurgeonPortalGPLProfile.buildProfile(a1);                  
                gpl.add(GPLProfile);                    
                    
             }
         }
    }
    if (gpl.size()>0)
    { 
        insert gpl;         
        system.debug('GPL Map---->'+mapAccountGplId);
        for(GPL_Profile__c gplRecord: [Select Account__c,Id from GPL_Profile__c])
        {
            mapAccountGplId.put(gplRecord.Account__c, gplRecord.Id);
        }
        for(Account a1 : acc)
        {
            system.debug('Account Id---->'+a1.Id);
            ID gpRecordId = mapAccountGplId.get(a1.Id);
            if(gpRecordId!=null)
            {
                 system.debug('Outside For Loop2---->'+a1.RecordTypeId);
                 if(a1.RecordTypeId == '012800000003YfK' && a1.PersonLeadSource=='Physician Locator')
                 {
                     a1.RecordTypeId='012800000002C4gAAE';
                     system.debug('Inside For Loop2---->'+a1.RecordTypeId);
                 }
                a1.GPL_Profile__c=gpRecordId;
                a1.Physicians_Locator__c=true;
                a1.SurgeonOrDistributorManaged__pc='';
                a1.PhysicianLocatorUpdated__pc='';
                accountlist.add(a1);
                gpRecordId=null;                
            }           
        }
        update accountlist;
    }       
}

*/
if(trigger.isUpdate)
{
    system.debug('Inside isUpdate---->');     
    
    map<Id, GPL_Profile__c> mapAccountGPL = new map<Id, GPL_Profile__c>();
    for(GPL_Profile__c gplRecord: [Select Account__c,Id from GPL_Profile__c])
    {
        mapAccountGPL.put(gplRecord.Account__c, gplRecord);
    }            
    for(Account a1 : acc)
    {
    
    system.debug('indide account a1 of isUpdate --->' + a1.Id );
    
        if(a1.RecordTypeId == '012800000002C4gAAE' || a1.RecordTypeId== '012800000003YRmAAM' || a1.RecordTypeId== '012800000003YRcAAM' || a1.RecordTypeId == '012800000003YRrAAM' || a1.RecordTypeId == '012800000003YRhAAM' || a1.RecordTypeId == '012800000003YRnAAM')
        {   
            //Check if update account record is Locator Pending or Locator Displayed    
            if(a1.Physician_Locator_Status__pc=='Locator Pending' || a1.Physician_Locator_Status__pc=='' || a1.Physician_Locator_Status__pc==null)
            {
                //Check if GPL Record exists            
                if(mapAccountGPL.get(a1.Id)!=null)
                {                                   
                    GPL_Profile__c updategplRecord = SurgeonPortalGPLProfile.updateProfile(a1,mapAccountGPL.get(a1.Id));
                    updategplRecord.Inactive__c=true; 
                    system.debug('indide if of account a1 to mark GPL inactive true --->' + updategplRecord.Inactive__c );                      
                    gpl.add(updategplRecord);
                }                               
                else
                {                   
                    if(a1.PhysicianLocatorUpdated__pc=='True' || a1.Physicians_Locator__pc==true)
                    {
                        GPL_Profile__c newgplRecord = new GPL_Profile__c();        
                        newgplRecord = SurgeonPortalGPLProfile.buildProfile(a1);
                        newgplRecord.Inactive__c=true; 
                        system.debug('indide else of account a1 to mark GPL inactive true --->' + newgplRecord.Inactive__c );                      
                                        
                        gpl.add(newgplRecord);
                    }
                }
            }
            else if(a1.Physician_Locator_Status__pc=='Locator Displayed' && a1.Physicians_Locator__pc==true)
            {
                if(mapAccountGPL.get(a1.Id)!=null)
                {                                   
                    GPL_Profile__c activegplRecord = SurgeonPortalGPLProfile.updateProfile(a1,mapAccountGPL.get(a1.Id));                                        
                    activeGPLList.add(activegplRecord);
                } 
            }
            
        }
    }           
   system.debug('Size of GPL List--->'+gpl.size());             
   if (gpl.size()>0)
    { 
        upsert gpl;
        mapAccountGPL.clear();
        for(GPL_Profile__c gplRecord: [Select Account__c,Id from GPL_Profile__c])
        {
            mapAccountGPL.put(gplRecord.Account__c, gplRecord);
        }
        system.debug('Size of mapAccountGPL List--->'+mapAccountGPL.size());                
        for(Account a1 : acc)
        {               
            GPL_Profile__c gpRecord = mapAccountGPL.get(a1.Id);
            if(gpRecord!=null)
            {
                if(a1.SurgeonOrDistributorManaged__pc=='True')
                {
                    a1.Surgeon_Managed__pc=true;
                    a1.Distributor_Managed__pc=false;
                }
                else if(a1.SurgeonOrDistributorManaged__pc=='False')
                {
                    a1.Surgeon_Managed__pc=false;
                    a1.Distributor_Managed__pc=true;
                }
                a1.GPL_Profile__c=gpRecord.Id;
                a1.Physicians_Locator__c=true;
                a1.Physicians_Locator__pc=true;
                if (a1.Physician_Locator_Status__pc!='Locator Displayed') a1.Physician_Locator_Status__pc='Locator Pending';
                a1.SurgeonOrDistributorManaged__pc='';
                a1.PhysicianLocatorUpdated__pc='';
                accountlist.add(a1);
                gpRecord=null;                  
            }           
        }
        update accountlist;
    }
   if(activeGPLList.size()>0)
   {
        update activeGPLList;
   }            
 
}
}
}