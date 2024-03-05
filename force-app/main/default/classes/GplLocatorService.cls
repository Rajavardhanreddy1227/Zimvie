global class GplLocatorService {    
    //private static Id CLINIC_RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL Clinic Profile' );
    private static Id CLINIC_RECORD_TYPE_ID = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_ClinicProfile');
    //private static Id physicianRecordTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL Physician Profile' );
    private static Id physicianRecordTypeId = RecordTypeHelper.getRecordTypeId('GPL_Profile__c','GPL_PhysicianProfile');
    private static GplDataManager manager = new GpLDataManager(); 
    
    webservice static list<GplDataModel.PhysicianProfile> searchPhysicians(GplDataModel.SearchCriteria criteria){
        return manager.searchPhysicians(criteria);
    }
    
    //Code added by Goldy on 03-Jun-2013 for Find A Dentist Functionality
    webservice static list<GplDataModel.DentistProfile> searchDentists(GplDataModel.SearchCriteria criteria){
        return manager.searchDentists(criteria);
    }
    //Code Addition Ends Here
    
    webservice static list<GplDataModel.ClinicProfile> searchClinics(GplDataModel.SearchCriteria criteria){
        return manager.searchClinics(criteria);
    }
    webservice static GplDataModel.Photo retrievePhoto(String id){
        return manager.retrievePhoto(id);
    }    
}