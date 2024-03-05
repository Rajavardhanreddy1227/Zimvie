//***************************//
        // Developer  : Hardeep Brar
        // Version    : 1.0
        // Object     : Account
        // Class      : DentalAccountTriggerHandler
        // Trigger    : UpdateDentalAccountOwner
        // Description: When any DN-ACCT-RECORD-TYPE Record will be created in Salesforce, then this trigger will update the Account 
        //              Owner for that record, to be same as provided Salesperson ID, if valid user with alias = Salesperson ID exists
        //              in the system.
        //***************************//
        
@isTest (seeAllData=false)
private class DentalAccountTriggerHandlerTest{

            private static testmethod void basic()
            {
               Test.startTest(); 
              
                Account accountTest = new Account();
                ID recordTypeIdTemp = [select id from RecordType where SObjectType='Account' and Name='DN-ACCT-RECORD-TYPE'].id;
                accountTest.Name='Test Account'; 
                accountTest.RecordTypeId=recordTypeIdTemp;
                accountTest.Salesperson_ID__c='RMC';
                accountTest.BillingCountry='US';
                accountTest.BillingState='CA';
                accountTest.BillingStreet='Test Line1'+'\n'+'Mailing line2'+'\n'+'Mailing line3';
                accountTest.Distributor_Name__c='Test Distributor Name';
                accountTest.Territory_Number__c='9999';
                accountTest.Phone='9999-9999-00';
                
                insert accountTest;
               
                System.debug('Created new DN-ACCT-RECORD-TYPE Account');
               
               Test.stoptest();
        
            }
    
    private static testmethod void acctest()
            {
               Test.startTest(); 
                Account accountTest2 = new Account();
                ID recordTypeIdTemp2 = [select id from RecordType where SObjectType='Account' and Name='DN-EU-ACCT-RECORD-TYPE'].id;
                accountTest2.Name='Test Account2'; 
                accountTest2.RecordTypeId=recordTypeIdTemp2;
                accountTest2.Salesperson_ID__c='TUS';
                //accountTest2.BillingCountry='US';
                //accountTest2.BillingState='CA';
                //accountTest2.BillingStreet='Test Line1'+'\n'+'Mailing line2'+'\n'+'Mailing line3';
                //accountTest2.Distributor_Name__c='Test Distributor Name';
                //accountTest2.Territory_Number__c='9999';
                //accountTest2.Phone='9999-9999-00';
                insert accountTest2;
                
                System.debug('Created new DN-EU-ACCT-RECORD-TYPE Account');
               
               Test.stoptest();
        
            }
}