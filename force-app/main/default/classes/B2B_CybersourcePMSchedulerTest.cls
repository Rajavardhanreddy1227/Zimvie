@isTest
public class B2B_CybersourcePMSchedulerTest {
   /* @IsTest
    
    static void executeTest() {
        SchedulableContext sc = null;
        B2B_CybersourcePMScheduler cyberPMSschdeule = new B2B_CybersourcePMScheduler();
        cyberPMSschdeule.execute(sc);
        B2B_CybersourcePMScheduler.deleteOtherPendingJobs();
    }*/
    @isTest
    static void testExecuteMethod() {
          Test.setMock(HttpCalloutMock.class, new MockHttpResponse());
        
         SchedulableContext sc = null;
        B2B_CybersourcePMScheduler scheduler = new B2B_CybersourcePMScheduler();
        scheduler.isUpdateToken = true; 
        Test.startTest();
        scheduler.execute(sc);
        B2B_CybersourcePMScheduler.deleteOtherPendingJobs();
      
        Test.stopTest();
       
    }
    
    
}