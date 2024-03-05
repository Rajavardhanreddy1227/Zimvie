public with sharing class GplRestDataManager {
    
    private static Id CLINIC_RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('GPL_Profile__c', 'GPL_ClinicProfile');
    private static Id PHYSICIAN_RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('GPL_Profile__c', 'GPL_PhysicianProfile');
    private static Id DENTIST_RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('GPL_Profile__c', 'GPL_DentistProfile');
    
    
    public list<GplRestDataModel.Profile> searchPhysicians(GplRestDataModel.Criteria criteria){
        list<GPL_Location__c> matches = Database.query(buildQuery(criteria, PHYSICIAN_RECORD_TYPE_ID));
        map<Id, GplRestDataModel.Profile> results = new map<Id, GplRestDataModel.Profile>();
        set<String> ids = new set<String>();
        for(GPL_Location__c location : matches){
            GplRestDataModel.Profile profile = results.get(location.GPL_Profile__c);
            if(profile == null){
                profile = createPhysician(location.GPL_Profile__r);
                ids.add(location.GPL_Profile__r.MasterId__c);
            }
            results.put(location.GPL_Profile__c, profile);
        }
        
        list<GPl_Location__c> locations = findLocations(results.keySet());
        for(GPL_Location__c location : locations){
            GplRestDataModel.Profile profile = results.get(location.GPL_Profile__c);
            profile.locations.add(createLocation(location));
            results.put(location.GPL_Profile__c, profile);
        }
        
        return results.values();
    }
    
    public list<GplRestDataModel.Profile> searchClinics(GplRestDataModel.Criteria criteria){
        list<GPL_Location__c> matches = Database.query(buildQuery(criteria, CLINIC_RECORD_TYPE_ID));
        map<Id, GplRestDataModel.Profile> results = new map<Id, GplRestDataModel.Profile>();
        set<String> ids = new set<String>();
        for(GPL_Location__c location : matches){
            GplRestDataModel.Profile profile = results.get(location.GPL_Profile__c);
            if(profile == null){
                profile = createClinic(location.GPL_Profile__r);
            }
            results.put(location.GPL_Profile__c, profile);
        }
        
        list<GPl_Location__c> locations = findLocations(results.keySet());
        for(GPL_Location__c location : locations){
            GplRestDataModel.Profile profile = results.get(location.GPL_Profile__c);
            profile.locations.add(createLocation(location));
            results.put(location.GPL_Profile__c, profile);
        }
        
        return results.values();
    }
    
    public list<GplRestDataModel.Profile> searchDentists(GplRestDataModel.Criteria criteria){
        list<GPL_Location__c> matches = Database.query(buildQuery(criteria, DENTIST_RECORD_TYPE_ID));
        map<Id, GplRestDataModel.Profile> results = new map<Id, GplRestDataModel.Profile>();
        set<String> ids = new set<String>();
        for(GPL_Location__c location : matches){
            GplRestDataModel.Profile profile = results.get(location.GPL_Profile__c);
            if(profile == null){
                profile = createDentist(location.GPL_Profile__r);
                ids.add(location.GPL_Profile__r.MasterId__c);
            }
            results.put(location.GPL_Profile__c, profile);
        }
        
        list<GPl_Location__c> locations = findLocations(results.keySet());
        for(GPL_Location__c location : locations){
            GplRestDataModel.Profile profile = results.get(location.GPL_Profile__c);
            profile.locations.add(createLocation(location));
            results.put(location.GPL_Profile__c, profile);
        }
        
        return results.values();
    }
    
    
    public GplRestDataModel.Photo retrievePhoto(String id){
        GplRestDataModel.Photo photo = null;
        Attachment a = [select Body, ContentType, BodyLength from Attachment where Id = :id];
        if (a != null){
            photo = new GplRestDataModel.Photo();
            photo.body = a.Body;
            photo.bodyLength = a.BodyLength;
            photo.contentType = a.ContentType;
        }
        return photo;
    }
    
    private String buildQuery(GplRestDataModel.Criteria criteria, Id recordType){
        String query = 'SELECT Id, Name__c, City__c, Country__c, Fax__c, Latitude__c, Longitude__c, Geolocation__c, ' + 
                       'Geolocation__Latitude__s, Geolocation__Longitude__s, Phone__c, ' +
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
                        'GPL_Profile__r.PreferredName__c, GPL_Profile__r.Specialty_Type__c, '+
                        'GPL_Profile__r.Contact_Title__c '+
                        'FROM GPL_Location__c ' +                           
                        'WHERE GPL_Profile__r.RecordTypeId = \'' + recordType + '\'';
        if (criteria.id == null || criteria.id.trim().length() == 0){
            query += ' AND GPL_Profile__r.Inactive__c = false ';
            query += ' AND Location_Type__c != \'Hospital\'';
        }
        
        if (criteria.postalCode != null && criteria.postalCode.trim().length() > 0){
            query += ' and PostalCode__c = \'' + String.escapeSingleQuotes(criteria.postalCode) + '\'';
        }   
        if (criteria.city != null && criteria.city.trim().length() > 0) {
            query += ' and City__c = \'' + String.escapeSingleQuotes(criteria.city) + '\'';
        }                  
        if (criteria.state != null && criteria.state.trim().length() > 0) {
            query += ' and State__c = \'' + String.escapeSingleQuotes(criteria.state) + '\'';
        }
        if(criteria.coordinate != null && criteria.coordinate.latitude != null && criteria.coordinate.longitude != null){
            if (criteria.radius == null || criteria.radius > 100) {
                criteria.radius = 25;
            }
            if (criteria.radiusUom != 'mi' || criteria.radiusUom != 'km') {
                criteria.radiusUom = 'mi';
            }
            query += ' and DISTANCE(Geolocation__c, GEOLOCATION(' + criteria.coordinate.latitude + ',' + criteria.coordinate.longitude + '), \'' + String.escapeSingleQuotes(criteria.radiusUom) + '\') < ' + criteria.radius;
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
        if (criteria.name != null && criteria.name.trim().length() > 0) {
            query += ' and (GPL_Profile__r.Name__c like \'%' + String.escapeSingleQuotes(criteria.name) + '%\' ' + 
                        'or GPL_Profile__r.PreferredName__c like \'&' + String.escapeSingleQuotes(criteria.name) + '%\')';
        }
        if (criteria.specialty != null && criteria.specialty.trim().length() > 0){
            query += ' and (GPL_Profile__r.Specialties__c includes (\'' + String.escapeSingleQuotes(criteria.specialty) + '\') or GPL_Profile__r.Specialty_Type__c includes (\'' + String.escapeSingleQuotes(criteria.specialty) + '\'))';
        }
        if (criteria.medicalDevice != null && criteria.medicalDevice.trim().length() > 0){
            query += ' and GPL_Profile__r.Devices__c includes (\'' + String.escapeSingleQuotes(criteria.medicalDevice) + '\')';
        }
        if (criteria.procedure != null && criteria.procedure.trim().length() > 0){
            query += ' and GPL_Profile__r.Procedures__c includes (\'' + String.escapeSingleQuotes(criteria.procedure) + '\')';
        }       
        if (criteria.name != null && criteria.name.trim().length() > 0){
            query += ' and Name__c like \'%' + String.escapeSingleQuotes(criteria.name) + '%\'';
        }
        if (criteria.id != null && criteria.id.trim().length() > 0){
            query += ' and GPL_Profile__c = \'' + String.escapeSingleQuotes(criteria.id) + '\'';
        }
        System.debug('-----------------------------------------' + query);
        return query;
    }
    
    private GplRestDataModel.Profile createPhysician(GPL_Profile__c x){
        GplRestDataModel.Profile p = new GplRestDataModel.Profile();
        p.id = x.Id;
        p.masterId = x.ParentId__c;
        p.salutation = x.Salutation__c;
        if(x.PreferredFirstName__c == null || x.PreferredFirstName__c.trim().length() == 0){
            p.name = x.FirstName__c + ' ' + x.LastName__c;
        } else{
            p.name = x.PreferredFirstName__c + ' ' + x.LastName__c;
        }
        p.firstName = x.FirstName__c;
        p.lastName = x.LastName__c;
        p.preferredName = x.PreferredFirstName__c;
        p.medicalSchool = x.MedicalSchool__c;
        p.residency = x.Residency__c;
        p.fellowship = x.Fellowship__c;
        p.procedures = x.Procedures__c;
        p.specialties = x.Specialties__c;
        p.devices = x.Devices__c;
        p.honors = x.Honors__c;
        p.groups = x.Groups__c;
        p.publications = x.Publications__c;
        p.languages = x.Languages__c;
        p.pictureId = x.PhotoId__c;
        p.facebook = x.Facebook__c;
        p.twitter = x.Twitter__c;
        p.linkedIn = x.LinkedIn__c;
        p.youtube = x.YouTube__c;
        p.locations = new list<GplRestDataModel.Location>();
        return p;
    }
    
    private GplRestDataModel.Profile createClinic(GPL_Profile__c x){
        GplRestDataModel.Profile p = new GplRestDataModel.Profile();
        p.id = x.Id;
        p.masterId = x.ParentId__c;
        p.name = x.Name__c;
        p.preferredName = x.PreferredName__c;
        p.devices = x.Devices__c;
        p.specialties = x.Specialties__c;
        p.procedures = x.Procedures__c;
        p.languages = x.Languages__c;
        p.facebook = x.Facebook__c;
        p.twitter = x.Twitter__c;
        p.linkedIn = x.LinkedIn__c;
        p.pictureId = x.PhotoId__c;
        p.locations = new list<GplRestDataModel.Location>();
        return p;
    }
    
    private GplRestDataModel.Profile createDentist(GPL_Profile__c x){
        GplRestDataModel.Profile p = new GplRestDataModel.Profile();
        p.id = x.Id;
        p.masterId = x.ParentId__c;
        p.salutation = x.Salutation__c;
        if(x.PreferredFirstName__c == null || x.PreferredFirstName__c.trim().length() == 0){
            p.name = x.FirstName__c + ' ' + x.LastName__c;
        } else{
            p.name = x.PreferredFirstName__c + ' ' + x.LastName__c;
        }
        p.firstName = x.FirstName__c;
        p.lastName = x.LastName__c;
        p.preferredName = x.PreferredFirstName__c;
        p.medicalSchool = x.MedicalSchool__c;
        p.residency = x.Residency__c;
        p.fellowship = x.Fellowship__c;
        p.honors = x.Honors__c;
        p.groups = x.Groups__c;
        p.publications = x.Publications__c;
        p.languages = x.Languages__c;
        p.pictureId = x.PhotoId__c;
        p.facebook = x.Facebook__c;
        p.twitter = x.Twitter__c;
        p.linkedIn = x.LinkedIn__c;
        p.youtube = x.YouTube__c;
        p.specialties = x.Specialty_Type__c;
        p.locations = new list<GplRestDataModel.Location>();
        return p;
    }
    
     private list<GPL_Location__c> findLocations(set<Id> physicianIds){
        return [SELECT Id, City__c, Country__c, Fax__c, Geolocation__Latitude__s, Geolocation__Longitude__s, Name__c, 
                       Phone__c, PostalCode__c, Services__c, State__c, Street__c, Website__c,
                       Location_Type__c, GPL_Profile__c 
                FROM GPL_Location__c
                WHERE GPL_Profile__c in :physicianIds];
                //WHERE GPL_Profile__r.Inactive__c = false
                //AND GPL_Profile__c in :physicianIds ];
    }
    
    private GplRestDataModel.Location createLocation(GPL_Location__c x){
        GplRestDataModel.Location l = new GplRestDataModel.Location();
        l.id = x.Id;
        l.locationType = x.Location_Type__c;
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
        l.latitude = x.Geolocation__Latitude__s;//x.Latitude__c;
        l.longitude = x.Geolocation__Longitude__s;//x.Longitude__c;
        return l;
    }

}