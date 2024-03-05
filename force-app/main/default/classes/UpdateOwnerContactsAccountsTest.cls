@isTest
private class UpdateOwnerContactsAccountsTest { 
    
    @testSetup static void setup() {
        
        Trigger_Settings__c cs = new Trigger_Settings__c();
        cs.Name = 'AddUsersToPSQueues Trigger';
        cs.Active__c = true;
        insert cs;
    }
    
    public static User user_admin{
        
        get{
            if(user_admin == null){
                Profile p = [SELECT Id FROM profile WHERE name='System Administrator'];
                user_admin = new User(alias = 'uA1', email='uA1@testorg.com',
                                      emailencodingkey='UTF-8', lastname='Testing', 
                                      languagelocalekey='en_US',IsActive=true,
                                      localesidkey='en_US', profileid = p.Id,Bulletin_Board__c=true,
                                      timezonesidkey='America/Los_Angeles',username='uA1@testorg.com');
                insert user_admin;
                
            }
            return user_admin;
        }
        set;
    }
    
    public static User user_admin2{
        
        get{
            if(user_admin2 == null){
                Profile p = [SELECT Id FROM profile WHERE name='System Administrator'];
                user_admin2 = new User(alias = 'uA2', email='uA2@testorg.com',
                                       emailencodingkey='UTF-8', lastname='UserA', 
                                       languagelocalekey='en_US',IsActive=true,
                                       localesidkey='en_US', profileid = p.Id,Bulletin_Board__c=true,
                                       timezonesidkey='America/Los_Angeles',username='uA2@testorg.com');
                insert user_admin2;
                
            }
            return user_admin2;
        }
        set;
    }
    
    
    
    static testMethod void testUpdateOwnerContactsAccTrigger() {
        Account A= new Account();
        A.Name = 'TestA';
        //NewD.CurrencyIsoCode = 'USD - U.S.Dollar';
        //NewD.Bulletin_Board_Date__c = Now();
        A.OwnerId = User_admin.Id;
        insert A;
        Contact C= new Contact();
        C.LastName = 'TestC';
        C.OwnerId = user_admin2.Id ;
        C.AccountId = A.Id ;
        //C.CurrencyIsoCode = 'USD - U.S.Dollar';
        //NewD.Bulletin_Board_Date__c = Now();
        //A.OwnerId = User_admin.Id;
        insert C;
        A.OwnerId = User_admin2.Id;
        Update A;
        System.AssertEquals(C.OwnerId, A.OwnerId );
    }
    
}