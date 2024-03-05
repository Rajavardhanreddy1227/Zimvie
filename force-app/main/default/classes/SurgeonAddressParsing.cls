/*****************************************************************************/
/* Class name: SurgeonAddressParsing                                        */
/* Author: Saikishore R Aengareddy                                          */
/* Last modified: 10/29/2010                                                */
/* Purpose: Used to provide unit test coverage for SurgeonAddressParsing    */
/****************************************************************************/

@istest
private class SurgeonAddressParsing{

    public static testMethod void AddressParsingtest() {    
        
            Account a1 = new Account();
            //String rtId = [select id from RecordType where SObjectType = 'Account' and IsActive = true and Name = 'Physician(processing)'].Id;
            //String rtId = [select id from RecordType where SObjectType = 'Account' and IsActive = true and DeveloperName = 'Physician_Processing'].Id;
            //Modified by RA : Modified Record Tpe from Physician Processing to Physician because Physician Processing Record type is deleted from production
            String rtId = [select id from RecordType where SObjectType = 'Account' and IsActive = true and DeveloperName = 'Physician'].Id;
            a1.RecordTypeId = rtId;
            a1.LastName = 'TEST ACCOUNT1';
            a1.FirstName='test 1';
            a1.PersonMailingCountry = 'US';  
            a1.PersonMailingState='AK';
            a1.PersonMailingStreet ='Test street one dr' + '\n' + 'Mailing line 2' + '\n' + 'Mailing Line 3' ;
            a1.PersonOtherStreet ='Test street one dr' + '\n' + 'Other line 2' + '\n' + 'Other Line 3' ;
            a1.PersonOtherCountry = 'US';  
            a1.PersonOtherState='AK';
            a1.PersonMailingPostalCode='12345';
            a1.PersonMailingCity ='NY';
            a1.MDM_SAP_ID__c = '1111100000';
            a1.Refer_To__c = '';
            insert a1;
                                
   }
}