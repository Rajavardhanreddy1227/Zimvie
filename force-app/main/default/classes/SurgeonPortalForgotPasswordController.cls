/**
 * An apex page controller that exposes the site forgot password functionality
 */

public class SurgeonPortalForgotPasswordController {
    public String username {get; set;}   
       
    public SurgeonPortalForgotPasswordController() {}
  
    public PageReference forgotPassword() {
      boolean success = Site.forgotPassword(username);
      //system.debug('Before Page');
      PageReference pr = Page.SurgeonPortalForgotPasswordConfirm;
      //system.debug('After Page');
      pr.setRedirect(true);
      
      if (success) {        
        return pr;
      }
      return null;
    }
    /*
     public static testMethod void testForgotPasswordController() 
     {
      // Instantiate a new controller with all parameters in the page
      SurgeonPortalForgotPasswordController controller = new SurgeonPortalForgotPasswordController();
      controller.username = 'test@salesforce.com';       
    
      System.assertEquals(controller.forgotPassword(),null); 
    }*/
}