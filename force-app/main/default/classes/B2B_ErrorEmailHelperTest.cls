@isTest
public class B2B_ErrorEmailHelperTest {
    @isTest
    static void sendEmailTest(){
        test.startTest();
      	 B2B_ErrorEmailHelper.sendEmail('Test Subject','Error Messsage');
        test.stopTest();
       
        
        
    }
}