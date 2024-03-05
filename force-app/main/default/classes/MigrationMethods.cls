public class MigrationMethods {
  public static void migratePhotos() {
    MigrationPhotosBatch batch = new MigrationPhotosBatch();
    Id batchId = Database.executeBatch(batch, 200);
    system.debug(batchId);
  }

  public static void migrateProfiles() {
    MigrationProfilesBatch batch = new MigrationProfilesBatch();
    Id batchId = Database.executeBatch(batch, 100);
    system.debug(batchId);
  }

  public static void migrateLocations() {
    MigrationLocationsBatch batch = new MigrationLocationsBatch();
    Id batchId = Database.executeBatch(batch, 2000);
    system.debug(batchId);
  }
    
  public static void migratePostLocations() {
    MigrationPostLocationBatch batch = new MigrationPostLocationBatch();
    Id batchId = Database.executeBatch(batch, 2000);
    system.debug(batchId);
  }

  public static Map<Account, GPL_Profile__c> mapPhysicianToProfile(
    List<Account> listPhysicians
  ) {
    Set<Id> setPhysicianIds = new Set<Id>();
    for (Account physician : listPhysicians) {
      setPhysicianIds.add(physician.Id);
    }
    Set<Id> setPhysicianIdAlreadyAssigned = new Set<Id>();
    Map<Account, GPL_Profile__c> mapPhysicianToProfile = new Map<Account, GPL_Profile__c>();
    for (GPL_Profile__c profile : [
      SELECT ID, Account__c, PhotoId__c
      FROM GPL_Profile__c
      WHERE Account__c IN :setPhysicianIds AND PhotoId__c != NULL
      ORDER BY Inactive__c
    ]) {
      if (!setPhysicianIdAlreadyAssigned.contains(profile.Account__c)) {
        mapPhysicianToProfile.put(
          new Account(Id = profile.Account__c),
          profile
        );
        setPhysicianIdAlreadyAssigned.add(profile.Account__c);
      }
    }

    return mapPhysicianToProfile;
  }

  public static List<Attachment> prepareNewPhotos(
    Map<Account, GPL_Profile__c> mapPhysicianToProfile
  ) {
    List<Attachment> listNewPhotos = new List<Attachment>();
    Set<Id> setPhotosIds = new Set<Id>();
    for (Account physician : mapPhysicianToProfile.keySet()) {
      GPL_Profile__c profile = mapPhysicianToProfile.get(physician);
      setPhotosIds.add(profile.PhotoId__c);
    }
    List<Attachment> listOldPhotos = [
      SELECT ID, ParentId, NAME, BODY
      FROM ATTACHMENT
      WHERE ID IN :setPhotosIds
    ];
    for (Account physician : mapPhysicianToProfile.keySet()) {
      GPL_Profile__c profile = mapPhysicianToProfile.get(physician);
      Attachment oldPhoto = new Attachment();
      for (Attachment photo : listOldPhotos) {
        if (photo.Id == profile.PhotoId__c)
          oldPhoto = photo;
      }
      Attachment newPhoto = new Attachment();
      newPhoto.Body = oldPhoto.Body;
      String extension = '.png';
      if (String.isNotBlank(oldPhoto.Name))
        extension = oldPhoto.name.right(4);
      newPhoto.Name = PhotoManagementController.PHOTO_NAME + extension;
      newPhoto.ParentId = physician.Id;
        /*
        
        insert cv;
        */
      if (newPhoto.Body != null)
        listNewPhotos.add(newPhoto);
    }
    return listNewPhotos;
  }

  public static List<Account> updatePhotoURLInPhysicians(
    Map<Account, GPL_Profile__c> mapPhysicianToProfile,
    List<Attachment> listNewPhotos
  ) {
    List<Account> listPreparedPhysicians = new List<Account>();
    for (Account physician : mapPhysicianToProfile.keySet()) {
      GPL_Profile__c profile = mapPhysicianToProfile.get(physician);
      for (Attachment newPhoto : listNewPhotos) {
        if (newPhoto.ParentId == physician.Id) {
          physician.btydev__Picture_Id__pc = newPhoto.Id;
          listPreparedPhysicians.add(physician);
          break;
        }
      }
    }
    return listPreparedPhysicians;
  }
    public static void insertContentDocument(List<Attachment> listPhotos){
        List<ContentVersion> listCV = new List<ContentVersion>();
        Map<Id,Id> mapCVToPhysician = new Map<Id,Id>();
            Set<Id> setCV = new Set<Id>();
        for(Attachment att : listPhotos){
            String extension = '.png';
            if (String.isNotBlank(att.Name))
                extension = att.name.right(4);
            ContentVersion cv = new ContentVersion();
            cv.ContentLocation = 'S';
            cv.VersionData = att.Body;
            cv.Physician__c=att.ParentId;
            cv.Title = PhotoManagementController.PHOTO_NAME + extension;
            cv.PathOnClient = PhotoManagementController.PHOTO_NAME + extension;            
            listCV.add(cv);
        }
        insert listCV;
        for(ContentVersion cv : listCV){
            setCV.add(cv.Id);
        }
        List<ContentVersion> listCVWithCD = [SELECT ID, CONTENTDOCUMENTID,Physician__c FROM CONTENTVERSION WHERE ID IN :SETCV];
        List<ContentDocumentLink> listCDL = new List<ContentDocumentLink>();
        for(ContentVersion cv :listCVWithCD){
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = cv.ContentDocumentId;
            cdl.LinkedEntityId = cv.Physician__c;
            cdl.ShareType = 'V';
            listCDL.add(cdl);
        }
        insert listCDL;
    }
  public static List<Account> preparePhysicians(List<Account> listPhysicians) {
    Map<Account, GPL_Profile__c> mapAccountsToProfiles = mapAccountsToProfiles(
      listPhysicians
    );
    List<Account> listPreparedPhysicians = new List<Account>();
    for (Account physician : mapAccountsToProfiles.keySet()) {
      GPL_Profile__c profile = mapAccountsToProfiles.get(physician);
      physician.PreferredFirstName__c = profile.PreferredFirstName__c;
      physician.Procedures__c = profile.Procedures__c;
      physician.Physicians_Locator__pc = profile.GPL_Physician_Locator__c;
      physician.Specialty_integration__c += ';'+profile.Specialties__c;
      physician.Fellowship__c = profile.Fellowship__c;
      listPreparedPhysicians.add(physician);
    }
    return listPreparedPhysicians;
  }

  public static Map<Account, GPL_Profile__c> mapAccountsToProfiles(
    List<Account> listPhysicians
  ) {
    Set<Id> setPhysicianIds = new Set<Id>();
    for (Account physician : listPhysicians) {
      setPhysicianIds.add(physician.Id);
    }
    Map<Id, GPL_Profile__c> mapProfiles = new Map<Id, GPL_Profile__c>(
      [
        SELECT
          ID,
          Account__c,
          PreferredFirstName__c,
          Procedures__c,
          GPL_Physician_Locator__c,
          Fellowship__c,
          Specialties__c
        FROM GPL_Profile__c
        WHERE Account__c IN :setPhysicianIds AND Inactive__c = FALSE
      ]
    );
    Set<Id> setProfileIds = new Set<Id>();
    for (GPL_Profile__c profile : mapProfiles.values()) {
      setProfileIds.add(profile.Id);
    }
    List<GPL_Profile__c> listProfilesWithLocations = new List<GPL_Profile__c>();
    set<Id> setProfilesAssigned = new Set<Id>();
    for (GPL_Location__c location : [
      SELECT ID, GPL_Profile__c
      FROM GPL_Location__c
      WHERE
        GPL_Profile__c IN :setProfileIds
        AND GPL_Profile__r.Inactive__c = FALSE
    ]) {
      if (!setProfilesAssigned.contains(location.GPL_Profile__c)) {
        listProfilesWithLocations.add(mapProfiles.get(location.GPL_Profile__c));
        setProfilesAssigned.add(location.GPL_Profile__c);
      }
    }
    Set<Id> setPhysicianIdAlreadyAssigned = new Set<Id>();
    Map<Account, GPL_Profile__c> mapPhysicianToMatchingProfile = new Map<Account, GPL_Profile__c>();
    for (GPL_Profile__c profile : listProfilesWithLocations) {
      if (!setPhysicianIdAlreadyAssigned.contains(profile.Account__c)) {
        mapPhysicianToMatchingProfile.put(
          new Account(Id = profile.Account__c),
          profile
        );
        setPhysicianIdAlreadyAssigned.add(profile.Account__c);
      }
    }
    return mapPhysicianToMatchingProfile;
  }

  public static Map<Id, GPL_Profile__c> mapAccountIdsToProfiles(
    List<Account> listPhysicians
  ) {
    Set<Id> setPhysicianIds = new Set<Id>();
    for (Account physician : listPhysicians) {
      setPhysicianIds.add(physician.Id);
    }
    Map<Id, GPL_Profile__c> mapProfiles = new Map<Id, GPL_Profile__c>(
      [
        SELECT
          ID,
          Account__c,
          PreferredFirstName__c,
          Procedures__c,
          GPL_Physician_Locator__c
        FROM GPL_Profile__c
        WHERE Account__c IN :setPhysicianIds AND Inactive__c = FALSE
      ]
    );
    Set<Id> setProfileIds = new Set<Id>();
    for (GPL_Profile__c profile : mapProfiles.values()) {
      setProfileIds.add(profile.Id);
    }
    List<GPL_Profile__c> listProfilesWithLocations = new List<GPL_Profile__c>();
    set<Id> setProfilesAssigned = new Set<Id>();
    for (GPL_Location__c location : [
      SELECT ID, GPL_Profile__c
      FROM GPL_Location__c
      WHERE GPL_Profile__c IN :setProfileIds
    ]) {
      if (!setProfilesAssigned.contains(location.GPL_Profile__c)) {
        listProfilesWithLocations.add(mapProfiles.get(location.GPL_Profile__c));
        setProfilesAssigned.add(location.GPL_Profile__c);
      }
    }
    Set<Id> setPhysicianIdAlreadyAssigned = new Set<Id>();
    Map<Id, GPL_Profile__c> mapPhysicianToMatchingProfile = new Map<Id, GPL_Profile__c>();
    for (GPL_Profile__c profile : listProfilesWithLocations) {
      if (!mapPhysicianToMatchingProfile.containsKey(profile.Account__c)) {
        mapPhysicianToMatchingProfile.put(profile.Account__c, profile);
      }
    }
    return mapPhysicianToMatchingProfile;
  }

  public static List<Healthcare_Surgeon_Relationship__c> relatePhysicianWithMatchingProfile(
    List<Healthcare_Surgeon_Relationship__c> listRelationships
  ) {
    List<Account> listPhysicians = new List<Account>();
    Set<Id> setPhysiciansAssigned = new Set<Id>();
    for (Healthcare_Surgeon_Relationship__c relationship : listRelationships) {
      if (!setPhysiciansAssigned.contains(relationship.Surgeon__c)) {
        listPhysicians.add(new Account(Id = relationship.Surgeon__c));
        setPhysiciansAssigned.add(relationship.Surgeon__c);
      }
    }
    Map<Id, GPL_Profile__c> mapAccountIdsToProfiles = mapAccountIdsToProfiles(
      listPhysicians
    );
    for (Healthcare_Surgeon_Relationship__c relationship : listRelationships) {
      relationship.Surgeon__r.GPL_Profile__r = mapAccountIdsToProfiles.get(
        relationship.Surgeon__c
      );
    }
    return listRelationships;
  }
  public static GPL_Location__c getMatchingLocation(
    Healthcare_Surgeon_Relationship__c relationship,
    Map<Id, List<GPL_Location__c>> mapProfileIdToLocations
  ) {
    List<GPL_Location__c> listLocations = mapProfileIdToLocations.get(
      relationship.Surgeon__c
    );
    if (listLocations == null) {
      return null;
    }
      GPL_Location__c matchingLocation = null;
    for (GPL_Location__c location : listLocations) {
        String locationPostalCode = location.PostalCode__c;
        String healthcarePostalCode = relationship.Healthcare_Facility__r.ShippingPostalCode;
        if(String.isNotBlank(locationPostalCode))
            if(locationPostalCode.getChars().size()>4)
            	locationPostalCode = locationPostalCode.substring(0, 5);
        if(String.isNotBlank(healthcarePostalCode))
            if(healthcarePostalCode.getChars().size()>4)
            	healthcarePostalCode = healthcarePostalCode.substring(0, 5);
      if (
        locationPostalCode ==
        healthcarePostalCode &&
        location.State__c ==
        relationship.Healthcare_Facility__r.ShippingState          
      ) {
          if( 
              (getFirstNumberInString(location.Street__c) ==
               getFirstNumberInString(
                   relationship.Healthcare_Facility__r.ShippingStreet
               )
               ||
               getFirstNumberInStringSeparatedByLines(location.Street__c) ==
               getFirstNumberInStringSeparatedByLines(
                   relationship.Healthcare_Facility__r.ShippingStreet
               ))){
                   if(location.Location_Type__c=='Practice')
                       return location;
                   else
                       matchingLocation=location;
               }
          else if(deeperStreetComparison(location.Street__c,relationship.Healthcare_Facility__r.ShippingStreet) >= 0.40){
              if(location.Location_Type__c=='Practice')
                  return location;
              else
                  matchingLocation=location;
          }
      }
    }
    return matchingLocation;
  }
    public static Decimal deeperStreetComparison(String locationStreet, String facilityStreet) {
      List<String> locationStreetList = new List<String>();
      List<String> facilityStreetList = new List<String>();
      Map<String,String> keywordsMap = getKeywordsMap();
      for(String token : locationStreet.split(' ')){
          String newToken = token.toLowerCase();
          if(keywordsMap.containsKey(newToken))
          	locationStreetList.add(keywordsMap.get(newToken));
          else
          	locationStreetList.add(newToken);
      }
      for(String token : facilityStreet.split(' ')){
          String newToken = token.toLowerCase();
          if(keywordsMap.containsKey(newToken))
          	facilityStreetList.add(keywordsMap.get(newToken));
          else
          	facilityStreetList.add(newToken);
      }
      Decimal matchesFound = 0;
      for(String token : locationStreetList){
          if(facilityStreetList.contains(token))
              matchesFound++;
      }
      Decimal maxtotalTokens = Math.max(locationStreetList.size(), facilityStreetList.size());
      return matchesFound/maxtotalTokens;
  }
    
  public static Map<String,String> getKeywordsMap() {
      Map<String,String> keywordsMap = new Map<String,String>();
      keywordsMap.put('se','southeast');
      keywordsMap.put('ne','northeast');
      keywordsMap.put('sw','southwest');
      keywordsMap.put('nw','northwest');
      keywordsMap.put('pl','place');
      keywordsMap.put('hosp','hospital');
      keywordsMap.put('ave','avenue');
      keywordsMap.put('st','street');
      keywordsMap.put('fl','floor');
      keywordsMap.put('e','east');
      keywordsMap.put('n','north');
      keywordsMap.put('s','south');
      keywordsMap.put('w','west');
      return keywordsMap;
  }
    
  public static String getFirstNumberInString(String str) {
    Pattern pat = Pattern.compile('([0-9]+)');
    Matcher matcher = pat.matcher(str);
    if (matcher.find()) {
      return matcher.group(1);
    }
    return str;
  }
    
  public static String getFirstNumberInStringSeparatedByLines(String str) {
    List<String> listStr = str.split('\n');
      for(String line : listStr){
          List<String> listWords = line.split(' ');
          if(listWords.size()>0)
              if(listWords.get(0).isNumeric())
              	return listWords.get(0);
      }
      return str;
  }
    
  public static Map<Id, List<GPL_Location__c>> mapAccountToLocations(
    List<Healthcare_Surgeon_Relationship__c> listRelationships
  ) {
    Map<Id, List<GPL_Location__c>> mapAccountToLocations = new Map<Id, List<GPL_Location__c>>();
    Set<Id> setPhysiciansAssigned = new Set<Id>();
    for (Healthcare_Surgeon_Relationship__c relationship : listRelationships) {
      if (!setPhysiciansAssigned.contains(relationship.Surgeon__c)) {
        setPhysiciansAssigned.add(relationship.Surgeon__c);
      }
    }
    for (GPL_Location__c location : [
      SELECT
        Name__c,
        GPL_Profile__c,
        GPL_Profile__r.Account__c,
        GPL_Profile__r.Account__r.Name,
        PostalCode__c,
        State__c,
        Street__c,
        Location_Type__c
      FROM GPL_Location__c
      WHERE GPL_Profile__r.Account__c IN :setPhysiciansAssigned
        AND GPL_Profile__r.Inactive__c = FALSE
         ORDER BY location_type__c
    ]) {
      if (mapAccountToLocations.containsKey(location.GPL_Profile__r.Account__c)) {
        List<GPL_Location__c> listLocations = mapAccountToLocations.get(
          location.GPL_Profile__r.Account__c
        );
        listLocations.add(location);
        mapAccountToLocations.put(location.GPL_Profile__r.Account__c, listLocations);
      } else {
        List<GPL_Location__c> listLocations = new List<GPL_Location__c>{
          location
        };
        mapAccountToLocations.put(location.GPL_Profile__r.Account__c, listLocations);
      }
    }
    return mapAccountToLocations;
  }
}