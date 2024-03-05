public class USReconAndCAIvan_Scheduler implements schedulable
{
    public Map<string,Contact> contactMap ;//contains  records of Contact
    public list<Contact> contactList {get;set;}//list used to display records
    public List<String> toAddresses = new List<String>(); //to email addresses
    
    public String subject { get; set; }
    public String body { get; set; }
    
    //constructor define
    public void execute(SchedulableContext SC)
    {
        sendexcelfile();
    }
    
    //method to send csv file as an export 
    public void sendexcelfile() 
    {
        //intialize list
        contactMap = new Map<string,Contact>();
        contactList = new list<Contact>();
        
        try
        {
            //get the Report receipents
            List<string> reportReceipentsEmailAddresses = new List<String> ();
            
            //get recipient from custom settings
            Map<String, US_CA_Ivan_Report_Recipient__c> reportMap = US_CA_Ivan_Report_Recipient__c.getAll();
            
            //list to have all the key sets
            List<String> strList = new List<String>();
            strList.addAll(reportMap.keySet());
            
            //iterate over strList to fetch the email addresses of report receipents
            for(string receipentName : strList) 
            {
                US_CA_Ivan_Report_Recipient__c recipientRecord = reportMap.get(receipentName);
                system.debug('-----custom setting records---'+recipientRecord);
                string str = recipientRecord.Email__c;
                system.debug('----email address---'+str);
                toAddresses.add(str);
            }
            
            //get sales contact record type Id
            Id salescontactrecordtypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales Contact').getRecordTypeId();
            
            //fetching records
            for(Contact con :[select Id, FirstName, LastName, Email, RecordTypeId, Term_Date__c, Role_Classification__c,CreatedDate,CreatedBy.Name from Contact 
                                        where RecordTypeId =: salescontactrecordtypeId AND Role_Classification__c IN ('Sales Associate' , 'Zimmer Biomet Canada Recon')
                                        AND CreatedDate=LAST_WEEK AND Hire_Date__c!=NULL AND Term_Date__c=: NULL])
            {
                contactMap.put(con.Id, con);
            }
           
            contactList = contactMap.values();
            
            // creating header for each column in csv file
            string reportTitle = 'SFDC Sales Contact - New - US & CA - Ivan'+'\n'+'\n';
            string header ='FirstName,LastName,Email,CreatedDate,CreatedBy \n';
            string finalstr = reportTitle+header;
            //iterate list and creating string that hold fields values  to show  in csv files
            for(Contact obj:contactMap.values())
            {   
                String Recordstring;
                //check if FirstName is not null else shows blank value in the column
                if(obj.FirstName != null && obj.FirstName != ''){
                    Recordstring = obj.FirstName+',';
                }
                else{
                    Recordstring = ' '+',';
                }
                //check if LastName is not null else shows blank value in the column
                if(obj.LastName != null && obj.LastName != ''){
                    Recordstring = Recordstring + obj.LastName+',';
                }
                else{
                    Recordstring = Recordstring + ' '+',';
                }
                //check if Email is not null else shows blank value in the column
                if(obj.Email != null && String.isNotBlank(obj.Email)){
                    Recordstring = Recordstring + obj.Email+',';
                }
                else{
                    Recordstring = Recordstring + ' '+',';   
                }
                //check if CreatedDate is not null else shows blank value in the column
                if(obj.CreatedDate != null){
                    Recordstring = Recordstring + obj.CreatedDate+',';
                }
                else{
                    Recordstring = Recordstring + ' '+',';
                }
                //check if CreatedBy is not null else shows blank value in the column
                if(obj.CreatedBy.Name != null && obj.CreatedBy.Name != ''){
                    Recordstring = Recordstring + obj.CreatedBy.Name+'\n';
                }
                else{
                    Recordstring = Recordstring + ' '+'\n';
                }
                
                system.debug('--abc--'+Recordstring); 
                //Concatenate the string
                finalstr = finalstr+Recordstring;   
            }
          
            //call send email method
            system.debug('---contactList SIZE---'+contactList.size());
            if(contactList.size() > 0){
                SendEmail(finalstr);
            }
            else{
                //Send email when there is no record 
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setToAddresses(toAddresses);
                message.optOutPolicy = 'FILTER';
                message.subject = 'SFDC Sales Contact - New - US & CA - Ivan';
                message.plainTextBody = 'Hi,'+ '\n' + '\n'+' No sales contacts Created last week. '+'\n' +'\n'+ 'Thank you!'+'\n'+'Zimmer Biomet Sales';
                Messaging.SingleEmailMessage[] messages = 
                    new List<Messaging.SingleEmailMessage> {message};
                        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                if (results[0].success) {
                    System.debug('The email was sent successfully.');
                } else {
                    System.debug('The email failed to send: ' + results[0].errors[0].message);
                }
            }
        }
        
        catch(exception ex){
            // Handle exception
            sendExceptionEmail(ex.getMessage());
        }
    }

    //Method to sendEmail
    public void SendEmail(string finalstr)
    {
        try
        {
            system.debug('-----toAddresses----'+toAddresses);
            //Send email method
            Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
            blob excel = blob.valueOf(finalstr);
            attach.setBody(excel);
            attach.setFileName('US Recon and Canada Report Sales Contact - New.csv');
            subject = 'SFDC Sales Contact - New - US & CA - Ivan';
            body =  'Hi,'+ '<BR>' + '<BR>'+'&nbsp;'+' Please find the attached following Salesforce Sales Contact Report to process for <b> <span style="color:red">"MG-NAM-SALESTEAM-EXTERNAL"</span> </b> group.'+'<BR>' +'&nbsp;&nbsp;&nbsp;&nbsp;'+' • SFDC Sales Contact - New - US & CA - Ivan'+'<BR>'+'<BR>'+ 'Thank you!'+'<BR>'+'Zimmer Biomet Sales';

            Messaging.singleEmailMessage Emailwithattch = new Messaging.singleEmailMessage();
            Emailwithattch.setSubject(subject);
            Emailwithattch.setToaddresses(toAddresses);
            Emailwithattch.setHtmlBody(body);
            Emailwithattch.setFileAttachments(new Messaging.EmailFileAttachment[]{attach});
            
            // Sends the email
            Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {Emailwithattch});
        }
        
        catch(Exception ex){
            // Handle exception
            sendExceptionEmail(ex.getMessage());
        }
    }
    
    Public void sendExceptionEmail(string errMsg) 
    {
        // Handle exception
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.toaddresses = new String[] {'mohit.gulati@zimmerbiomet.com','Arun.singh@zimmerbiomet.com'};
        message.optOutPolicy = 'FILTER';
        message.subject = 'SFDC Sales Contact - New - US & CA - Ivan: EXCEPTION OCCURRED';
        message.plainTextBody = 'Hi,'+'\n'+'An Exception occurred while generating the SFDC Sales Contact - New - US & CA - Ivan Report.'+'\n'+'Error Message: '+errMsg+'\n'+'\n'+'Please contact your system admin.'+'\n' +'\n'+ 'Thank you!'+'\n'+'Zimmer Biomet Sales';
        
        Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages); 
    }
}