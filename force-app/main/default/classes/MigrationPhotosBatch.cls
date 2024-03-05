global class MigrationPhotosBatch implements Database.Batchable<sObject>,Database.Stateful {
    public integer matchCount = 0;
    
  global Database.QueryLocator start(Database.BatchableContext BC) {
      Id physicianRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
          .get('Physician')
          .getRecordTypeId();
    String query = 'SELECT ID, GPL_Profile__c, GPL_Profile__r.PhotoId__c FROM Account WHERE RecordTypeId=:physicianRecordTypeId';
    return Database.getQueryLocator(query);
  }

  global void execute(
    Database.BatchableContext BC,
    List<Account> listPhysicians
  ) {
     Map<Account, GPL_Profile__c> mapPhysicianToProfile = MigrationMethods.mapPhysicianToProfile(listPhysicians);
    List<Attachment> listNewPhotos = MigrationMethods.prepareNewPhotos(
      mapPhysicianToProfile
    );
    system.debug('List of photos: ' + listNewPhotos.size());
    insert listNewPhotos;
      
    MigrationMethods.insertContentDocument(
      listNewPhotos
    );

    List<Account> listPhysiciansToUpdate = MigrationMethods.updatePhotoURLInPhysicians(
      mapPhysicianToProfile,
      listNewPhotos
    );
    system.debug(
      'List of physicianstoUpdate: ' + listPhysiciansToUpdate.size()
    );

    List<Database.SaveResult> updateResults = Database.update(listPhysiciansToUpdate, false);
      for(Database.SaveResult result : updateResults){
          if(result.isSuccess())
              matchCount+=1;
      }
  }

  global void finish(Database.BatchableContext BC) {
      System.debug('Number of matches: '+matchCount);
  }
}