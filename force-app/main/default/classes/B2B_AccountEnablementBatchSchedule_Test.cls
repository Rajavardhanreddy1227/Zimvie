@isTest
public class B2B_AccountEnablementBatchSchedule_Test {
 @isTest
    static void schedule(){
        Test.startTest();
        B2B_AccountEnablementBatchSchedule scheduler = new B2B_AccountEnablementBatchSchedule();
         scheduler.execute(null);
        Test.stopTest();
    }
}