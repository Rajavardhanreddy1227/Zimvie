trigger UpdateAccountContactProfile on GPL_Profile__c (after insert, after update) {

system.debug('the Flag value is:'+GPLProfileUpdateRecordHelper.hasAlreadyUpdatedGPLProfileRecord());
if(GPLProfileUpdateRecordHelper.hasAlreadyUpdatedGPLProfileRecord()==False){

GPLProfileUpdateRecordHelper.setAlreadyUpdatedGPLProfileRecord();

List<ID> gplAccountId = new list<ID>();
List<ID> gplContactId = new list<ID>();

for(GPL_Profile__c gplId : [Select Id, Account__c, Contact__c, Account__r.IsPersonAccount from GPL_Profile__c where Id IN: trigger.new]){
   if(gplId.Account__c != Null && gplId.Account__r.IsPersonAccount){
   // if(gplId.Account__c != Null)
    gplAccountId.add(gplId.Account__c);
    }
    if(gplId.Contact__c != Null){
    gplContactId.add(gplId.Contact__c);
    }
}
system.debug('the size of the account list is: '+gplAccountId.size());


list<Account> accountId = new List<Account>();
list<Contact> contactId = new list<Contact>();
list<Account> accountUpdate = new list<Account>();

accountId = [select id, Technique__c, Specialty_integration__c, Expertise_Integration_purpose__c,
             Languages__c, Memberships_Associations_Conferences__c, Awards_Honors_Patents__c,
             Publications_Presentations__c, Physician_Locator_Status__pc, Physicians_Locator__pc,
             Facebook_URL__c, Twitter_ID__c, LinkedInURL__c, Preferred_Name__c, IsPersonAccount, GPL_Profile__c, Distributor_Managed__pc from Account where Id IN : gplAccountId];
contactId = [select id, Language__c from Contact where Id IN : gplContactId];

system.debug('the size of the account list is: '+accountId.size());

if(trigger.IsInsert){
    integer i;
    for(GPL_Profile__c gpl : trigger.new){
         for(i=0; i<accountId.size() ;i++){
         system.debug('the integer number is : '+i);
             if(gpl.Account__c == accountId[i].id){
             system.debug('the account ids match');
                accountId[i].GPL_Profile__c=gpl.id;
                accountUpdate.add(accountId[i]);
            }
        }
        update  accountUpdate;
    }
}

if(trigger.IsUpdate){
//system.debug('the old Value is:'+Trigger.old.GPL_Profile__c.PreferredName__c);
Integer i;
Integer j;
//for(GPL_Profile__c gpl : trigger.new){
for(GPL_Profile__c gpl :[Select Id, Account__c, Contact__c, Account__r.IsPersonAccount,Devices__c,Specialties__c,Procedures__c,Languages__c,MedicalSchool__c,Fellowship__c,Residency__c,Facebook__c,Twitter__c, LinkedIn__c, Picture_Id__c,GPL_Physician_Locator__c, PreferredName__c, Inactive__c from GPL_Profile__c where Id IN: trigger.new]){
    system.debug('the size of the account list is: '+accountId.size());
    system.debug('GPLAccount__c:'+gpl.Account__c);
    system.debug('The GPL Accoun is'+gpl.Account__r.IsPersonAccount);
    //if(gpl.Account__c != Null){
    if(gpl.Account__c != Null && gpl.Account__r.IsPersonAccount==True){
    system.debug('the preffered name Value is:'+gpl.PreferredName__c);
    for(i=0; i<accountId.size() ;i++)
        {
    system.debug('the preffered name Value is:'+gpl.PreferredName__c);
     system.debug('the value is:'+gpl.Inactive__c);
            //if(gpl.Account__c == accountId[i].id && gpl.Account__r.IsPersonAccount)
            if(gpl.Account__c == accountId[i].id)
            {
                system.debug('the preffered name Value is:'+gpl.PreferredName__c);
                accountId[i].Technique__c = gpl.Devices__c;
                accountId[i].Specialty_integration__c = gpl.Specialties__c;
                accountId[i].Expertise_Integration_purpose__c = gpl.Procedures__c;
                accountId[i].Languages__c = gpl.Languages__c;
                accountId[i].Medical_School__c = gpl.MedicalSchool__c;
                accountId[i].Fellowship__c = gpl.Fellowship__c;
                accountId[i].Residency__c = gpl.Residency__c;
                accountId[i].Facebook_URL__c = gpl.Facebook__c;
                accountId[i].Twitter_ID__c = gpl.Twitter__c;
                accountId[i].LinkedInURL__c = gpl.LinkedIn__c;  
                //accountId[i].Preferred_Name__c = gpl.PreferredName__c;            
                accountId[i].Account_Picture_Id__c = gpl.Picture_Id__c;
                
                //GPLProfile.MedicalSchool__c = GplProfileBuilder.formatMedicalSchool(Acc[0].Medical_Degree__c, Acc[0].Medical_School__c, Acc[0].Med_Grad_Date__c);
                //GPLProfile.Fellowship__c = GplProfileBuilder.formatResOrFellow(Acc[0].Fellowship__c, Acc[0].Fellowship_Completion_Date__c);
                //GPLProfile.Residency__c = GplProfileBuilder.formatResOrFellow(Acc[0].Residency__c, Acc[0].Residency_Completion_Date__c); 
            
                 system.debug('the value is:'+gpl.Inactive__c);
                  system.debug('the distri value is:'+accountId[i].Distributor_Managed__pc);
                if(gpl.Inactive__c == False && accountId[i].Distributor_Managed__pc == True){
                    system.debug('the value is:'+gpl.Inactive__c);
                    gpl.GPL_Physician_Locator__c = True;
                    accountId[i].Physician_Locator_Status__pc='Locator Displayed';
                }
                
                if(gpl.GPL_Physician_Locator__c==True){
                
                   accountId[i].Physician_Locator_Status__pc='Locator Displayed';
                    //accountId[i].Physicians_Locator__pc=True;
                }
                    system.debug('the preffered name Value is:'+gpl.PreferredName__c);
                accountUpdate.add(accountId[i]);
    
            }
                       
        } 
         update  accountUpdate; 
                system.debug('the preffered name Value is:'+gpl.PreferredName__c);
    GPL_Profile__c gpl1 = new GPL_Profile__c();
    gpl1 = [select PreferredName__c from GPL_Profile__c where id=:gpl.id];
    system.debug('the preffered name Value is:'+gpl1.PreferredName__c);
    } 
        
    
    if(gpl.Contact__c != Null){
    for(j=0; j<contactId.size() ;j++)
        {
            if(contactId[j].id==gpl.Contact__c)
            {
            contactId[j].Language__c = gpl.Languages__c;
            
            }
        }
        update contactId;
    }

}
}
}
}