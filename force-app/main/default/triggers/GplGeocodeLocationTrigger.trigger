trigger GplGeocodeLocationTrigger on GPL_Location__c (after insert, after update) {
    
    List<Id> updates = new List<Id>();
    for (Integer i=0;i<trigger.new.size();i++){
        GPL_Location__c updated = trigger.new.get(i);
        GPL_Location__c original = null;
        if (trigger.isUpdate){ 
            original = trigger.old.get(i);
            String updatedAddress = GplGeocodeService.buildAddress(updated.Street__c, updated.City__c, updated.State__c, updated.PostalCode__c, updated.Country__c);
            String originalAddress = GplGeocodeService.buildAddress(original.Street__c, original.City__c, original.State__c, original.PostalCode__c, original.Country__c);
            if (!originalAddress.equals(updatedAddress) && !updatedAddress.startsWith('TEST ')){
                updates.add(updated.Id);
            }
        } else if (!updated.Street__c.startsWith('TEST ')){
            updates.add(updated.Id);
        } 
    }
    list<list<String>> batches = new list<list<String>>();
    list<String> batch = new list<String>();
    Integer count = 0;
    for (Id id : updates){
        if (count == 10){
            count = 0;
            batches.add(batch);
            batch = new list<String>();
        }
        batch.add(id);
    }
    if (batch.size() > 0){
        batches.add(batch);
    }
    if (batches.size() > 0){
        for (list<String> ids : batches){
            GplGeocodeService.geocodeLocationsAsynchronously(ids);
        }   
    }
}