@isTest
private class insuranceVerificationTestSuite{

     public Static ApexPages.StandardController insuranceController;
     public Static insuranceVerificationPDFAttacher2 insuranceVerification;
     public static Insurance_Verification__c insurance;
     public Static Account patient;
     
     public Static void createSampleData(){
     
        patient= new Account();
        //ID recordTypeId3 = [select id from RecordType where SObjectType = 'Account' and IsActive = true and Name = 'Consumer'].id;
        ID recordTypeId3 = [select id from RecordType where SObjectType = 'Account' and IsActive = true and DeveloperName = 'Consumer'].id;
        patient.LastName='Account Attendee 1 Test';
        patient.AcctInactive__c= false;
        patient.FirstName='Test';
        patient.RecordTypeId=recordTypeId3;
        patient.MDM_SAP_ID__c='7865';
        patient.PersonMailingCountry='US';
        patient.PersonMailingState='CA';
        patient.PersonMailingStreet='Test1 Line1'+'\n'+'Mailing line2'+'\n'+'Mailing line3';
        patient.PersonMailingCity='LA';
        patient.PersonMailingPostalCode='10106';
        
        insert patient;
        
        insurance = new Insurance_Verification__c();
        //insurance.Name = 'Test Insurance';
        insurance.Patient__c = patient.id;
         insurance.Date_Initiated__c =Date.newInstance(2018, 05, 9);
        insert insurance;
     
     } 

      private Static Void initInsuranceVerification(){
      
       createSampleData();
       //insuranceController = new ApexPages.StandardController(insurance);
       
      
      }
      
      public Static testmethod void insuranceVerificationEmailTest(){
      initInsuranceVerification();
      test.StartTest();
      
          insuranceVerificationPDFAttacher2 insuranceVerification1 = new insuranceVerificationPDFAttacher2(); 
          insuranceVerification1.toEmail = 'naveen.chugh@zimmer.com';
          insuranceVerification1.ccEmail = 'naveen.chugh@zimmer.com';
          Apexpages.currentPage().getParameters().put('id',insurance.id);
          insuranceVerification1.sendEmail();
          insuranceVerification1.ccEmail = 'naveen.chugh@zimme';
          insuranceVerification1.toEmail = 'naveen.chugh@zimom';
          insuranceVerification1.checkRequiredFieldsSave();
          insuranceVerification1.toEmail = '';
          insuranceVerification1.checkRequiredFieldsSave();
      
      test.StopTest();
      
      }


}