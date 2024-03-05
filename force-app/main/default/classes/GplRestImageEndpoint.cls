@RestResource(urlMapping = '/gpl/image/*')
global class GplRestImageEndpoint {

    private static GplRestDataManager manager = new GplRestDataManager();
    
    @HttpGet
    global static void searchImage(){    	
    	RestRequest request = RestContext.request;
    	RestResponse response = RestContext.response;
    	String photoID = request.requestURI.substring(request.requestURI.lastIndexOf('/')+1);
    	GplRestDataModel.Photo p =  manager.retrievePhoto(photoID);
    	String contentType = p.contentType;
    	response.addHeader('Content-Type', contentType);
    	response.responseBody = p.body;
    }
}