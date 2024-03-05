@isTest
public class RetrySchedulerTest {

  /*  @isTest
    static void testScheduleNewBatch() {
        Test.startTest();
        RetryScheduler.scheduleNewBatch(5);
        Test.stopTest();
    }*/

    @isTest
    static void testSchedule() {
        Test.startTest();
        RetryScheduler.schedule();
        Test.stopTest();
    }

    @isTest
    static void testScheduleWithExistingJob() {
        Test.startTest();
        RetryScheduler.schedule(5);
        Test.stopTest();
    }
}