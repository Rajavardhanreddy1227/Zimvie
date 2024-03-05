public class testClass {
    
     private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.ORDER_CREATION);
     public static void createAccount() {
     
      try{
          
          Account acc = new Account();
          insert acc;
          
      } catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
      }      

    }
    
    
}