public class AccTeamMemberHandler {
    
    //Apex properties or variables
    public Id ownerId;
    public Id userId;
    public Id devRecordTypeId;
    public string currentUserEmailId;
    
    //constructor to get the user record
    public AccTeamMemberHandler(ApexPages.StandardController controller) {
        
        User usr =  (User) controller.getRecord();
        ownerId = usr.Id;
        currentUserEmailId = userinfo.getUserEmail();
        devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('DN-ACCT-RECORD-TYPE').getRecordTypeId();
        userId = ApexPages.currentPage().getParameters().get('id');
        System.debug('User record: ' + userId);
        System.debug('RecordType record: ' + devRecordTypeId); 
        
    }
    
    //Method that can is called from the Visual Force page action attribute
    public void updateISRNameOnAccounts() {
        
        System.debug('User record: ' + userId);
        System.debug('RecordType record: ' + devRecordTypeId);
        
        list<Account> updateAccts = new list<Account>();
        
        try  
        {
            Account acct = [Select Id,Name,OwnerId from Account where OwnerId=:userId and RecordTypeId=:devRecordTypeId and Account_Status__c=:'Active' Limit 1];
            system.debug('---acct-'+acct.Id);
            Id dentalISR_Id = [SELECT UserId,AccountId FROM AccountTeamMember WHERE TeamMemberRole=:'Dental - Inside Sales' AND AccountId=:acct.id ORDER BY TeamMemberRole ASC LIMIT 1].UserId;
            System.debug('dentalISR_Id: ' + dentalISR_Id);
            
            //Call Batch class
            //submits the batchExample batch Apex job for execution with a batch size of 50
            
            if(!Test.isRunningTest()){
                Id batchInstanceId = Database.executeBatch(new AccountTeamBatchClass(dentalISR_Id,userId,devRecordTypeId,currentUserEmailId), 50);
			}
            else{
                Database.executeBatch(new AccountTeamBatchClass(dentalISR_Id,userId,devRecordTypeId,currentUserEmailId));
            }
			
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Account teams update process started. You will get a confirmation email once the update is completed.')); 
            
        }
        
        catch(Exception ex)
        {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Some error occurred while updating the account teams :'+ex.getMessage())); 
        }
    }
    
}