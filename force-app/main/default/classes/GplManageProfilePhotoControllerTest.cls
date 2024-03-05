@isTEst
public class GplManageProfilePhotoControllerTest {
    static PageReference pageRef;
   	 private static Id CLINIC_RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_ClinicProfile');
  
    private static Id physicianRecordTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_PhysicianProfile');
    
      static testmethod void testGplManageProfilePhotoController(){
        Id personAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','Physician');                
        Id physicianRTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_PhysicianProfile');
          
            Account personAccounts = new Account(
                RecordTypeId = personAccountTypeId,
                FirstName = 'Test',
                LastName = 'Doctor',
                PersonMailingStreet = 'TEST 789 Maple St',
                PersonMailingCity = 'Puerto Villamil',
                PersonMailingState = 'EC',
                PersonMailingPostalCode = 'EC012001',
                PersonMailingCountry = 'EC',
                MDM_SAP_ID__c = '9999999',
                Specialty_integration__c = 'Knee',
                Technique__c = 'MIS',
                Expertise_Integration_purpose__c = 'Gender Knee',
                Physicians_Locator__c = true
            );     
      
        insert personAccounts;
         
       
            GPL_Profile__c profiles = new GPL_Profile__c(
                Account__c = personAccounts.Id,
                MasterId__c = personAccounts.Id,
                RecordTypeId = physicianRTypeId,
                Devices__c = 'Kinectiv',
                Groups__c = 'AAOS',
                Honors__c = 'Man of the Year (2011)',
                Publications__c = 'How to replace a knee (Doctor Review - May 2011)',
                Specialties__c = 'Knee',
                Procedures__c = 'MIS',
                Languages__c = 'English',
                Facebook__c = 'http://www.facebook.com',
                Twitter__c = 'http://www.twitter.com',
                LinkedIn__c = 'http://www.linkedin.com',
                YouTube__c = 'http://www.youtube.com'
            );
           
        
        insert profiles;
          System.debug('%%%%%' + profiles.id);
           
        
		pageRef = new PageReference('/apex/GplManageProfilePhotoPageVF?id=profiles.Id');   
		Test.setCurrentPage(pageRef);  
		pageRef.getParameters().put('id', profiles.Id); 
        Attachment attach=new Attachment();       
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId=profiles.id;
        
       
        
        List<Attachment> attachments=[select id, name from Attachment where parent.id=:profiles.id];
        System.assertEquals(0, attachments.size());
        
       ApexPages.StandardController stdCtr = new ApexPages.StandardController(profiles);
        
         GplManageProfilePhotoController ctr = new GplManageProfilePhotoController(stdCtr);
          ctr.photo.parentId = profiles.id;
          ctr.photo= attach;
    
        ctr.savePhoto(); 
        
        pageRef = ctr.savePhoto(); 
    }
}