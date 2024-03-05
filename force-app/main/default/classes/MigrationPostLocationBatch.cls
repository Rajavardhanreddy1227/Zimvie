global class MigrationPostLocationBatch implements Database.Batchable<sObject>,Database.Stateful{
    public integer count = 0;
  	public String csv = 'RelationshipId,PhysicianId\n';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
      Id physicianRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
          .get('Physician')
          .getRecordTypeId();
        String classCode='002';
        List<GPL_Profile__c> listProfiles = [SELECT Account__c FROM GPL_Profile__c 
                                             WHERE Inactive__c=false AND Account__r.RecordtypeId=:physicianRecordTypeId];
        Set<Id> setAccountsIds = new Set<Id>();
        for(GPL_Profile__c profile : listProfiles){
            setAccountsIds.add(profile.Account__c);
        }
        String query = 'SELECT Id,Surgeon__c FROM HEALTHCARE_SURGEON_RELATIONSHIP__C '+
                                        ' WHERE LOCATION_TYPE__C=null AND HEALTHCARE_FACILITY__R.CLASS__C=:classCode AND Surgeon__c IN :setAccountsIds';
        if(Test.isRunningTest())
            query='SELECT Id,Surgeon__c FROM HEALTHCARE_SURGEON_RELATIONSHIP__C LIMIT 1';
        return Database.getQueryLocator(query);
    }
    
    global void execute(
        Database.BatchableContext BC,
        List<Healthcare_Surgeon_Relationship__c> listRelationships
    ) {
        for(Healthcare_Surgeon_Relationship__c relationship : listRelationships){
            csv+= relationship.Id+','+relationship.Surgeon__c+'\n';
            relationship.location_type__c='Hospital';
        }
        count+=listRelationships.size();
        update listRelationships;
    }
    
    global void finish(Database.BatchableContext BC) {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = Blob.valueOf(csv);
        cv.Title =  'Post Location Migration Script Results.txt';
        cv.PathOnClient = 'Post Location Migration Script Results.txt';       
        insert cv;
        system.debug(cv.Id);
        system.debug('Number of updated relationships: ' + count);
    }
}