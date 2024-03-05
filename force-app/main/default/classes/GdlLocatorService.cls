global class GdlLocatorService {
    private static Id RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('Account','Distributor');
    
    webservice static list<GdlDataModel.DistributorLocation> searchLocations(GdlDataModel.SearchCriteria criteria){
        list<Account> matches = Database.query(buildQuery(criteria));
        list<GdlDataModel.DistributorLocation> locations = new list<GdlDataModel.DistributorLocation>();
        map<Id,Id> profiles = new map<Id,Id>();
        for (GDL_Profile__c p : [SELECT Id, Account__c from GDL_Profile__c where Account__c IN :matches]){
            profiles.put(p.Account__c, p.Id);
        } 
        for (Account a : matches){
            GdlDataModel.DistributorLocation l = new GdlDataModel.DistributorLocation();
            l.id = a.Id;
            l.name = a.Name;
            l.street = a.BillingStreet;
            l.city = a.BillingCity;
            l.state = a.BillingState;
            l.postalCode = a.BillingPostalCode;
            l.country = a.BillingCountry;
            l.latitude = a.Latitude__c;
            l.longitude = a.Longitude__c;
            if (a.Toll_free__c != null && a.Toll_free__c.length() > 0){
                l.phone = a.Toll_free__c;   
            } else {
                l.phone = a.Phone;
            }
            l.fax = a.Fax;
            l.website = a.Website;
            l.specialties = a.Distributor_Specialties__c;
            l.parentId = a.ParentId;
            Id profileId = profiles.get(a.Id);
            if (profileId == null){
                profileId = profiles.get(a.ParentId);
            }
            l.hasProfile = (profileId != null);
            locations.add(l);
        }
        
        
        return locations;
    }
    
    webservice static GdlDataModel.DistributorProfile getDistributorProfile(String id){
        GdlDataModel.DistributorProfile profile = null;
        Account acct = [SELECT Id, ParentId FROM Account WHERE id = :id LIMIT 1];
        if (acct != null){
            Id parentId = acct.Id;
            if (acct.ParentId != null){
                parentId = acct.ParentId;
            }
            list<Account> accounts = [SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry,
                                             Latitude__c, Longitude__c, Phone, Fax, Website, Toll_free__c, Distributor_Specialties__c,parentId
                                      FROM Account
                                      WHERE RecordTypeId = :RECORD_TYPE_ID
                                        AND (Id = :parentId OR ParentId = :parentId)
                                        AND (Deactive_Date__c = null OR Deactive_Date__c > TODAY)];
            
            list<GdlDataModel.DistributorLocation> locations = new list<GdlDataModel.DistributorLocation>();
            for (Account a : accounts){
                GdlDataModel.DistributorLocation l = new GdlDataModel.DistributorLocation();
                l.id = a.Id;
                l.name = a.Name;
                l.street = a.BillingStreet;
                l.city = a.BillingCity;
                l.state = a.BillingState;
                l.postalCode = a.BillingPostalCode;
                l.country = a.BillingCountry;
                l.latitude = a.Latitude__c;
                l.longitude = a.Longitude__c;
                l.parentId = a.ParentId;
                if (a.Toll_free__c != null && a.Toll_free__c.length() > 0){
                    l.phone = a.Toll_free__c;   
                } else {
                    l.phone = a.Phone;
                }
                l.fax = a.Fax;
                l.website = a.Website;
                l.specialties = a.Distributor_Specialties__c;
                locations.add(l);
            }
            profile = new GdlDataModel.DistributorProfile();
            profile.mainOfficeId = parentId; 
            profile.requestedOfficeId = id;
            GDL_Profile__c p = [SELECT Id, Account__c, Name__c, Image__c, Content__c, OwnerId
                                         FROM GDL_Profile__c
                                         WHERE Account__c = :parentId LIMIT 1];
            profile.content = p.Content__c;
            profile.image = p.Image__c;
            profile.name = p.Name__c;
            profile.supportQueueId = p.OwnerId;
            list<GDL_DistributorEvent__c> gdlEvents = [SELECT Id, Name, StartDate__c, EndDate__c, Description__c, DistributorProfile__c, Title__c
                                                       FROM GDL_DistributorEvent__c
                                                       WHERE DistributorProfile__c = :p.Id
                                                         AND (StartDate__c >= TODAY OR EndDate__c >= TODAY)
                                                         ORDER BY StartDate__c];
            list<GdlDataModel.DistributorEvent> events = new list<GdlDataModel.DistributorEvent>();
            for (GDL_DistributorEvent__c gdlEvent : gdlEvents){
                GdlDataModel.DistributorEvent e = new GdlDataModel.DistributorEvent();
                e.startDate = gdlEvent.StartDate__c;
                e.endDate = gdlEvent.EndDate__c;
                e.name = gdlEvent.Title__c;
                e.description = gdlEvent.Description__c;
                events.add(e);
            }
            profile.events = events;
            list<GDL_DistributorLink__c> gdlLinks = [SELECT Id, Name, Target__c, Title__c, DistributorProfile__c
                                                     FROM GDL_DistributorLink__c
                                                     WHERE DistributorProfile__c = :p.Id];
            list<GdlDataModel.DistributorLink> links = new list<GdlDataModel.DistributorLink>();
            for (GDL_DistributorLink__c gdlLink : gdlLinks){
                GdlDataModel.DistributorLink link = new GdlDataModel.DistributorLink();
                link.name = gdlLink.Title__c;
                link.url = gdlLink.Target__c;
                links.add(link);
            }
            profile.links = links;
            profile.locations = locations;
        }
        return profile;
    }
            
    private static String buildQuery(GdlDataModel.SearchCriteria criteria){
        String query = 'SELECT Id, Name, BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry, ' +
                       'Latitude__c, Longitude__c, Phone, Fax, Website, ParentId, Toll_free__c, Distributor_Specialties__c ' +
                       'FROM Account ' +
                       'WHERE RecordTypeId = \'' + RECORD_TYPE_ID + '\'' +  
                       ' AND (Organization__c = \'Parent\' OR Organization__c = \'Satellite\') ' +  
                       ' AND (Deactive_Date__c = null OR Deactive_Date__c > TODAY) ';
        
        
        if ((criteria.id != null) && (criteria.id.length() > 0)){
            query += ' AND Id = \'' + criteria.id + '\'';
        }
        if ((criteria.name != null) && (criteria.name.length() > 0)){
            query += ' AND Name like \'%' + criteria.name + '%\'';
        }
        if ((criteria.specialty != null) && (criteria.specialty.length() > 0)){
            query += ' AND Distributor_Specialties__c includes (\'' + String.escapeSingleQuotes(criteria.specialty) + '\')';
        }
        if ((criteria.postalCode != null) && (criteria.postalCode.length() > 0)){
            if ((criteria.country == null) || (criteria.country == 'US')){
                list<String> tids = lookupTerritories(criteria.postalCode);
                if (tids!= null && !tids.isEmpty()){
                    query += ' AND Territory__c IN (';
                    for (Integer i=0; i<tids.size(); i++){
                        if (i > 0){
                            query += ',';
                        }
                        query += '\'' + tids.get(i)+ '\'';
                    }
                    query += ')';
                }
            } else {
                query += ' AND BillingPostalCode = \'' + criteria.postalCode + '\'';                    
            }       
        }
        if ((criteria.country != null) && (criteria.country.length() > 0)){
            query += ' AND BillingCountry = \'' + criteria.country + '\'';
        }       
        return query;
    }
    
    public static list<String> lookupTerritories(String postalCode){
        list<String> territories = null;
        list<Zip_codes_distributor__c> zcd = [select id,name from Zip_codes_distributor__c where name = :postalCode];
        if(!zcd.isEmpty()) {
            list<County_to_Zip_codes__c> czc = [select id,County_Distributor__c,Zip_Codes_Distributor__c 
                                                from County_to_Zip_codes__c 
                                                where zip_Codes_Distributor__c IN :zcd];
            system.debug('the size of the territory ciountry  list is: ' +czc.size());
            if(!czc.isEmpty()) {
                list<String> CdId = new list<String>();
                for(County_to_Zip_codes__c cc :czc) {
                    CdId.add(cc.County_Distributor__c);
                }
                list<Territory_county__c> tc = [select id,County_Distributor__c,territory__c
                                                from Territory_county__c 
                                                where County_Distributor__c IN :CdId];
                system.debug('the size of the territory ciountry  list is: ' +tc.size());
                if(!tc.isEmpty()) {
                    territories = new list<String>();
                    for(Territory_county__c tt :tc) {
                        
                        if(tt.territory__c != null){
                            territories.add(tt.territory__c);
                        	system.debug('the territory value is:' + tt.territory__c);
                        }
                        
                    }
                }   
            }
        }
        return territories;        
    }
    
// Modified By Rohit Attri : Commented below code because TestMethods should be written in a separate test class 
// and created new Test Class GdlLocatorServiceTest for Code Coverage of GdlLocatorService and GdlDataModel Classes
/*
    static testmethod void testSearchLocations(){
        Account main = new Account(
            RecordTypeID = RECORD_TYPE_ID,
            Name = 'Test Parent Distributor',
            BillingStreet = 'TEST 123 Main Street',
            BillingCity = 'Easter Island',
            BillingState = 'CL',
            BillingPostalCode = 'CL012001',
            BillingCountry = 'CL',
            Latitude__c = -27.128,
            Longitude__c = -109.341,
            Territory_Number__c = '0000',
            Organization__c = 'Parent'
            //Territory__c = '0000' 
        );
        insert(main);
        Account s1 = new Account(
            RecordTypeId = RECORD_TYPE_ID,
            ParentId = main.Id,
            Name = 'Test Parent Distributor',
            BillingStreet = 'TEST 123 Main Street',
            BillingCity = 'Puerto Villamil',
            BillingState = 'EC',
            BillingPostalCode = 'EC012001',
            BillingCountry = 'EC',
            Latitude__c = -0.8292784,
            Longitude__c = -90.9820667999999,
            Territory_Number__c = '0000',
            Organization__c = 'Parent'
            //Territory__c = '0000'
        );
        insert(s1);
        GDL_Profile__c profile = new GDL_Profile__c(
            Account__c = main.Id,
            Content__c = '<h3>About Test Parent Distributor</h3><p>This is the content for this distributor</p>',
            Image__c = 'image1'
        );
        insert(profile);
        GDL_DistributorLink__c link = new GDL_DistributorLink__c(
            Target__c = 'http://www.google.com',
            Title__c = 'Google',
            DistributorProfile__c = profile.Id
        );
        insert(link);
        GDL_DistributorEvent__c event = new GDL_DistributorEvent__c(
            Title__c = 'A Test Event',
            StartDate__c = System.today(),
            EndDate__C = System.today(),
            DistributorProfile__c = profile.Id
        );
        insert(event);
        
        GdlDataModel.SearchCriteria criteria = new GdlDataModel.SearchCriteria();
        criteria.country = 'CL';
        criteria.state = 'CL';
        criteria.postalCode = 'CL012001';
        test.startTest();
            list<GdlDataModel.DistributorLocation> locations = searchLocations(criteria);
            System.assertEquals(1, locations.size());
            GdlDataModel.DistributorProfile prof = getDistributorProfile(locations.get(0).Id);
            System.assertNotEquals(null, prof);
        test.stopTest();
        
    } */
}