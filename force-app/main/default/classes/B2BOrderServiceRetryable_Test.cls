@isTest
public class B2BOrderServiceRetryable_Test {
 @isTest
    static void B2BOrderService(){
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenere());
        B2BOrderServiceRetryable orderRetry = new B2BOrderServiceRetryable('Error Messsage','1Os8L000000GnhLSAS');
        orderRetry.startJob();
    }
}