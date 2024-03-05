global class PhysicianLocatorService{

    global class Physician {
        WebService String PhysicianId;
        WebService String Salutation;
        WebService String FirstName;
        WebService String MiddleName;
        WebService String LastName;
        WebService String Suffix;
        WebService String Email;
        WebService String OfficeStreet;
        WebService String OfficeCity;
        WebService String OfficeStateOrProvince;
        WebService String OfficePostalCode;
        WebService String OfficeCountry;
        WebService String Graduate;
        WebService Date GraduationDate;
        WebService String Residency;
        WebService Date ResidencyDate;
        WebService String Fellowship;  
        WebService Date FellowshipDate;
        WebService String MIS; 
        WebService String SpecialInterest;
        WebService String MedicalDegree; 
        WebService String Specialties;
        WebService String SubSpecialties;
        WebService String Publications;
        WebService String Awards;
        WebService Decimal YearsPracticing;
        WebService String Languages;
        WebService String OfficeLocations;
        WebService String Gender;
        WebService String PictureID;        
        WebService String FacebookUrl;
        WebService String TwitterId;
        WebService String LinkedInUrl;
        WebService String JobTitle;
        WebService list<Hospital> HospitalAffiliations;
        WebService list<MedicalPractice> MedicalPractices;
    }
    
    global class PhysicianLocatorSearchCriteria {
        WebService list<String> ZipCodes;
        WebService String City;
        WebService String State;
        WebService String FirstName;
        WebService String LastName;
        WebService String Specialty;
        WebService String MedicalPracticeName;
        WebService String PhysicianId;
        WebService String MedicalPracticeId;
    }
    
    global class MedicalPractice {
        WebService String Id;
        WebService String Name;
        WebService String Street;
        WebService String City;
        WebService String State;
        WebService string Country;
        WebService String PostalCode; 
        WebService String Phone;
        WebService String Fax;
        WebService String WebSite;
    }
    
    global class Hospital {
        WebService String Id;
        WebService String Name;
        WebService String City;
        WebService String State;
        WebService String Country;
    }
    global class Photo {
        WebService Blob Body;
        WebService Integer BodyLength;
        WebService String ContentType;
    }
    
    WebService static list<Physician> searchByZipCode(list<String> zipCodes){
        String query = buildQuery(zipCodes, null, null, null, null, null, null, null, null);
        return performSearch(query);
    }
    
    WebService static list<Physician> searchByCityState(String city, String state){
        String query = buildQuery(null, city, state, null, null, null, null, null, null);
        return performSearch(query);
    }
    
    WebService static Physician searchById(String medicalPracticeId, String physicianId){
        String query = buildQuery(null, null, null, null, null, null, null, physicianId, medicalPracticeId);
        list<Physician> results = performSearch(query);
        if (results.isEmpty()){
            return null;
        }else{
            return results.get(0);
        }
    }
    
    WebService static list<Physician> search(PhysicianLocatorSearchCriteria criteria){
        String query = buildQuery(criteria);
        return performSearch(query);
    }
    
    WebService static Photo getPhysicianPhoto(String id){
        Photo photo = null;
        try {
            Attachment a = [select Body, ContentType, BodyLength from Attachment where Id = :id];
            if (a != null){
                photo = new Photo();
                photo.Body = a.Body;
                photo.BodyLength = a.BodyLength;
                photo.ContentType = a.ContentType;
            }
        } catch (System.Queryexception ex){
            
        }
        return photo;
        
    }
    
    private static list<Physician> performSearch(String query){
        list<Practice_Surgeon_Link__c> surgeons = Database.query(query);
        list<String> surgeonIds = new list<String>();
        for (Practice_Surgeon_Link__c surgeon : surgeons){
            surgeonIds.add(surgeon.Surgeon__c);
        }
        //list<Healthcare_Surgeon_Relationship__c> surgeonHealthcareFacilities = listHealthcareFacilitiesBySurgeon(surgeons);
        map<ID, list<MedicalPractice>> practicesBySurgeon = listMedicalPracticesBySurgeon(surgeonIds);
        map<ID, list<Hospital>> hospitalsBySurgeon = listHealthcareFacilitiesBySurgeon(surgeonIds);
        map<ID,Physician> physicians = new map<ID,Physician>();
        for (Practice_Surgeon_Link__c surgeon : surgeons){
            Physician physician = physicians.get(surgeon.Surgeon__c);
            if (physician == null){
                physician = createPhysician(surgeon); 
                physician.MedicalPractices = practicesBySurgeon.get(surgeon.Surgeon__c);
                physician.HospitalAffiliations = hospitalsBySurgeon.get(surgeon.Surgeon__c);
                physicians.put(surgeon.Surgeon__c, physician);
            }
        }
        return physicians.values();
    }
    
    private static map<ID, list<MedicalPractice>> listMedicalPracticesBySurgeon(list<String> surgeonIds){
        map<ID, list<MedicalPractice>> output = new map<ID, list<MedicalPractice>>();
        list<Practice_Surgeon_Link__c> relationships = new list<Practice_Surgeon_Link__c>();
        relationships = [ select id, Practice__c, Practice__r.Name, Practice__r.ShippingCity,
                      Practice__r.ShippingCountry, Practice__r.ShippingPostalCode,
                      Practice__r.ShippingState, Practice__r.ShippingStreet, Practice__r.Website,
                      Practice__r.Phone, Practice__r.Fax, Surgeon__c
                 from Practice_Surgeon_Link__c
                 where Surgeon__c IN :surgeonIds
                 limit 2000]; 
        for (Practice_Surgeon_Link__c relationship : relationships){
            list<MedicalPractice> practices = output.get(relationship.Surgeon__c);
            if (practices == null){
                practices = new list<MedicalPractice>();
            }  
            practices.add(createMedicalPractice(relationship));
            output.put(relationship.Surgeon__c, practices);
        }     
        return output;
    }
    
    private static map<ID, list<Hospital>> listHealthcareFacilitiesBySurgeon(list<String> surgeons){
        map<ID, list<Hospital>> output = new map<ID, list<Hospital>>();
        list<Healthcare_Surgeon_Relationship__c> relationships = new list<Healthcare_Surgeon_Relationship__c>();
        relationships = [ select id,Healthcare_Facility__c,Healthcare_Facility__r.Name,
                        Healthcare_Facility__r.ShippingCity,Healthcare_Facility__r.ShippingCountry,                                                           
                        Healthcare_Facility__r.ShippingState,Surgeon__c
                 from Healthcare_Surgeon_Relationship__c
                 where Surgeon__c IN :surgeons
                 limit 2000];      
        for (Healthcare_Surgeon_Relationship__c relationship : relationships){
            list<Hospital> hospitals = output.get(relationship.Surgeon__c);
            if (hospitals == null){
                hospitals = new list<Hospital>();
            }
            Hospital hospital = new Hospital();
            hospital.Name = relationship.Healthcare_Facility__r.Name;
            hospital.City = relationship.Healthcare_Facility__r.ShippingCity;
            hospital.State = relationship.Healthcare_Facility__r.ShippingState;
            hospital.Country = relationship.Healthcare_Facility__r.ShippingCountry;    
            hospitals.add(hospital);
            output.put(relationship.Surgeon__c, hospitals);
        }     
        return output;
    }
    
    private static String buildQuery(PhysicianLocatorSearchCriteria criteria){
        return buildQuery(criteria.ZipCodes, criteria.City, criteria.State, criteria.FirstName, criteria.LastName,
                          criteria.Specialty, criteria.MedicalPracticeName, criteria.PhysicianId, criteria.MedicalPracticeId);
    }
    
    private static String buildQuery(list<String> zipCodes, String city, String state, String firstName, 
                                     String lastName, String specialty, String practiceName, String physicianId,
                                     String medicalPracticeId ) {
        String query = 'select id, Surgeon__c, Surgeon__r.FirstName, ' +
                       'Surgeon__r.Middle_Name__c, Surgeon__r.LastName, Surgeon__r.Suffix__c, ' +
                       'Surgeon__r.Technique__c, Surgeon__r.Expertise_integration_purpose__c, ' +
                       'Surgeon__r.Medical_School__c, Surgeon__r.Residency__c, Surgeon__r.Fellowship__c,' +
                       'Surgeon__r.Medical_Degree__c, Surgeon__r.Specialty_Integration__c, ' +
                       'Surgeon__r.PersonMailingCity, Surgeon__r.PersonMailingCountry, ' +
                       'Surgeon__r.PersonMailingPostalCode, Surgeon__r.PersonMailingState, ' +
                       'Surgeon__r.PersonMailingStreet, Surgeon__r.MDM_SAP_ID__c, ' + 
                       'Surgeon__r.Physicians_Locator__c, Surgeon__r.Account_Picture_Id__c, ' +
                       'Surgeon__r.Publications_Presentations__c, Surgeon__r.Awards_Honors_Patents__c, ' +
                       'Surgeon__r.Years_experienced__c, Surgeon__r.Languages__c, Surgeon__r.Gender__c, ' +
                       'Surgeon__r.PersonEmail, Surgeon__r.Med_Grad_Date__c, Surgeon__r.Residency_Completion_Date__c, ' +
                       'Surgeon__r.Fellowship_Completion_Date__c, Surgeon__r.Salutation, Surgeon__r.Facebook_URL__c, ' +
                       'Surgeon__r.Twitter_ID__c, Surgeon__r.LinkedInURL__c, Surgeon__r.PersonTitle,  ' +
                       'Surgeon__r.Surgical_Interests__c ' +
                       'from Practice_Surgeon_Link__c ' + 
                       'where Surgeon__r.Physicians_Locator__c = true ';
        if ((zipCodes != null) && !(zipCodes.isEmpty())){
            boolean first = true;
            String values = '';
            for (String zipCode : zipCodes){
                if (zipCode != null && zipCode.trim().length() > 0){
                    if (!first){
                        values += ', ';
                    }           
                    values += '\''+ zipCode +'\'';
                    first = false;
                }
            }
            if (values.length() > 0){
                query += ' and Practice__r.ShippingPostalCode in (' + values + ')';
            }
        }   
        if (city != null && city.trim().length() > 0) {
            query += ' and Practice__r.ShippingCity = \'' + String.escapeSingleQuotes(city) + '\'';
        }                  
        if (state != null && state.trim().length() > 0) {
            query += ' and Practice__r.ShippingState = \'' + String.escapeSingleQuotes(state) + '\'';
        }
        if (firstName != null && firstName.trim().length() > 0) {
            query += ' and Surgeon__r.FirstName like \'%' + String.escapeSingleQuotes(firstName) + '%\'';
        }
        if (lastName != null && lastName.trim().length() > 0) {
            query += ' and Surgeon__r.LastName like \'%' + String.escapeSingleQuotes(lastName) + '%\'';
        }
        if (specialty != null && specialty.trim().length() > 0){
            query += ' and Surgeon__r.Specialty_Integration__c includes (\'' + String.escapeSingleQuotes(specialty) + '\')';
        }
        if (practiceName != null && practiceName.trim().length() > 0){
            query += ' and Practice__r.Name like \'%' + String.escapeSingleQuotes(practiceName) + '%\'';
        }
        if (physicianId != null && physicianId.trim().length() > 0){
            query += ' and Surgeon__c = \'' + String.escapeSingleQuotes(physicianId) + '\'';
        }
        if (medicalPracticeId != null && medicalPracticeId.trim().length() > 0){
            query += ' and Practice__c = \'' + String.escapeSingleQuotes(medicalPracticeId) + '\'';
        }
        query += ' limit 999';
        return query;
    }       
    
    private static Physician createPhysician(Practice_Surgeon_Link__c surgeon){
        Physician physician = new Physician();
        physician.PhysicianId = surgeon.Surgeon__c;
        physician.Salutation = surgeon.Surgeon__r.Salutation;
        physician.FirstName = surgeon.Surgeon__r.FirstName;
        physician.MiddleName = surgeon.Surgeon__r.Middle_Name__c;
        physician.LastName = surgeon.Surgeon__r.LastName;
        physician.Suffix = surgeon.Surgeon__r.Suffix__c;
        physician.Email = surgeon.Surgeon__r.PersonEmail;
        physician.OfficeStreet = surgeon.Surgeon__r.PersonMailingStreet;
        physician.OfficeCity = surgeon.Surgeon__r.PersonMailingCity;
        physician.OfficeStateOrProvince = surgeon.Surgeon__r.PersonMailingState;
        physician.OfficePostalCode = surgeon.Surgeon__r.PersonMailingPostalCode;
        physician.OfficeCountry = surgeon.Surgeon__r.PersonMailingCountry;
        physician.Graduate = surgeon.Surgeon__r.Medical_School__c;
        physician.GraduationDate = surgeon.Surgeon__r.Med_Grad_Date__c;
        physician.Residency = surgeon.Surgeon__r.Residency__c;
        physician.ResidencyDate = surgeon.Surgeon__r.Residency_Completion_Date__c;
        physician.Fellowship = surgeon.Surgeon__r.Fellowship__c;
        physician.FellowshipDate = surgeon.Surgeon__r.Fellowship_Completion_Date__c;  
        physician.MIS = surgeon.Surgeon__r.Technique__c; 
        physician.SpecialInterest = surgeon.Surgeon__r.Expertise_integration_purpose__c;
        physician.MedicalDegree = surgeon.Surgeon__r.Medical_Degree__c; 
        physician.Specialties = surgeon.Surgeon__r.Specialty_Integration__c;
        physician.SubSpecialties = surgeon.Surgeon__r.Surgical_Interests__c;
        physician.Publications = surgeon.Surgeon__r.Publications_Presentations__c;
        physician.Awards = surgeon.Surgeon__r.Awards_Honors_Patents__c;
        physician.YearsPracticing = surgeon.Surgeon__r.Years_experienced__c;
        physician.Languages = surgeon.Surgeon__r.Languages__c;
        physician.OfficeLocations = '';
        physician.Gender = surgeon.Surgeon__r.Gender__c;
        physician.PictureID = surgeon.Surgeon__r.Account_Picture_Id__c;
        physician.FacebookUrl = surgeon.Surgeon__r.Facebook_URL__c;
        physician.TwitterId = surgeon.Surgeon__r.Twitter_ID__c;
        physician.LinkedInUrl = surgeon.Surgeon__r.LinkedInURL__c;
        physician.JobTitle = surgeon.Surgeon__r.PersonTitle;
        return physician;
    }
    
    private static MedicalPractice createMedicalPractice(Practice_Surgeon_Link__c surgeon){
        MedicalPractice practice = new MedicalPractice();
        practice.Id = surgeon.Practice__c;
        practice.Name = surgeon.Practice__r.Name;
        practice.Street = surgeon.Practice__r.ShippingStreet;
        practice.City = surgeon.Practice__r.ShippingCity;
        practice.State = surgeon.Practice__r.ShippingState;
        practice.Country = surgeon.Practice__r.ShippingCountry;
        practice.PostalCode = surgeon.Practice__r.ShippingPostalCode; 
        practice.Phone = surgeon.Practice__r.Phone;
        practice.Fax = surgeon.Practice__r.Fax;
        practice.WebSite = surgeon.Practice__r.Website;
        return practice;
    }
    
    static testMethod void testAll(){
        list<String> zipCodes = new list<String>();
        zipCodes.add('19107');
        zipCodes.add('19145');
        zipCodes.add('08080');
        test.startTest();
        Boolean result = false;
        list<Physician> zipPhysicians = searchByZipCode(zipCodes);
        if (zipPhysicians.size() > 0){
            Physician p = zipPhysicians.get(0);
            MedicalPractice mp = p.MedicalPractices.get(0);
            list<Physician> csPhysicians = searchByCityState(mp.City, mp.State);
            Physician pById = searchById(mp.Id, p.PhysicianId);
            PhysicianLocatorSearchCriteria criteria = new PhysicianLocatorSearchCriteria();
            //criteria.FirstName = p.FirstName;
            //criteria.LastName = p.LastName;
            //citeria.City = mp.City;
            criteria.State = mp.State;
            //criteria.Specialty = p.Specialties;
            list<Physician> freePs = search(criteria);  
            String names = '';
            for (Physician x : zipPhysicians){
                names += x.FirstName + ' ' + x.LastName + '\n';
            }
            system.debug('--------ZIP CODE RESULTS--------------');
            system.debug(names);
            names = '';
            for (Physician x : csPhysicians){
                names += x.FirstName + ' ' + x.LastName + '\n';
            }
            system.debug('--------CITY STATE RESULTS------------');
            system.debug(names);
            
            system.debug('--------BY ID RESULTS------------------');
            system.debug(pById.FirstName + ' ' + pById.LastName);
            
            names = '';
            for (Physician x : freePs){
                names += x.FirstName + ' ' + x.LastName + '\n';
            }
            System.debug('---------------------------------------------->>>' + freePs.size());
            System.debug('---------------FREE SEARCH RESULTS----------------');
            system.debug(names);
            
            result = ((csPhysicians.size() > 0) && (pById != null));     
            system.debug(result);
        }
        test.stopTest();
        System.assert(result);
    }
}