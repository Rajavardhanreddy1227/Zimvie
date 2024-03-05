global class GplGeocodeLocationsBatchJob implements Database.Batchable<sObject>, Database.AllowsCallouts {
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
				GplGeocodeService.geocodeLocations(ids); 
			}	
		}
		
	}
	global void finish(Database.BatchableContext bc){
	}
	static testMethod void testGplGeocodeLocationsBatchJob(){
		GPL_Profile__c profile = new GPL_Profile__c(
			Devices__c = 'Kinectiv',
			Groups__c = 'AAOS',
			Honors__c = 'Man of the Year (2011)',
			Publications__c = 'How to replace a knee (Doctor Review - May 2011)',
			Specialties__c = 'Knee',
			Procedures__c = 'MIS',
			Languages__c = 'English',
			Facebook__c = 'http://www.facebook.com',
			Twitter__c = 'http://www.twitter.com',
			LinkedIn__c = 'http://www.linkedin.com',
			YouTube__c = 'http://www.youtube.com'
		);
		insert(profile);
		list<GPL_Location__c> locations = new list<GPL_Location__c>();
		for (integer i=0;i<25;i++){
			GPL_Location__c l1 = new GPL_Location__c(
				GPL_Profile__c = profile.Id,
				Name__c = 'TEST Practice ' + i,
				Street__c = 'TEST Mataveri International Airport',
				City__c = 'Easter Island',
				State__c = 'CL',
				PostalCode__c = 'CL012001',
				Country__c = 'CL',
			   	Phone__c = '574-372-4068',
			   	Fax__c = '574-372-4068',
			   	Website__c = 'http://www.google.com',
			   	Services__c = 'Pickup Services'
			);
			locations.add(l1);
		}
		insert locations;
		String q = 'SELECT Id FROM GPL_Location__c where Id IN (';
		boolean f = true;
		for (GPL_Location__c l : locations){
			if (!f){
				q = q + ', ';
			}
			q = q + '\'' + l.Id + '\'';
			f = false;
		}
		q = q + ')';		
		GplGeocodeLocationsBatchJob job = new GplGeocodeLocationsBatchJob();
		job.query = q;
		test.startTest();
		Database.executeBatch(job,200);
		Test.stopTest();
	}
	

}