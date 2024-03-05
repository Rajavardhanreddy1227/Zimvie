@isTest
public class GplLocatorUpdateServiceTests {
    private static GplDataManager manager = new GpLDataManager(); 
	static testmethod void testUpdatePhysician(){ 
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
		GplDataModel.SearchCriteria criteria1 = new GplDataModel.SearchCriteria();
		criteria1.physicianId = profiles.get(0).id;
		GplDataModel.PhysicianProfile profileToUpdate = manager.searchPhysicians(criteria1).get(0);
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
		test.startTest();
		GplLocatorUpdateService.updatePhysician(profileToUpdate,null,emptyPdf,'TESTUSER');
		GplLocatorUpdateService.updatePhysician(profileToAdd,null,emptyPdf,'TESTUSER');
		GplDataModel.PhysicianProfile updatedProfile = manager.searchPhysicians(criteria1).get(0);
		System.assertEquals('UPDATED',updatedProfile.preferredFirstName);
		System.assertEquals(1,updatedProfile.locations.size());
		list<GplDataModel.PhysicianProfile> results = manager.searchPhysicians(criteria2);
		System.assertEquals(4,results.size());		
		test.stopTest();
		
	}	 
}