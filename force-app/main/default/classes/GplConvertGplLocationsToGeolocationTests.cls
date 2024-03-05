@isTest
private class GplConvertGplLocationsToGeolocationTests {
    static testMethod void testGplConvertGplLocationsToGeolocation() {        
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
		
        Test.startTest();
        String query = 'SELECT Id, Latitude__c, Longitude__c, Geolocation__Latitude__s, Geolocation__Longitude__s FROM GPL_Location__c where Name__c like \'TEST%\'';
        GplConvertGplLocationsToGeolocation batch = new GplConvertGplLocationsToGeolocation();
        batch.query = query;
        Id batchProcessId = Database.executeBatch(batch);
        Test.stopTest();
		List<sObject> results = Database.query(query);
		boolean valid = true;        
        for (sObject obj : results) {
            GPL_Location__c loc = (GPL_Location__c)obj;
            if (loc.Latitude__c != loc.Geolocation__Latitude__s || loc.Longitude__c != loc.Geolocation__Longitude__s) {
                valid = false;
                break;
            }
        }
        
        System.assertEquals(valid, true);
		
    }
}