global class B2BRegistrationHandler {
    @InvocableMethod(label='B2B Register User')
    global static List<RegisterUserResult> registerUser(List<RegisterUserRequest> requests) {
        List<RegisterUserResult> results = new List<RegisterUserResult>();
        for (RegisterUserRequest request : requests) {
            results.add(registerUser(request));
        }
        return results;
    }
    
    public static RegisterUserResult registerUser(RegisterUserRequest request) {
        RegisterUserResult result = new RegisterUserResult();
        User u = new User();
        if(request.accountId != null && request.User != null){
            u = (User)request.User;
            u.CommunityNickName = getUniqueCommunityNickName(u.FirstName);
        }
        
        try {
            result.userId = Site.createExternalUser(u, request.accountId, null,request.sendEmailToOwner);
            System.Debug(result.userId);
            Map<String, String> dataMap = new Map<String, String>();
            dataMap.put('userId', result.userId);
            B2BUtils.assignPermissionSet(dataMap);
            
        } 
        catch(Site.ExternalUserCreateException ex) {
            //List<String> errorList = new List<String>();
           // for (String error :  ex.getDisplayMessages())  {
                System.debug(LoggingLevel.Error,'Errrors:' + ex.getDisplayMessages());
           // }
 			throw new RegisterUserActionException(ex.getMessage());  
        }
        return result;    
    }
    public static String getUniqueCommunityNickName(String communityNickname) {
        Set<String> communityNicknameSet = new Set<String>();
        for (User usr : [SELECT Id, CommunityNickname FROM User WHERE CommunityNickname != NULL]) {
            communityNicknameSet.add(usr.CommunityNickname);
        }
        String uniqueCommunityNickName;
        if (communityNicknameSet.isEmpty())
        {
            if (communityNickname.length() > 4) 
            {
                uniqueCommunityNickName = communityNickname.substring(0, 4) + String.valueOf(Integer.valueOf(Math.random() * 10000));
            } else 
            {
                uniqueCommunityNickName = communityNickname + String.valueOf(Integer.valueOf(Math.random() * 10000));
            }
        } 
        else
        {
            for (Integer i = 1; i <= 9999; i++) 
            {
                if (communityNickname.length() > 4) 
                {
                    uniqueCommunityNickName = communityNickname.substring(0, 4) + String.valueOf(Integer.valueOf(Math.random() * 10000));
                } 
                else 
                {
                    uniqueCommunityNickName = communityNickname + String.valueOf(Integer.valueOf(Math.random() * 10000));
                }
                if (!communityNicknameSet.contains(uniqueCommunityNickName)) 
                {
                    break;
                }
            }
        }
        return uniqueCommunityNickName;
    }
    global class RegisterUserRequest {
        
        
        @InvocableVariable
        global ID accountId;
        
      /*  @InvocableVariable
        global ID contactId;*/
        
        @InvocableVariable
        global Sobject User;
        
        @InvocableVariable
        global Boolean sendEmailToOwner;
    }
    
    global class RegisterUserResult {
        @InvocableVariable
        global ID userId;
        
    }
    
    class RegisterUserActionException extends Exception {}
}