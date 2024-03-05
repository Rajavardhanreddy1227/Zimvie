@isTest
public class GplDatamanagerTest {
    private static Id CLINIC_RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_ClinicProfile' );
    static testmethod void testCreatePhysicianFromLead(){
        
        Id physicianLeadTypeId = RecordTypeHelper.getRecordTypeId('Lead','GPL_Physician_Lead');
        
        Lead lead = new Lead(
            RecordTypeId = physicianLeadTypeId,
            FirstName = 'First Name',
            LastName = 'Last Name',
            NPI__c = '7777777777',
            Facebook_URL__c = 'http://facebook.com',
            Twitter_handle__c = 'http://twitter.com',
            Youtube__c = 'http://youtube.com',
            Procedure_Product_Specialties__c = 'SternaLock 360',
            Specialty__c = 'Thoracic',
            Practice_1_Geolocation__Latitude__s = -0.8292784,
            Practice_1_Geolocation__Longitude__s = -90.98206679999998,
            Practice_Name__c = 'Test Practice Name',
            Practice_Address__c = 'TEST 406 S Main St',
            Practice_City_1__c = 'Puerto Villamil',
            Practice_State_1__c = 'EC',
            Practice_Zip_Code_1__c = 'EC012001',
            Practice_Country_1__c = 'EC',
            Practice_2_Geolocation__Latitude__s = -0.8292784,
            Practice_2_Geolocation__Longitude__s = -90.98206679999998,
            Practice_Name_2__c = 'Test Practice Name',
            Practice_Address_2__c = 'TEST 406 S Main St',
            Practice_City_2__c = 'Puerto Villamil',
            Practice_State_2__c = 'EC',
            Practice_Zip_Code_2__c = 'EC012001',
            Practice_Country_2__c = 'EC',
            Practice_3_Geolocation__Latitude__s = -0.8292784,
            Practice_3_Geolocation__Longitude__s = -90.98206679999998,
            Practice_Name_3__c = 'Test Practice Name',
            Practice_Address_3__c = 'TEST 406 S Main St',
            Practice_City_3__c = 'Puerto Villamil',
            Practice_State_3__c = 'EC',
            Practice_Zip_Code_3__c = 'EC012001',
            Practice_Country_3__c = 'EC'            
        );
        insert lead;
        
        test.startTest();
        GplDataManager manager = new GplDataManager();        
        String out = manager.createPhysicianFromLead(lead.Id);
        System.assert(out == 'Physician Profile created successfully');
        test.stopTest();
        
        
    }
    
    static testmethod void testCreateClinicFromLead() {
        Id practiceAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','HealthcareFacility');
        Id clinicLeadTypeId = RecordTypeHelper.getRecordTypeId('Lead','Clinic_Lead');
        Account practice = new Account(
            RecordTypeId = practiceAccountTypeId,
            Name = 'TEST Medical Practice ', 
            ShippingStreet = 'TEST 123 Maple St',
            ShippingCity = 'Puerto Villamil',
            ShippingState = 'EC',
            ShippingPostalCode = 'EC012001 ',
            ShippingCountry = 'EC'
        );
        insert practice;
        Lead lead = new Lead(
            RecordTypeId = clinicLeadTypeId,
            Account__c = practice.Id,
            LastName = 'Test Lead Name',
            Facebook_URL__c = 'http://facebook.com',
            Twitter_handle__c = 'http://twitter.com',
            Youtube__c = 'http://youtube.com',
            Procedure_Product_Specialties__c = 'Gel-One;Anterior Supine',
            Specialty__c = 'Knee',
            Practice_1_Geolocation__Latitude__s = -0.8292784,
            Practice_1_Geolocation__Longitude__s = -90.98206679999998,
            Practice_Name__c = 'Test Practice Name',
            Practice_Address__c = 'TEST 406 S Main St',
            Practice_City_1__c = 'Puerto Villamil',
            Practice_State_1__c = 'EC',
            Practice_Zip_Code_1__c = 'EC012001',
            Practice_Country_1__c = 'EC',
            Practice_2_Geolocation__Latitude__s = -0.8292784,
            Practice_2_Geolocation__Longitude__s = -90.98206679999998,
            Practice_Name_2__c = 'Test Practice Name',
            Practice_Address_2__c = 'TEST 406 S Main St',
            Practice_City_2__c = 'Puerto Villamil',
            Practice_State_2__c = 'EC',
            Practice_Zip_Code_2__c = 'EC012001',
            Practice_Country_2__c = 'EC',
            Practice_3_Geolocation__Latitude__s = -0.8292784,
            Practice_3_Geolocation__Longitude__s = -90.98206679999998,
            Practice_Name_3__c = 'Test Practice Name',
            Practice_Address_3__c = 'TEST 406 S Main St',
            Practice_City_3__c = 'Puerto Villamil',
            Practice_State_3__c = 'EC',
            Practice_Zip_Code_3__c = 'EC012001',
            Practice_Country_3__c = 'EC'            
        );
        insert lead;
        
        test.startTest();
        GplDataManager manager = new GplDataManager();        
        String out = manager.createClinicFromLead(lead.Id);
        System.assert(out == 'Clinic Profile created successfully');
        test.stopTest();
    }
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
        criteria1.specialty = 'Knee';
        criteria1.procedure = 'MIS';
        criteria1.medicalDevice = 'Kinectiv';
        criteria1.city = 'Puerto Villamil';
        criteria1.state = 'EC';
        criteria1.postalCode = 'EC012001';
        criteria1.country = 'EC';		
        criteria1.firstName = 'Test';
        criteria1.lastName = 'Doctor';
        criteria1.clinicName = 'Practice';
        
        
		GplDataModel.SearchCriteria criteria2 = new GplDataModel.SearchCriteria();
        GplDataModel.BoundingBox box = new GplDataModel.BoundingBox();
        box.east = -90.93714631272884;
        box.west = -91.02698728727113;
        box.north = -0.784363463881532;
        box.south = -0.874193336118468;
        criteria1.box = box;  //within 5 miles of the Galapagos Islands
        criteria2.specialty = 'Knee';
        criteria2.procedure = 'MIS';
        criteria2.medicalDevice = 'Kinectiv';
        criteria2.city = 'Puerto Villamil';
        criteria2.state = 'EC';
        criteria2.postalCode = 'EC012001';
        criteria2.country = 'EC';		
        criteria2.firstName = 'Test';
        criteria2.lastName = 'Doctor';
        criteria2.clinicName = 'Practice';
        
		test.startTest();
		GplDataManager manager = new GplDataManager();
		list<GplDataModel.PhysicianProfile> results1 = manager.searchPhysicians(criteria1);
		System.assertEquals(5,results1.size());
			
		list<GplDataModel.PhysicianProfile> results2 = manager.searchPhysicians(criteria2);
		System.assertEquals(5,results2.size());
		
		for (GplDataModel.PhysicianProfile p : results1){
			//System.assertEquals('Test',p.firstName);
			System.assertEquals(2, p.locations.size());	 
			for (GplDataModel.ProfileLocation l : p.locations){
				System.assertEquals(true,l.name.startsWith('TEST'));
			}
		}	
		
		test.stopTest();
	}
	//Code Added by Goldy on 05th June 2013 for Find a Dentist functionality
	static testmethod void testSearchDentists(){
		Id contactTypeId = RecordTypeHelper.getRecordTypeId('Contact','DN_Global_Contact_Record_Type');		
		Id DNCAAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','DN_ACCT_RECORD_TYPE');		
		Id dentistRTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_DentistProfile');
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
		
		for (integer i=0;i<5;i++){
			GPL_Profile__c profile = new GPL_Profile__c(
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
        criteria1.specialty = 'Knee';
        criteria1.procedure = 'MIS';
        criteria1.medicalDevice = 'Kinectiv';
        criteria1.city = 'Puerto Villamil';
        criteria1.state = 'EC';
        criteria1.postalCode = 'EC012001';
        criteria1.country = 'EC';		
        criteria1.firstName = 'Test';
        criteria1.lastName = 'Doctor';
        criteria1.clinicName = 'Practice';
        
        
		GplDataModel.SearchCriteria criteria2 = new GplDataModel.SearchCriteria();
        GplDataModel.BoundingBox box = new GplDataModel.BoundingBox();
        box.east = -90.93714631272884;
        box.west = -91.02698728727113;
        box.north = -0.784363463881532;
        box.south = -0.874193336118468;
        criteria1.box = box;  //within 5 miles of the Galapagos Islands
        criteria2.specialty = 'Knee';
        criteria2.procedure = 'MIS';
        criteria2.medicalDevice = 'Kinectiv';
        criteria2.city = 'Puerto Villamil';
        criteria2.state = 'EC';
        criteria2.postalCode = 'EC012001';
        criteria2.country = 'EC';		
        criteria2.firstName = 'Test';
        criteria2.lastName = 'Doctor';
        criteria2.clinicName = 'Practice';
        
		test.startTest();
		GplDataManager manager = new GplDataManager();
		list<GplDataModel.DentistProfile> results1 = manager.searchDentists(criteria1);
		System.assertEquals(5,results1.size());
			
		list<GplDataModel.DentistProfile> results2 = manager.searchDentists(criteria2);
		System.assertEquals(5,results2.size());
		
		for (GplDataModel.DentistProfile p : results1){
			//System.assertEquals('Test',p.firstName);
			System.assertEquals(2, p.locations.size());	 
			for (GplDataModel.ProfileLocation l : p.locations){
				System.assertEquals(true,l.name.startsWith('TEST'));
			}
		}	
		
		test.stopTest();
	}
	
	
	static testmethod void testSearchClinics(){
		//Id practiceAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Medical Practice');
		Id practiceAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Practice');
		list<GPL_Profile__c> profiles = new list<GPL_Profile__c>();
		list<Account> practiceAccounts = new list<Account>();
		for (integer i=0;i<5;i++){
			Account practice = new Account(
				RecordTypeId = practiceAccountTypeId,
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
		for (integer i=0;i<5;i++){
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
		for (integer i=0;i<5;i++){
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
				Name__c = 'TEST Location 2 for ' + profile.Name,
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
        criteria1.specialty = 'Knee';
        criteria1.procedure = 'MIS';
        criteria1.medicalDevice = 'Kinectiv';
        criteria1.city = 'Puerto Villamil';
        criteria1.state = 'EC';
        criteria1.postalCode = 'EC012001';
        criteria1.country = 'EC';		
        //criteria1.clinicName = 'Practice';
        
        
		GplDataModel.SearchCriteria criteria2 = new GplDataModel.SearchCriteria();
        GplDataModel.BoundingBox box = new GplDataModel.BoundingBox();
        box.east = -90.93714631272884;
        box.west = -91.02698728727113;
        box.north = -0.784363463881532;
        box.south = -0.874193336118468;
        criteria1.box = box;  //within 5 miles of the Galapagos Islands
        criteria2.specialty = 'Knee';
        criteria2.procedure = 'MIS';
        criteria2.medicalDevice = 'Kinectiv';
        criteria2.city = 'Puerto Villamil';
        criteria2.state = 'EC';
        criteria2.postalCode = 'EC012001';
        criteria2.country = 'EC';		
        //criteria2.clinicName = 'Practice';
        
		test.startTest();
		GplDataManager manager = new GplDataManager();
		list<GplDataModel.ClinicProfile> results1 = manager.searchClinics(criteria1);
		System.assertEquals(5,results1.size());
			
		list<GplDataModel.ClinicProfile> results2 = manager.searchClinics(criteria2);
		System.assertEquals(5,results2.size());
		
		for (GplDataModel.ClinicProfile p : results1){
			//System.assertEquals('Test',p.firstName);
			System.assertEquals(2, p.locations.size());	 
			for (GplDataModel.ProfileLocation l : p.locations){
				System.assertEquals(true,l.name.startsWith('TEST'));
			}
		}	
		
		test.stopTest();
	}
	
	
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
		GplDataManager manager = new GplDataManager();
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
		manager.updatePhysician(profileToUpdate,null,emptyPdf,'TESTUSER');
		manager.updatePhysician(profileToAdd,null,emptyPdf,'TESTUSER');
		GplDataModel.PhysicianProfile updatedProfile = manager.searchPhysicians(criteria1).get(0);
		System.assertEquals('UPDATED',updatedProfile.preferredFirstName);
		System.assertEquals(1,updatedProfile.locations.size());
		list<GplDataModel.PhysicianProfile> results = manager.searchPhysicians(criteria2);
		System.assertEquals(4,results.size());		
		test.stopTest();
		
	}	
}