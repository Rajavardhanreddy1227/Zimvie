public with sharing class RegionAdder {
    
    //pull data of user in list
    public static void regionUpdate (list<User> userList){
        
        //creating map , key and value as countryISO and will pull values related to key
        map<String,countryISO__c> csMap = new map<String,countryISO__c>();
        map<String,CountryISO__c> csiMap = new map<String,CountryISO__c>();
        //iterate values of custom settings, and pulling values from custom settings using getall() method
        for(CountryISO__c each : CountryISO__c.getAll().values()){
            
            //creating map putting all data related to CountryISO__c.name
            csMap.put(each.Geography__c,each);
            csiMap.put(each.name,each);
        }
        
        //itarating user list
        for(User eachUser : userList){
            
            if(eachUser.Geography__c != null || eachUser.Geography__c != 'N/A'){
         
                if(csMap.containsKey(eachUser.Geography__c)){
                        //add region
                        eachUser.Region__c = csMap.get(eachUser.Geography__c).Region__c;
                }
                
                else if(csiMap.containsKey(eachUser.Geography__c)){
                        //add region
                        eachUser.Region__c = csiMap.get(eachUser.Geography__c).Region__c;
                        //replace billing country with ISO
                        eachUser.Geography__c = csiMap.get(eachUser.Geography__c).Geography__c;
                }
                
                else{
                    //eachUser.Geography__c.addError('Please enter valid country');
                }
            }
            else{}
        }
    }
}