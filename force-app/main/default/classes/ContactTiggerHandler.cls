public class ContactTiggerHandler {
    
    public void ontrigger(){
        
        list<Contact> cont = new list<Contact>();
        list<User> userList = new list<User>();
        Map<String,Contact> tempContactMap = new Map<String, Contact>(); 
        Set<String> userToInsertContactIdSet = new Set<String>();  
        Set<String> assignPermissionSet = new Set<String>(); 
        Set<String> existingUsersEmail = new Set<String>();
        
        boolean IsBulk = false;
        IsBulk = trigger.newmap.size()>1?True:False;
        
        Id devRecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Sales Contact').getRecordTypeId();
        System.debug('###RecordTypeID' +devRecordTypeId);
        
        Can_Create_Sales_User__mdt[] allowedUsers = [SELECT MasterLabel, DeveloperName, UserId__c  FROM Can_Create_Sales_User__mdt];
        System.debug('Allowed User List: '+allowedUsers);
        
        cont=[SELECT Id, FirstName, LastName,RecordTypeId,Email,Inactive__c,Sales_Assoc_ID__c,Role_Classification__c,Hire_Date__c,
              Account.Distributor_Specialties__c,userName__c,Account.Name, Account.Distributor_Name__c,Name, LastModifiedById, LastModifiedBy.ProfileId FROM Contact
              where Id IN : trigger.New AND Inactive__c=:FALSE AND RecordTypeId=:devRecordTypeId AND Sales_Assoc_ID__c != null]; 
        
        system.debug('the query output is'+ cont);
        
        // User Map
        Map<string,User> userMap = new Map<string,User>();
        Set<String> conIDSet = new Set<String>();
        Boolean allowUserCreation = false;
        
        if((trigger.isInsert || trigger.isUpdate) )
            //if(trigger.isInsert)
        {     
            system.debug('Inside isInsert---->');
            
            for(Contact con : cont){
                allowUserCreation = false;
                system.debug('Inside For Loop----> '+con.RecordTypeId+'@#'+con.Account); 
                
                if (trigger.isInsert)
                    allowUserCreation = true;
                
                if (trigger.isUpdate)
                {
                    for (Can_Create_Sales_User__mdt a: allowedUsers)
                    {
                        if (con.LastModifiedById == a.UserId__c) {
                            allowUserCreation = true;
                            break;
                        }
                    }                    
                }
                
                if(con.Account.Distributor_Specialties__c != null){
                    if((con.RecordTypeId==devRecordTypeId)
                       && (con.Account.Distributor_Specialties__c.contains('Reconstructive'))
                       && (con.Email != null) 
                       && (allowUserCreation)
                       && con.Sales_Assoc_ID__c != null
                       && ( con.Role_Classification__c != Null &&
                           (con.Role_Classification__c.contains('Distributor')
                            || con.Role_Classification__c.contains('Sales Associate')
                            || con.Role_Classification__c.contains('Sales Manager with accounts' )
                            || con.Role_Classification__c.contains('Surgery Case Specialist')
                            || con.Role_Classification__c.contains('Sales Manager without accounts'))))
                    {
                        system.debug('Inside if condition Insert----> ');
                        
                        tempContactMap.put(String.valueOf(con.Id), con);   
                        conIDSet.add(con.Email);
                        system.debug('--conIDSet--'+conIDSet);
                        
                    }
                }  
            }  
            
            for(User u : [Select IsActive,email,username,contactID,Contact_to_user__c From user where email IN:conIDSet]){
                userMap.put(u.Email,u);
                system.debug('--User Email--'+u.Email);
            }
            
            for(Contact con : tempContactMap.values())
            {
                if(!userMap.containsKey(con.Email))
                {
                    /*if(!isBulk){
//sendExceptionEmail('This username already exists. Please enter unique email Id.', con.Id,con.Email,con.FirstName,con.LastName) ;
Trigger.newMap.get(con.Id).addError('User already exists.');
}*/
                    
                    //else{
                    userToInsertContactIdSet.add(String.valueOf(con.Id));
                    //}
                }
                else if(userMap.containsKey(con.Email))
                {
                    User u = userMap.get(con.Email);
                    if(!u.IsActive){
                        existingUsersEmail.add(u.Id);
                        userToInsertContactIdSet.add(String.valueOf(con.Id));
                    }
                }
            }
            
            if(userToInsertContactIdSet.size()>0 || existingUsersEmail.size()>0){
                createUser(userToInsertContactIdSet,existingUsersEmail);
            }
        }
    }
    
    //Future method to create user account for the sales contact.
    
    @future
    public static void createUser(Set<String> contactIds, Set<String>existingUsers)
    {
        System.debug('----Future method for user creation is called');
        system.debug('---contactIds-----'+contactIds);
        system.debug('---existingUsers-----'+existingUsers);
        Set<String> contactNameSet = new Set<String>();
        list<User> userList = new list<User>();        
        list<Id> assignPermissionSet = new list<Id>();
        Map<String, String> roleNameIdMap = new Map<String, String>();
        
        // User Map
        Map<string,User> userMap = new Map<string,User>();
        
        profile p = [SELECT ID FROM profile WHERE name='US Rosa Sales and Service'];
        
        List<Contact> cont=[SELECT Id, FirstName, LastName,RecordTypeId,Email,Inactive__c,Hire_Date__c,Sales_Assoc_ID__c,
                            Account.Distributor_Specialties__c,userName__c,Title, Account.Name, Account.Distributor_Name__c,
                            Name FROM Contact where id IN : contactIds]; 
        
        for(User EX_User : [SELECT Id,Email,Contact_to_user__c,IsActive FROM User 
                            WHERE Id IN:existingUsers])
        {
            userMap.put(EX_User.Email,EX_User);
        }
        
        for(Contact ct : cont){
            contactNameSet.add(ct.Account.Name+' Uncategorized');
        }
        
        if(contactNameSet.size()>0){
            for(UserRole role :[Select id, Name from userRole where Name IN : contactNameSet]){
                roleNameIdMap.put(role.Name, role.Id);
            }
        }
        
        Integer maxLength = 8;
        for(Contact con : cont){
            
            //Update If user already exist
            If(userMap.ContainsKey(con.Email))
            {
                system.debug('--UPDATE EXISTING USER--');
                User oldUser = userMap.get(con.Email);
                oldUser.Contact_to_user__c = con.Id;
                oldUser.UserPermissionsSFContentUser = True;
                oldUser.UserPermissionsInteractionUser = True;
                oldUser.UserPermissionsMarketingUser = False;
                oldUser.ForecastEnabled = False;
                if(con.Email != 'na@zimmerbiomet.com' && oldUser.Email != con.Email){
                    oldUser.username=con.email;    
                    oldUser.email= con.email;
                }
                oldUser.EmailEncodingKey ='ISO-8859-1';    
                oldUser.LanguageLocaleKey ='en_US';         
                oldUser.LocaleSidKey ='en_US';  
                oldUser.TimeZoneSidKey ='America/Indiana/Indianapolis';  
                oldUser.profileId=p.Id;
                oldUser.Region__c='AM';   
                oldUser.Geography__c='US';    
                oldUser.Business_Division__c= 'RC';  
                oldUser.Rep_Code__c=con.Sales_Assoc_ID__c;
                oldUser.Contact_to_user__c = con.Id;
                oldUser.Title = con.Title;
                oldUser.CompanyName = con.Account.name;                  
                oldUser.Division = '901743';
                oldUser.User_Hire_date__c = con.Hire_Date__c;
				oldUser.Pass_Reset__c = True;
                
                System.debug('##Con.email'+con.email);
                System.debug('##Inactive'+ con.Inactive__c);
                
                if(con.Inactive__c == true){
                    oldUser.isActive = false;                         
                }
                else {
                    oldUser.isActive = True;
                }
                
                System.debug('@#'+con.Account.name);
                System.debug('@#1'+roleNameIdMap);
                
                if(roleNameIdMap.containsKey(con.Account.name+' Uncategorized')){
                    oldUser.userRoleId = roleNameIdMap.get(con.Account.name+' Uncategorized');
                }
                system.debug('$$$UserRole$$$'+oldUser.userRole);
                system.debug('New User Details are'+ oldUser.FirstName); 
                userList.add(oldUser);
            }
            
            //Create new user
            else
            {
                system.debug('--CREATE NEW USER--');
                User u = new User(); 
                u.Contact_to_user__c = con.Id;
                u.FirstName = con.FirstName;
                u.LastName = con.LastName;
                u.UserPermissionsSFContentUser = True;
                //MG - Added on 4.16.20
                u.UserPermissionsInteractionUser = True;
                //MV - Added 2/14/2020
                u.UserPermissionsMarketingUser = False;
                u.ForecastEnabled = False;
                if(con.Email != 'na@zimmerbiomet.com'){
                    u.username=con.email;    
                    u.email= con.email;
                }
                if(con.LastName.length() >= 4){
                    u.Alias = con.FirstName.subString(0,1) + con.LastName.subString(0,4);
                }
                else
                    if(con.LastName.Length() < 4 ){
                        u.Alias = con.FirstName.subString(0,1) + con.LastName;
                    }
                
                u.EmailEncodingKey ='ISO-8859-1';    
                u.LanguageLocaleKey ='en_US';         
                u.LocaleSidKey ='en_US';  
                u.TimeZoneSidKey ='America/Indiana/Indianapolis';  
                //Rohit Attri: Modified on 01-Mar-2018 as per REQ0124763 to update user profile and licence
                u.profileId=p.Id;
                u.Region__c='AM';   
                u.Geography__c='US';    
                u.Business_Division__c= 'RC';  
                u.Rep_Code__c=con.Sales_Assoc_ID__c;
                u.Contact_to_user__c = con.Id;
                u.Title = con.Title;
                u.CompanyName = con.Account.name;                  
                u.Division = '901743';
                u.User_Hire_date__c = con.Hire_Date__c;
                if(u.LastModifiedDate == u.CreatedDate){
                    u.Pass_Reset__c = True;
                }
                
                System.debug('##Con.email'+con.email);
                System.debug('##Inactive'+ con.Inactive__c);
                
                if(con.Inactive__c == true){
                    System.debug('##Con.email'+con.email);
                    u.isActive = false;                         
                }
                else {
                    u.isActive = True;
                }
                
                System.debug('@#'+con.Account.name);
                System.debug('@#1'+roleNameIdMap);
                
                if(roleNameIdMap.containsKey(con.Account.name+' Uncategorized')){
                    u.userRoleId = roleNameIdMap.get(con.Account.name+' Uncategorized');
                }
                system.debug('$$$UserRole$$$'+u.userRole);
                system.debug('New User Details are'+ u.FirstName); 
                userList.add(u);                 
            }
            
        }
        
        
        // creating header for each column in csv file
        string reportTitle = ' Errors Occurred During SFDC User Account Creation for Sales Contact'+'\n'+'\n';
        string header ='Error Message \n';
        string finalstr = reportTitle + header;
        string finalstr2 = reportTitle + 'Contacts Id: ';
        boolean hasErrors = false;
        
        if(userList.size()>0){  
            Schema.SObjectField f = User.Fields.Contact_to_user__c;
            Database.UpsertResult [] cr = Database.upsert(userList, f, false);
            
            for(Database.UpsertResult sr : cr){
                
                if(sr.isSuccess()){
                    assignPermissionSet.add(sr.getId());
                }
                
                if (!sr.isSuccess()) { 
                    
                    hasErrors = true;
                    
                    System.debug('TTTTT'+sr.getErrors());   
                    
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('The following error has occurred.');
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        
                        String Recordstring;
                        Recordstring = err.getFields()+','+err.getMessage() +'\n';
                        system.debug('--abc -->>'+Recordstring); 
                        
                        //Concatenate the values
                        finalstr = finalstr+Recordstring;   
                    }
                }
            }
            
            if(hasErrors)
            {
                List<String> toAddresses = new List<String>(); //email addresses
                //get recipient from custom settings
                Map<String, Error_Notification_Recipient__c> reportMap = Error_Notification_Recipient__c.getAll();
                
                system.debug('---userContIdSuccess---'+assignPermissionSet);
                system.debug('---userContIdSuccesssize---'+assignPermissionSet.size());
                system.debug('---UpdateContId---'+contactIds);
                system.debug('---UpdateContId---'+contactIds.size());
                
                for( User usr : [Select Contact_to_user__c FROM user where Id IN:assignPermissionSet])
                {
                    if(contactIds.contains(usr.Contact_to_user__c))
                    {
                        contactIds.remove(usr.Contact_to_user__c);
                    }
                }
                
                system.debug('---refreshContactIds--'+contactIds);
                system.debug('---refreshContactIds--'+contactIds.size());
                
                for(String str : contactIds) {
                    
                    String Recordstring2;
                    Recordstring2 =str +'\n';
                    system.debug('--abc -->>'+Recordstring2); 
                    
                    //Concatenate the values
                    finalstr2 = finalstr2+Recordstring2;   
                }
                
                //list to have all the key sets
                List<String> strList = new List<String>();
                strList.addAll(reportMap.keySet());
                
                //iterate over strList to fetch the email addresses of report receipents
                for(string receipentName : strList) {
                    Error_Notification_Recipient__c recipientRecord = reportMap.get(receipentName);
                    system.debug('-----custom setting records---'+recipientRecord);
                    string str = recipientRecord.Email__c;
                    system.debug('----email address---'+str);
                    toAddresses.add(str);
                }
                
                //Send email method
                List<Messaging.EmailFileAttachment> efaList = new List<Messaging.EmailFileAttachment>();
                
                Messaging.EmailFileAttachment attach1 = new Messaging.EmailFileAttachment();
                blob excel = blob.valueOf(finalstr);
                attach1.setBody(excel);
                attach1.setFileName('Error Log.csv'); 
                efaList.add(attach1);
                
                Messaging.EmailFileAttachment attach2 = new Messaging.EmailFileAttachment();
                blob excel2 = blob.valueOf(finalstr2);
                attach2.setBody(excel2);
                attach2.setFileName('Error Records.csv'); 
                efaList.add(attach2);
                
                string subject = 'SFDC User Account For Sales Contact - Error Log';
                string body =  'Hi,'+ '<BR>' + '<BR>'+'&nbsp;'+' An error occurred while creating SFDC user account in salesforce for sales contacts. Please find the attached Error log.'+'<BR>' +'Please contact your admin for more details.'+'<BR>'+'<BR>'+ 'Thank you!'+'<BR>'+'Zimmer Biomet Sales';
                
                Messaging.singleEmailMessage Emailwithattch = new Messaging.singleEmailMessage();
                Emailwithattch.setSubject(subject);
                Emailwithattch.setToAddresses(toAddresses);
                Emailwithattch.setHtmlBody(body); 
                Emailwithattch.setFileAttachments(efaList); 
                
                // Sends the email
                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {Emailwithattch});
            }
        }               
        
        //Commenting this code since SF Platform user need no Permissions (14-Feb-2020)
        /*
        PermissionSet pS1 = [SELECT Id FROM PermissionSet where name ='DSA_User'];
        List<PermissionSetAssignment> permissionSetList = new List<PermissionSetAssignment>();
        Set<Id> usersWithAccess = new Set<Id>();
        
        //Rohit Attri: Modified on 01-Mar-2018: Updated Permission Set assignment from DSA Force.com User to DSA_user        
        
        for(PermissionSetAssignment psa : [SELECT AssigneeId FROM PermissionSetAssignment WHERE PermissionSetId =: ps1.ID]) {          
        usersWithAccess.add(psa.AssigneeId); 
        }
        
        system.debug('---userList----'+userList);
        system.debug('---assignPermissionSet---'+assignPermissionSet);
        if(!assignPermissionSet.isEmpty())
        {
        for(string u1 : assignPermissionSet){
        system.debug('----usrId--'+u1);
        if (!usersWithAccess.contains(u1)){
        System.debug('$$$AssigneeId'+u1);               
        //  if(u1.IsActive == True){
        PermissionSetAssignment newPSA = new PermissionSetAssignment(PermissionSetId = pS1.ID, AssigneeId = u1);                
        permissionSetList.add(newPSA);
        //}
        }
        }
        }
        
        
        if (!permissionSetList.isEmpty()) 
        { 
        //if there are records to insert
        System.debug('$$Assigned List$$'+ permissionSetList.size());   
        insert permissionSetList; //insert
        }
        */
    }
    
    Public void sendExceptionEmail(string errMsg, string contId, string conEmail, string fstName, string lstName) 
    {
        List<String> toAddresses = new List<String>(); //email addresses
        //get recipient from custom settings
        Map<String, Error_Notification_Recipient__c> reportMap = Error_Notification_Recipient__c.getAll();
        
        //list to have all the key sets
        List<String> strList = new List<String>();
        strList.addAll(reportMap.keySet());
        
        //iterate over strList to fetch the email addresses of report receipents
        for(string receipentName : strList) {
            Error_Notification_Recipient__c recipientRecord = reportMap.get(receipentName);
            system.debug('-----custom setting records---'+recipientRecord);
            string str = recipientRecord.Email__c;
            system.debug('----email address---'+str);
            toAddresses.add(str);
        }
        
        // Handle exception
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(toAddresses);
        message.optOutPolicy = 'FILTER';
        message.subject = 'SFDC User From Sales Contact: EXCEPTION OCCURRED';
        message.plainTextBody = 'Hi,'+'\n'+'An Exception occurred while creating the SFDC user account for the below Sales Contact.'+'\n'+'\n'+'Record Id:- '+contId+'\n'+'Contact Email:- '+conEmail+'Contact Name:- '+fstName+' '+lstName+'\n'+'\n'+'Error Message:- '+errMsg+'\n'+'\n'+'Please contact your system admin.'+'\n' +'\n'+ 'Thank you!'+'\n'+'Zimmer Biomet Sales';
        
        Messaging.SingleEmailMessage[] messages = 
            new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages); 
    }
}