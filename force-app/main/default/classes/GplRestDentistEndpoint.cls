@RestResource(urlMapping='/gpl/searchdentists')
global class GplRestDentistEndpoint {
    
    private static GplRestDataManager dataManager = new GplRestDataManager();
    
    @HttpPost
    global static list<GplRestDataModel.Profile> searchDentists(GplRestDataModel.Criteria criteria){
    	return dataManager.searchDentists(criteria);
    }

}