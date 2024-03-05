//******************************************************************************************//
  // Trigger name: SurgeonCustomMerge
  // Class Name: aaaSurgeonMergeClass
  // Test Class: SurgeonMergeTest
  // Author: Saikishore Aengareddy
  // Date of last modification: 10/22/2010
  // Purpose of this trigger: When two accounts (physician, physician(processing),Fellow, 
  //                          Fellow(Processing), Resident(Processing), Resident) are merged 
  //                          then the deleted record will be un-deleted.

  //******************************************************************************************//
  
trigger aaaSurgeonCustomMerge on Account (after delete) {

  List<Id> idList = new List<Id>();
  string masterid;
  string ZimmerAccNum;
  string RecTypeId, MasterRecTypeID;
  //profile[] UserProfile = [Select Name From Profile where Id = :UserInfo.getProfileId() limit 1];
  //if(UserProfile.size()>0 && UserProfile[0].Name == 'Custom - Data Administrator')
  profile[] UserProfile = [Select Id From Profile where Id = :UserInfo.getProfileId() limit 1];
  if(UserProfile.size()>0 && (UserProfile[0].Id == '00e80000001SQMIAA4' || UserProfile[0].Id == '00e80000000sptdAAA'))
  {
      for(Account a : trigger.old)
      {
        system.debug( 'the id of the account is:' + a.Id);
        system.debug( 'the name of the account is:' + a.Name);
          if(a.MasterRecordId != null)
          {
              system.debug( 'the id of the Master Accounts Id is:' + a.MasterRecordId);
              system.debug( 'the id of the Master Accounts SAP Id is:' + a.MDM_SAP_ID__c);
              system.debug( 'the id of the Master Accounts Record Type is:' + a.RecordTypeId);
              idList.add(a.id);
              masterid = a.MasterRecordId;
              ZimmerAccNum = a.MDM_SAP_ID__c;
              RecTypeId = a.RecordTypeId;
             
              
        }
    } 
    
      Account[] Master = [select Id, External_ID__c, RecordTypeId, MDM_SAP_ID__c from Account where id = :masterid limit 1];
  for(Account b : Master)
  {
  system.debug( 'the id of the Master Accounts Record Type is:' + b.Id);
    system.debug( 'the external id of the Master Accounts Record Type is:' + b.External_ID__c); 
  }
  if(idList.size()==1)    
   if(Master.size()>0)
   {
    
       MasterRecTypeID = Master[0].RecordTypeId;
       if((ZimmerAccNum != NULL) && (Master[0].MDM_SAP_ID__c != NULL))
         if(ZimmerAccNum != Master[0].MDM_SAP_ID__c)
           if(RecTypeId == '012800000002C4gAAE' || RecTypeId == '012800000003YRmAAM' || RecTypeId == '012800000003YRcAAM' || RecTypeId == '012800000003YRrAAM' || RecTypeId == '012800000003YRhAAM' || RecTypeId == '012800000003YRnAAM')
             if(MasterRecTypeID == '012800000002C4gAAE' || MasterRecTypeID == '012800000003YRmAAM' || MasterRecTypeID == '012800000003YRcAAM' || MasterRecTypeID == '012800000003YRrAAM' || MasterRecTypeID == '012800000003YRhAAM' || MasterRecTypeID == '012800000003YRnAAM')
                 {
                 
                 aaaSurgeonMergeClass.undelfunction(idList,masterid);
                 }              
                      
     }
   }
}