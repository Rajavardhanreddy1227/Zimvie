@RestResource(urlMapping='/gpl/searchclinics')
global class GplRestClinicEndpoint {
    
    private static GplRestDataManager dataManager = new GplRestDataManager();
    
    @HttpPost
    global static list<GplRestDataModel.Profile> searchClinics(GplRestDataModel.Criteria criteria){
    	return dataManager.searchClinics(criteria);
    }
	
}