@isTest
public class SurgeonPortalForgotPasswordConTest {
	 public static testMethod void testForgotPasswordController() 
     {
      // Instantiate a new controller with all parameters in the page
      SurgeonPortalForgotPasswordController controller = new SurgeonPortalForgotPasswordController();
      controller.username = 'test@salesforce.com';       
    
      System.assertEquals(controller.forgotPassword(),null); 
    }
}