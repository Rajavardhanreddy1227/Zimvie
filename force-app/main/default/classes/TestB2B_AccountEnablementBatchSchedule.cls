@isTest
private class TestB2B_AccountEnablementBatchSchedule {

    @isTest static void testScheduler() {
        Test.startTest();
        
        // Schedule the job
        String jobName = 'Test_B2B_AccountEnablement_Batch_Job';
        String scheduleExpr = '0 0 * * * ?'; // Run every hour
        System.schedule(jobName, scheduleExpr, new B2B_AccountEnablementBatchSchedule());
        
        // Wait for the scheduled job to complete
        // Adjust the time based on the expected duration of the batch job
        Long waitTime = 2000; // Wait for 2 seconds
        Test.stopTest();
        System.assertEquals(1, [SELECT count() FROM CronTrigger WHERE CronJobDetail.Name = :jobName]);
        
        // Optionally, you can add assertions or query data to verify the batch job's execution
        
        // Delete the scheduled job
        System.abortJob(jobName);
    }
}