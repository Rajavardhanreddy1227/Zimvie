global class GplGeocodeLocationsBatchJobScheduler  implements Schedulable {
	global void execute(SchedulableContext sc){
		String query = 'SELECT Id from GPL_Location__c';
	   	GplGeocodeLocationsBatchJob job = new GplGeocodeLocationsBatchJob();
	   	job.query = query;
	   	Database.executeBatch(job,1);
	}
	
	static testmethod void testGplGeocodeAccountsBatchJobScheduler1(){
		Test.startTest();
		GplGeocodeLocationsBatchJobScheduler job = new GplGeocodeLocationsBatchJobScheduler();
        Datetime dt = Datetime.now().addMinutes(1);
        String cron = '0 ' + dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ' + ' ? ' + dt.year();
        System.schedule('Schedule', cron, job);
		Test.stopTest();
	}
}