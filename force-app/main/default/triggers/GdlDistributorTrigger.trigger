trigger GdlDistributorTrigger on Account (after insert, after update) {
	Id recordTypeId = RecordTypeHelper.getRecordTypeId('Account','Distributor');
	list<Account> accounts = new list<Account>();
	list<GDL_Profile__c> profiles = new list<GDL_Profile__c>();
	for (Integer i=0;i<trigger.new.size();i++){
		Account a = trigger.new.get(i);
		if (a.RecordTypeId == recordTypeId){
			if (trigger.isInsert){
				accounts.add(a); 
				//if (a.ParentId == null){
				//	GDL_Profile__c profile = new GDL_Profile__c();
				//	profile.Account__c = a.Id;
				//	profiles.add(profile);
				//}
			} else if (trigger.isUpdate){
				Account old = trigger.old.get(i);
				String updatedAddress = GplGeocodeService.buildAddress(a.BillingStreet, a.BillingCity, a.BillingState, a.BillingPostalCode, a.BillingCountry);
				String originalAddress = GplGeocodeService.buildAddress(old.BillingStreet, old.BillingCity, old.BillingState, old.BillingPostalCode, old.BillingCountry);
				if (!originalAddress.equals(updatedAddress)){
					accounts.add(a);		
				}	
			}			
		}
	}
	//if (profiles.size() > 0){
	//	insert profiles;
	//}
	
	list<list<String>> batches = new list<list<String>>();
	list<String> batch = new list<String>();
	Integer count = 0;
	for (Account acct : accounts){
		if (count == 10){
			count = 0;
			batches.add(batch);
			batch = new list<String>();
		}
		batch.add(acct.Id);
	}
	if (batch.size() > 0){
		batches.add(batch);
	}
	if (batches.size() > 0){
		for (list<String> ids : batches){
			GplGeocodeService.geocodeAccountsAsynchronously(ids);
		}	
	}
	
}