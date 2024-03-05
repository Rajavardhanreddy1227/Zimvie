public class AccountShareHandler {

    //
    // signature methods

    // handle updated rows
    public static void beforeUpdate(Account[] oldRows, Account[] newRows) {
        // init
        List<Id> accIds = new List<Id>();
        for(Account acc : newRows) accIds.add(acc.Id);
        
        // calc old shares
        List<Id> accssOld = new List<Id>();
        For(AccountShare accs : 
                [ select Id FROM AccountShare 
                    WHERE (AccountId in :accIds) AND (LastModifiedBy.Username LIKE 'sapadminprod@zimmer.com%')
                    AND RowCause in ( 'Manual', 'Owner' ) AND AccountAccessLevel in ( 'Edit', 'All' )    
                ])
            accssOld.add(accs.Id);
        
        // calc new shares
        List<AccountShare> accssNew = new List<AccountShare>();
        Map<Id, Id> acc2OwnerMap = new Map<Id, Id>();
        for(SalesareaAccountRole__c sar : 
                [ SELECT AccountId__c, SalesTeamMemberId__r.UserId__c FROM SalesareaAccountRole__c 
                    WHERE AccountId__c in :accIds AND SalesTeamMemberId__r.UserId__c <> '' 
                ]) {
            // process share obj
            AccountShare accs = new AccountShare( AccountId=sar.AccountId__c, UserOrGroupId=sar.SalesTeamMemberId__r.UserId__c, 
                AccountAccessLevel='Edit', OpportunityAccessLevel='Edit', CaseAccessLevel='Edit' );
            accssNew.add(accs);
            // process ownership
            if ( acc2OwnerMap.get(sar.AccountId__c) == null )
                acc2OwnerMap.put(sar.AccountId__c, sar.SalesTeamMemberId__r.UserId__c); 
        }
        
        // remove old share
        System.debug( '*** accssOld: '+accssOld.size() );
        if (accssOld.size()>0) logDbErrors( Database.delete(accssOld, false), '*** accssOld' );
        
        // set account owner
        for(Account newRow : newRows) {
            Id userId = acc2OwnerMap .get(newRow.Id);
            if ( userId != null ) newRow.OwnerId = userId;
        }
        
        // insert new share - false for partial processing
        System.debug( '*** accssNew: '+accssNew.size() );
        if (accssNew.size()>0) logDbErrors( Database.insert(accssNew, false), '*** accssNew' );
    }
    
    
    //
    // help methods
    
    private static void logDbErrors(Database.SaveResult[] lsr, String title) {
        for(Database.SaveResult sr : lsr) {
            if ( sr.isSuccess() ) continue;
            System.debug( title +': '+ sr.getErrors()[0].getMessage()  );  
        }
    }
    
    private static void logDbErrors(Database.DeleteResult[] ldr, String title) {
        for(Database.DeleteResult dr : ldr) {
            if ( dr.isSuccess() ) continue;
            System.debug( title +': '+ dr.getErrors()[0].getMessage()  );  
        }
    }
    
    
    //
    // testing methods
    
    static testMethod void testAccountShareTriggers() {
        
        Account ac = new Account();
        ac.Name='NewAcc';
        ac.SapId__c = '';
        insert ac;
        
        // retrieve a user
        User usr = [ SELECT Id, eMail, Lastname, Firstname FROM User WHERE IsActive = True LIMIT 1 ];
        // retrieve an account
        Account acc = [ SELECT Id, SapId__c, SalesAreaId__r.SapId__c,BillingCountry FROM Account WHERE sapId__c <> '' LIMIT 1 ];
        String sapPrefix = acc.SapId__c.substring(0,8);
        String sorg = 'B001';
        
        // create sales team member
        SalesTeamMember__c stm = new SalesTeamMember__c( sapId__c=sapPrefix+'4711', Name=usr.Lastname+' '+usr.Firstname+' - 4711', eMail__c=usr.eMail, UserId__c=usr.Id );
        insert stm;
        // create a Y* role
        String accRoleSapId = acc.SapId__c + sorg +'#Y2#4711';
        SalesareaAccountRole__c accRole = new SalesareaAccountRole__c( SapId__c=accRoleSapId , Name=accRoleSapId , AccountId__c=acc.Id, SalesTeamMemberId__c=stm.id, RoleCode__c ='Y2' );
        insert accRole;
        
        // update account
        //acc.SapShareUpdate__c = True;
        acc.BillingCountry='US';
        acc.BillingState='CA';
        acc.BillingStreet='Test Line1'+'\n'+'Mailing line2'+'\n'+'Mailing line3';
        acc.Distributor_Name__c='Test Distributor Name';
        acc.Territory_Number__c='9999';   
        update acc;
    }

}