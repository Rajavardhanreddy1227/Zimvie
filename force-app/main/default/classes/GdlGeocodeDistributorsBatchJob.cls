global class GdlGeocodeDistributorsBatchJob implements Database.Batchable<sObject>, Database.AllowsCallouts{

	global String query {get;set;}
	global Database.QueryLocator start (Database.BatchableContext bc){
		return Database.getQueryLocator(query);
	}
	global void execute(Database.BatchableContext bc, list<sObject> scope){
		list<list<String>> batches = new list<list<String>>();
		list<String> batch = new list<String>();
		Integer count = 0;
		for (sObject so : scope){
			if (count == 10){
				count = 0;
				batches.add(batch);
				batch = new list<String>();
			}
			batch.add(so.Id);
			count = count + 1;
		}
		if (batch.size() > 0){
			batches.add(batch);
		}
		if (batches.size() > 0){
			for (list<String> ids : batches){
				GplGeocodeService.geocodeAccounts(ids); 
			}	
		}
		
	}
	global void finish(Database.BatchableContext bc){
	}
	
	static testmethod void testJob(){
		Id RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('Account','Distributor');
		list<Account> accounts = new list<Account>();
		for (integer i = 0; i < 25; i++){
	    	Account a = new Account(
	    		RecordTypeID = RECORD_TYPE_ID,
	    		Name = 'Test Parent Distributor' + i,
	    		BillingStreet = 'TEST 123 Main Street',
	    		BillingCity = 'Easter Island',
	    		BillingState = 'CL',
	    		BillingPostalCode = 'CL012001',
	    		BillingCountry = 'CL',
	    		Territory_Number__c = '0000',
	    		Organization__c = 'Parent'	
	    	);
	    	accounts.add(a);
		}
    	insert accounts;
    	GdlGeocodeDistributorsBatchJob job = new GdlGeocodeDistributorsBatchJob();
    	String q = 'SELECT Id FROM Account WHERE Id IN (';
		boolean f = true;
    	for (Account a : accounts){
			if (!f){
				q = q + ', ';
			}
			q = q + '\'' + a.Id + '\'';
			f = false;
		}
		q = q + ')';
    	job.query = q;
    	test.startTest();
    	Database.executeBatch(job,200);
    	test.stopTest();
	}
}