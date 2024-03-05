global class GplProfileBuilder {
    //private static Id physicianRTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL Physician Profile' );
    //private static Id clinicRTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL Clinic Profile' );
    //private static Id hospitalRTypeId = RecordTypeHelper.getRecordTypeId('Account','Healthcare Facility');
        private static Id physicianRTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_PhysicianProfile' );
        private static Id clinicRTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_ClinicProfile' );
        private static Id dentistRTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_DentistProfile' );
        private static Id hospitalRTypeId = RecordTypeHelper.getRecordTypeId('Account','HealthcareFacility');
    
    public static GPL_Profile__c buildProfile(Account a){
    GPL_Profile__c p = new GPL_Profile__c();
    p.Account__c = a.Id;
    p.MasterId__c = a.Id;
        p.Devices__c = a.Expertise_Integration_purpose__c;
        p.Specialties__c = a.Specialty_integration__c;
        p.Procedures__c = a.Technique__c;
        p.Languages__c = a.Languages__c;
    if (a.IsPersonAccount == true){
      p.RecordTypeId = physicianRTypeId;
     // p.MedicalSchool__c = formatMedicalSchool(a.Medical_Degree__c, a.Medical_School__c, a.Med_Grad_Date__c);
     // p.Fellowship__c = formatResOrFellow(a.Fellowship__c, a.Fellowship_Completion_Date__c);
     // p.Residency__c = formatResOrFellow(a.Residency__c, a.Residency_Completion_Date__c);
           p.Groups__c = a.Memberships_Associations_Conferences__c;
          p.Honors__c = a.Awards_Honors_Patents__c;
          p.Publications__c = a.Publications_Presentations__c;
    } else {
      p.RecordTypeId = clinicRTypeId;
    }
    return p;
  }
  public static GPL_Profile__c buildProfile(Contact c){
    GPL_Profile__c p =  new GPL_Profile__c();
    p.Contact__c = c.Id;
    p.MasterId__c = c.Id;
    p.RecordTypeId = dentistRTypeId;
    p.Specialty_Type__c=c.Specialty_Type__c;
    //p.Languages__c = c.Language__c;
    return p;
  }
    
  public static GPL_Location__c buildLocation(Account a){
    GPL_Location__c l = new GPL_Location__c();
    l.City__c = a.ShippingCity;
    l.Country__c = a.ShippingCountry;
    l.Fax__c = a.Fax;
    l.Name__c = a.Name;
    l.Phone__c = a.Phone;
    l.PostalCode__c = a.ShippingPostalCode;
    l.Street__c = a.ShippingStreet;
    l.State__c = a.ShippingState;
    l.Website__c = a.Website;
    if (a.RecordTypeId == hospitalRTypeId){
      l.Location_Type__c = 'Hospital';
    } else {
      l.Location_Type__c = 'Practice';
    }
    return l;
  }
  
  public static GPL_Location__c buildLocation(Contact c){
    GPL_Location__c l = new GPL_Location__c();
    l.City__c = c.MailingCity;
    l.Country__c = c.MailingCountry;
    l.Fax__c = c.Fax;
    l.Name__c = c.Name;
    l.Phone__c = c.Phone;
    l.PostalCode__c = c.MailingPostalCode;
    l.Street__c = c.MailingStreet;
    l.State__c = c.MailingState;
    l.Website__c = c.Website__c;    
    l.Location_Type__c = 'Practice';
    return l;
  }
  
  
  private static String formatMedicalSchool(String degree, String school, String year){
    String out = '';
    if (degree != null && degree.length() > 0){
      out = degree;
    }
    if (school != null && school.length() > 0){
      if (out.length() > 0){
        out = out + ', ';
      }
      out = out + school;
    }
    if (year != null && year.length() > 0){
      out = out + ' (' + year + ')';
    }
    return out;
  }
  private static String formatResOrFellow(String institution, String year){
    String out = '';
    if (institution != null && institution.length() > 0){
      out = out + institution;
    }
    if (year != null && year.length() > 0){
      out = out + ' (' + year + ')';
    }
    return out;
  }
  
  static testmethod void testProfileBuilder(){
    Id physicianTypeId = RecordTypeHelper.getRecordTypeId('Account', 'Physician');
    System.debug('---------------PTYPEID: ' + physicianTypeID);
    //Id practiceTypeId = RecordTypeHelper.getRecordTypeId('Account', 'Medical Practice');
    Id practiceTypeId = RecordTypeHelper.getRecordTypeId('Account', 'Practice');
  //  Id DNCAAccountTypeId = RecordTypeHelper.getRecordTypeId('Account', 'DN_CA_Account_Record_Type');
  
        Id DNCAAccountTypeId = RecordTypeHelper.getRecordTypeId('Account','DN_EU_Ghost_Account');
      
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
    System.debug('---------------PTYPEID: ' + doctor.RecordTypeID);
    Account practice = new Account(
      RecordTypeId = practiceTypeId,
      Name = 'TEST Medical Practice ', 
      ShippingStreet = 'TEST 123 Maple St',
      ShippingCity = 'Puerto Villamil',
      ShippingState = 'EC',
      ShippingPostalCode = 'EC012001 ',
      ShippingCountry = 'EC',
      Phone = '123-456-7810',
      Fax = '987-654-3210',
      Website = 'http://www.google.com'
    );
    insert(practice);
    Account DNCAAccount=new Account(Name='DENTIST LOCATOR TEST1', RecordTypeId=DNCAAccountTypeId);
    insert (DNCAAccount);
    Contact DNCAContact = new Contact (
      FirstName = 'Test',
      LastName = 'Doctor',
      Language__c = 'English',
      MailingCity='Puerto Villamil',
      MailingCountry='EC',
      Fax='987-654-3210',
      AccountId=DNCAAccount.Id,
      Phone='123-456-7810',
      MailingPostalCode='EC012001',
      MailingStreet='TEST 123 Maple St',
      MailingState='EC',
      Website__c='http://www.google.com'    
    );
    insert(DNCAContact);
    Contact contact = new Contact (
      FirstName = 'Test',
      LastName = 'Doctor',
      Language__c = 'English'
    );
    insert(contact);
    test.startTest();
    GPL_Profile__c profile2 = buildProfile(contact);
    GPL_Location__c loc = buildLocation(practice);
    GPL_Profile__c profile1 = buildProfile(doctor);
    GPL_Location__c loc2 = buildLocation(DNCAContact);
    test.stopTest();
  }
  
}