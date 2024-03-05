public with sharing class SurgeonPortalGPLProfile
{
    //private static Id physicianRTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL Physician Profile' );
    //private static Id clinicRTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL Clinic Profile' );
    private static Id physicianRTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_PhysicianProfile' );
    private static Id clinicRTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_ClinicProfile' );
    
    public static GPL_Profile__c buildProfile(Account a)
    {
        GPL_Profile__c p = new GPL_Profile__c();
        p.Account__c = a.Id;
        p.MasterId__c = a.Id;
        p.Procedures__c = a.Technique__c;
        p.Specialties__c = a.Specialty_integration__c;
        p.Devices__c = a.Expertise_Integration_purpose__c;
        p.Languages__c = a.Languages__c;
        p.Middle_Name__c = a.Middle_Name__c;
        if (a.IsPersonAccount)
        {
            p.RecordTypeId = physicianRTypeId;
            p.MedicalSchool__c = a.Medical_School__c;
            p.Fellowship__c = a.Fellowship__c;
            p.Residency__c = a.Residency__c;
        }
        else
        {
            p.RecordTypeId = clinicRTypeId;
        }
        p.Inactive__c=true;
        return p;
    }
    
    public static GPL_Profile__c updateProfile(Account a,GPL_Profile__c p)
    {        
        p.Devices__c = a.Expertise_Integration_purpose__c;
        p.Specialties__c = a.Specialty_integration__c;
        p.Procedures__c = a.Technique__c;
        p.Languages__c = a.Languages__c;
        p.Twitter__c = a.Twitter_ID__c;
        p.Facebook__c = a.Facebook_URL__c;
        p.LinkedIn__c = a.LinkedInURL__c;
        //p.PreferredName__c = a.Preferred_Name__c;
        //p.PreferredName__c = 'test1234';
        p.Middle_Name__c = a.Middle_Name__c;
        if (a.IsPersonAccount)
        {
            p.MedicalSchool__c = a.Medical_School__c;
            p.Fellowship__c = a.Fellowship__c;
            p.Residency__c = a.Residency__c;
        }
        return p;
    }

static testmethod void testProfileBuilder(){
    Id physicianTypeId = RecordTypeHelper.getRecordTypeId('Account', 'Physician');
    System.debug('---------------PTYPEID: ' + physicianTypeID);
    //Id practiceTypeId = RecordTypeHelper.getRecordTypeId('Account', 'Medical Practice');
    Id practiceTypeId = RecordTypeHelper.getRecordTypeId('Account', 'Practice');
    Account doctor = new Account(
      RecordTypeId = physicianTypeId,
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
      Medical_Degree__c = 'MD',
      Medical_School__c = 'Indiana University',
     // Med_Grad_Date__c = date.today(),
      Fellowship__c = 'General Hospital',
    //  Fellowship_Completion_Date__c = date.today()+2,
      Residency__c = 'General Hospital',
    //  Residency_Completion_Date__c = date.today()+1,
      Memberships_Associations_Conferences__c = 'AAOS',
      Awards_Honors_Patents__c = 'Academy Award - Best Doctor',
      Publications_Presentations__c = 'Doctor Weekly 2012',
      Physicians_Locator__c = true
    );
    insert(doctor);
    doctor.RecordTypeId = physicianTypeId;
    update(doctor);    
    
    test.startTest();   
    GPL_Profile__c profile1 = buildProfile(doctor);
    test.stopTest();
  }

}