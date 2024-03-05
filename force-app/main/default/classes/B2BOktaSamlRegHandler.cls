//This class provides logic for inbound just-in-time provisioning of single sign-on users in your Salesforce organization.
global class B2BOktaSamlRegHandler implements Auth.SamlJitHandler {
  private class JitException extends Exception{}
  private void handleUser(boolean create, User u, Map<String, String> attributes,
    String federationIdentifier, boolean isStandard) {
        if(attributes.containsKey('username')){
           List<User> uList =  [SELECT ID FROM USER WHERE Username =:attributes.get('username')];
            
            if(uList.isEmpty()){
                create = true;
            }
            else{
                create = false;
                u.Id = uList[0].Id;
            }
        }
         
        
    if(create && attributes.containsKey('username')) {
      u.Username = attributes.get('username');
    }
    if(create) {
      if(attributes.containsKey('federationIdentifier')) {
        u.FederationIdentifier = attributes.get('federationIdentifier');
      } else {
        u.FederationIdentifier = federationIdentifier;
      }
      
    }
    if(attributes.containsKey('phone')) {
      u.Phone = attributes.get('phone');
    }
    if(attributes.containsKey('email')) {
      u.Email = attributes.get('email');
    }
    if(attributes.containsKey('fname')) {
      u.FirstName = attributes.get('fname');
    }
    if(attributes.containsKey('lname')) {
      u.LastName = attributes.get('lname');
    }
    if(attributes.containsKey('title')) {
      u.Title = attributes.get('title');
    }
    if(attributes.containsKey('companyName')) {
      u.CompanyName = attributes.get('companyName');
    }
     if(attributes.containsKey('fname')) {
     u.Alias = u.CommunityNickname =  B2BRegistrationHandler.getUniqueCommunityNickName(attributes.get('fname'));
       
    }
  /*  if(attributes.containsKey('User.AboutMe')) {
      u.AboutMe = attributes.get('User.AboutMe');
    }
    if(attributes.containsKey('User.Street')) {
      u.Street = attributes.get('User.Street');
    }
    if(attributes.containsKey('User.State')) {
      u.State = attributes.get('User.State');
    }
    if(attributes.containsKey('User.City')) {
      u.City = attributes.get('User.City');
    }
    if(attributes.containsKey('User.Zip')) {
      u.PostalCode = attributes.get('User.Zip');
    }
    if(attributes.containsKey('User.Country')) {
      u.Country = attributes.get('User.Country');
    }
    if(attributes.containsKey('User.CallCenter')) {
      u.CallCenterId = attributes.get('User.CallCenter');
    }
    if(attributes.containsKey('User.Manager')) {
      u.ManagerId = attributes.get('User.Manager');
    }
    if(attributes.containsKey('User.MobilePhone')) {
      u.MobilePhone = attributes.get('User.MobilePhone');
    }
    if(attributes.containsKey('User.DelegatedApproverId')) {
      u.DelegatedApproverId = attributes.get('User.DelegatedApproverId');
    }
    if(attributes.containsKey('User.Department')) {
      u.Department = attributes.get('User.Department');
    }
    if(attributes.containsKey('User.Division')) {
      u.Division = attributes.get('User.Division');
    }
    if(attributes.containsKey('User.EmployeeNumber')) {
      u.EmployeeNumber = attributes.get('User.EmployeeNumber');
    }
    if(attributes.containsKey('User.Extension')) {
      u.Extension = attributes.get('User.Extension');
    }
    if(attributes.containsKey('User.Fax')) {
      u.Fax = attributes.get('User.Fax');
    }*/
    
    
    String uid = UserInfo.getUserId();
    User currentUser = 
      [SELECT LocaleSidKey, LanguageLocaleKey, TimeZoneSidKey, EmailEncodingKey FROM User WHERE Id=:uid];
    if(attributes.containsKey('User.LocaleSidKey')) {
      u.LocaleSidKey = attributes.get('User.LocaleSidKey');
    } else if(create) {
      u.LocaleSidKey = currentUser.LocaleSidKey;
    }
    if(attributes.containsKey('User.LanguageLocaleKey')) {
      u.LanguageLocaleKey = attributes.get('User.LanguageLocaleKey');
    } else if(create) {
      u.LanguageLocaleKey = currentUser.LanguageLocaleKey;
    }
    if(attributes.containsKey('alias')) {
      u.Alias = attributes.get('alias');
    } else if(create) {
      String alias = '';
      if(u.FirstName == null) {
        alias = u.LastName;
      } else {
        alias = u.FirstName.charAt(0) + u.LastName;
      }
      if(alias.length() > 5) {
        alias = alias.substring(0, 5);
      }
      u.Alias = alias;
    }
    if(attributes.containsKey('User.TimeZoneSidKey')) {
      u.TimeZoneSidKey = attributes.get('User.TimeZoneSidKey');
    } else if(create) {
      u.TimeZoneSidKey = currentUser.TimeZoneSidKey;
    }
    if(attributes.containsKey('User.EmailEncodingKey')) {
      u.EmailEncodingKey = attributes.get('User.EmailEncodingKey');
    } else if(create) {
      u.EmailEncodingKey = currentUser.EmailEncodingKey;
    }

    /*
     * If you are updating Contact or Account object fields, you cannot update the following User fields at the same time.
     * If your identity provider sends these User fields as attributes along with Contact 
     * or Account fields, you must modify the logic in this class to update either these 
     * User fields or the Contact and Account fields.
     */
    if(attributes.containsKey('User.IsActive')) {
      String IsActiveVal = attributes.get('User.IsActive');
      u.IsActive = '1'.equals(IsActiveVal) || Boolean.valueOf(IsActiveVal);
    }
    if(attributes.containsKey('User.ForecastEnabled')) {
      String ForecastEnabledVal = attributes.get('User.ForecastEnabled');
      u.ForecastEnabled = '1'.equals(ForecastEnabledVal) || Boolean.valueOf(ForecastEnabledVal);
    }
   // if(attributes.containsKey('User.ProfileId')) {
      String profileId = attributes.get('User.ProfileId');
      Profile p = [SELECT Id FROM Profile WHERE Name='B2B Lightning Community Plus Login'];
      u.ProfileId = p.Id;
   // }
    if(attributes.containsKey('User.UserRoleId')) {
      String userRole = attributes.get('User.UserRoleId');
      UserRole r = [SELECT Id FROM UserRole WHERE Id=:userRole];
      u.UserRoleId = r.Id;
    }
        System.debug('userid '+ u.Id);
         Map<String, String> dataMap = new Map<String, String>();
         dataMap.put('userId', u.Id);
         B2BUtils.assignPermissionSet(dataMap);

    //Handle custom fields here

    if(!create) {
      update(u);
    }
  }

  private void handleContact(boolean create, String accountId, User u, Map<String, String> attributes) {
    Contact c;
    boolean newContact = false;
    
      if(attributes.containsKey('email')) {
      String email = attributes.get('email');
        c = [SELECT Id, AccountId,Okta_User_Id__c, Okta_Deactivate_Link__c FROM Contact WHERE Email=:email AND AccountId =:accountId];
        u.ContactId = c.Id;
        u.Okta_User_Id__c = c.Okta_User_Id__c;
        u.Okta_Deactivate_Link__c = c.Okta_Deactivate_Link__c;  
      }else{
          throw new JitException('Could not find contact'); 
      } 
   
/*
    if(attributes.containsKey('email')) {
      c.Email = attributes.get('email');
    }
    if(attributes.containsKey('fname')) {
      c.FirstName = attributes.get('fname');
    }
    if(attributes.containsKey('lname')) {
      c.LastName = attributes.get('lname');
    }
    if(attributes.containsKey('Contact.Phone')) {
      c.Phone = attributes.get('Contact.Phone');
    }
    if(newContact) {
      c.AccountId = accountId;
      insert(c);
      u.ContactId = c.Id;
    } else {
      update(c);
    }*/
  }

  private String handleAccount(boolean create, User u, Map<String, String> attributes) {
    Account a;
    boolean newAccount = false;
  
       if(attributes.containsKey('customernumber')) {
        String customerNumber = attributes.get('customernumber');
           List<Account> acList = [SELECT Id FROM Account WHERE Customer_Number__c=:customerNumber];
           if(!acList.isEmpty()){
               a = acList[0]; 
           }else{
               throw new JitException('Could not find account with Customer Number');
           }
       
       }else{
           throw new JitException('Could not find account');
       }
    
/*    if(newAccount) {
      insert(a);
    } else {
      update(a);
    }*/
    return a.Id;
  }

  private void handleJit(boolean create, User u, Id samlSsoProviderId, Id communityId, Id portalId,
    String federationIdentifier, Map<String, String> attributes, String assertion) {
        System.debug('attributes '+ attributes);
    if(communityId != null || portalId != null) {
      String accountId = handleAccount(create, u, attributes);
      handleContact(create, accountId, u, attributes);
      if(create){
        Account acc=[Select Id, BillingCountry,BillingCountryCode From Account where id =:u.accountId];
        if(acc.BillingCountryCode=='US'){
          u.LanguageLocaleKey='en_US';
          u.LocaleSidKey='en_US';
          u.CurrencyIsoCode='USD';
        }
        else if(acc.BillingCountryCode=='CA'){
          u.LanguageLocaleKey='en_US';
          u.LocaleSidKey='en_CA';
          u.CurrencyIsoCode='CAD';
        }
        else if(acc.BillingCountryCode=='ES'){
          u.LanguageLocaleKey='es_MX';
          u.LocaleSidKey='es_ES';
          u.CurrencyIsoCode='EUR';
        }
        else if(acc.BillingCountryCode=='FR'){
          u.LanguageLocaleKey='fr';
          u.LocaleSidKey='fr_FR';
          u.CurrencyIsoCode='EUR';
        }
        else if(acc.BillingCountryCode=='DE'){
          u.LanguageLocaleKey='de';
          u.LocaleSidKey='de_DE';
          u.CurrencyIsoCode='EUR';
        }
      }
      handleUser(create, u, attributes, federationIdentifier, false);
    } else {
      handleUser(create, u, attributes, federationIdentifier, true);
    }
  }

  global User createUser(Id samlSsoProviderId, Id communityId, Id portalId,
    String federationIdentifier, Map<String, String> attributes, String assertion) {
    User u = new User();
    handleJit(true, u, samlSsoProviderId, communityId, portalId,
      federationIdentifier, attributes, assertion);
    return u;
  }

  global void updateUser(Id userId, Id samlSsoProviderId, Id communityId, Id portalId,
    String federationIdentifier, Map<String, String> attributes, String assertion) {
    User u = [SELECT Id, FirstName, ContactId FROM User WHERE Id=:userId];
    handleJit(false, u, samlSsoProviderId, communityId, portalId,
      federationIdentifier, attributes, assertion);
  }
}