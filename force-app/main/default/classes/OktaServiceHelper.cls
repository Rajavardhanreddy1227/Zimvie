public without sharing class OktaServiceHelper {

   @AuraEnabled
    public static Map<String,Object> toggleUserActivation(Map<String,Object> requestParam){
       System.debug('toggleUserActivation-----');
       System.debug('Request Paramter---------');
       System.debug(requestParam);        
        Map<String,Object> responseParam = new Map<String,Object>();
        if(requestParam.containsKey('userId') && requestParam.get('userId') != null
          && requestParam.containsKey('deactivateLink') && requestParam.get('deactivateLink') != null
          && requestParam.containsKey('action') && requestParam.get('action') != null){
            
              String action = (String)requestParam.get('action');
              String deactivateLink = (String)requestParam.get('deactivateLink');
              Http http = new Http();
              HttpRequest request = new HttpRequest();
              if(action == 'deactivate'){
                 request.setEndpoint(deactivateLink); 
              }else if(action == 'activate'){
                 String reactivateLink =  deactivateLink.replace('/deactivate', '/activate');
                 request.setEndpoint(reactivateLink); 
              }
              
              request.setHeader('Acccept','application/json');
              request.setHeader('Content-Type','application/json');
              request.setHeader('Authorization','SSWS00WzdhHqNoS4sJx0sB5h5vtUQL0GiuO_oorOtbz-rV');
              request.setMethod('POST');
              
              System.debug('request '+ request);        
        	  HttpResponse response = http.send(request);
              System.debug('response '+ response);
         	  System.debug('results '+ response.getBody());
              
              //Inactivate SF User
              User u = new User();
              u.Id = (String)requestParam.get('userId');
              
              if(action == 'deactivate'){
                u.IsActive = false;  
              }else if(action == 'activate'){
                  u.IsActive = true; 
              }
              
              update u;
        
        }
        
        return responseParam;
    }
}