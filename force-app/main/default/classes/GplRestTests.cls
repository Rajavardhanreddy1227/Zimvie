@isTest
private class GplRestTests {

    static testmethod void testSearchPhysicians(){
        Id personAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Physician');
    //Id hospitalAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Healthcare Facility');
    Id hospitalAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','HealthcareFacility');
    //Id physicianRTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL Physician Profile' );
    Id physicianRTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_PhysicianProfile');
    list<GPL_Profile__c> profiles = new list<GPL_Profile__c>();
    list<Account> personAccounts = new list<Account>();
    list<Account> hospitalAccounts = new list<Account>();
    for (integer i=0;i<5;i++){
      Account doctor = new Account(
        RecordTypeId = personAccountTypeId,
        FirstName = 'Test' + i,
        LastName = 'Doctor',
        PersonMailingStreet = 'TEST 789 Maple St',
        PersonMailingCity = 'Puerto Villamil',
        PersonMailingState = 'EC',
        PersonMailingPostalCode = 'EC012001',
        PersonMailingCountry = 'EC',
        MDM_SAP_ID__c = '9999999' + i,
        Specialty_integration__c = 'Knee',
        Technique__c = 'MIS',
        Expertise_Integration_purpose__c = 'Gender Knee',
        Physicians_Locator__c = true
      );
      personAccounts.add(doctor);
    }
    insert personAccounts;
    for (Account a : personAccounts){
      a.RecordTypeId = personAccountTypeId;
    }
    update personAccounts;
    for (integer i=0;i<5;i++){
      GPL_Profile__c profile = new GPL_Profile__c(
        Account__c = personAccounts.get(i).Id,
        MasterId__c = personAccounts.get(i).Id,
        RecordTypeId = physicianRTypeId,
        Devices__c = 'Kinectiv',
        Groups__c = 'AAOS',
        Honors__c = 'Man of the Year (2011)',
        Publications__c = 'How to replace a knee (Doctor Review - May 2011)',
        Specialties__c = 'Knee',
        Procedures__c = 'MIS',
        Languages__c = 'English',
        Facebook__c = 'http://www.facebook.com',
        Twitter__c = 'http://www.twitter.com',
        LinkedIn__c = 'http://www.linkedin.com',
        YouTube__c = 'http://www.youtube.com'
      );
      profiles.add(profile);
    }
    insert profiles;
    list<GPL_Location__c> locations = new list<GPL_Location__c>();
    for (integer i=0;i<5;i++){
      GPL_Profile__c profile = profiles.get(i);
      GPL_Location__c l1 = new GPL_Location__c(
        GPL_Profile__c = profile.Id,
        Location_Type__c = 'Practice',
        Name__c = 'TEST Practice 1 for ' + profile.Name,
        Street__c = 'TEST Mataveri International Airport',
        City__c = 'Easter Island',
        State__c = 'CL',
        PostalCode__c = 'CL012001',
        Country__c = 'CL',
           Geolocation__latitude__s = -27.128,
           Geolocation__longitude__s = -109.341, //Easter Island
           Phone__c = '574-372-4068',
           Fax__c = '574-372-4068',
           Website__c = 'http://www.google.com',
           Services__c = 'Pickup Services'
      );
      locations.add(l1);
      GPL_Location__c l2 = new GPL_Location__c(
        GPL_Profile__c = profile.Id,
        Location_Type__c = 'Practice',
        Name__c = 'TEST Practice 2 for ' + profile.Name,
        Street__c = 'TEST 123 Main Street',
        City__c = 'Puerto Villamil',
        State__c = 'EC',
        PostalCode__c = 'EC012001',
        Country__c = 'EC',
           Geolocation__latitude__s = -0.8292784,
           Geolocation__longitude__s = -90.98206679999998,  //Galapagos Islands
           Phone__c = '574-372-4068',
           Fax__c = '574-372-4068',
           Website__c = 'http://www.google.com',
           Services__c = 'Pickup Services'
      );
      locations.add(l2);
    }
    insert locations;
    
    GplRestDataModel.Criteria criteria1 = new GplRestDataModel.Criteria();
        GplRestDataModel.Coordinate coordinate = new GplRestDataModel.Coordinate();
        coordinate.longitude = -90.93714631272884;
        coordinate.latitude = -0.874193336118468;
        criteria1.coordinate = coordinate; 
        criteria1.radius = 10;        //within 5 miles of the Galapagos Islands
        criteria1.radiusUom = 'mi';
        criteria1.specialty = 'Knee';
        criteria1.procedure = 'MIS';
        criteria1.medicalDevice = 'Kinectiv';
        criteria1.city = 'Puerto Villamil';
        criteria1.state = 'EC';
        criteria1.postalCode = 'EC012001';
        criteria1.country = 'EC';    
        criteria1.firstName = 'Test';
        criteria1.lastName = 'Doctor';
        
    GplRestDataModel.Criteria criteria2 = new GplRestDataModel.Criteria();
        criteria2.specialty = 'Knee';
        criteria2.procedure = 'MIS';
        criteria2.medicalDevice = 'Kinectiv';
        criteria2.city = 'Puerto Villamil';
        criteria2.state = 'EC';
        criteria2.postalCode = 'EC012001';
        criteria2.country = 'EC';    
        criteria2.firstName = 'Test';
        criteria2.lastName = 'Doctor';
        
    test.startTest();
    //GplRestDataManager manager = new GplRestDataManager();
    //manager.searchPhysicians(criteria1);
    /*list<GplRestDataModel.Profile> results1 = GplRestPhysicianEndpoint.searchPhysicians(criteria1);
    System.assertEquals(5,results1.size());
      
    list<GplRestDataModel.Profile> results2 = GplRestPhysicianEndpoint.searchPhysicians(criteria2);
    System.assertEquals(5,results2.size());
    
    for (GplRestDataModel.Profile p : results1){
      //System.assertEquals('Test',p.firstName);
      System.assertEquals(2, p.locations.size());   
      for (GplRestDataModel.Location l : p.locations){
        System.assertEquals(true,l.name.startsWith('TEST'));
      }
    } */ 
    
    test.stopTest();
    }
    static testmethod void testSearchClinics(){
        Id CLINIC_RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_ClinicProfile' );
        //Id practiceAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Practice');
    Id hospitalAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','HealthcareFacility');
        list<GPL_Profile__c> profiles = new list<GPL_Profile__c>();
        list<Account> practiceAccounts = new list<Account>();
        for(integer i=0; i<5; i++){
            Account practice = new Account(
                RecordTypeId = hospitalAccountTypeId,
              Name = 'TEST Medical Practice ' + i, 
        ShippingStreet = 'TEST 123 Maple St',
        ShippingCity = 'Puerto Villamil',
        ShippingState = 'EC',
        ShippingPostalCode = 'EC012001 ',
        ShippingCountry = 'EC'
            );
            practiceAccounts.add(practice);
        }
        
        insert practiceAccounts;
        
        for(integer i = 0; i<5; i++){
            GPL_Profile__c profile = new GPL_Profile__c(
              Account__c = practiceAccounts.get(i).Id,
                MasterId__c = practiceAccounts.get(i).Id,
        RecordTypeId = CLINIC_RECORD_TYPE_ID,
        Devices__c = 'Kinectiv',
        Specialties__c = 'Knee',
        Procedures__c = 'MIS',
        Facebook__c = 'http://www.facebook.com',
        Twitter__c = 'http://www.twitter.com',
        LinkedIn__c = 'http://www.linkedin.com',
        YouTube__c = 'http://www.youtube.com'
              );  
            profiles.add(profile);
        }
        
        insert profiles;
        list<GPL_Location__c> locations = new list<GPL_Location__c>();
        for(integer i=0; i<5; i++){
            GPL_Profile__c profile = profiles.get(i);
            GPL_Location__c l1 = new GPL_Location__c(
                GPL_Profile__c = profile.Id,
        Location_Type__c = 'Practice',
        Name__c = 'TEST Location 1 for ' + profile.Name,
        Street__c = 'TEST Mataveri International Airport',
        City__c = 'Easter Island',
        State__c = 'CL',
        PostalCode__c = 'CL012001',
        Country__c = 'CL',
           Geolocation__Latitude__s = -27.128,
           Geolocation__Longitude__s = -109.341, //Easter Island
           Phone__c = '574-372-4068',
           Fax__c = '574-372-4068',
           Website__c = 'http://www.google.com',
           Services__c = 'Pickup Services'
            );
            locations.add(l1);
            
            GPL_Location__c l2 = new GPL_Location__c(
        GPL_Profile__c = profile.Id,
        Location_Type__c = 'Practice',
        Name__c = 'TEST Location 2 for ' + profile.Name,
        Street__c = 'TEST 123 Main Street',
        City__c = 'Puerto Villamil',
        State__c = 'EC',
        PostalCode__c = 'EC012001',
        Country__c = 'EC',
           Geolocation__Latitude__s = -0.8292784,
           Geolocation__Longitude__s = -90.98206679999998,  //Galapagos Islands
           Phone__c = '574-372-4068',
           Fax__c = '574-372-4068',
           Website__c = 'http://www.google.com',
           Services__c = 'Pickup Services'
      );
      locations.add(l2);
        }
        insert locations;
        
        GplRestDataModel.Criteria criteria1 = new GplRestDataModel.Criteria();
        criteria1.specialty = 'Knee';
        criteria1.procedure = 'MIS';
        criteria1.medicalDevice = 'Kinectiv';
        criteria1.city = 'Puerto Villamil';
        criteria1.state = 'EC';
        criteria1.postalCode = 'EC012001';
        criteria1.country = 'EC';  
        
        GplRestDataModel.Criteria criteria2 = new GplRestDataModel.Criteria();
        GplRestDataModel.Coordinate coordinate = new GplRestDataModel.Coordinate();
        coordinate.latitude = -0.784363463881532;
        coordinate.longitude = -91.02698728727113;
        criteria1.coordinate = coordinate;
        criteria1.radius = 10;
        criteria1.radiusUom = 'mi';
        criteria2.specialty = 'Knee';
        criteria2.procedure = 'MIS';
        criteria2.medicalDevice = 'Kinectiv';
        criteria2.city = 'Puerto Villamil';
        criteria2.state = 'EC';
        criteria2.postalCode = 'EC012001';
        criteria2.country = 'EC';  
        
        test.startTest();
        //GplRestDataManager manager = new GplRestDataManager();
        //manager.searchClinics(criteria1);
        /*list<GplRestDataModel.Profile> results1 = GplRestClinicEndpoint.searchClinics(criteria1);
    System.assertEquals(5,results1.size());
      
    list<GplRestDataModel.Profile> results2 = GplRestClinicEndpoint.searchClinics(criteria2);
    System.assertEquals(5,results2.size());
        
        for (GplRestDataModel.Profile p : results1){
      //System.assertEquals('Test',p.firstName);
      System.assertEquals(2, p.locations.size());   
      for (GplRestDataModel.Location l : p.locations){
        System.assertEquals(true,l.name.startsWith('TEST'));
      }
    }*/  
    
    test.stopTest();
    }
    
    static testmethod void testSearchDentists(){
        Id contactTypeId = RecordTypeHelper.getRecordTypeId('Contact','DN_Global_Contact_Record_Type');    
  //  Id DNCAAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','DN_CA_Account_Record_Type');    
    Id dentistRTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_DentistProfile');
        Id DNCAAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','DN_EU_Ghost_Account');
    list<GPL_Profile__c> profiles = new list<GPL_Profile__c>();
    list<Contact> DNCAContacts = new list<Contact>();
    list<Account> DNCAAccounts = new list<Account>();
    Account DNCAAccount= new Account(Name='DENTIST LOCATOR TEST', RecordTypeId=DNCAAccountTypeId);
        insert DNCAAccount;
        
        for (integer i=0;i<5;i++){
      Contact dentist = new Contact(
        RecordTypeId = contactTypeId,
        FirstName = 'Test' + i,
        LastName = 'Doctor',
        MailingStreet = 'TEST 789 Maple St',
        MailingCity = 'Puerto Villamil',
        MailingState = 'EC',
        MailingPostalCode = 'EC012001',
        MailingCountry = 'EC',
        //MDM_SAP_ID__c = '9999999' + i,
        //Specialty_integration__c = 'Knee',
        //Technique__c = 'MIS',
        //Expertise_Integration_purpose__c = 'Gender Knee',
        Physicians_Locator__c = true,
        AccountId=DNCAAccount.Id
      );
      DNCAContacts.add(dentist);
    }
        
        insert DNCAContacts;
        
        for(integer i=0; i<5; i++){
            GPL_Profile__c profile = new  GPL_Profile__c(
                Contact__c = DNCAContacts.get(i).Id,
        MasterId__c = DNCAContacts.get(i).Id,
        RecordTypeId = dentistRTypeId,
        Devices__c = 'Kinectiv',
        Groups__c = 'AAOS',
        Honors__c = 'Man of the Year (2011)',
        Publications__c = 'How to replace a knee (Doctor Review - May 2011)',
        Specialties__c = 'Knee',
        Procedures__c = 'MIS',
        Languages__c = 'English',
        Facebook__c = 'http://www.facebook.com',
        Twitter__c = 'http://www.twitter.com',
        LinkedIn__c = 'http://www.linkedin.com',
        YouTube__c = 'http://www.youtube.com'
            );
            profiles.add(profile);
        }
        
        insert profiles;
        list<GPL_Location__c> locations = new list<GPL_Location__c>();
    for (integer i=0;i<5;i++){
      GPL_Profile__c profile = profiles.get(i);
      GPL_Location__c l1 = new GPL_Location__c(
        GPL_Profile__c = profile.Id,
        Location_Type__c = 'Practice',
        Name__c = 'TEST Practice 1 for ' + profile.Name,
        Street__c = 'TEST Mataveri International Airport',
        City__c = 'Easter Island',
        State__c = 'CL',
        PostalCode__c = 'CL012001',
        Country__c = 'CL',
           Geolocation__Latitude__s = -27.128,
           Geolocation__Longitude__s = -109.341, //Easter Island
           Phone__c = '574-372-4068',
           Fax__c = '574-372-4068',
           Website__c = 'http://www.google.com',
           Services__c = 'Pickup Services'
      );
      locations.add(l1);
         GPL_Location__c l2 = new GPL_Location__c(
        GPL_Profile__c = profile.Id,
        Location_Type__c = 'Practice',
        Name__c = 'TEST Practice 2 for ' + profile.Name,
        Street__c = 'TEST 123 Main Street',
        City__c = 'Puerto Villamil',
        State__c = 'EC',
        PostalCode__c = 'EC012001',
        Country__c = 'EC',
           Geolocation__Latitude__s = -0.8292784,
           Geolocation__Longitude__s = -90.98206679999998,  //Galapagos Islands
           Phone__c = '574-372-4068',
           Fax__c = '574-372-4068',
           Website__c = 'http://www.google.com',
           Services__c = 'Pickup Services'
      );
      locations.add(l2);
    }
        
        insert locations;
        GplRestDataModel.Criteria criteria1 = new GplRestDataModel.Criteria();
        criteria1.specialty = 'Knee';
        criteria1.procedure = 'MIS';
        criteria1.medicalDevice = 'Kinectiv';
        criteria1.city = 'Puerto Villamil';
        criteria1.state = 'EC';
        criteria1.postalCode = 'EC012001';
        criteria1.country = 'EC';    
        criteria1.firstName = 'Test';
        criteria1.lastName = 'Doctor';
        
    GplRestDataModel.Criteria criteria2 = new GplRestDataModel.Criteria();
        GplRestDataModel.Coordinate coordinate = new GplRestDataModel.Coordinate();
        coordinate.latitude = -0.784363463881532;
        coordinate.longitude = -91.02698728727113;
        criteria1.coordinate = coordinate;
        criteria1.radius = 10;
        criteria1.radiusUom = 'mi';
        criteria2.specialty = 'Knee';
        criteria2.procedure = 'MIS';
        criteria2.medicalDevice = 'Kinectiv';
        criteria2.city = 'Puerto Villamil';
        criteria2.state = 'EC';
        criteria2.postalCode = 'EC012001';
        criteria2.country = 'EC';    
        criteria2.firstName = 'Test';
        criteria2.lastName = 'Doctor';
        
        test.startTest();
        //GplRestDataManager manager = new GplRestDataManager();
        //manager.searchDentists(criteria1);
        /*list<GplRestDataModel.Profile> results1 = GplRestDentistEndpoint.searchDentists(criteria1);
    System.assertEquals(5,results1.size());
      
    list<GplRestDataModel.Profile> results2 = GplRestDentistEndpoint.searchDentists(criteria2);
    System.assertEquals(5,results2.size());
        
        for (GplRestDataModel.Profile p : results1){
      //System.assertEquals('Test',p.firstName);
      System.assertEquals(2, p.locations.size());   
      for (GplRestDataModel.Location l : p.locations){
        System.assertEquals(true,l.name.startsWith('TEST'));
      }
    } */ 
    
    test.stopTest();
    }
    
    
    static testmethod void testRetrieveImage(){ 
    Id personAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Physician');
    Id hospitalAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','HealthcareFacility');
    Id physicianRTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_PhysicianProfile');
    list<GPL_Profile__c> profiles = new list<GPL_Profile__c>();
    list<Account> personAccounts = new list<Account>();
    list<Account> hospitalAccounts = new list<Account>();
    for (integer i=0;i<5;i++){
      Account doctor = new Account(
        RecordTypeId = personAccountTypeId,
        FirstName = 'Test' + i,
        LastName = 'Doctor',
        PersonMailingStreet = 'TEST 789 Maple St',
        PersonMailingCity = 'Puerto Villamil',
        PersonMailingState = 'EC',
        PersonMailingPostalCode = 'EC012001',
        PersonMailingCountry = 'EC',
        MDM_SAP_ID__c = '9999999' + i,
        Specialty_integration__c = 'Knee',
        Technique__c = 'MIS',
        Expertise_Integration_purpose__c = 'Gender Knee',
        Physicians_Locator__c = true
      );
      personAccounts.add(doctor);
    }
    insert personAccounts;
    for (Account a : personAccounts){
      a.RecordTypeId = personAccountTypeId;
    }
    update personAccounts;
    for (integer i=0;i<3;i++){
      GPL_Profile__c profile = new GPL_Profile__c(
        Account__c = personAccounts.get(i).Id,
        MasterId__c = personAccounts.get(i).Id,
        RecordTypeId = physicianRTypeId,
        Devices__c = 'Kinectiv',
        Groups__c = 'AAOS',
        Honors__c = 'Man of the Year (2011)',
        Publications__c = 'How to replace a knee (Doctor Review - May 2011)',
        Specialties__c = 'Knee',
        Procedures__c = 'MIS',
        Languages__c = 'English',
        Facebook__c = 'http://www.facebook.com',
        Twitter__c = 'http://www.twitter.com',
        LinkedIn__c = 'http://www.linkedin.com',
        YouTube__c = 'http://www.youtube.com'
      );
      profiles.add(profile);
    }
    insert profiles;
        
    list<GPL_Location__c> locations = new list<GPL_Location__c>();
    for (integer i=0;i<3;i++){
      GPL_Profile__c profile = profiles.get(i);
      GPL_Location__c l1 = new GPL_Location__c(
        GPL_Profile__c = profile.Id,
        Location_Type__c = 'Practice',
        Name__c = 'TEST Practice 1 for ' + profile.Name,
        Street__c = 'TEST Mataveri International Airport',
        City__c = 'Easter Island',
        State__c = 'CL',
        PostalCode__c = 'CL012001',
        Country__c = 'CL',
                Geolocation__Latitude__s = -27.128,
                Geolocation__Longitude__s = -109.341,
           Latitude__c = -27.128,
           Longitude__c = -109.341, //Easter Island
           Phone__c = '574-372-4068',
           Fax__c = '574-372-4068',
           Website__c = 'http://www.google.com',
           Services__c = 'Pickup Services'
      );
      locations.add(l1);
      GPL_Location__c l2 = new GPL_Location__c(
        GPL_Profile__c = profile.Id,
        Location_Type__c = 'Practice',
        Name__c = 'TEST Practice 2 for ' + profile.Name,
        Street__c = 'TEST 123 Main Street',
        City__c = 'Puerto Villamil',
        State__c = 'EC',
        PostalCode__c = 'EC012001',
        Country__c = 'EC',
                Geolocation__Latitude__s = -0.8292784,
                Geolocation__Longitude__s = -90.98206679999998,
           Latitude__c = -0.8292784,
           Longitude__c = -90.98206679999998,  //Galapagos Islands
           Phone__c = '574-372-4068',
           Fax__c = '574-372-4068',
           Website__c = 'http://www.google.com',
           Services__c = 'Pickup Services'
      );
      locations.add(l2);
    }
    insert locations;
    GplDataModel.SearchCriteria criteria1 = new GplDataModel.SearchCriteria();
    criteria1.physicianId = profiles.get(0).id;
    GplDataModel.PhysicianProfile profileToUpdate = GplLocatorService.searchPhysicians(criteria1).get(0);
    profileToUpdate.preferredFirstName = 'UPDATED';
    profileToUpdate.locations.get(0).name = profileToUpdate.locations.get(0).name + ' UPDATED';
    profileToUpdate.locations.remove(1); 
    GplDataModel.PhysicianProfile profileToAdd = new GplDataModel.PhysicianProfile();
    profileToAdd.preferredFirstName = 'ADDED';
    profileToAdd.specialties = 'Knee';
    profileToAdd.masterId = personAccounts.get(3).Id;
    list<GplDataModel.ProfileLocation> ptal = new list<GplDataModel.ProfileLocation>();
    GplDataModel.ProfileLocation ptal1 = new GplDataModel.ProfileLocation();
    ptal1.name = 'TEST Added Location 1';
    ptal1.street = 'TEST 123 Main Street';  
    ptal1.city = 'Puerto Villamil';
    ptal1.state = 'EC';
    ptal1.postalCode = 'EC012001';
    ptal1.country = 'EC';
    ptal1.latitude = -0.8292784;
    ptal1.longitude = -90.98206679999998;
    ptal1.phone = '123-456-7890';
    ptal1.fax = '098-765-4321';
    ptal1.website = 'http://www.google.com';
    ptal.add(ptal1);
    profileToAdd.locations = ptal;    
    list<GplDataModel.Hospital> ptah = new list<GplDataModel.Hospital>();
    GplDataModel.Hospital ptah1 = new GplDataModel.Hospital();
    ptah1.name = 'TEST Added Hospital 1';
    ptah1.street = 'TEST 123 Main Street';
    ptah1.city = 'Puerto Villamil';
    ptah1.state = 'EC';
    ptah1.postalCode = 'EC012001'; 
    ptah1.country = 'EC';
    ptah.add(ptah1);
    profileToAdd.hospitals = ptah;
        GplDataModel.Photo photo = new GplDataModel.Photo();
        photo.body = EncodingUtil.base64Decode('R0lGODlhAQABAPAAAP///////yH5BAAAAAAALAAAAAABAAEAAAICRAEAOw==');
        photo.contentType = 'image/gif';
        photo.bodyLength = photo.body.size();
    GplDataModel.Photo emptyPdf = new GplDataModel.Photo();
    emptyPdf.body = blob.toPdf('test');
    emptyPdf.contentType = 'application/pdf';
    emptyPdf.bodyLength = emptyPdf.body.size(); 
    
    GplDataModel.SearchCriteria criteria2 = new GplDataModel.SearchCriteria();
        GplDataModel.BoundingBox box = new GplDataModel.BoundingBox();
        box.east = -90.93714631272884;
        box.west = -91.02698728727113;
        box.north = -0.784363463881532;
        box.south = -0.874193336118468;        
    GplLocatorUpdateService.updatePhysician(profileToUpdate,photo,emptyPdf,'TESTUSER');
    GplLocatorUpdateService.updatePhysician(profileToAdd,null,emptyPdf,'TESTUSER');
    GplDataModel.PhysicianProfile updatedProfile = GplLocatorService.searchPhysicians(criteria1).get(0);
        
    test.startTest();
        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();
        req.requestURI = '/services/apexrest/gpl/image/' + updatedProfile.pictureId;
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = resp;
        GplRestImageEndpoint.searchImage();
        System.assert(resp.responseBody != null);
    test.stopTest();
    }

}