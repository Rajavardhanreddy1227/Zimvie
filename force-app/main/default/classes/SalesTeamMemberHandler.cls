public class SalesTeamMemberHandler {


  
    //
    // signature methods
    
    // hndle inserted rows
    public static void beforeInsert(SalesTeamMember__c[] newRows) {
    /*
        SalesTeamMember__c[] rowsToProcess = new SalesTeamMember__c[]{};
        for(SalesTeamMember__c newRow : newRows) {
            String newEmail = ( newRow.eMail__c == null )? '' : newRow.eMail__c.toLowerCase();
            if ( newEmail != '' )
                rowsToProcess.add(newRow);
        }
        connectToUser(rowsToProcess);
        */
    }
    
    // handle updated rows
    public static void beforeUpdate(SalesTeamMember__c[] oldRows, SalesTeamMember__c[] newRows) {
        /*
        SalesTeamMember__c[] rowsToProcess = new SalesTeamMember__c[]{};
        for(Integer i = 0; i < oldRows.size(); i++) {
            SalesTeamMember__c oldRow = oldRows[i];
            SalesTeamMember__c newRow = newRows[i];
            String oldEmail = ( oldRow.eMail__c == null )? '' : oldRow.eMail__c.toLowerCase();
            String newEmail = ( newRow.eMail__c == null )? '' : newRow.eMail__c.toLowerCase();
            if ( newEmail == '' ) {
                newRow.UserId__c = null;
            } else if ( newEmail != oldEmail ) {
                newRow.UserId__c = null;
                rowsToProcess.add(newRow);
            }
        }
        connectToUser(rowsToProcess );
        */
    }
    
    
    //
    // help methods
    
    public static void connectToUser(SalesTeamMember__c[] rows) {
    
    /*
        // build email2user map
        Map<String, User> email2userMmap = new Map<String, User>();
        for(User userRow : [select id, email, username from User where IsActive = true]) {
            String email = userRow.email.toLowerCase();
            String email2 = chopSuffix( email, '.' );
            if ( email2userMmap.get(email) == null )
                email2userMmap.put(email, userRow); 
            if ( email2userMmap.get(email2) == null )
                email2userMmap.put(email2, userRow); 
        }
        
        // connect sales team members to SFDC user objects
        for(SalesTeamMember__c row : rows) {
            User userRow = email2userMmap.get(row.eMail__c.toLowerCase());
            if ( userRow != null )
                row.UserId__c = userRow.Id;
            else row.UserId__c = null;
        }
        */
    }
    
   /* public static String chopSuffix(String s, String marker) {
    
        if ( s == null || marker == null ) return '';
        Integer pos = s.lastIndexOf(marker);
        return (pos == -1)? s : s.substring(0, pos);
    
    }
    */
    
    //
    // testing methods
    
    static testMethod void testSalesTeamMemberTriggers() {    
        /*
        // retrieve a user
        User[] usr = [ SELECT Id, eMail, Lastname, Firstname FROM User WHERE IsActive = True LIMIT 2 ];
        if ( usr.size() < 2 ) return;
        
        // create sales team member
        String sapPrefix = 'SOQ#100#';
        SalesTeamMember__c stm = new SalesTeamMember__c( sapId__c=sapPrefix+'4711', Name=usr[1].Lastname+' '+usr[1].Firstname+' - 4711', eMail__c=usr[1].eMail );
        insert stm;
        stm.sapId__c = sapPrefix+'0815';
        stm.Name = usr[0].Lastname+' '+usr[0].Firstname+' - 0815';
        stm.eMail__c = usr[0].eMail;
        update stm;
        stm.eMail__c = '';
        update stm;
        */
    }
   
}