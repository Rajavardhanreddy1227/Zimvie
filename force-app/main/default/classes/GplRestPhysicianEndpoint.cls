@RestResource(urlMapping = '/gpl/searchphysicians')
global class GplRestPhysicianEndpoint {
    
    private static GplRestDataManager dataManager = new GplRestDataManager();
    
    @HttpPost
    global static list<GplRestDataModel.Profile> searchPhysicians(GplRestDataModel.Criteria criteria){
        return dataManager.searchPhysicians(criteria);
    }

}