public class AUSurgeonPortalForgotPasswordController {
    public String username {get; set;}   
       
    public AUSurgeonPortalForgotPasswordController() {}
  
    public PageReference forgotPassword() {
      boolean success = Site.forgotPassword(username);
      //system.debug('Before Page');
      PageReference pr = Page.AUSurgeonPortalForgotPasswordConfirm;
      //system.debug('After Page');
      pr.setRedirect(true);
      
      if (success) {        
        return pr;
      }
      return null;
    }
    /*
     public static testMethod void testForgotPasswordController() {
      // Instantiate a new controller with all parameters in the page
      AUSurgeonPortalForgotPasswordController controller = new AUSurgeonPortalForgotPasswordController();
      controller.username = 'test@salesforce.com';       
    
      System.assertEquals(controller.forgotPassword(),null); 
    }*/
}