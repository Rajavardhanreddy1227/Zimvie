global class GplConvertGplLocationsToGeolocation implements Database.Batchable<sObject> {
     global String query;
    
    public Database.QueryLocator start(Database.BatchableContext context) {
        //return Database.getQueryLocator('select Id, Latitude__c, Longitude__c, Geolocation__Latitude__s, Geolocation__Longitude__s from GPL_Location__c') ;
        return Database.getQueryLocator(query);
    }
    
    public void execute (Database.BatchableContext context, List<sObject> scope) {
        for (sObject s : scope) {
            GPL_Location__c loc = (GPL_Location__c)s;
            loc.Geolocation__Latitude__s = loc.Latitude__c;
            loc.Geolocation__Longitude__s = loc.Longitude__c;
        }
        update scope;
    }
    
    public void finish(Database.BatchableContext bc) {
        
    }
    
}