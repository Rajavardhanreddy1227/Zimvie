global class GdlGeocodeDistributorsBatchJobScheduler implements Schedulable {
	private Id recordTypeId = RecordTypeHelper.getRecordTypeId('Account','Distributor');
	global void execute(SchedulableContext sc){
		String query = 'SELECT Id from Account WHERE RecordTypeId = \'' + recordTypeId + '\'';
	   	GdlGeocodeDistributorsBatchJob job = new GdlGeocodeDistributorsBatchJob();
	   	job.query = query;
	   	Database.executeBatch(job,1);
	}
	static testmethod void testScheduler(){
		Test.startTest();
		GdlGeocodeDistributorsBatchJobScheduler job = new GdlGeocodeDistributorsBatchJobScheduler();
        Datetime dt = Datetime.now().addMinutes(1);
        String cron = '0 ' + dt.minute() + ' * ' + dt.day() + ' ' + dt.month() + ' ' + ' ? ' + dt.year();
        System.schedule('Schedule', cron, job);
		Test.stopTest();
	}
}