//***************************//
// Developer : Dave Ankit
// Version : 1.0
// Object : EmailMessage
// Trigger : EmailDataCopy
//***************************//

public class EmailDataRetrive {
    
    
    public static void EmailCopier (list<EmailMessage> emList){
        string emailmessages;
        set<string> Data = new set<String>();
        list<Case> UpdateCases = new list<Case>(); 
        map<id,list<EmailMessage>> emailMap = new map<id,list<EmailMessage>>();
        
        for(EmailMessage em : emList)
        {
            if(emailMap.containsKey(em.ParentId)){
                emailMap.get(em.ParentId).add(em);
            }
            else{
                list<EmailMessage> templist = new list<EmailMessage>();
                templist.add(em);
                emailMap.put(em.ParentId,templist);
            }
        }
        
       for(case c: [select id, Email_Data__c from Case where id in :emailMap.keySet()]){
            
           if(c.Email_Data__c != null && c.Email_Data__c.contains(' ')) Data = new set<String>(c.Email_Data__c.split(' '));
           else if (c.Email_Data__c != null && !c.Email_Data__c.contains(' ')){ Data = new set<String>(); data.add(c.Email_Data__c);}
            emailmessages = null;           
            for(EmailMessage copyEm : emailMap.get(c.Id)){
                if(copyEm.ToAddress != null && (!data.contains(copyEm.ToAddress))) emailmessages = copyEm.ToAddress;
                if(copyEm.CcAddress != null && (!data.contains(copyEm.CcAddress))) emailmessages = emailmessages + ' ' +copyEm.CcAddress;
                if(copyEm.BccAddress != null && (!data.contains(copyEm.BccAddress))) emailmessages = emailmessages + ' ' +copyEm.BccAddress;
            }
           
           c.Email_Data__c = c.Email_Data__c + ' ' + emailmessages;
           updateCases.add(c);
        }
        
        list<Database.SaveResult> Result = database.update(updateCases,false);
    }
}