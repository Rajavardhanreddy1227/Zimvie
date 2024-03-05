public with sharing class GplGeocodeService {
    
    @future (callout=true)
    public static void geocodeAccountsAsynchronously(list<String> ids){
        geocodeAccounts(ids);
    }
    
    
    
    @future (callout=true)
    public static void geocodeLocationsAsynchronously(list<String> ids){
        geocodeLocations(ids);  
    }
    
    
    public static void geocodeAccounts(list<String> ids){
        /*
        list<Account> updates = new list<Account>();
        list<Account> accounts = [ select Id, Name, BillingStreet, BillingCity, BillingState, 
                                          BillingPostalCode, BillingCountry, Latitude__c,
                                          Longitude__c
                                    from Account
                                    where Id in :ids ];
        for (Account a : accounts){
            String address = buildAddress(a.BillingStreet, a.BillingCity, a.BillingState, a.BillingPostalCode, a.BillingCountry);
            System.debug('---------------------- Geocoding:' + a.Name + ': ' + address);
            GplDataModel.GeoPoint coordinates = getGeopoint(address);
            if (coordinates != null){
                a.Latitude__c = coordinates.latitude;
                a.Longitude__c = coordinates.longitude;
                System.debug('---------------------- Geocoding results:' + a.Name + ': ' + a.Latitude__c + '/' + a.Longitude__c);
                updates.add(a);
            }
        }
        if (updates.size() > 0){
            update updates;
        }  
        */
    }
    
    public static void geocodeLocations(list<String> ids){
        list<GPL_Location__c> updates = new list<GPL_Location__c>();
        list<GPL_Location__c> locations = [select Id, Name__c, Street__c, City__c, State__c,
                                                PostalCode__c, Country__c, Latitude__c,
                                                Longitude__c, Geolocation__Latitude__s, Geolocation__Longitude__s
                                            from GPL_Location__c
                                            where Id in :ids];
        for (GPL_Location__c l : locations){
            String address = buildAddress(l.Street__c, l.City__c, l.State__c, l.PostalCode__c, l.Country__c);
            System.debug('---------------------- Geocoding:' + l.Name__c + ': ' + address);
            GplDataModel.GeoPoint coordinates = getGeopoint(address);
            if (coordinates != null){
                l.Geolocation__Latitude__s = coordinates.latitude;
                l.Geolocation__Longitude__s = coordinates.longitude;
                l.Latitude__c = coordinates.latitude;
                l.Longitude__c = coordinates.longitude;
                System.debug('---------------------- Geocoding results:' + l.Name__c + ': ' + l.Latitude__c + '/' + l.Longitude__c);
                updates.add(l);
            }
        }
        if (updates.size() > 0){
            update updates;
        }
    }
    
    public static GplDataModel.GeoPoint getGeoPoint(String address){
        String key = 'AIzaSyCScNMPV7Ceqj9TpdKsXxDmeoIreP5Qhnc';
        GplDataModel.GeoPoint point = null;
        HttpRequest req = new HttpRequest();
        Http http = new Http();
        req.setMethod('GET');
        String url = 'https://maps.googleapis.com/maps/api/geocode/xml?sensor=false&address=' + address + '&key=' + key;
        req.setEndpoint(url);
        String xml;
        if (test.isRunningTest() || address.startsWith('TEST ')){
            xml = '<?xml version="1.0" encoding="UTF-8"?>' +
                '<GeocodeResponse><status>OK</status><result><type>locality</type><type>political</type><formatted_address>Warsaw, IN, USA</formatted_address><address_component><long_name>Warsaw</long_name><short_name>Warsaw</short_name><type>locality</type><type>political</type></address_component><address_component><long_name>Wayne Township</long_name><short_name>Wayne Township</short_name><type>administrative_area_level_3</type><type>political</type></address_component><address_component><long_name>Kosciusko County</long_name><short_name>Kosciusko County</short_name><type>administrative_area_level_2</type><type>political</type></address_component><address_component><long_name>Indiana</long_name><short_name>IN</short_name><type>administrative_area_level_1</type><type>political</type></address_component><address_component><long_name>United States</long_name><short_name>US</short_name><type>country</type><type>political</type></address_component><geometry><location><lat>41.2381000</lat><lng>-85.8530469</lng></location><location_type>APPROXIMATE</location_type><viewport><southwest><lat>41.2048720</lat><lng>-85.8912571</lng></southwest><northeast><lat>41.2902841</lat><lng>-85.7823109</lng></northeast></viewport><bounds><southwest><lat>41.2048720</lat><lng>-85.8912571</lng></southwest><northeast><lat>41.2902841</lat><lng>-85.7823109</lng></northeast></bounds></geometry><partial_match>true</partial_match><place_id>ChIJZ7-cQiycFogRAMhnvFnmkbU</place_id></result></GeocodeResponse>' ;     
        }else {         
            HTTPResponse resp = http.send(req);
            xml = resp.getBody();   
        }
        if ((xml != null) && (xml.length() > 0)){       
            DOM.Document doc = new DOM.Document();
            doc.load(xml);
            DOM.Xmlnode root = doc.getRootElement();
            DOM.XmlNode result = root.getChildElement('result', null);
            DOM.XmlNode status = root.getChildElement('status', null);
            //Integer code = Integer.valueOf(error.getText());
            String statusCode = String.valueOf(status.getText());
            if (statusCode.equalsIgnoreCase('OK') && result != null){
                DOM.XmlNode geometry = result.getChildElement('geometry', null);
                DOM.XmlNode location = geometry.getChildElement('location', null);
                DOM.XmlNode latitude = location.getChildElement('lat', null);
                DOM.XmlNode longitude = location.getChildElement('lng', null);                
                if (latitude != null && longitude != null){
                    point = new GplDataModel.GeoPoint();
                    point.latitude = Double.valueOf(latitude.getText());
                    point.longitude = Double.valueOf(longitude.getText());
                }
            }
        }
        return point;
        
    }
    
    public static String buildAddress(String street, String city, String state, String postalCode, String country){
            String address = '';
            if (street != null && street.trim().length() > 0){
                address += ' ' + street.trim() + ',';
            }
            if (city != null && city.trim().length() > 0){
                address += ' ' + city.trim() + ',';
            }
            if (state != null && state.trim().length() > 0){
                address += ' ' + state.trim();
            }
            if (postalCode != null && postalCode.trim().length() > 0){
                address += ' ' + postalCode.trim();
            }
            if (country != null && country.trim().length() > 0){
                country += ' ' + country;
            }
            //address = address.trim().replace('\n',' ').replace(' ','+');
            return EncodingUtil.urlEncode(address, 'UTF-8');
    } 

      /*
    static testmethod void testGetGeoPoint(){
      
        list<Account> accounts = new list<Account>();
        for (Integer i=0;i<25;i++){
            Account account = new Account(RecordTypeId = '01280000000Q0ke',
                                       Name = 'TEST Account ' + i, 
                                       ShippingStreet = 'TEST 1800 W Center St',
                                       ShippingCity = 'Warsaw',
                                       ShippingState = 'IN',
                                       ShippingPostalCode = '46580',
                                       ShippingCountry = 'US');
            accounts.add(account);
        }   
        insert accounts;
        List<Id> ids = new List<Id>();
        for (Account a : accounts){
            ids.add(a.Id);
        }
        test.startTest();
        geocodeAccounts(ids);
        list<Account> updates = [select Id, Latitude__c, Longitude__c from Account where Id in :ids];
        for (Account a : updates){
            System.assertEquals(41.238565, a.Latitude__c);
            System.assertEquals(-85.852799, a.Longitude__c);
        }
        test.stopTest();
       
    } */
}