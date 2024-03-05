global class AccountTeamBatchClass implements Database.Batchable<sObject>
{
    // collect the batches of records or objects to be passed to execute
    
    global final Id dentalISR_Id;
    global final Id acctOwner_Id;
    global final Id recordType_Id;
    global final string userEmail;
    global final string accStatus = 'Active';
    
    global map<string,Account> updateAccts = new map<string,Account>();
    
    
    global AccountTeamBatchClass(Id dentalISR,Id userId, Id recordTypeId, string userEmailId){
        
        System.debug('- Constructor: Begin -');
        
        system.debug('RecordType Id :'+recordTypeId);
        system.debug('User Id :'+userId);
        system.debug('Dental ISR Id :'+dentalISR);
        system.debug('UserEmail Id :'+userEmailId);
        
        dentalISR_Id = dentalISR;
        acctOwner_Id = userId;
        recordType_Id = recordTypeId;
        userEmail = userEmailId;
		
    }
	
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        // process each batch of records
        
        System.debug('- start: Begin -');
        
        //create sting query
        string query = 'SELECT Id, Name, ISR_Name__c, Account_Status__c FROM Account WHERE RecordTypeId=:recordType_Id AND Account_Status__c=:accStatus AND OwnerId=:acctOwner_Id AND ISR_Name__c!=:dentalISR_Id';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        System.debug('- execute: Begin -');
        for(Sobject s : scope){
            Account a = (Account)s; //typecast sobject to Account Object
            a.ISR_Name__c = dentalISR_Id;
            updateAccts.put(a.Id,a); 
        }      
        
        if(!updateAccts.isEmpty()){
        	update updateAccts.values();    
        }
        
        System.debug('- execute: End -');
    }
    
    global void finish(Database.BatchableContext BC){
        // execute any post-processing operations
        System.debug('- finish: Begin -');
        system.debug('- Update Accts List Batch Size -'+updateAccts.size());
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        mail.setToAddresses(new String[] {userEmail,'mohit.gulati@zimmerbiomet.com'});
        mail.setReplyTo('mohit.gulati@zimmerbiomet.com');
        mail.setSenderDisplayName('Batch Processing');
        mail.setSubject('Batch Process Completed');
        mail.setPlainTextBody('Batch Process has completed');
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        
    }
    
}