//*******************************************************************************************************************************//
// Trigger to copy Email To,Cc,Bcc data in custom field to make case available for global search searching through email address
// Developer : Dave Ankit
// Version : 1.0
// Object : EmailMessage
// Class : EmailDataRetrive
//*******************************************************************************************************************************//

trigger EmailDataCopy on EmailMessage (after insert, after update) {
    
    //Copy emailMessage data
    EmailDataRetrive.EmailCopier(Trigger.new);
    
}