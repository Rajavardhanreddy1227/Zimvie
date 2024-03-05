global class MigrationLocationsBatch implements Database.Batchable<sObject>,Database.Stateful {
    public integer matchCount = 0;
    public integer noMatchCount = 0;
    public integer noMatchWithLocationsCount = 0;
    public integer practiceCount = 0;
    public integer hospitalCount = 0;
    public String csv = 'PhysicianId,PhysicianName,Object,Zimmer Account,Name,Postal Code,State,Street,LocationType\n';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        Id healthcareRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Healthcare Facility')
            .getRecordTypeId();
        String classCode='002';
        String query = 'SELECT ID,Healthcare_Facility__r.Zimmer_Number__c,Surgeon__r.FirstName,Surgeon__r.LastName,Healthcare_Facility__r.Name,Location_Type__c, Surgeon__r.GPL_Profile__c, Healthcare_Facility__r.ShippingPostalCode, '+
            'Healthcare_Facility__r.ShippingState, Healthcare_Facility__r.ShippingStreet '+
            'FROM Healthcare_Surgeon_Relationship__c '+
            'WHERE Surgeon__c != NULL '+
            'AND Healthcare_Facility__c != NULL '+
            'AND Healthcare_Facility__r.RecordtypeId=:healthcareRecordTypeId '+
            'AND Healthcare_Facility__r.Class__c=:classCode';
        return Database.getQueryLocator(query);
    }
    
    global void execute(
        Database.BatchableContext BC,
        List<Healthcare_Surgeon_Relationship__c> listRelationships
    ) {
        listRelationships = MigrationMethods.relatePhysicianWithMatchingProfile(listRelationships);
        Map<Id, List<GPL_Location__c>> mapAccountIdToLocations = MigrationMethods.mapAccountToLocations(
            listRelationships
        );
        List<Healthcare_Surgeon_Relationship__c> listUpdatedRelationships = new List<Healthcare_Surgeon_Relationship__c>();
        for (Healthcare_Surgeon_Relationship__c relationship : listRelationships) {
            GPL_Location__c matchingLocation = MigrationMethods.getMatchingLocation(
                relationship,
                mapAccountIdToLocations
            );
            if (matchingLocation != null) {
                relationship.Location_Type__c = matchingLocation.Location_Type__c;
                if(relationship.Location_Type__c=='Practice')
                    practiceCount++;
                if(relationship.Location_Type__c=='Hospital')
                    hospitalCount++;
                if(relationship.Location_Type__c!=null){
                    matchCount++;
                    listUpdatedRelationships.add(relationship);
                }
            } else { 
                noMatchCount++;
                String unmatchedStr = relationship.Surgeon__c+','+relationship.Surgeon__r.FirstName.replace(',','')+' '+relationship.Surgeon__r.LastName.replace(',','')+','+'R,'+relationship.Healthcare_Facility__r.Zimmer_Number__c+','+relationship.Healthcare_Facility__r.Name.replace('\n','').replace('\r','').replace(',','')+',';
                if(String.isNotBlank(relationship.Healthcare_Facility__r.ShippingPostalCode))
                    unmatchedStr+=relationship.Healthcare_Facility__r.ShippingPostalCode.replace('\n','').replace('\r','').replace(',','')+',';
                else
                    unmatchedStr+=relationship.Healthcare_Facility__r.ShippingPostalCode+',';
                
                if(String.isNotBlank(relationship.Healthcare_Facility__r.ShippingState))
                    unmatchedStr+=relationship.Healthcare_Facility__r.ShippingState.replace('\n','').replace('\r','').replace(',','')+',';
                else
                    unmatchedStr+=relationship.Healthcare_Facility__r.ShippingState+',';
                
                if(String.isNotBlank(relationship.Healthcare_Facility__r.ShippingStreet))
                    unmatchedStr+=relationship.Healthcare_Facility__r.ShippingStreet.replace('\n','').replace('\r','').replace(',','')+',';
                else
                    unmatchedStr+=relationship.Healthcare_Facility__r.ShippingStreet+',';
                unmatchedStr+=relationship.Location_Type__c+',\n';
                List<GPL_Location__c> listLocations = mapAccountIdToLocations.get(
                    relationship.Surgeon__c
                );
                if(listLocations!=null){
                    noMatchWithLocationsCount++;
                    for(GPL_Location__c location : listLocations){
                        unmatchedStr+=location.GPL_Profile__r.Account__c+',,'+'L,,';
                        if(String.isNotBlank(location.PostalCode__c))
                            unmatchedStr+=location.Name__c.replace('\n','').replace('\r','').replace(',','')+',';
                        else
                            unmatchedStr+=location.Name__c+',';
                        
                        if(String.isNotBlank(location.PostalCode__c))
                            unmatchedStr+=location.PostalCode__c.replace('\n','').replace('\r','').replace(',','')+',';
                        else
                            unmatchedStr+=location.PostalCode__c+',';
                        
                        if(String.isNotBlank(location.State__c))
                            unmatchedStr+=location.State__c.replace('\n','').replace('\r','').replace(',','')+',';
                        else
                            unmatchedStr+=location.State__c+',';
                        
                        if(String.isNotBlank(location.Street__c))
                            unmatchedStr+=location.Street__c.replace('\n','').replace('\r','').replace(',','')+',';
                        else
                            unmatchedStr+=location.Street__c+',';
                        unmatchedStr+=location.Location_Type__c+',\n';
                    }
                }
                csv += unmatchedStr;
                
            }
        }
        //update listUpdatedRelationships;
    }
    
    global void finish(Database.BatchableContext BC) {
        ContentVersion cv = new ContentVersion();
        cv.ContentLocation = 'S';
        cv.VersionData = Blob.valueOf(csv);
        cv.Title =  'Unmatches Location Migration Script.txt';
        cv.PathOnClient = 'Unmatches Location Migration Script.txt';       
        insert cv;
        system.debug(cv.Id);
        system.debug('Number of matched relationships: ' + matchCount);
        system.debug('Number of practice relationships: ' + practiceCount);
        system.debug('Number of hospital relationships: ' + hospitalCount);
        system.debug('Number of unmatched relationships: ' + noMatchCount);
        system.debug('Number of unmatched relationships with locations: ' + noMatchWithLocationsCount);
    }
}