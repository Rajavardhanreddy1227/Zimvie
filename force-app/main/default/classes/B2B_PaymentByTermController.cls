public with sharing class B2B_PaymentByTermController {

    //Module Name
    private static final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
    @AuraEnabled(cacheable=true)
    public static Account getLoggedInUserAccountDetails() {

    Account userAccount = null;
    try{
        // Get the Id of the currently logged-in user (portal user)
        Id loggedInUserId = UserInfo.getUserId();

        // Query for the User record of the logged-in user
        User loggedInUser = [SELECT Id, ContactId, Contact.AccountId FROM User WHERE Id = :loggedInUserId];

        

        // Check if the User record has a related Contact record (assuming it's stored in the ContactId field)
        if (loggedInUser != null && loggedInUser.ContactId != null) {
            // Query for the related Account using the Contact object
            userAccount = [SELECT Id, Available_Terms__c, Ecomm_Payment_Options__c  FROM Account WHERE Id = :loggedInUser.Contact.AccountId AND Available_Terms__c != NULL];
        }

    

        }catch (Exception ex) {
    
            logger.error(ex);
            
        } finally {
        
            logger.flush();
            
       }
       return userAccount;
   }

}