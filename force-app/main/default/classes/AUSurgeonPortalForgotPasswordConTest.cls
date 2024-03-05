@isTest
public class AUSurgeonPortalForgotPasswordConTest {
	 public static testMethod void testForgotPasswordController() {
      // Instantiate a new controller with all parameters in the page
      AUSurgeonPortalForgotPasswordController controller = new AUSurgeonPortalForgotPasswordController();
      controller.username = 'test@salesforce.com';       
    
      System.assertEquals(controller.forgotPassword(),null); 
    }
}