trigger ContactRecordCustomMerge on Contact (after delete) 
{
//******************************************************************************************//
// Trigger name: ContactRecordCustomMerge 
//Author: Naveen Chugh 
// Date of last modification: 9/2/2011  
// Purpose of this trigger: When two Contacts (Zimmer Standard contact record type)   
// then the deleted record will be undeleted. This Trigger runs after a contact has been
// deleted by performing a Merge and with the Help of a class Undeletes the contact and amkes it
// Inactive.
//******************************************************************************************//
    List<Id> idList = new List<Id>();
    string masterid;
    //string ZimmerContactNum;
    string RecTypeId, MasterRecTypeID, MergeRecId;
    //Setting the condition that only an user of Custom-Data Admin profile can perform custom Merge on Contacts
    profile[] UserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId() limit 1];
    if(UserProfile.size()>0 && UserProfile[0].Id == '00e80000001SQMI') 
    {
        //Getting the various field values from the just deleted contact by due to Standard Merge
        for(Contact a : trigger.old)
        {
        MergeRecId=a.id;
        if(a.MasterRecordId != null)
            {
            idList.add(a.id);
            masterid = a.MasterRecordId;
            //ZimmerAccNum = a.MDM_SAP_ID__c;
            RecTypeId = a.RecordTypeId; 
            }
        }
        Contact[] Master = [select Id, RecordTypeId from Contact where id = :masterid limit 1];
        if(idList.size()==1)
        if(Master.size()>0)
            {
            //Assigning the value of the Master record Type Id to a variable
            MasterRecTypeID = Master[0].RecordTypeId;
                       // The custom Merge will work only if both the contacts that hav been merged are of Zimmer Standard Contact Record Type
                        if(RecTypeId == '012800000002DoLAAU' )
                            if(MasterRecTypeID == '012800000002DoLAAU')
                            {
                                //The Required variables are being passed over to the ContactCustomMergeClass to undelete the Contacts just deleted by standard merge 
                                ContactCustomMergeClass.undelfunction(idList,masterid);
                            }
            }
     }
}