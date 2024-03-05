/*****************************************************************************/
/* Class name: SurgeonMergeClass                                             */
/* Author: Saikishore R Aengareddy                                           */
/* Last modified: 09/28/2010                                                 */
/* Purpose: Used to provide unit test coverage for SurgeonmMergeClass        */
/*****************************************************************************/

@istest
private class SurgeonMergeTest{

    public static testMethod void testSurgeon() {    
        profile[] UserProfile1 = [Select Id, Name From Profile where name = 'Custom - Data Administrator' limit 1];
        User u1 = new user (Username = ' test@key.net', FirstName = 'FirstTest', LastName ='LastTest', alias = 'FLast', 
                            email='test@key.net', communityNickname='test0101019', TimeZoneSidKey='America/Indiana/Indianapolis',
                            LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', ProfileId=UserProfile1[0].Id ,
                            LanguageLocaleKey='en_US',Region__c='AM', Geography__c='US', Business_Division__c='DN');
        insert u1;
        System.debug('-----SurgeonMergeTest.testSurgeon-u1----- = ' + u1);
        System.RunAs(u1) {
            Account a1 = new Account();
            //String rtId = [select id from RecordType where SObjectType = 'Account' and IsActive = true and Name = 'Physician(processing)'].Id;
            //String rtId = [select id from RecordType where SObjectType = 'Account' and IsActive = true and DeveloperName = ''].Id;
            a1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            a1.Name='test 1';
            
            a1.MDM_SAP_ID__c = '1111100000';
            a1.Refer_To__c = '';
            a1.Refer_To_SFDC_Id__c= '';
            insert a1;
            
            Account a2 = new Account();
            a2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
            a2.Name='test 2';
            
            a2.MDM_SAP_ID__c = '2222200000';
            a2.Refer_To__c = '';
            //Code Change Added By Naveen Chugh For Custom Merge FUnctionality
            a2.Refer_To_SFDC_Id__c= '';
            //Code Change Ends Here
            insert a2;
            
            //Because the merging is asynchronous
            Test.startTest();     
                Merge a1 a2;
            Test.stopTest();
    
    Account[] a =[select id from Account where MDM_SAP_ID__c = '1111100000' all rows];
    
    Account[] unDeletedAcc = [select Refer_To__c,Refer_To_SFDC_Id__c, Deactive_date__c from Account where MDM_SAP_ID__c = '2222200000' all rows];
    //Code Change Added By Naveen Chugh For Custom Merge FUnctionality
    //system.assertequals(a[0].id,unDeletedAcc[0].Refer_To_SFDC_Id__c);
    //Code Change Ends Here
    //system.assertequals('1111100000',unDeletedAcc[0].Refer_To__c);
    //System.assertNotEquals(unDeletedAcc[0].Deactive_date__c,NULL);
    } //end of runAs(u1)
  }
}