global class MigrationProfilesBatch implements Database.Batchable<sObject>,Database.Stateful {
    public integer matchCount = 0;
    
  global Database.QueryLocator start(Database.BatchableContext BC) {
      Id physicianRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
          .get('Physician')
          .getRecordTypeId();
    String query = 'SELECT ID, GPL_Profile__c, GPL_Profile__r.PreferredFirstName__c, GPL_Profile__r.Procedures__c, '+
        'GPL_Profile__r.GPL_Physician_Locator__c '+
        'FROM Account '+
        'WHERE RecordTypeId=:physicianRecordTypeId '+
        'AND GPL_PROFILE__R.INACTIVE__C=FALSE';
    return Database.getQueryLocator(query);
  }

  global void execute(Database.BatchableContext BC, List<Account> listPhysicians) {
    List<Account> listPreparedPhysicians = MigrationMethods.preparePhysicians(
        listPhysicians
    );
    matchCount += listPreparedPhysicians.size();
    update listPreparedPhysicians;
  }

  global void finish(Database.BatchableContext BC) {
      system.debug('Number of matches: '+matchCount);
  }
}