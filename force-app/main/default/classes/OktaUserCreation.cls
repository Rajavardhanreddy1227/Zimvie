global class OktaUserCreation {
    @InvocableMethod
    global static List<OktaUserCreationResponse> sendUserCreation(List<OktaUserCreationRequest> requests){
        List<OktaUserCreationResponse> results = new List<OktaUserCreationResponse>();
        for (OktaUserCreationRequest request : requests){
            results.add(sendUserCreation(request));
        }
        return results;
    } 
    
    public static OktaUserCreationResponse sendUserCreation(OktaUserCreationRequest oktaUserRequest)
    {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint('https://zimvie-oktatest.oktapreview.com/api/v1/users?activate=true');
        request.setHeader('Acccept','application/json');
         request.setHeader('Content-Type','application/json');
         request.setHeader('Authorization',System.Label.OKTA_AUTHORIZATION_ID);
        request.setMethod('POST');
        
        Contact c = oktaUserRequest.contact;
        Account a = oktaUserRequest.account;
     
           
   
        JSON2ApexOktaUser jsonU = new JSON2ApexOktaUser();
        JSON2ApexOktaUser.Profile pro = new JSON2ApexOktaUser.Profile();
        pro.firstName = c.FirstName;
        pro.lastName = c.LastName;
        pro.email = c.Email;
        pro.login = c.Email;
        pro.mobilePhone = c.MobilePhone;
        pro.customerNumber = a.Customer_Number__c;
        jsonU.Profile = pro;
        List<String> groupIds = new List<String>();
        groupIds.add(System.Label.OKTA_COMMERCE_GROUP_ID);
        jsonU.groupIds = groupIds;
        String jsonBody = JSON.serialize(jsonU);        
		System.debug('jsonBody'+jsonBody);
        request.setBody(jsonBody);

	System.debug('request '+ request);        
        HttpResponse response = http.send(request);
        
        // If the request is successful, parse the JSON response.
       System.debug('response '+ response);
         System.debug('results '+ response.getBody());
        
        String oktaUserId;
        String deactivateLink;
        Boolean isSucesss = false;
        String exceptionMsg;
        if (response.getStatusCode() == 200) {
            isSucesss = true;
            Map<String, Object> results = (Map<String, Object>)JSON.deserializeUntyped(response.getBody());
            System.debug('results '+ response.getBody());
            oktaUserId = (String)results.get('id');
            System.debug('oktaUserId '+ oktaUserId);
           	Map<String, Object> links = (Map<String, Object>)results.get('_links');
            Map<String, Object> deactivate = (Map<String, Object>)links.get('deactivate');
            deactivateLink = (String)deactivate.get('href');
            System.debug('deactivateLink '+ deactivateLink);
            
        }else{
          	exceptionMsg = response.getStatus();
            isSucesss = false; 
        }
        OktaUserCreationResponse oktaUserResponse = new OktaUserCreationResponse();
		oktaUserResponse.oktaUserId = oktaUserId;
        oktaUserResponse.deactivateLink = deactivateLink;
        oktaUserResponse.isSucesss = isSucesss;
        oktaUserResponse.exceptionMsg = exceptionMsg;
        return oktaUserResponse;
    }
    
    
    global class OktaUserCreationRequest{
        @InvocableVariable(required=true label='Account' description='yourDescription')
        global  Account account;
         @InvocableVariable(required=true label='Contact' description='yourDescription')
        global  Contact contact;
    }
    
    global class OktaUserCreationResponse{
        @InvocableVariable
        global String oktaUserId;
        
        @InvocableVariable
        global String deactivateLink;
        
         @InvocableVariable
        global Boolean isSucesss;
        
         @InvocableVariable
        global String exceptionMsg;
    }
    
    
}