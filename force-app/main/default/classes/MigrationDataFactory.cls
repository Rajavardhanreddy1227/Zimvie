public class MigrationDataFactory {
    public static Account createPhysician(){
        Id physicianRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Physician')
            .getRecordTypeId();
        Account physician = new Account();
        physician.FirstName = 'Test';
        physician.LastName = 'Test';
        physician.Preferred_Name__c ='test';
        physician.PersonMailingCountry = 'US';
        physician.PersonMailingCity = 'test';
        physician.PersonMailingState = 'MO';
        physician.PersonMailingStreet = 'test';
        physician.PersonMailingPostalCode = '12345';        
        physician.RecordTypeId = physicianRecordTypeId;
        insert physician;
        return physician;
    }
    
    public static GPL_Profile__c createProfile(Account physician){        
        GPL_Profile__c profile = new GPL_Profile__c();
        profile.Account__c = physician.Id;
        profile.GPL_Physician_Locator__c=true;
        profile.Inactive__c=false;
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = GPL_Profile__c.Procedures__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        
        profile.Procedures__c=pickListValuesList.get(0);
        insert profile;
        physician.GPL_Profile__c=profile.Id;
        update physician;
        return profile;
    }
    
    public static Attachment createPhoto(GPL_Profile__c profile){        
        Attachment photo = new Attachment();
        photo.name = 'Test';
        photo.Body = Blob.valueOf('Test');
        photo.ParentId = profile.Id;
        insert photo;
        profile.Picture_Id__c=photo.Id;
        update profile;
        return photo;
    }
    
    public static GPL_Location__c createLocationWithStreetNameAndType(GPL_Profile__c profile,String street,String locationType){   
        GPL_Location__c location = new GPL_Location__c();
        location.GPL_Profile__c = profile.Id;
        location.Name__c='Test Hospital';
        location.Country__c='US';
        location.State__c='MO';
        location.City__c='Test';
        location.PostalCode__c='12345';
        location.Location_Type__c=locationType;
        location.Street__c=street;
        insert location;
        return location;
    }
       
    public static Account createHealthcareWithStreetName(String street){   
        Id healthcareRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
            .get('Healthcare Facility')
            .getRecordTypeId();
        Account healthcare = new Account();
        healthcare.Name = 'Test Hospital 1';
        healthcare.ShippingCountry = 'US';
        healthcare.ShippingCity = 'test';
        healthcare.ShippingState = 'MO';
        healthcare.ShippingStreet = street;
        healthcare.ShippingPostalCode = '12345';
        healthcare.Class__c='002';
        
        healthcare.RecordTypeId = healthcareRecordTypeId;
        insert healthcare;
        return healthcare;
    }
    
    public static Healthcare_Surgeon_Relationship__c createRelationship(Account physician, Account healthcare){           
        Healthcare_Surgeon_Relationship__c relationship = new Healthcare_Surgeon_Relationship__c();
        relationship.Surgeon__c=physician.Id;
        relationship.Healthcare_Facility__c = healthcare.Id;
        insert relationship;
        return relationship;
    }
}