@isTest (seeAllData=false)
private class UpdateAccountInfoOnDealsDNAnalyticsTest{

            private static testmethod void basic()
            {
               Test.startTest(); 
                Account accountTest = new Account();
                ID recordTypeIdTemp = [select id from RecordType where SObjectType='Account' and Name='DN-ACCT-RECORD-TYPE'].id;
                accountTest.Name='Test Account'; 
                accountTest.RecordTypeId=recordTypeIdTemp;
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
}