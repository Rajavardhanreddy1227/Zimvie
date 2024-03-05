global class GplConvertAccountsBatchJobScheduler implements Schedulable {
	global void execute(SchedulableContext sc){
		String query = 'select id, Surgeon__c, Surgeon__r.FirstName, ' +
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
					   'where Surgeon__r.Physicians_Locator__c = true ';
	   	GplConvertAccountsBatchJob job = new GplConvertAccountsBatchJob();
	   	job.query = query;
	   	Database.executeBatch(job,1);
	}
	
	static testmethod void testGplGeocodeAccountsBatchJobScheduler1(){
		Test.startTest();
		GplConvertAccountsBatchJobScheduler job = new GplConvertAccountsBatchJobScheduler();
        Datetime dt = Datetime.now().addMinutes(1);
        String cron = '0 ' + dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ' + ' ? ' + dt.year();
        System.schedule('Schedule', cron, job);
		Test.stopTest();
	}
}