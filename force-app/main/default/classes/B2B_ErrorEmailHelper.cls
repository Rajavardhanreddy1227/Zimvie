public class B2B_ErrorEmailHelper {

    // Method to send an email using custom metadata addresses
    // Parameters:
    //   subject: The subject of the email
    //   body: The body content of the email
    public static void sendEmail(String subject, String body) {
        // Get comma-separated email addresses from custom metadata
        String toAddress = getCommaSeparatedEmailValuesFromCustomMetadata();
        
        // Create an instance of Messaging.SingleEmailMessage
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        
        // Set the recipients (To addresses) using the comma-separated email addresses
        email.setToAddresses(toAddress.split(','));
        
        // Set the subject and body of the email
        email.setSubject(subject);
        email.setPlainTextBody(body);
        
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { email });
    } 

    // Method to retrieve comma-separated email addresses from custom metadata
    // Returns:
    //   A comma-separated string of email addresses
    public static String getCommaSeparatedEmailValuesFromCustomMetadata() {
        // Initialize the variable to store comma-separated email addresses
        String commaSeparatedEmails = '';
        
        // Query and retrieve custom metadata records
        List<B2B_Error_Emails__mdt> customMetadataRecords = [SELECT Emails__c FROM B2B_Error_Emails__mdt];
        
        // Loop through the records and concatenate email values with a comma
        for (B2B_Error_Emails__mdt record : customMetadataRecords) {
            // Access the custom field value
            String emails = record.Emails__c;
            
            // Concatenate email value to the commaSeparatedEmails string
            if (!String.isBlank(emails)) {
                commaSeparatedEmails += emails + ',';
            }
        }
        
        // Remove the trailing comma, if any
        if (!String.isBlank(commaSeparatedEmails)) {
            commaSeparatedEmails = commaSeparatedEmails.removeEnd(',');
        }
        
        // Return the comma-separated email addresses
        return commaSeparatedEmails;
    }
}