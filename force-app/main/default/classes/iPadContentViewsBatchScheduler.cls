global class  iPadContentViewsBatchScheduler  implements Schedulable {
	global void execute(SchedulableContext sc) {
      String query='select '
			            + 'Id, ' 
			            + 'ContentId__c, '
			            + 'howMuch__c ' 
			            +  'from iPad_Content_Views__c where howMuch__c >0';  
	  iPadContentViewsBatch ipcvBatch = new iPadContentViewsBatch(query);
      Id batchprocessid = Database.executeBatch(ipcvBatch);	
   }
   
   static testmethod void testSchedule() {
   Test.startTest();
      String jobId = System.schedule('test',
      '0 0 0 3 9 ? 2022', 
         new iPadContentViewsBatchScheduler());

      CronTrigger ct = [SELECT id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];
    
      System.assertEquals('0 0 0 3 9 ? 2022', 
         ct.CronExpression);
      System.assertEquals(0, ct.TimesTriggered);
      
      System.assertEquals('2022-09-03 00:00:00', 
         String.valueOf(ct.NextFireTime));

   	 Test.stopTest();
   }
}