@isTest
private class AccountTeamMemberHandler_Test 
{
    public static Account acc;
    public static Account acc2;
    public static Opportunity newOpp1;
    public static Opportunity newOpp2;
    public static User u;
    public static Id devRecordTypeId;
    
    @testSetup static void setup() {
        
        list<Account> insertAcct = new list<Account>();
        list<AccountTeamMember> insertAcctTeam = new list<AccountTeamMember>();
        list<AccountShare> shareacct = new list<AccountShare>();
        list<UserAccountTeamMember> userAcctTeam = new list<UserAccountTeamMember>();
        
        String teamMemberRole = 'Dental - Inside Sales';
        String accountAccessLevel = 'Edit', opportunityAccessLevel = 'Read', caseAccessLevel = 'Read';
        
        Trigger_Settings__c cs = new Trigger_Settings__c();
        cs.Name = 'AddUsersToPSQueues Trigger';
        cs.Active__c = false;
        insert cs; 
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        
        UserRole role = new UserRole(Name = 'DN Rep');
        
        u = new User(Alias = 'stand', Email='DNuser@testorg.com',
                     EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                     LocaleSidKey='en_US', ProfileId = p.Id,UserRoleId=role.Id,
                     TimeZoneSidKey='America/Los_Angeles', UserName='DNuser@testorg.com');
        insert u;
        
        system.debug('user--->'+u.username);
        
        devRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('DN-ACCT-RECORD-TYPE').getRecordTypeId();
        
        for(Integer i=0;i<200;i++){
            acc = new Account();
            acc.RecordTypeId = devRecordTypeId;
            acc.Name = 'Test DN '+i;
            acc.OwnerId = u.Id;
            acc.Account_Status__c = 'Active';
            insertAcct.add(acc);
        }
        
        insert insertAcct;
        
        // Todo : Query all the above inserted accounts with Clause Name Like%Test DN
        
        List<Account> accLists = [SELECT Id,Name FROM Account WHERE Name LIKE:'%Test DN%']; 
        system.debug('---accLists---'+accLists.size());
        
        
        for(Account acct : accLists) {
            
            //Account acct1 = [select Id, Name from Account where Name=:'Test DN 2' limit 1];
            system.debug('--UserId - >'+u.Id);
            system.debug('--AcctId - >'+acct.Id);
            insertAcctTeam.add(New AccountTeamMember(AccountId =acct.Id, TeamMemberRole = teamMemberRole, UserId= u.Id));
            //shareacct.add(new AccountShare(AccountAccessLevel = 'Edit', OpportunityAccessLevel = 'Read', CaseAccessLevel = 'Read', UserOrGroupId = u.Id, AccountId ='001C000001fb02EIAQ'));
        }
        insert insertAcctTeam;
        //insert shareacct;
    }
    
    
    @isTest static void test1() 
    {
        Id AccRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('DN-ACCT-RECORD-TYPE').getRecordTypeId();
        User thisUser = [SELECT Id, Email, UserName FROM User WHERE UserName =:'DNuser@testorg.com'];
        system.debug('user-----'+thisUser.username);
        system.debug('user-----'+thisUser.id);
        
        // System.runAs() allows mixed DML operations in test context
        //System.runAs(thisUser) {
        // startTest/stopTest block to run future method synchronously
        Test.startTest();      
        
        PageReference pageRef = Page.UpdateAccountTeam;
        pageRef.getParameters().put('id', thisUser.id);
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(thisUser); 
        AccTeamMemberHandler accteam= new AccTeamMemberHandler(sc);
        accteam.updateISRNameOnAccounts();
        
        Test.stopTest();
        
        Account acc3 = [select Id, Name,ISR_Name__c from Account where OwnerId=:thisUser.id limit 1];
        system.debug('----acc3---->'+acc3);
        system.debug('----acc3---->'+acc3.ISR_Name__c);
        system.assertEquals(thisUser.Id, acc3.ISR_Name__c);
        
        //}
    }
}