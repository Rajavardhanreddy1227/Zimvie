//***************************//
        // Developer  : Hardeep Brar
        // Version    : 1.0
        // Object     : Account
        // Class      : DentalAccountTriggerHandler
        // Trigger    : UpdateDentalAccountOwner
        // Description: When any DN-ACCT-RECORD-TYPE or DN-EU-ACCT-RECORD TYPERecord will be created in Salesforce, then this trigger will update the Account 
        //              Owner for that record, to be same as provided Salesperson ID, if valid user with alias = Salesperson ID exists
        //              in the system.
        //***************************//
        
Public Class DentalAccountTriggerHandler
{
    Public Static Void UpdateAccOwner(List<Account> AccList)   {
        
        Set<String> AliasNames = new Set<String>();
        ID recordTypeId = [select id from RecordType where SObjectType='Account' and Name='DN-ACCT-RECORD-TYPE'].id;
                
        for(Account acc : AccList)   {
            
            if(acc.Salesperson_ID__c != NULL && acc.RecordTypeId == recordTypeId)  {
                AliasNames.Add(acc.Salesperson_ID__c);
                
            }
        }
                        
        List<User> UserList = [SELECT Id,Alias FROM User WHERE Alias =:AliasNames ];
       
            FOR(Account acc : AccList){
                FOR(User usr : UserList){
                    IF(acc.Salesperson_ID__c == usr.Alias) {
                            acc.OwnerId = usr.Id;                 
                            System.Debug('Owner Id Updated');
                    }
                    
                }
            }
        
    }
    
    
    
    Public Static Void UpdateAccOwner2(List<Account> AccList2)   {
        
        Set<String> AliasNames = new Set<String>();
        ID recordTypeId2 = [select id from RecordType where SObjectType='Account' and Name='DN-EU-ACCT-RECORD-TYPE'].id;
                
        for(Account acc2 : AccList2)   {
            
            if(acc2.Salesperson_ID__c != NULL && acc2.RecordTypeId == recordTypeId2)  {
                AliasNames.Add(acc2.Salesperson_ID__c);
                
            }
        }
                        
        List<User> UserList = [SELECT Id,Alias FROM User WHERE Alias =:AliasNames ];
       
            FOR(Account acc2 : AccList2){
                FOR(User usr2 : UserList){
                    IF(acc2.Salesperson_ID__c == usr2.Alias) {
                            acc2.OwnerId = usr2.Id;                 
                            System.Debug('Owner Id Updated');
                    }
                    
                }
            }
        
    }
}