public with sharing class GplDataManager {
    //private static Id CLINIC_RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL Clinic Profile' );
    private static Id CLINIC_RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_ClinicProfile' );
    //private static Id PHYSICIAN_RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL Physician Profile' );
    private static Id PHYSICIAN_RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_PhysicianProfile');
    private static Id DENTIST_RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_DentistProfile');
    private static Id PERSON_ACCOUNT_RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('Account','Physician');
    
    public list<GplDataModel.PhysicianProfile> searchPhysicians(GplDataModel.SearchCriteria criteria){
        list<GPL_Location__c> matches = Database.query(buildQuery(criteria, PHYSICIAN_RECORD_TYPE_ID));
        map<Id,GplDataModel.PhysicianProfile> results = new map<Id,GplDataModel.PhysicianProfile>();
        set<String> ids = new set<String>();
        for (GPL_Location__c location : matches){
            GplDataModel.PhysicianProfile p = results.get(location.GPL_Profile__c);
            if (p == null){
                p = createPhysician(location.GPL_Profile__r); 
                ids.add(location.GPL_Profile__r.MasterId__c);
            }
            ///p.locations.add(createLocation(location));
            results.put(location.GPL_Profile__c, p);
        }
        //add all the locations;
        list<GPL_Location__c> locations = findLocations(results.keySet());
        for (GPL_Location__c location : locations){
            GplDataModel.PhysicianProfile p = results.get(location.GPL_Profile__c);
            if (location.Location_Type__c == 'Hospital'){
                p.hospitals.add(createHospital(location));
            } else {
                p.locations.add(createLocation(location));
            }
            results.put(location.GPL_Profile__c, p);
        }
        //attach hospital relationships
        /*
        map<Id,list<Account>> hospitalLinks = findHospitals(ids);
        for (GplDataModel.PhysicianProfile p : results.values()){
            list<Account> hospitals = hospitalLinks.get(p.masterId);
            if (hospitals != null){
                for (Account h : hospitals){
                    p.hospitals.add(createHospital(h));
                }
                results.put(p.Id, p);
            }
        }
        */
        return results.values(); 
    }
    
    //Code added by Goldy on 30-May-2013 for Find A Dentist Functionality
    public list<GplDataModel.DentistProfile> searchDentists(GplDataModel.SearchCriteria criteria){
        list<GPL_Location__c> matches = Database.query(buildQuery(criteria, DENTIST_RECORD_TYPE_ID));
        map<Id,GplDataModel.DentistProfile> results = new map<Id,GplDataModel.DentistProfile>();
        set<String> ids = new set<String>();
        for (GPL_Location__c location : matches){
            GplDataModel.DentistProfile p = results.get(location.GPL_Profile__c);
            if (p == null){
                p = createDentist(location.GPL_Profile__r); 
                ids.add(location.GPL_Profile__r.MasterId__c);
            }
            ///p.locations.add(createLocation(location));
            results.put(location.GPL_Profile__c, p);
        }
        //add all the locations;
        list<GPL_Location__c> locations = findLocations(results.keySet());
        for (GPL_Location__c location : locations){
            GplDataModel.DentistProfile p = results.get(location.GPL_Profile__c);
            if (location.Location_Type__c == 'Hospital'){
                p.hospitals.add(createHospital(location));
            } else {
                p.locations.add(createLocation(location));
            }
            results.put(location.GPL_Profile__c, p);
        }   
        
        return results.values(); 
    }
    //Code Addition Ends Here
    
    public list<GplDataModel.ClinicProfile> searchClinics(GplDataModel.SearchCriteria criteria){
        list<GPL_Location__c> matches = Database.query(buildQuery(criteria, CLINIC_RECORD_TYPE_ID));
        map<Id,GplDataModel.ClinicProfile> results = new map<Id,GplDataModel.ClinicProfile>();
        for (GPL_Location__c location : matches){
            GplDataModel.ClinicProfile p = results.get(location.GPL_Profile__c);
            if (p == null){
                p = createClinic(location.GPL_Profile__r);
            }
            results.put(location.GPL_Profile__c, p);
        }
        //add all the locations;
        list<GPL_Location__c> locations = findLocations(results.keySet());
        for (GPL_Location__c location : locations){
            GplDataModel.ClinicProfile p = results.get(location.GPL_Profile__c);
            p.locations.add(createLocation(location));
            results.put(location.GPL_Profile__c, p);
        }
        return results.values(); 
    }
    
    public GplDataModel.Photo retrievePhoto(String id){
        GplDataModel.Photo photo = null;
        //Attachment a = [select Body, ContentType, BodyLength from Attachment where Id = :id];
        List<Attachment> a = [select Body, ContentType, BodyLength from Attachment where Id = :id];
        if (a != null && !a.isEmpty()){
            photo = new GplDataModel.Photo();
            photo.body = a[0].Body;
            photo.bodyLength = a[0].BodyLength;
            photo.contentType = a[0].ContentType;
        }
        return photo;
    }
    
    public void updatePhysician(GplDataModel.PhysicianProfile physician, GplDataModel.Photo photo, GplDataModel.Photo pdf, String username) {
        GPL_Profile__c p = null;
        Account parent = null;
        list<GPL_Location__c> gpllocs = new list<GPL_Location__c>();
        if (physician.id != null) {
            p = [SELECT Id, Name, Devices__c, Facebook__c, Fellowship__c, FirstName__c,
                                    Languages__c, LastName__c, LinkedIn__c, MedicalSchool__c,
                                    Procedures__c, Residency__c, Salutation__c, Specialties__c,
                                    Twitter__c, Username__c, YouTube__c, Groups__c, Honors__c, Publications__c, 
                                    PhotoId__c
                                FROM GPL_Profile__c
                                WHERE Id = :physician.id];
            gpllocs = [SELECT Id, Name__c, City__c, Country__c, Fax__c, Phone__c,  Location_Type__c,
                                                    PostalCode__c, Services__c, State__c, Street__c, Website__c,
                                                    GPL_Profile__c
                                                FROM GPL_Location__c
                                                WHERE GPL_Profile__c = :physician.id];
        } else {
            p = new GPL_Profile__c();
            parent = [SELECT Id, Physician_Locator_Status__pc from Account Where Id = :physician.masterId];
            p.Account__c = physician.masterId;
            p.RecordTypeId = PHYSICIAN_RECORD_TYPE_ID;
        }
        map<Id, GPL_Location__c> locations = new map<Id, GPL_Location__c>();
        map<Id, GPL_Location__c> hospitals = new map<Id, GPL_Location__c>();
        for (GPL_Location__c loc : gpllocs){
            if (loc.Location_Type__c == 'Hospital') {
                hospitals.put(loc.Id, loc);
            } else {
                locations.put(loc.Id, loc);
            }
        }
        list<GPL_Profile__c> updateProfs = new list<GPL_Profile__c>();
        //p.FirstName__c = physician.firstName;
        //p.LastName__c = physician.lastName;
        p.PreferredName__c = physician.preferredFirstName;
        p.Facebook__c = physician.facebook;
        p.Twitter__c = physician.twitter;
        p.LinkedIn__c = physician.linkedIn;
        p.YouTube__c = physician.youtube;
        p.Specialties__c = physician.specialties;
        p.Devices__c = physician.devices;
        p.Procedures__c = physician.procedures;
        p.MedicalSchool__c = physician.medicalSchool;
        p.Residency__c = physician.residency;
        p.Fellowship__c = physician.fellowship;
        p.Groups__c = physician.groups;
        p.Honors__c = physician.honors;
        p.Languages__c = physician.languages;
        updateProfs.add(p);
        
        list<GPL_Location__c> upsertLocs = new list<GPL_Location__c>();
        list<GPL_Location__c> deleteLocs = new list<GPL_Location__c>();
        list<Attachment> attachments = new list<Attachment>();
        for (GplDataModel.ProfileLocation pl : physician.locations){
            GPL_Location__c l = locations.get(pl.id);
            if (l == null){
                l = new GPL_Location__c();
                l.GPL_Profile__c = p.Id;
            }
            l.Name__c = pl.name;
            l.City__c = pl.city;
            l.Country__c = pl.country;
            l.Fax__c = pl.fax;
            l.Phone__c = pl.phone;
            l.PostalCode__c = pl.postalCode;
            l.Services__c = pl.services;
            l.State__c = pl.state;
            l.Street__c = pl.street;
            l.Website__c = pl.website;
            l.Latitude__c = pl.latitude;
            l.Longitude__c = pl.longitude;
            l.Geolocation__Latitude__s = pl.latitude;
            l.Geolocation__Longitude__s = pl.longitude;
            l.Location_Type__c = 'Practice';
            upsertLocs.add(l);
        }
        for (GPL_Location__c existing : locations.values()){
            boolean exists = false;
            for (GplDataModel.ProfileLocation updated : physician.locations){
                if (existing.Id == updated.id){
                    exists = true;
                    break;
                }
            }
            if (!exists){
                deleteLocs.add(existing);
            }
        }
        if (physician.hospitals != null) {
            for (GplDataModel.Hospital hl : physician.hospitals){
                GPL_Location__c l = hospitals.get(hl.id);
                if (l == null){
                    l = new GPL_Location__c();
                    l.GPL_Profile__c = p.Id;
                }
                l.Name__c = hl.name;
                l.City__c = hl.city;
                l.Country__c = hl.country;
                l.PostalCode__c = hl.postalCode;
                l.State__c = hl.state;
                l.Street__c = hl.street;
                l.Location_Type__c = 'Hospital';
                upsertLocs.add(l);
            }
        }
        for (GPL_Location__c existing : hospitals.values()){
            boolean exists = false;
            if (physician.hospitals != null) {
                for (GplDataModel.Hospital updated : physician.hospitals){
                    if (existing.Id == updated.id){
                        exists = true;
                        break;
                    }
                }
            }
            if (!exists){
                deleteLocs.add(existing);
            }
        }
        
        
        
        
        if (photo != null){
            Attachment a = new Attachment();
            a.Body = photo.Body;
            a.ContentType = photo.contentType;
            a.Name = physician.firstName + '-' + physician.lastName + '.png';
            attachments.add(a); 
        }
        if (pdf != null){
            Attachment a = new Attachment();
            a.Body = pdf.Body;
            a.ContentType = pdf.contentType;
            a.Name = 'Web Update - ' + username + '-' + datetime.now().format('yyyy-MM-dd') + '.pdf';
            attachments.add(a);
        }
        savepoint sp = Database.setSavePoint();
        try {
            upsert(p);
            
            for (GPL_Location__c loc : upsertLocs) {
                if (loc.GPL_Profile__c == null) {
                    loc.GPL_Profile__c = p.Id;
                }
            }
            upsert(upsertLocs);
            if (deleteLocs.size() > 0){
                delete(deleteLocs);
            }       
            if (attachments.size() > 0) {
                for (Attachment a : attachments) {
                    a.ParentId = p.Id;
                }
                insert(attachments);
                if (photo != null) {
                    p.Picture_Id__c = attachments.get(0).Id;
                    update(p);
                }
            }
            if (physician.id == null) {
                parent.Physician_Locator_Status__pc = 'Locator Displayed';
                update(parent);
                p.Inactive__c = false;
                update(p);
            }
            
         
        } catch(exception e){
            database.rollback(sp);
            throw e;
        }
    }   
    
    public String createPhysicianFromLead(Id leadId) {
        Lead lead = [SELECT FirstName, LastName, Medical_School__c, Fellowship__c, Residency__c, Email, Facebook_URL__c, 
                     Twitter_handle__c, Youtube__c, Website, Specialty__c, Procedure_Product_Specialties__c, NPI__c,
                     Practice_1_Geolocation__Latitude__s, Practice_1_Geolocation__Longitude__s, Practice_Name__c, Practice_Address__c,
                     Practice_City_1__c, Practice_State_1__c, Practice_Country_1__c, Practice_Phone_1__c, Practice_Fax_1__c, Practice_Zip_Code_1__c,
                     Practice_2_Geolocation__Latitude__s, Practice_2_Geolocation__Longitude__s, Practice_Name_2__c, Practice_Address_2__c,
                     Practice_City_2__c, Practice_State_2__c, Practice_Country_2__c, Practice_Phone_2__c, Practice_Fax_2__c, Practice_Zip_Code_2__c,
                     Practice_3_Geolocation__Latitude__s, Practice_3_Geolocation__Longitude__s, Practice_Name_3__c, Practice_Address_3__c,
                     Practice_City_3__c, Practice_State_3__c, Practice_Country_3__c, Practice_Phone_3__c, Practice_Fax_3__c, Practice_Zip_Code_3__c,
                     Status from Lead where Id = :leadId];
        if (lead == null) {
            System.debug('>>>>1'); 
            return 'Conversion Failed: Lead lookup failed.';
        }
        String npi = lead.NPI__c;
        if (npi == null || String.isEmpty(npi)) {
            return 'Conversion Failed: The lead must include a valid NPI.';
        }
        Account account = null;
        List<Account> accounts = [SELECT Id, GPL_Profile__c, Physicians_Locator__c, Physician_Locator_Status__pc from Account where RecordTypeId = :PERSON_ACCOUNT_RECORD_TYPE_ID and NPI__c = :npi];
        if (accounts != null && !accounts.isEmpty()) {
            account = accounts.get(0);
        } 
        if (account == null) {
            System.debug('>>>>2 - no account found.  create new account');
            account = new Account(
                RecordTypeId = PERSON_ACCOUNT_RECORD_TYPE_ID,
                FirstName = lead.FirstName,
                LastName = lead.LastName,
                PersonMailingStreet = lead.Practice_Address__c,
                PersonMailingCity = lead.Practice_City_1__c,
                PersonMailingState = lead.Practice_State_1__c,
                PersonMailingPostalCode = lead.Practice_Zip_Code_1__c,
                PersonMailingCountry = 'US',
                Specialty_integration__c = 'Thoracic',
                NPI__c = npi,
                Physicians_Locator__c = true
            );   
        }
        if (account.GPL_Profile__c != null) {
            System.debug('>>>>3');
            return 'Conversion Failed: A profile already exists for the associated account.';
        }
        GPL_Profile__c profile = new GPL_Profile__c();
        List<GPL_Location__c> locations = new List<GPL_Location__c>();
        profile.RecordTypeId = PHYSICIAN_RECORD_TYPE_ID;
        profile.PreferredName__c = lead.FirstName;
        profile.Facebook__c = lead.Facebook_URL__c;
        profile.Twitter__c = lead.Twitter_handle__c;
        profile.YouTube__c = lead.Youtube__c;
        profile.Specialties__c = lead.Specialty__c;
        profile.MedicalSchool__c = lead.Medical_School__c;
        profile.Fellowship__c = lead.Fellowship__c;
        profile.Residency__c = lead.Residency__c;
        profile.Devices__c = '';
        profile.Procedures__c = '';
        if (lead.Procedure_Product_Specialties__c != null) {
            String[] values = lead.Procedure_Product_Specialties__c.split(';');    
            for (String s : values) {
                if (s.equalsIgnoreCase('Chondrofix') || s.equalsIgnoreCase('Early Intervention') || s.equalsIgnoreCase('Gel-One') || s.equalsIgnoreCase('Patient Specific Instruments')
                        || s.equalsIgnoreCase('Persona Knee System') || s.equalsIgnoreCase('PFJ') || s.equalsIgnoreCase('Trabecular Metal Total Ankle') || s.equalsIgnoreCase('Vanguard')
                        || s.equalsIgnoreCase('VitaminE') || s.equalsIgnoreCase('Vivacity-E-Hip Construct') || s.equalsIgnoreCase('XP') || s.equalsIgnoreCase('Oxford Partial Knee')
                        || s.equalsIgnoreCase('SternaLock Blu') || s.equalsIgnoreCase('SternaLock 360') || s.equalsIgnoreCase('RibFix Blue') || s.equalsIgnoreCase('Pectus Bar')
                        || s.equalsIgnoreCase('Adkins Strut')) {
                    profile.Devices__c += s + ';';
                } else if (s.equalsIgnoreCase('Anterior Supine') || s.equalsIgnoreCase('MIS') || s.equalsIgnoreCase('Subchondroplasty')) {
                    profile.Procedures__c += s + ';';
                }
            }
        }
        if (lead.Practice_1_Geolocation__Latitude__s != null && lead.Practice_1_Geolocation__Longitude__s != null ) {
            GPL_Location__c loc = new GPL_Location__c();
            loc.Location_Type__c = 'Practice';
            loc.Name__c = lead.Practice_Name__c;
            loc.Street__c = lead.Practice_Address__c;
            loc.City__c = lead.Practice_City_1__c;
            loc.State__c = lead.Practice_State_1__c;
            loc.PostalCode__c = lead.Practice_Zip_Code_1__c;
            loc.Country__c = lead.Practice_Country_1__c;
            if (loc.Country__c == null) {
                loc.Country__c = 'US';
            }
            loc.Phone__c = lead.Practice_Phone_1__c;
            loc.Fax__c = lead.Practice_Fax_1__c;
            loc.Geolocation__Latitude__s = lead.Practice_1_Geolocation__Latitude__s;
            loc.Geolocation__Longitude__s = lead.Practice_1_Geolocation__Longitude__s;
            locations.add(loc);
        }
        if (lead.Practice_2_Geolocation__Latitude__s != null && lead.Practice_2_Geolocation__Longitude__s != null ) {
            GPL_Location__c loc = new GPL_Location__c();
            loc.Location_Type__c = 'Practice';
            loc.Name__c = lead.Practice_Name_2__c;
            loc.Street__c = lead.Practice_Address_2__c;
            loc.City__c = lead.Practice_City_2__c;
            loc.State__c = lead.Practice_State_2__c;
            loc.PostalCode__c = lead.Practice_Zip_Code_2__c;
            loc.Country__c = lead.Practice_Country_2__c;
            if (loc.Country__c == null) {
                loc.Country__c = 'US';
            }
            loc.Phone__c = lead.Practice_Phone_2__c;
            loc.Fax__c = lead.Practice_Fax_2__c;
            loc.Geolocation__Latitude__s = lead.Practice_2_Geolocation__Latitude__s;
            loc.Geolocation__Longitude__s = lead.Practice_2_Geolocation__Longitude__s;
            locations.add(loc);
        }
        if (lead.Practice_3_Geolocation__Latitude__s != null && lead.Practice_3_Geolocation__Longitude__s != null ) {
            GPL_Location__c loc = new GPL_Location__c();
            loc.Location_Type__c = 'Practice';
            loc.Name__c = lead.Practice_Name_3__c;
            loc.Street__c = lead.Practice_Address_3__c;
            loc.City__c = lead.Practice_City_3__c;
            loc.State__c = lead.Practice_State_3__c;
            loc.PostalCode__c = lead.Practice_Zip_Code_3__c;
            loc.Country__c = 'US';
            if (loc.Country__c == null) {
                loc.Country__c = 'US';
            }
            loc.Phone__c = lead.Practice_Phone_3__c;
            loc.Fax__c = lead.Practice_Fax_3__c;
            loc.Geolocation__Latitude__s = lead.Practice_3_Geolocation__Latitude__s;
            loc.Geolocation__Longitude__s = lead.Practice_3_Geolocation__Longitude__s;
            locations.add(loc);
        }
        
        savepoint sp = Database.setSavePoint();
        try {
            upsert(account);
            profile.Account__c = account.Id;
            upsert(profile);
            
            for (GPL_Location__c loc : locations) {
                if (loc.GPL_Profile__c == null) {
                    loc.GPL_Profile__c = profile.Id;
                }
            }
            upsert(locations);
                      
            account.Physician_Locator_Status__pc = 'Locator Displayed';
            account.GPL_Profile__c = profile.Id;
            account.Physicians_Locator__c = true;
            update(account);
            profile.Inactive__c = false;
            update(profile);
            lead.Status = 'Closed';
            update(lead);
            
        } catch(exception e){
            database.rollback(sp);
            System.debug('>>>>' + e.getMessage());
            return 'Conversion Failed: ' + e.getMessage();
            
        }        
        return 'Physician Profile created successfully';
    }
    
    public String createClinicFromLead(Id leadId) {
        Lead lead = [SELECT Name, Account__c, Account__r.GPL_Profile__c, Account__r.Physician_Locator_Status__pc, Email, Facebook_URL__c, 
                     Twitter_handle__c, Youtube__c, Specialty__c, Procedure_Product_Specialties__c,
                     Practice_1_Geolocation__Latitude__s, Practice_1_Geolocation__Longitude__s, Practice_Name__c, Practice_Address__c,
                     Practice_City_1__c, Practice_State_1__c, Practice_Country_1__c, Practice_Phone_1__c, Practice_Fax_1__c, Practice_Zip_Code_1__c,
                     Practice_2_Geolocation__Latitude__s, Practice_2_Geolocation__Longitude__s, Practice_Name_2__c, Practice_Address_2__c,
                     Practice_City_2__c, Practice_State_2__c, Practice_Country_2__c, Practice_Phone_2__c, Practice_Fax_2__c, Practice_Zip_Code_2__c,
                     Practice_3_Geolocation__Latitude__s, Practice_3_Geolocation__Longitude__s, Practice_Name_3__c, Practice_Address_3__c,
                     Practice_City_3__c, Practice_State_3__c, Practice_Country_3__c, Practice_Phone_3__c, Practice_Fax_3__c, Practice_Zip_Code_3__c,
                     Status from Lead where Id = :leadId];
        if (lead == null) {
            System.debug('>>>>1');
            return 'Conversion Failed: Lead lookup failed.';
        }
        Account account = lead.Account__r;
        if (account == null) {
            System.debug('>>>>2');
            return 'Conversion Failed: Account lookup failed.';
        }
        if (account.GPL_Profile__c != null) {
            System.debug('>>>>3');
            return 'Conversion Failed: A profile already exists for the associated account.';
        }
        GPL_Profile__c profile = new GPL_Profile__c();
        List<GPL_Location__c> locations = new List<GPL_Location__c>();
        profile.RecordTypeId = CLINIC_RECORD_TYPE_ID;
        profile.Account__c = lead.Account__c;        
        profile.PreferredName__c = lead.Name;
        profile.Facebook__c = lead.Facebook_URL__c;
        profile.Twitter__c = lead.Twitter_handle__c;
        profile.YouTube__c = lead.Youtube__c;
        profile.Specialties__c = lead.Specialty__c;
        String[] values = lead.Procedure_Product_Specialties__c.split(';');
        profile.Devices__c = '';
        profile.Procedures__c = '';
        for (String s : values) {
            if (s.equalsIgnoreCase('Chondrofix') || s.equalsIgnoreCase('Early Intervention') || s.equalsIgnoreCase('Gel-One') || s.equalsIgnoreCase('Patient Specific Instruments')
                    || s.equalsIgnoreCase('Persona Knee System') || s.equalsIgnoreCase('PFJ') || s.equalsIgnoreCase('Trabecular Metal Total Ankle') || s.equalsIgnoreCase('Vanguard')
                    || s.equalsIgnoreCase('VitaminE') || s.equalsIgnoreCase('Vivacity-E-Hip Construct') || s.equalsIgnoreCase('XP') || s.equalsIgnoreCase('Oxford Partial Knee')) {
                profile.Devices__c += s + ';';
            } else if (s.equalsIgnoreCase('Anterior Supine') || s.equalsIgnoreCase('MIS') || s.equalsIgnoreCase('Subchondroplasty')) {
                profile.Procedures__c += s + ';';
            }
        }
        if (lead.Practice_1_Geolocation__Latitude__s != null && lead.Practice_1_Geolocation__Longitude__s != null ) {
            GPL_Location__c loc = new GPL_Location__c();
            loc.Name__c = lead.Practice_Name__c;
            loc.Street__c = lead.Practice_Address__c;
            loc.City__c = lead.Practice_City_1__c;
            loc.State__c = lead.Practice_State_1__c;
            loc.PostalCode__c = lead.Practice_Zip_Code_1__c;
            loc.Country__c = lead.Practice_Country_1__c;
            if (loc.Country__c == null) {
                loc.Country__c = 'US';
            }
            loc.Phone__c = lead.Practice_Phone_1__c;
            loc.Fax__c = lead.Practice_Fax_1__c;
            loc.Geolocation__Latitude__s = lead.Practice_1_Geolocation__Latitude__s;
            loc.Geolocation__Longitude__s = lead.Practice_1_Geolocation__Longitude__s;
            locations.add(loc);
        }
        if (lead.Practice_2_Geolocation__Latitude__s != null && lead.Practice_2_Geolocation__Longitude__s != null ) {
            GPL_Location__c loc = new GPL_Location__c();
            loc.Name__c = lead.Practice_Name_2__c;
            loc.Street__c = lead.Practice_Address_2__c;
            loc.City__c = lead.Practice_City_2__c;
            loc.State__c = lead.Practice_State_2__c;
            loc.PostalCode__c = lead.Practice_Zip_Code_2__c;
            loc.Country__c = lead.Practice_Country_2__c;
            if (loc.Country__c == null) {
                loc.Country__c = 'US';
            }
            loc.Phone__c = lead.Practice_Phone_2__c;
            loc.Fax__c = lead.Practice_Fax_2__c;
            loc.Geolocation__Latitude__s = lead.Practice_2_Geolocation__Latitude__s;
            loc.Geolocation__Longitude__s = lead.Practice_2_Geolocation__Longitude__s;
            locations.add(loc);
        }
        if (lead.Practice_3_Geolocation__Latitude__s != null && lead.Practice_3_Geolocation__Longitude__s != null ) {
            GPL_Location__c loc = new GPL_Location__c();
            loc.Name__c = lead.Practice_Name_3__c;
            loc.Street__c = lead.Practice_Address_3__c;
            loc.City__c = lead.Practice_City_3__c;
            loc.State__c = lead.Practice_State_3__c;
            loc.PostalCode__c = lead.Practice_Zip_Code_3__c;
            loc.Country__c = lead.Practice_Country_3__c;
            if (loc.Country__c == null) {
                loc.Country__c = 'US';
            }
            loc.Phone__c = lead.Practice_Phone_3__c;
            loc.Fax__c = lead.Practice_Fax_3__c;
            loc.Geolocation__Latitude__s = lead.Practice_3_Geolocation__Latitude__s;
            loc.Geolocation__Longitude__s = lead.Practice_3_Geolocation__Longitude__s;
            locations.add(loc);
        }
        
        savepoint sp = Database.setSavePoint();
        try {
            upsert(profile);
            
            for (GPL_Location__c loc : locations) {
                if (loc.GPL_Profile__c == null) {
                    loc.GPL_Profile__c = profile.Id;
                }
            }
            upsert(locations);
                      
            //account.Physician_Locator_Status__pc = 'Locator Displayed';
            account.GPL_Profile__c = profile.Id;
            update(account);
            profile.Inactive__c = false;
            update(profile);
            lead.Status = 'Closed';
            update(lead);
            
        } catch(exception e){
            database.rollback(sp);
            System.debug('>>>>' + e.getMessage());
            return 'Conversion Failed: ' + e.getMessage();
            
        }        
        return 'Clinic Profile created successfully';
    }
    /*
    public void updateClinic(GplDataModel.ClinicProfile clinic, GplDataModel.Photo photo){
        GPL_Profile__c p = [SELECT Id, Name, Devices__c, Facebook__c, FirstName__c,
                                Languages__c, LastName__c, LinkedIn__c,
                                Procedures__c, Specialties__c,
                                Twitter__c, Username__c, YouTube__c, PhotoId__c
                            FROM GPL_Profile__c
                            WHERE Id = :clinic.id];
        GPL_Location__c[] gpllocs = [SELECT Id, Name__c, City__c, Country__c, Fax__c, Phone__c, 
                                                PostalCode__c, Services__c, State__c, Street__c, Website__c
                                            FROM GPL_Location__c
                                            WHERE GPL_Profile__c = :clinic.id];
        map<Id, GPL_Location__c> locations = new map<Id, GPL_Location__c>();
        for (GPL_Location__c loc : gpllocs){
            locations.put(loc.Id, loc);
        }
        list<GPL_Profile__c> updateProfs = new list<GPL_Profile__c>();
        p.Facebook__c = clinic.facebook;
        p.Twitter__c = clinic.twitter;
        p.LinkedIn__c = clinic.linkedIn;
        p.YouTube__c = clinic.youtube;
        p.Specialties__c = clinic.specialties;
        p.Devices__c = clinic.devices;
        p.Procedures__c = clinic.procedures;
        p.Languages__c = clinic.languages; 
        updateProfs.add(p);
        
        list<GPL_Location__c> upsertLocs = new list<GPL_Location__c>();
        list<GPL_Location__c> deleteLocs = new list<GPL_Location__c>();
        for (GplDataModel.ProfileLocation pl : clinic.locations){
            GPL_Location__c l = locations.get(pl.id);
            if (l == null){
                l = new GPL_Location__c();
                l.GPL_Profile__c = p.Id;
            }
            l.Name__c = pl.name;
            l.City__c = pl.city;
            l.Country__c = pl.country;
            l.Fax__c = pl.fax;
            l.Phone__c = pl.phone;
            l.PostalCode__c = pl.postalCode;
            l.Services__c = pl.services;
            l.State__c = pl.state;
            l.Street__c = pl.street;
            l.Website__c = pl.website;
            upsertLocs.add(l);
        }
        for (GPL_Location__c existing : locations.values()){
            boolean exists = false;
            for (GplDataModel.ProfileLocation updated : clinic.locations){
                if (existing.Id == updated.id){
                    exists = true;
                    break;
                }
            }
            if (!exists){
                deleteLocs.add(existing);
            }
        }
        if (photo != null){
            Attachment a = new Attachment();
            a.Body = photo.Body;
            a.ContentType = photo.contentType;
            a.Name = 'Profile Photo';
            a.ParentId = p.Id;
            insert(a);
            //p.PhotoId__c = a.Id;          
        }
        update(p);
        upsert(upsertLocs);
        if (deleteLocs.size()>0){
            delete(deleteLocs);
        }
        
    }   
    */  
    private String buildQuery(GplDataModel.SearchCriteria criteria, Id recordType){
        String query =  'SELECT Id, Name__c,  City__c, Country__c, Fax__c, Geolocation__Latitude__s, Geolocation__Longitude__s, Phone__c, ' + 
                        'PostalCode__c, Services__c, State__c, Street__c, Website__c, Location_Type__c, GPL_Profile__c, ' + 
                        'GPL_Profile__r.Devices__c, GPL_Profile__r.Facebook__c, GPL_Profile__r.Name, ' +
                        'GPL_Profile__r.Fellowship__c, GPL_Profile__r.FirstName__c, ' +
                        'GPL_Profile__r.Languages__c, GPL_Profile__r.LastName__c, ' + 
                        'GPL_Profile__r.LinkedIn__c, GPL_Profile__r.MedicalSchool__c, ' +
                        'GPL_Profile__r.Procedures__c, ' + // GPL_Profile__r.JobTitle__c, ' +
                        'GPL_Profile__r.Residency__c, GPL_Profile__r.Salutation__c, ' +
                        'GPL_Profile__r.Specialties__c, GPL_Profile__r.Twitter__c, ' +
                        'GPL_Profile__r.Username__c, GPL_Profile__r.YouTube__c, ' +
                        'GPL_Profile__r.MasterId__c, GPL_Profile__r.Groups__c, GPL_Profile__r.ParentId__c, ' +
                        'GPL_Profile__r.Honors__c, GPL_Profile__r.Publications__c, ' +
                        'GPL_Profile__r.PhotoId__c, GPL_Profile__r.Name__c, GPL_Profile__r.PreferredFirstName__c, ' +
                        'GPL_Profile__r.Specialty_Type__c, '+
                        'GPL_Profile__r.Contact_Title__c '+
                        'FROM GPL_Location__c ' +                           
                        'WHERE GPL_Profile__r.RecordTypeId = \'' + recordType + '\''; 
                        
        
        if ((criteria.physicianId == null || criteria.physicianId.trim().length() == 0) //for queries by id, include inactive and thosse without practices
            && (criteria.clinicId == null || criteria.clinicId.trim().length() == 0)){
            query += ' AND GPL_Profile__r.Inactive__c = false ';                
            query += ' AND Location_Type__c != \'Hospital\'';
        }
        if (criteria.box == null){ 
            if (criteria.postalCode != null && criteria.postalCode.trim().length() > 0){
                query += ' and PostalCode__c = \'' + String.escapeSingleQuotes(criteria.postalCode) + '\'';
            }   
            if (criteria.city != null && criteria.city.trim().length() > 0) {
                query += ' and City__c = \'' + String.escapeSingleQuotes(criteria.city) + '\'';
            }                  
            if (criteria.state != null && criteria.state.trim().length() > 0) {
                query += ' and State__c = \'' + String.escapeSingleQuotes(criteria.state) + '\'';
            }
        } else {
            query += ' and Geolocation__Latitude__s >= ' + criteria.box.south;
            query += ' and Geolocation__Latitude__s <= ' + criteria.box.north;
            query += ' and Geolocation__Longitude__s >= ' + criteria.box.west;
            query += ' and Geolocation__Longitude__s <= ' + criteria.box.east;
        }
        if (criteria.country != null && criteria.country.trim().length() > 0){
            query += ' and Country__c = \'' +  String.escapeSingleQuotes(criteria.country) + '\'';
        }
        if (criteria.firstName != null && criteria.firstName.trim().length() > 0) {
            query += ' and (GPL_Profile__r.FirstName__c like \'%' + String.escapeSingleQuotes(criteria.firstName) + '%\' ' + 
                        'or GPL_Profile__r.PreferredFirstName__c like \'&' + String.escapeSingleQuotes(criteria.firstName) + '%\')';
        }
        if (criteria.lastName != null && criteria.lastName.trim().length() > 0) {
            query += ' and GPL_Profile__r.LastName__c like \'%' + String.escapeSingleQuotes(criteria.lastName) + '%\'';
        }
        if (criteria.specialty != null && criteria.specialty.trim().length() > 0){
            query += ' and GPL_Profile__r.Specialties__c includes (\'' + String.escapeSingleQuotes(criteria.specialty) + '\')';
        }
        if (criteria.medicalDevice != null && criteria.medicalDevice.trim().length() > 0){
            query += ' and GPL_Profile__r.Devices__c includes (\'' + String.escapeSingleQuotes(criteria.medicalDevice) + '\')';
        }
        if (criteria.procedure != null && criteria.procedure.trim().length() > 0){
            query += ' and GPL_Profile__r.Procedures__c includes (\'' + String.escapeSingleQuotes(criteria.procedure) + '\')';
        }       
        if (criteria.clinicName != null && criteria.clinicName.trim().length() > 0){
            query += ' and Name__c like \'%' + String.escapeSingleQuotes(criteria.clinicName) + '%\'';
        }
        if (criteria.physicianId != null && criteria.physicianId.trim().length() > 0){
            query += ' and GPL_Profile__c = \'' + String.escapeSingleQuotes(criteria.physicianId) + '\'';
        }
        if (criteria.clinicId != null && criteria.clinicId.trim().length() > 0){
            query += ' and GPL_Profile__c = \'' + String.escapeSingleQuotes(criteria.clinicId) + '\'';
        }
        System.debug('-----------------------------------------' + query);
        return query;
    }   
    
    private list<GPL_Location__c> findLocations(set<Id> physicianIds){
        return [SELECT Id, City__c, Country__c, Fax__c, Latitude__c, Longitude__c, Geolocation__Latitude__s, Geolocation__Longitude__s, Name__c, 
                       Phone__c, PostalCode__c, Services__c, State__c, Street__c, Website__c,
                       Location_Type__c, GPL_Profile__c 
                FROM GPL_Location__c
                WHERE GPL_Profile__c in :physicianIds];
                //WHERE GPL_Profile__r.Inactive__c = false
                //AND GPL_Profile__c in :physicianIds ];
    }
    /*
    private static map<Id,list<Account>> findHospitals(set<String> physicianIds){
        list<Healthcare_Surgeon_Relationship__c> links = 
                [SELECT Id, Surgeon__c, Healthcare_Facility__c, Healthcare_Facility__r.Name, Healthcare_Facility__r.ShippingCity,
                        Healthcare_Facility__r.ShippingCountry, Healthcare_Facility__r.ShippingPostalCode,                                                       
                        Healthcare_Facility__r.ShippingState, Healthcare_Facility__r.ShippingStreet, Healthcare_Facility__r.Phone                       
               FROM Healthcare_Surgeon_Relationship__c
               WHERE Surgeon__c IN :physicianIds];
        map<Id, list<Account>> out = new map<Id, list<Account>>();
        for (Healthcare_Surgeon_Relationship__c link : links){
            if (link.Healthcare_Facility__c != null){
                list<Account> accounts = out.get(link.Surgeon__c);
                if (accounts == null){
                    accounts = new list<Account>();
                }
                accounts.add(link.Healthcare_Facility__r);
                out.put(link.Surgeon__c, accounts);
            }
        }
        
        return out;
    }
    */
    private GplDataModel.PhysicianProfile createPhysician(GPL_Profile__c x){
        GplDataModel.PhysicianProfile p = new GplDataModel.PhysicianProfile(); 
        p.id = x.Id;
        p.masterId = x.ParentId__c;//x.MasterId__c;
        p.salutation = x.Salutation__c;
        p.firstName = x.FirstName__c;
        p.lastName = x.LastName__c; 
        p.preferredFirstName = x.PreferredFirstName__c;
        p.medicalSchool = x.MedicalSchool__c;
        p.residency = x.Residency__c;
        p.fellowship = x.Fellowship__c;  
        p.devices = x.Devices__c;
        p.groups = x.Groups__c;
        p.honors = x.Honors__c;
        p.publications = x.Publications__c; 
        p.specialties = x.Specialties__c;
        p.procedures = x.Procedures__c;
        p.languages = x.Languages__c;
        p.facebook = x.Facebook__c;
        p.twitter = x.Twitter__c;
        p.linkedIn = x.LinkedIn__c;
        p.youtube = x.YouTube__c;
        p.pictureId = x.PhotoId__c;
        p.locations = new list<GplDataModel.ProfileLocation>();
        p.hospitals = new list<GplDataModel.Hospital>();
        return p;
    }
    //Code added by Goldy on 30-May-2013 for Find A Dentist Functionality
    private GplDataModel.DentistProfile createDentist(GPL_Profile__c x){
        GplDataModel.DentistProfile p = new GplDataModel.DentistProfile(); 
        p.id = x.Id;
        p.masterId = x.ParentId__c;//x.MasterId__c;
        p.salutation = x.Salutation__c;
        p.firstName = x.FirstName__c;
        p.lastName = x.LastName__c; 
        p.contactTitle = x.Contact_Title__c;
        p.preferredFirstName = x.PreferredFirstName__c;
        p.medicalSchool = x.MedicalSchool__c;
        p.residency = x.Residency__c;
        p.fellowship = x.Fellowship__c;  
        //p.devices = x.Devices__c;
        p.groups = x.Groups__c;
        p.honors = x.Honors__c;
        p.publications = x.Publications__c; 
        //p.specialties = x.Specialties__c;
        //p.procedures = x.Procedures__c;
        p.specialtyType = x.Specialty_Type__c;
        p.languages = x.Languages__c;
        p.facebook = x.Facebook__c;
        p.twitter = x.Twitter__c;
        p.linkedIn = x.LinkedIn__c;
        p.youtube = x.YouTube__c;
        p.pictureId = x.PhotoId__c;
        p.locations = new list<GplDataModel.ProfileLocation>();
        p.hospitals = new list<GplDataModel.Hospital>();
        return p;
    }
    //Code Addition Ends Here
    
    private GplDataModel.ClinicProfile createClinic(GPL_Profile__c x){
        GplDataModel.ClinicProfile p = new GplDataModel.ClinicProfile();
        p.id = x.Id;
        //p.masterId = x.MasterId__c;
        p.name = x.Name__c;  
        p.devices = x.Devices__c; 
        p.specialties = x.Specialties__c;
        p.procedures = x.Procedures__c;
        p.languages = x.Languages__c;
        p.facebook = x.Facebook__c;
        p.twitter = x.Twitter__c;
        p.linkedIn = x.LinkedIn__c;
        p.youtube = x.YouTube__c;
        p.pictureId = x.PhotoId__c;
        
        p.locations = new list<GplDataModel.ProfileLocation>();
        return p;
    }
    /*
    private GplDataModel.Hospital createHospital(Account a){
        GplDataModel.Hospital h = new GplDataModel.Hospital();
        h.name = a.Name;
        h.street = a.ShippingStreet;
        h.city = a.ShippingCity;
        h.state = a.ShippingState;
        h.postalCode = a.ShippingPostalCode;
        h.country = a.ShippingCountry;
        return h;
    }
    */
    private GplDataModel.Hospital createHospital(GPL_Location__c l){
        GplDataModel.Hospital h = new GplDataModel.Hospital();
        h.id = l.Id;
        h.name = l.Name__c;
        h.street = l.Street__c;
        h.city = l.City__c;
        h.state = l.State__c;
        h.postalCode = l.PostalCode__c;
        h.country = l.Country__c;
        return h;
    }
    
    private GplDataModel.ProfileLocation createLocation(GPL_Location__c x){
        GplDataModel.ProfileLocation l = new GplDataModel.ProfileLocation(); 
        l.id = x.Id; 
        l.name = x.Name__c;
        l.street = x.Street__c;
        l.city = x.City__c;
        l.state = x.State__c;
        l.country = x.Country__c; 
        l.postalCode = x.PostalCode__c;
        l.phone = x.Phone__c;
        l.fax = x.Fax__c;
        l.website = x.Website__c;
        l.services = x.Services__c;
        l.latitude = x.Geolocation__Latitude__s;
        l.longitude = x.Geolocation__Longitude__s;
        return l;
    }
    
}