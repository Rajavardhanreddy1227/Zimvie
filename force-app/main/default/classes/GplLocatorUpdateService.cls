global class GplLocatorUpdateService {
    
    private static GplDataManager manager = new GpLDataManager(); 
    
    webservice static void updatePhysician(GplDataModel.PhysicianProfile physician, GplDataModel.Photo photo, GplDataModel.Photo pdf, String username) {
        manager.updatePhysician(physician, photo, pdf, username);
    }   
}