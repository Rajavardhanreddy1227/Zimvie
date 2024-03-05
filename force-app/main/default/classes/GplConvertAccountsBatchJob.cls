global class GplConvertAccountsBatchJob implements Database.Batchable<sObject> {
    //private Id recordTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL Physician Profile' );
    private Id recordTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_PhysicianProfile' );
    
    global String query {get; set;}
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, list<sObject> scope) {
        map<Id,GPL_Profile__c> profiles = new map<Id,GPL_Profile__c>();
        list<GPL_Location__c> locations = new list<GPL_Location__c>();
        set<Id> accountIds = new set<Id>();
        set<Account> accounts = new set<Account>();
        for (sObject s : scope){
            Practice_Surgeon_Link__c link = (Practice_Surgeon_Link__c)s;
            accountIds.add(link.Surgeon__c);
            accounts.add(link.Surgeon__r);
            GPL_Profile__c profile = profiles.get(link.Surgeon__c);
            if (profile == null){
                profile = GplProfileBuilder.buildProfile(link.Surgeon__r);//createPhysician(link.Surgeon__r); 
            }
            profiles.put(link.Surgeon__c, profile);
        }
        upsert profiles.values() GPL_Profile__c.MasterId__c;
        for (sObject s : scope){
            Practice_Surgeon_Link__c link = (Practice_Surgeon_Link__c)s;
            if (link.Practice__r != null){
                GPL_Location__c location =  GplProfileBuilder.buildLocation(link.Practice__r);//createLocation(link.Practice__r);
                if ((location.Street__c != null) && (location.Street__c.length() > 0)
                    &&(location.City__c != null) && (location.City__c.length() > 0)
                    &&(location.State__c != null) && (location.State__c.length() > 0)
                    &&(location.PostalCode__c != null) && (location.PostalCode__c.length() > 0)
                    &&(location.Country__c != null) && (location.Country__c.length() > 0)){ 
                    location.GPL_Profile__c = profiles.get(link.Surgeon__c).Id;
                    locations.add(location);    
                }
            }
        }
        
        list<Healthcare_Surgeon_Relationship__c> links = 
                [SELECT Id, Surgeon__c, Healthcare_Facility__c, Healthcare_Facility__r.Name, Healthcare_Facility__r.ShippingCity,
                        Healthcare_Facility__r.ShippingCountry, Healthcare_Facility__r.ShippingPostalCode, Healthcare_Facility__r.RecordTypeId,                                                      
                        Healthcare_Facility__r.ShippingState, Healthcare_Facility__r.ShippingStreet, Healthcare_Facility__r.Phone,
                        Healthcare_Facility__r.Fax, Healthcare_Facility__r.Website                      
               FROM Healthcare_Surgeon_Relationship__c
               WHERE Surgeon__c IN :accountIds];
        for (Healthcare_Surgeon_Relationship__c link : links){
            GPL_Profile__c p = profiles.get(link.Surgeon__c);
            if (p != null && link.Healthcare_Facility__r != null){
                GPL_Location__c location = GplProfileBuilder.buildLocation(link.Healthcare_Facility__r);
                if ((location.Street__c != null) && (location.Street__c.length() > 0)
                    &&(location.City__c != null) && (location.City__c.length() > 0)
                    &&(location.State__c != null) && (location.State__c.length() > 0)
                    &&(location.PostalCode__c != null) && (location.PostalCode__c.length() > 0)
                    &&(location.Country__c != null) && (location.Country__c.length() > 0)){ 
                    location.GPL_Profile__c = profiles.get(link.Surgeon__c).Id;
                    locations.add(location);    
                }
            }
       }
       insert locations;
       for (Account a : accounts){
            GPL_Profile__c profile = profiles.get(a.Id);
            a.GPL_Profile__c = profile.Id;
            a.Physician_Locator_Status__pc = 'Locator Displayed';
       }
       update new List<Account>(accounts);
    }
    
    global void finish(Database.BatchableContext bc){
        
    }
    
    static testmethod void testGplConvertAccountsBatchJob(){    
        Id personAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Physician');   
        //Id hospitalAccountTypeId = RecordTypeHelper.getRecordTypeId('Account', 'Healthcare Facility');
        Id hospitalAccountTypeId = RecordTypeHelper.getRecordTypeId('Account', 'HealthcareFacility');
        
        list<Account> doctors = new list<Account>();
        list<Account> practices = new list<Account>();
        list<Account> hospitals = new list<Account>();
        for (Integer i=0;i<25;i++){
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
            doctors.add(doctor);
            Account practice = new Account(RecordTypeId = hospitalAccountTypeId,
                                       Name = 'TEST Practice ' + i, 
                                       ShippingStreet = 'TEST 1800 W Center St',
                                       ShippingCity = 'Warsaw',
                                       ShippingState = 'IN',
                                       ShippingPostalCode = '46580',
                                       ShippingCountry = 'US');
            practices.add(practice);
            Account hospital = new Account(RecordTypeId = hospitalAccountTypeId,
                                       Name = 'TEST Hospital ' + i, 
                                       ShippingStreet = 'TEST 1800 W Center St',
                                       ShippingCity = 'Warsaw',
                                       ShippingState = 'IN',
                                       ShippingPostalCode = '46580',
                                       ShippingCountry = 'US');
            hospitals.add(hospital);
        }   
        insert doctors;
        insert practices;
        insert hospitals;
        for (Account a : doctors){
            a.RecordTypeId = personAccountTypeId;
        }
        update doctors;
        list<Practice_Surgeon_Link__c> links = new list<Practice_Surgeon_Link__c>();
        list<Healthcare_Surgeon_Relationship__c> hlinks = new list<Healthcare_Surgeon_Relationship__c>();
        for (integer i=0;i<doctors.size();i++){
            Practice_Surgeon_Link__c link = new Practice_Surgeon_Link__c(
                Surgeon__c = doctors.get(i).Id,
                Practice__c = practices.get(i).Id
            );
            links.add(link);
            Healthcare_Surgeon_Relationship__c hlink = new Healthcare_Surgeon_Relationship__c(
                Surgeon__c = doctors.get(i).Id,
                Healthcare_Facility__c = hospitals.get(i).Id
            );
            hlinks.add(hlink);
        }
        insert links;
        insert hlinks;
        String q = 'select id, Surgeon__c, Surgeon__r.FirstName, ' +
                       'Surgeon__r.Middle_Name__c, Surgeon__r.LastName, Surgeon__r.Suffix__c, ' +
                       'Surgeon__r.Technique__c, Surgeon__r.Expertise_integration_purpose__c, ' +
                       'Surgeon__r.Medical_School__c, Surgeon__r.Residency__c, Surgeon__r.Fellowship__c,' +
                       'Surgeon__r.Medical_Degree__c, Surgeon__r.Specialty_Integration__c, ' +
                       'Surgeon__r.Physicians_Locator__c, Surgeon__r.Account_Picture_Id__c, ' +
                       'Surgeon__r.Publications_Presentations__c, Surgeon__r.Awards_Honors_Patents__c, ' +
                       'Surgeon__r.Years_experienced__c, Surgeon__r.Languages__c, Surgeon__r.Gender__c, ' +
                       'Surgeon__r.Med_Grad_Date__c, Surgeon__r.Residency_Completion_Date__c, ' +
                       'Surgeon__r.Fellowship_Completion_Date__c, Surgeon__r.Salutation, Surgeon__r.PersonTitle, Practice__r.Name, ' +
                       'Surgeon__r.Surgical_Interests__c, Practice__r.ShippingState, Practice__r.ShippingPostalCode, ' +
                       'Surgeon__r.Memberships_Associations_Conferences__c, ' +
                       'Practice__r.ShippingCountry, Practice__r.Phone, Practice__r.Fax, Practice__r.Website, ' +
                       'Practice__r.ShippingStreet, Practice__r.ShippingCity, Practice__r.RecordTypeId, Surgeon__r.IsPersonAccount ' +
                       'from Practice_Surgeon_Link__c ' + 
                       'where Surgeon__r.Physicians_Locator__c = true AND Id in (';
        boolean f = true;
        for (Practice_Surgeon_Link__c l : links){
            if (!f){
                q = q + ', ';
            }
            q = q + '\'' + l.Id + '\'';
            f = false;
        }
        q = q + ')';
        System.debug('------------------------------' + q);
        GplConvertAccountsBatchJob job = new GplConvertAccountsBatchJob();
        job.query = q;
        test.startTest();
        Database.executeBatch(job,200);
        Test.stopTest();
    }
}