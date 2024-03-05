@isTest (seeAllData=false)
private class DNGlobalContactOwnerDataTest{

            private static testmethod void basic(){
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
                insert accountTest;
                
                System.debug('Created new Account');
                Contact Con = New Contact();
                Con.LastName = 'TEST CONTACT1';
                RecordType RecType =([ SELECT Id from RecordType where Name = 'DN-Global-Contact Record Type' and SobjectType = 'Contact']);
                Con.RecordTypeId= RecType.Id; 
                //[select id from RecordType where SObjectType='Contact' and Name='DN_Global_Contact_Record_Type'].id;
                Con.AccountId= accountTest.id;
               
                Insert Con;
                System.debug('Created new Contact');
               Test.stoptest();
        
            }
}