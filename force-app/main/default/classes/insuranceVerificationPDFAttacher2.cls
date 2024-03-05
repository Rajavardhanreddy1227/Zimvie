Global with sharing class insuranceVerificationPDFAttacher2 {

   
    
    Public Insurance_Verification__c insurance;
    Public Insurance_Verification__c insuranceAcct;
    Public Account account;
    public String toEmail {get;set;}
    public String ccEmail {get;set;}
    
    //Public insuranceVerificationPDFAttacher2(ApexPages.StandardController controller){
        //this.insurance=(Insurance_Verification__c)Controller.getRecord();
    //}

    public PageReference sendEmail(){
    
        If(!checkRequiredFieldsSave())
        {
        return null;
        }
    
        Id insuranceId = Apexpages.currentPage().getParameters().get('id');
        InsuranceAcct = [select id, Doctor__r.Name, Doctor__c, Patient__c, Patient__r.Name, Name from Insurance_Verification__c where id=: insuranceId LIMIT 1];
        //account = [select Name, Id, PersonEmail, PersonContactId from Account where id=: insuranceAcct.Doctor__c LIMIT 1];  
        
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        
        PageReference pdfPage = Page.InsuranceVerificationDetail;
        pdfPage.getParameters().put('id',insuranceId);
        system.debug('parameter id is:'+pdfPage.getParameters().get('id'));
        Blob pdfBlob;
        
        try{
        pdfBlob = pdfPage.getContent(); 
        
        }catch(exception e){
         ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Blob Failed to load'));
       
        }
        
        Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
        efa.setFileName( InsuranceAcct.Name+'.pdf');
        efa.setBody(pdfBlob);
        
        String[] toAddress = toEmail.split(';',0);
        String[] ccAddress = ccEmail.split(';',0);
        String textBody = 'Dear Requestor:'+'\n'+'\n'+'Please find the attached Insurance Verification Summary.'+'\n'+'\n'+'Sincerely,'+'\n'+'Zimmer Insurance Verification'+'\n'+'\n'+'\n'+'\n'+'\n'+'Confidentiality Notice:  The document accompanying this email contain confidential information.  The information is intended only for the use of the individual or entity named above.  If you are not the intended recipient, you are notified that any disclosure, copying, distribution, or taking of any action in reliance on the contents of this information is not permissible.  If you have received this email in error, please immediately notify us by telephone at 866-946-0444. Thanks you.';
        
        
        email.setToAddresses( toAddress );
        if(ccEmail != ''){
        email.setCcAddresses( ccAddress );}
         if(ccEmail == '' ){
          email.setCcAddresses( Null );}
        
        System.debug('to emails are = ' + toEmail);
        email.setSubject('Insurance Verification Summary');
        email.setPlainTextBody( textBody );
        //email.settargetObjectId(account.PersonContactId);
        //email.setTemplateId('00Xc0000000DcP1');
        
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});
        
        try{
        Messaging.SendEmailResult [] r = 
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}); 
            
            Task t = new Task();
            t.WhatId = insuranceId;
            t.Subject = ' Insurance Verification Summary';
            t.ActivityDate = date.today();
            t.description = 'To Address :'+toEmail + '\n'+'CC :'+ccEmail+'\n'+'BCC :'+'\n'+'Subject : Insurance Verification Form'+'\n'+ 'Body :'+'\n'+ textBody  ;
            t.Status= 'Completed';
            insert t;
        
            Attachment a = new Attachment(parentId = t.id, name= InsuranceAcct.name + '.pdf', body = pdfBlob);
            insert a;
            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The Email has been sent, and a record maintained under Tasks'));
            
            }catch (exception e){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'We have been unable to send the email presently because of some technical difficulty, Please try again after some time'));
            }
              
        
       
        //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'the record is is: '));
        return Null;
    }
    
    public boolean checkRequiredFieldsSave(){
    String message='';      
        Boolean success=true;
         
         if(toEmail == ''){
                    
               success=false;
               message='The To Email Address field cannot be left empty';
               ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));             
               
               return success;
                 
         }
         
         if(toEmail != ''){
         String[] toAddress = toEmail.split(';',0);
        
         for(String s : toAddress){
         
             String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
             Pattern p = Pattern.compile(emailRegex );
             Matcher pm = p.matcher(s);
             
             
             if(s != ''){
             if(!pm.Matches()){
             success=false;
             message='The email address:'+s+''+'entered by you in To Address is not in correct format.';
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));             
             }
             }
                          
         
         }
         }
         
         
         if(ccEmail != ''){
         String[] ccAddress = ccEmail.split(';',0);
         for(String c : ccAddress){
         
             String emailRegex = '([a-zA-Z0-9_\\-\\.]+)@((\\[a-z]{1,3}\\.[a-z]{1,3}\\.[a-z]{1,3}\\.)|(([a-zA-Z0-9\\-]+\\.)+))([a-zA-Z]{2,4}|[0-9]{1,3})';
             Pattern p = Pattern.compile(emailRegex );
             Matcher pm = p.matcher(c);
             
             
             if(c != ''){
             if(!pm.Matches()){
             success=false;
             message='The email address:'+c+''+'entered by in CC Address you is not in correct format.';
             ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));             
             }
             }
         }
         }
        return success;
    }
}