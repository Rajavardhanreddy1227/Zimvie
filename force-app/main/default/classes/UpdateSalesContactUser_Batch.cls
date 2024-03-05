global class UpdateSalesContactUser_Batch implements Database.Batchable<sObject>, Database.Stateful
{
    // collect the batches of records or objects to be passed to execute
    
    global final map<string,User>usersWithEmailMap ;
    global final Set<String> UserEmailList;
    
    global Set<String> RecordTypeIds = new set<String>();
    global map<string,User> updateUsers= new map<string,User>();// holds the records that need to be updated
    global List<String> toAddresses = new List<String>(); //to email addresses
    
    // instance member to retain state across transactions
    global Integer recordsProcessed;
    global Integer recordsProcessed1;
    global Integer recordsUpdated;
    global string finalstr;
    global string finalstr2;
    
    global UpdateSalesContactUser_Batch(map<string,User> usersMap){
        
        System.debug('- Constructor: Begin -');
        //system.debug('--usersMap--'+usersMap);
        
        recordsProcessed = 0;
        recordsProcessed1 = 0;
        recordsUpdated=0;
        finalstr = '';
        finalstr2 = '';
        usersWithEmailMap = usersMap;
        UserEmailList = usersMap.keySet();
        //system.debug('--UserEmailList--'+UserEmailList);
        
        //toAddresses.add('mohit.gulati@zimmerbiomet.com');
        
        //get Contact to User Batch Success Recipient from custom setting
        for(Contact_To_User_Batch_Recipient__c strg : Contact_To_User_Batch_Recipient__c.getall().values())
        {
            toAddresses.add(strg.Email__c);
        } 

        //get Contact Record Types from custom setting
        for(Contact_To_User_Contact_Record_Types__c str : Contact_To_User_Contact_Record_Types__c.getall().values())
        {
            RecordTypeIds.add(str.Record_Type_Id__c);
        }
    }
    
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        // process each batch of records
        
        System.debug('- start: Begin -');
        
        //create sting query
        //fetch Contact Records
        string query = 'SELECT Id, Email, Sales_Assoc_ID__c, RecordTypeId FROM Contact WHERE Email IN:UserEmailList AND RecordTypeId IN:RecordTypeIds';
        
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        
        System.debug('- execute: Begin -');
        
        for(Sobject s : scope){
            Contact con = (Contact)s; //typecast sobject to Contact Object
            system.debug('--con.Email--'+con.Email);
            for(User u : usersWithEmailMap.values())
            {
                //system.debug('--u.Email--'+u.Email);
                String correctEmail = '';
                
                if(u.Email.contains('.invalid')){
                    correctEmail = u.Email.removeEnd('.invalid');}
                else{
                    correctEmail = u.Email;}
                
                if(con.Email == correctEmail /*&& con.Sales_Assoc_ID__c == u.Rep_Code__c*/)
                {
                    recordsProcessed++;
                    recordsProcessed1++;
                    //Update ContactToUser
                    u.Contact_to_user__c = con.Id;
                    updateUsers.put(u.Id,u);
                }
            }
        }
        
        system.debug('--updateUsers--'+updateUsers.size());
        
        if(!updateUsers.isEmpty()){
            //update updateUsers.values();  
            
            Database.SaveResult[] SaveResultList = Database.update(updateUsers.values(),false); 
            
            // creating header for each column in csv file
            string reportTitle = 'Update Sales Contact On User - Success'+'\n'+'\n';
            string header ='Id,Email,ContactToUser \n';
            finalstr = reportTitle+header;
            
            string reportTitle2 = 'Update Sales Contact On User - Error'+'\n'+'\n';
            string header2 ='Error \n';
            finalstr2 = reportTitle2+header2;
            
            // Iterate through each returned result
            for (Database.SaveResult sr : SaveResultList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successfully Updated Users. User ID: ' + sr.getId());
                    
                    String Recordstring;
                    
                    If(updateUsers.containsKey(sr.getId()))
                    {
                        recordsUpdated++;
                        User u = updateUsers.get(sr.getId());
                        
                        Recordstring = u.Id+',';
                        Recordstring = Recordstring + u.Email+',';
                        Recordstring = Recordstring + u.Contact_to_user__c+'\n';
                        
                        system.debug('--Success abc--'+Recordstring); 
                        //Concatenate the string
                        finalstr = finalstr+Recordstring;
                    }
                } 
                else if (!sr.isSuccess()) {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        String ErrMsg = err.getStatusCode() + ': ' + err.getMessage();
                        recordsProcessed1--;
                        String Recordstring;
                        
                        
                        Recordstring = Recordstring + ErrMsg+'\n';
                        
                        system.debug('--Error abc--'+Recordstring); 
                        //Concatenate the string
                        finalstr2 = finalstr2+Recordstring;
                        
                    }
                }
            }
            
            System.debug('- execute: End -');
        }
    }
    
    global void finish(Database.BatchableContext BC){
        // execute any post-processing operations
        System.debug('- finish: Begin -');
        //system.debug('- Update Users List Batch Size -'+updateUsers.size());
        system.debug('--finalstr--'+finalstr);
        system.debug('--finalstr2--'+finalstr2);
        
        System.debug(recordsProcessed + ' records processed. Successfully!');
        System.debug(recordsUpdated + ' records Updated. Successfully!');
        
        AsyncApexJob job = [SELECT Id, Status, NumberOfErrors, 
                            JobItemsProcessed,
                            TotalJobItems, CreatedBy.Email
                            FROM AsyncApexJob
                            WHERE Id = :bc.getJobId()];
        
        if(finalstr != '' && finalstr2 != '')
        {
            //send email
            List<Messaging.EmailFileAttachment> efaList = new List<Messaging.EmailFileAttachment>();
            
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            blob excel = blob.valueOf(finalstr);
            attach.setBody(excel);
            attach.setFileName('Update Sales Contact On User - Success.csv');
            efaList.add(attach);
            
            Messaging.EmailFileAttachment attach1 = new Messaging.EmailFileAttachment();
            blob excel1 = blob.valueOf(finalstr2);
            attach1.setBody(excel1);
            attach1.setFileName('Update Sales Contact On User - Error.csv');
            efaList.add(attach1);
            
            String subject = 'Batch Process Completed - Update Contact on User';
            String body = 'Hi,'+ '<BR>' + '<BR>'+'Batch Process is completed. '+ '<BR>';
            body += recordsProcessed+ ' record(s) have been processed.'+'<BR>' +'<BR>';
            body += 'Please find the attached success & Error files.'+'<BR>' +'<BR>'+ 'Thank you!';
            
            Messaging.singleEmailMessage Emailwithattch = new Messaging.singleEmailMessage();
            Emailwithattch.setSubject(subject);
            Emailwithattch.setToaddresses(toAddresses);
            Emailwithattch.setReplyTo('mohit.gulati@zimmerbiomet.com'); 
            Emailwithattch.setSenderDisplayName('Batch Processing');
            Emailwithattch.setHtmlBody(body);
            Emailwithattch.setFileAttachments(efaList);
            
            // Sends the email
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {Emailwithattch});
        }
        
        else
        {
            String subject1 = 'Batch Process Completed - Update Contact on User';
            String body1 = 'Hi,'+ '<BR>' + '<BR>'+'Batch Process is completed. '+ '<BR>';
            body1 += 'No records found.'+'<BR>' +'<BR>';
            body1 += 'Thank you!';
            
            // Handle exception
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toaddresses = toAddresses;
            message.optOutPolicy = 'FILTER';
            message.subject = subject1;
            message.htmlbody= body1;
            
            Messaging.SingleEmailMessage[] messages = 
                new List<Messaging.SingleEmailMessage> {message};
                    Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        }
        
        
    }
}