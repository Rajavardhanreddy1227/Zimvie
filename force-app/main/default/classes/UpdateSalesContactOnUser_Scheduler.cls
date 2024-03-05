public class UpdateSalesContactOnUser_Scheduler implements schedulable 
{
    public Map<String,String> contactsMap ;//contains Sales Contact Records With Email
    Public Map<String,User> UsersMap; //contains Users Records With Email
    Public set<String>UserEmails;
    public Map<String,User>UpdateUserMap;
    public set<String>profileIds = new set<String>();
    public list<String>toAddress = new list<String>();
    
    //constructor define
    public void execute(SchedulableContext SC)
    {
        //get Error Notification Recipient from custom setting
        for(Error_Notification_Recipient__c strg : Error_Notification_Recipient__c.getall().values()){
            toAddress.add(strg.Email__c);
        }        
        updateData();
    }
    
    //method to send csv file as an export 
    public void updateData() 
    {
        //intialization
        contactsMap = new Map<String,String>();
        UsersMap = new Map<String,User>();
        UserEmails = new set<String>();
        UpdateUserMap = new Map<String,User>();
        
        try
    	{
            //get profiles from custom setting
            for(Contact_To_User_Profiles__c str : Contact_To_User_Profiles__c.getall().values()){
                //system.debug('--Profile_Id--'+str.Profile_Id__c);
                profileIds.add(str.Profile_Id__c);
            }
                
            //fetch user records 
            for(User usr :[select Id,Email, Contact_to_user__c,ProfileId,IsActive from User 
                              	where ProfileId IN:profileIds AND IsActive=:TRUE AND Contact_to_user__c=:NULL]) {
                //system.debug('---USR EMAIL ---'+usr.Email);
                
                String correctEmail = '';
                if(usr.Email.contains('.invalid')){
                    correctEmail = usr.Email.removeEnd('.invalid');
                }
                else{
                    correctEmail = usr.Email;}
                                    
                	UsersMap.put(correctEmail, usr);
	            //system.debug('---correctEmail---'+correctEmail);
	        }
            system.debug('--UserEmails--'+UsersMap.size());
            
            //Call batch class to update records in chunks of 50
            if(!Test.isRunningTest()){
                Id batchInstanceId = Database.executeBatch(new UpdateSalesContactUser_Batch(UsersMap), 50);}
            else{
                Database.executeBatch(new UpdateSalesContactUser_Batch(UsersMap));}
        }
	     
    	catch(exception ex){
            // Handle exception
            //sendExceptionEmail(ex.getMessage());
            system.debug('----Unknown Exception Occurred----'+ex.getMessage());
	    }
    }

    /*
    Public void sendExceptionEmail(string errMsg) 
    {
        // Handle exception
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toaddresses = toAddress;
       	message.optOutPolicy = 'FILTER';
        message.subject = 'Update Sales Contact to User: EXCEPTION OCCURRED';
        message.plainTextBody = 'Hi,'+'\n'+'An Exception occurred while Updating Sales Contact to User.'+'\n'+'\n'+'Error Message: '+errMsg+'\n'+'\n'+'Please contact your system admin.'+'\n' +'\n'+ 'Thank you!'+'\n'+'Zimmer Biomet Sales';
        
        Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages); 
    }
*/
}