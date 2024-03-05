trigger GplProfileAccountRecordUpdate on Account (after insert, after update) {

IF(GPLProfileAccountRecordHelper.hasAlreadyUpdatedGPLProfile()==false)
{
    GPLProfileAccountRecordHelper.setAlreadyUpdatedGPLProfile();
    
    list<id> accountId = new list<id>();
    list<Account> acc = new list<Account>();
    list<Account> accUpd = new list<Account>();
    list<GPL_Profile__c> gpl = new list<GPL_Profile__c>();
    
    for(account x : trigger.new)
    {
        accountId.add(x.id);
    }
    
    If(trigger.isInsert)
    {        
        acc=[select id, isPersonAccount, Physicians_Locator__pc, Physician_Locator_Status__pc, Surgeon_Managed__pc,Distributor_Managed__pc, RecordTypeId, Middle_Name__c  from Account where id IN: accountId];
        for(Account a1 : acc)
        {
            if(a1.RecordTypeId == '012800000002C4gAAE' || a1.RecordTypeId== '012800000003YRmAAM' || a1.RecordTypeId== '012800000003YRcAAM' || a1.RecordTypeId == '012800000003YRrAAM' || a1.RecordTypeId == '012800000003YRhAAM' || a1.RecordTypeId == '012800000003YRnAAM')
            {

            if((a1.Physician_Locator_Status__pc=='Locator Pending' && a1.Physicians_Locator__pc==True) || (a1.Physician_Locator_Status__pc=='Locator Pending' && a1.Physicians_Locator__pc==False && ((a1.Surgeon_Managed__pc==True)||(a1.Distributor_Managed__pc==TRUE))))
            {
                a1.Physicians_Locator__c=True;
                a1.SurgeonOrDistributorManaged__pc='';
                a1.PhysicianLocatorUpdated__pc='';
                
                GPL_Profile__c GPLProfile = new GPL_Profile__c();                
                //GPLProfile = GplProfileBuilder.buildProfile(a1);
                GPLProfile = SurgeonPortalGPLProfile.buildProfile(a1);                
                GPLProfile.Inactive__c=True;
                //a1.GPL_Profile__c=GPLProfile.Id;
                system.debug('The GPL Id is:'+GPLProfile);
                gpl.add(GPLProfile);
                accUpd.add(a1);
            }
            }

        }
        insert gpl;
        update accUpd;
        
}

if(trigger.isUpdate)
{

    acc=[SELECT Id, IsPersonAccount, Salutation, FirstName, LastName,
     Medical_Degree__c, Medical_School__c, Med_Grad_Date__c,
     Residency__c, Residency_Completion_Date__c, Fellowship__c,
     Fellowship_Completion_Date__c, Awards_Honors_Patents__c,
     Technique__c, Specialty_Integration__c, Expertise_Integration_Purpose__c,
     Languages__c, Account_Picture_Id__c, Memberships_Associations_Conferences__c,Publications_Presentations__c,
     Physicians_Locator__pc,Physicians_Locator__c, Physician_Locator_Status__pc, RecordTypeId, Facebook_URL__c,
     Twitter_ID__c, LinkedInURL__c, Preferred_Name__c, Surgeon_Managed__pc,Distributor_Managed__pc,SurgeonOrDistributorManaged__pc,PhysicianLocatorUpdated__pc, Middle_Name__c FROM Account where id IN : accountId];

for(Account a1 : acc)
{
    if(a1.RecordTypeId == '012800000002C4gAAE' || a1.RecordTypeId== '012800000003YRmAAM' || a1.RecordTypeId== '012800000003YRcAAM' || a1.RecordTypeId == '012800000003YRrAAM' || a1.RecordTypeId == '012800000003YRhAAM' || a1.RecordTypeId == '012800000003YRnAAM')
    {
    //if(a1.Physician_Locator_Status__pc=='Locator Pending' && a1.Physicians_Locator__pc==True)
    if(a1.Physician_Locator_Status__pc=='Locator Pending' || a1.Physician_Locator_Status__pc=='' || a1.Physician_Locator_Status__pc==null)
    {
    for(GPL_Profile__c GPLProfile : [SELECT Id, Name__c, Devices__c, Facebook__c, Fellowship__c, FirstName__c,
              Groups__c, Honors__c, Inactive__c, Languages__c, LastName__c, 
              LinkedIn__c, Account__c, MedicalSchool__c, PhotoId__c, Procedures__c, 
              Publications__c, Residency__c, Salutation__c, Specialties__c, Twitter__c,
              Username__c, YouTube__c, PreferredName__c, Middle_Name__c FROM GPL_Profile__c WHERE Account__c = :a1.Id  LIMIT 1])
    {
        
       if(a1.SurgeonOrDistributorManaged__pc=='True')
       {
            a1.Surgeon_Managed__pc=True;
            a1.Distributor_Managed__pc=False;
       }
       else if(a1.SurgeonOrDistributorManaged__pc=='False')
       {
            a1.Surgeon_Managed__pc=False;
            a1.Distributor_Managed__pc=True;
       }
       a1.Physicians_Locator__pc=True;
       a1.Physicians_Locator__c=True;
       a1.Physician_Locator_Status__pc='Locator Pending';
       a1.SurgeonOrDistributorManaged__pc='';
       a1.PhysicianLocatorUpdated__pc=''; 
       accUpd.add(a1);
       GPLProfile = SurgeonPortalGPLProfile.updateProfile(a1,GPLProfile);
       GPLProfile.Inactive__c=True;
       //a1.GPL_Profile__c=GPLProfile.Id;
       gpl.add(GPLProfile); 
       
       system.debug('the point of contact 1'); 
    
    }
    
    if(gpl.size()==0)
    {
        system.debug('the point of contact 2');
        //If Surgeon Managed is True
        if(a1.SurgeonOrDistributorManaged__pc=='True' && a1.PhysicianLocatorUpdated__pc=='True')
        {
            a1.Surgeon_Managed__pc=True;
            a1.Distributor_Managed__pc=False;
            a1.Physicians_Locator__pc=True;            
            a1.Physicians_Locator__c=True;
            system.debug('Phy Locator='+a1.Physicians_Locator__c);
            a1.Physician_Locator_Status__pc='Locator Pending';
            a1.SurgeonOrDistributorManaged__pc='';
            a1.PhysicianLocatorUpdated__pc='';
            GPL_Profile__c GPLProfile = new GPL_Profile__c();        
            GPLProfile = SurgeonPortalGPLProfile.buildProfile(a1);
            GPLProfile.Inactive__c=True;
            //a1.GPL_Profile__c=GPLProfile.Id;
            gpl.add(GPLProfile);
            //accUpd.add(a1);
            
        }
        else if(a1.SurgeonOrDistributorManaged__pc=='True' && a1.PhysicianLocatorUpdated__pc=='False')
        {
            a1.Surgeon_Managed__pc=True;
            a1.Distributor_Managed__pc=False;
            a1.Physicians_Locator__pc=False;
            a1.Physicians_Locator__c=False;
            a1.SurgeonOrDistributorManaged__pc='';
            a1.PhysicianLocatorUpdated__pc='';           
        }
        //If Distributor Managed is True and Physician Locator is True
        else if(a1.SurgeonOrDistributorManaged__pc=='False' && a1.PhysicianLocatorUpdated__pc=='True')
        {
            a1.Distributor_Managed__pc=True;
            a1.Surgeon_Managed__pc=False;
            a1.Physicians_Locator__pc=True;
            a1.Physicians_Locator__c=True;
            a1.Physician_Locator_Status__pc='Locator Pending';
            a1.SurgeonOrDistributorManaged__pc='';
            a1.PhysicianLocatorUpdated__pc='';
            GPL_Profile__c GPLProfile = new GPL_Profile__c();        
            GPLProfile = SurgeonPortalGPLProfile.buildProfile(a1);
            GPLProfile.Inactive__c=True;
            //a1.GPL_Profile__c=GPLProfile.Id;
            gpl.add(GPLProfile);
            //accUpd.add(a1);          
        }
        //If Distributor Managed is True and Physician Locator is False
        else if(a1.SurgeonOrDistributorManaged__pc=='False' && a1.PhysicianLocatorUpdated__pc=='False')
        {
            a1.Distributor_Managed__pc=True;
            a1.Surgeon_Managed__pc=False;
            a1.Physicians_Locator__pc=False;
            a1.Physicians_Locator__c=False;
            a1.SurgeonOrDistributorManaged__pc='';
            a1.PhysicianLocatorUpdated__pc='';
        }
                
        accUpd.add(a1);
        
    }        
   } 
    
    
    if(a1.Physician_Locator_Status__pc=='Locator Displayed' && a1.Physicians_Locator__pc==True)
    {
    for(GPL_Profile__c GPLProfile : [SELECT Id, Name__c, Devices__c, Facebook__c, Fellowship__c, FirstName__c,
              Groups__c, Honors__c, Inactive__c, Languages__c, LastName__c, 
              LinkedIn__c, Account__c, MedicalSchool__c, PhotoId__c, Procedures__c, 
              Publications__c, Residency__c, Salutation__c, Specialties__c, Twitter__c,
              Username__c, YouTube__c, PreferredName__c, Middle_Name__c FROM GPL_Profile__c WHERE Account__c = :a1.Id  LIMIT 1])
    {
            
        GPLProfile = SurgeonPortalGPLProfile.updateProfile(a1,GPLProfile);
        gpl.add(GPLProfile);  
    
    }
   }

    
    
    

 }
}

upsert gpl;
update accUpd;
}

}

}