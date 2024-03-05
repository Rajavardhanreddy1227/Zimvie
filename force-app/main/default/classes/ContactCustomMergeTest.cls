/*****************************************************************************/
/* Class name: ContactCustomMergeClass                                             */
/* Author: Naveen Chugh                                                      */
/* Last modified: 09/02/2011                                                 */
/* Purpose: Used to provide unit test coverage for ContactCustomMergeClass   */
/*****************************************************************************/

@istest
private class ContactCustomMergeTest{
    
    @testsetup
        public static void TestCustom(){
            
            Trigger_Settings__c cs = new Trigger_Settings__c();
            cs.Name = 'AddUsersToPSQueues Trigger';
            cs.Active__c = true;
            insert cs;
        } 

    public static testMethod void testContactMerge() 
    {   
        /************************************************************************************************
          Purpose: This method provides the test coverage for the Custom Merge Functionalty
                   designed fot Contacts 
          Parameters: None
          Returns: None
          ***********************************************************************************************/  
        
        //Creating the test user
        profile UserProfile1 = [Select Id, Name From Profile where name = 'Custom - Data Administrator' limit 1];
        User userx = new user (Username = 'testx@key.net', FirstName = 'FirstTestx', LastName ='LastTestx', alias = 'FLast', 
                            email='testx@key.net', communityNickname='test0101019', TimeZoneSidKey='America/Indiana/Indianapolis',
                            LocaleSidKey='en_US', EmailEncodingKey='ISO-8859-1', ProfileId=UserProfile1.Id ,
                            LanguageLocaleKey='en_US',Region__c='AM', Geography__c='US', Business_Division__c='DN');
        insert userx;
        
        
        System.debug('-----SurgeonMergeTest.testSurgeon-userx----- = ' + userx);
        //Logging into the System as User userx
        System.RunAs(userx) {
            //Creating Contact 1 that would be used in custom Contact Merge Functionality 
            Contact contact1 = new Contact();
            //String rtId = [select id from RecordType where SObjectType = 'Contact' and IsActive = true and Name = 'Zimmer Standard Contact'].Id;
            String rtId = [select id from RecordType where SObjectType = 'Contact' and IsActive = true and DeveloperName = 'Zimmer_Standard_Contact'].Id;
            contact1.RecordTypeId = rtId;
            contact1.LastName = 'TEST CONTACT1';
            //contact1.Name = 'TEST';
            contact1.Refer_To_SFDC_Id__c= '';
            insert contact1;
            
            //Creating Contact 2 that would be used in custom Contact Merge Functionality 
            Contact contact2 = new Contact();
            contact2.RecordTypeId = rtId;
            contact2.LastName = 'TEST CONTACT2';
            //contact1.Name = 'TEST';
            contact2.Refer_To_SFDC_Id__c= contact1.id;
            insert contact2;
            
            //Because the merging is asynchronous
            Test.startTest();     
                Merge contact1 contact2;
            Test.stopTest();
    
    Contact[] contactList =[select id from Contact where LastName = 'TEST CONTACT1' all rows];
    Contact[] unDeletedContact = [select Refer_To_SFDC_Id__c from Contact where LastName = 'TEST CONTACT2' all rows];
    
    //Test Case: The refer To SFDC Unique Id field of the undeleted account has been populated with the id of the master Contact
         System.debug('Contact 1 id = ' + contactList[0].id + ' Conatct 2 refer to id = '+unDeletedContact[0].Refer_To_SFDC_Id__c );
    system.assertequals(contactList[0].id,unDeletedContact[0].Refer_To_SFDC_Id__c);

    } //end of runAs(userx)
  }
}