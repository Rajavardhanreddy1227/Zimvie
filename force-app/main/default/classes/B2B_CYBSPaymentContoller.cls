/**
 * @description       : 
 * @author            : asood@rafter.one
 * @group             : 
 * @last modified on  : 09-21-2023
 * @last modified by  : Gaurav Setia
**/
public with sharing class B2B_CYBSPaymentContoller {
    public static string PMStreet;
    public static string PMCity;
    public static string PMState;
    public static string PMCountry;
    public static string PMPostalCode;
    public static string currencyCode;
    private static final DCM_Logger logger = DCM_Logger.getInstance('Payment Page');
    
    
    @AuraEnabled
    public static boolean is3Dsecure()
    {
        Boolean is3DSecure=false;
        
        try{
            B2B_CYBS_Merchant__mdt cyberSource= getMerchant();
            if(cyberSource.Is_3D_Secure_Enable__c)
            {
                is3DSecure=true;
            }
        }catch(Exception e)
        {
            logger.error(e);
        }
        finally {
            logger.flush();
        }
        return is3DSecure;
        
    }

    @AuraEnabled
    public static string getAddress(string cartId){
        String webstoreId = retrieveWebStoreIdByCommunityId();
        String sfdcURL = URL.getOrgDomainUrl().toExternalForm();
        String endpoint = sfdcURL + '/services/data/v54.0/commerce/webstores/' + webstoreId + 
            '/checkouts/active';
        system.debug('endpoint'+endpoint);

        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('GET');
        httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());        
        httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId()); 
        httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
        httpRequest.setEndpoint(endpoint);
        String response;        
        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            Integer statusCode = httpResponse.getStatusCode();
            if(statusCode >= 200 && statusCode <= 204) {
                response = httpResponse.getBody();
            } else {
                throw new CalloutException(httpResponse.getBody());
            }
        } catch(Exception e) {
            logger.error(e);
        } finally {
            logger.flush();
        }
        return response;
    }

    @AuraEnabled
    public static boolean isShippingAddSelected(string cartId)
    {
        Boolean isAddressSelected=false;
        try{
           
        List<WebCart> cartList = [SELECT ID, Selected_Contact_Point_Address__c FROM WebCart WHERE id =: cartId LIMIT 1];

        If(cartList.size() > 0){
            if(cartList[0].Selected_Contact_Point_Address__c != null){
                isAddressSelected = true;
            }else{

                isAddressSelected = false;
            }
           
        }


        }catch(Exception e)
        {
            logger.error(e);
        }
        finally {
            logger.flush();
        }
        return isAddressSelected;
        
    }

    @AuraEnabled
    public static List<CartDeliveryGroup> getShippingAddress(string cartId)
    {

        List<CartDeliveryGroup> listCartDelivery = new list<CartDeliveryGroup>();
       
        try{
           
        listCartDelivery = [SELECT ID, DeliverToAddress, DeliveryMethodId FROM CartDeliveryGroup WHERE ID =: cartId LIMIT 1];

        }catch(Exception e)
        {
            logger.error(e);
        }
        finally {
            logger.flush();
        }
        return listCartDelivery;
        
    }




    @AuraEnabled
    public static Map<string,string> isPoOrCreditCart(String cardId)
    {
        Decimal baseAmount = Decimal.valueOf(System.Label.B2B_Credit_Card_Base_Amount);
        Map<string,string> data=new map<string,string>();
        string isShowCreditCard='false';
        string isPOorBoth='n/a';
        try{
            string paymentTerm;
            User u = [select id,CurrencyIsoCode,contactId from user where id=:UserInfo.getUserId()];
            CurrencyType ctype = [select Id,ConversionRate, IsoCode from CurrencyType where IsActive = true and IsoCode=:u.CurrencyIsoCode limit 1];
            String accountId = [select id,AccountId from Contact where id=:u.ContactId].AccountId;
            Account acc = [Select id from Account where id=:accountId];
            List<WebCart> cart=[select id ,TotalAmount from Webcart where ownerId=:u.id and AccountId=:acc.id and status='Checkout' order by createddate desc limit 1];
            if(cart.size()>0) {
                Decimal cartAmount = ctype.IsoCode == 'USD' ? cart[0].TotalAmount : (cart[0].TotalAmount*ctype.ConversionRate);
               // ContactPointAddress cpa=[select id,ERP_Payment_Term_Name__c from ContactPointAddress where id=:cart[0].Billing_Address__c limit 1 ];
                // if(cpa.ERP_Payment_Term_Name__c != null){
                //     paymentTerm = cpa.ERP_Payment_Term_Name__c;
                // }else{
                //     paymentTerm = '';
                // }
                paymentTerm = '';
                isShowCreditCard='true';
                isPOorBoth='po';
                // if(paymentTerm.containsIgnoreCase('cia') || paymentTerm.containsIgnoreCase('Credit Card')){
                //     isShowCreditCard='true';
                // }else if((cartAmount <= baseAmount || acc.CCNoCap__c)){
                //     if(acc.POnly__c){
                //         isPOorBoth='po';
                //     }else{
                //         isShowCreditCard = 'true';
                //         isPOorBoth='both';
                //     }
                // }else{
                //     isPOorBoth='po';
                // }
                }
            } catch(Exception ex) {
                //logger.error(null, 'Exception during check payment term-->'+ex);
                data.put('isShowCreditCard',isShowCreditCard);
                data.put('poorboth',isPOorBoth);
                logger.error(ex);
                //logger.info(isShowCreditCard+'----Payment term is --'+acc.ERP_Payment_Term_Name__c);  
            } finally {
                logger.flush();
            }
            return data;
    }

    public static B2B_CYBS_Merchant__mdt getMerchant()
    {
        User user = [Select id,contactId from user where Id=:UserInfo.getUserId()];

        String accountId=[Select Id,AccountId from Contact where Id=:user.ContactId].AccountId;
        
        // Account acc = [select id,B2B_Legal_Entity__c,CurrencyISOCode from Account where Id=:accountId];
        // List<B2B_Legal_Entity__mdt> legalEntityData = [select id ,MerchantId__c,Legal_Entity__c from B2B_Legal_Entity__mdt where Legal_Entity__c=:acc.B2B_Legal_Entity__c];
       
         List<B2B_CYBS_Merchant__mdt> metaConfig=new List<B2B_CYBS_Merchant__mdt>();
        // List<String> midname=new List<String>();
        // for(B2B_Legal_Entity__mdt legalEntity:legalEntityData )
        // {
        //     midname.add(legalEntity.MerchantId__c);
            
        // }
        metaConfig = [SELECT Id, Key_ID__c, Private_Key__c, Microflex_Key_Creation_URL__c,Label,
                                                    DeveloperName,Is_3D_Secure_Enable__c FROM B2B_CYBS_Merchant__mdt ];//where id in:midname and Currency_ISO_Code__c=:acc.CurrencyISOCode limit 1];
        return metaConfig[0];
    }
    
    @AuraEnabled
    public static Map<String, Object> getComponentSetup(String cardId) {
        Map<String, Object> returnData = new Map<String, Object>();
        try {
            B2B_CYBS_Merchant__mdt cyberSource=getMerchant();
            if(cardId != null){
                B2B_CybersourceRESTUtility.getCYBSConfiguration(); 
            }
            else{
                B2B_CybersourceRESTUtility.getCYBSConfiguration(); 
            }
            String storeUrl=System.Label.B2B_StoreUrl ; 
            String requestBody = '{"encryptionType":"RsaOaep256", "targetOrigin":"'+ storeUrl +'"}'; 
            //Request for Key Id from Cyber source to USE Flex Form 
            HttpRequest request = B2B_CybersourceRESTUtility.generatePostRequest(B2B_CybersourceRESTUtility.microURL, requestBody);
            System.debug('Request Get Component body'+request.getBody() +'\nEnd point '+request.getEndpoint()+'\nheader-->'+request.toString());
            Http http = new Http();
            string responseBody;
            //if(!Test.isRunningTest()){
            HttpResponse response = http.send(request);
            responseBody = response.getBody();
            // }
            Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
            returnData.put('keyId', String.valueOf(resMap.get('keyId')));
            
        } catch(Exception e) {
            User u=[select id,contactId,Username from user where id=:UserInfo.getUserId()];
            String accountId=[select id,AccountId from Contact where id=:u.ContactId].AccountId;
        
            Account acc=[select id,Name from Account where id=:accountId];
            System.debug(e.getMessage());
            logger.error(e);
            returnData.put('error', e.getMessage());
        }
         finally {
            logger.flush();
        }
        
        return returnData;
    }
    
    public static string getJTiToken(string token)
    {
        
        String jwtTokenbody = token.split('\\.')[1]; 
        Blob decodedJWTToken = EncodingUtil.base64Decode(jwtTokenbody); 
        Map<String, Object> jwtTokenDataMap = (Map<String, Object>)JSON.deserializeUntyped(decodedJWTToken.toString()); 
        String jtiToken = (String)jwtTokenDataMap.get('jti');
        System.debug('___Decode jti Token -- ' + jtiToken);
        System.debug('___Decode jwtData -- ' + jwtTokenDataMap);
        return jtiToken;
    }
    
    public static string genrateAuthorizationRequest(String cartId,String jwtToken,String legacyToken,String transactionId, Map<String,String>liabilityShift, String webstoreId, commercepayments.AddressRequest address)
    {
        // WebCart cart=[Select id,GrandTotalAmount ,TotalProductAmount, CurrencyIsoCode ,Owner.FirstName,Owner.LastName,BillingStreet,BillingCity,
        //               BillingState,BillingPostalCode,BillingCountry,Owner.Email,Owner.Phone from Webcart where id=:cartId];
        System.debug('webstoreId----->'+webstoreId);
        List<Webcart> webCartObj = [SELECT Id,AccountId, Owner.Phone,Owner.FirstName, GrandTotalAmount,CurrencyIsoCode,Owner.LastName,Owner.email, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet FROM Webcart WHERE webstoreID=: webstoreId AND 
        OwnerId =: UserInfo.getUserId() AND Status in ('Active','Checkout')];
        System.debug('webCartObj----->'+webCartObj);
        System.debug('udduu------'+webCartObj.size());
        for(Webcart wCard : webCartObj){
            System.debug('webCartObj----->'+wCard);
        }
        WebCart cart = webCartObj[0];
        System.debug('cart----->'+cart);
                  
        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();
        
        jsGen.writeFieldName('clientReferenceInformation');
        jsGen.writeStartObject();
        
        jsGen.writeStringField('code', 'B2B_Commerce');
        jsGen.writeEndObject();
        
        jsGen.writeFieldName('orderInformation');
        
        jsGen.writeStartObject();
        jsGen.writeFieldName('amountDetails');
        jsGen.writeStartObject();
        if(cart.CurrencyIsoCode=='USD')
        {
            jsGen.writeStringField('totalAmount', string.valueOf(roundAmountValue(cart.GrandTotalAmount)));
        }
        else {
            jsGen.writeStringField('totalAmount', string.valueOf(roundAmountValue(cart.GrandTotalAmount)));
        }
        //jsGen.writeStringField('totalAmount', string.valueOf(cart.GrandTotalAmount));
        
        //currency has to be dynamic , pick from the quote currency field
        jsGen.writeStringField('currency', cart.CurrencyIsoCode);        
        jsGen.writeEndObject();
        
        jsGen.writeFieldName('billTo');
        jsGen.writeStartObject();
        
        
        //TODO - Update Contact fields to be pulled from request
        if(cart.Owner.Firstname != null){
            jsGen.writeStringField('firstName', cart.Owner.Firstname);
        }
        if(cart.Owner.LastName != null){
            jsGen.writeStringField('lastName', cart.Owner.LastName);     
        }
           
        if(address.street != null){
            jsGen.writeStringField('address1', address.street);
        }
        if(address.city != null){
            jsGen.writeStringField('locality',address.city); 
        }
        if(address.state != null){
            jsGen.writeStringField('administrativeArea', address.state);
        }
        if(address.postalCode != null){
            jsGen.writeStringField('postalCode', address.postalCode);
        }
        if(address.country != null){
            jsGen.writeStringField('country', address.country);
        }
        if(cart.Owner.Email != null){
            jsGen.writeStringField('email', cart.Owner.Email);
        }
        if(cart.Owner.Phone != null){
            jsGen.writeStringField('phoneNumber', cart.Owner.Phone); 
        }
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        
        if(jwtToken !=null)
        {
            jsGen.writeFieldName('tokenInformation');
            jsGen.writeStartObject();
            jsGen.writeStringField('transientTokenJwt', jwtToken);
            jsGen.writeEndObject();
        }
        
        
        
        //Buyer information -start
        if(cart.Owner.Phone != null){
            jsGen.writeFieldName('buyerInformation');
            jsGen.writeStartObject();
            
            
            jsGen.writeStringField('mobilePhone', cart.Owner.Phone);
            
            jsGen.writeEndObject();
        }
        //By=uyer Information -end
        
        
        //consumer detail
        if(transactionId !=null)
        {
            
            
            jsGen.writeFieldName('consumerAuthenticationInformation');
            jsGen.writeStartObject();
            
            jsGen.writeStringField('authenticationTransactionId', transactionId);
            jsGen.writeStringField('eciRaw', liabilityShift.get('eciRaw'));
            jsGen.writeStringField('paresStatus', liabilityShift.get('paresStatus'));
            if(liabilityShift.containsKey('ucafCollectionIndicator')){
                jsGen.writeStringField('ucafCollectionIndicator', liabilityShift.get('ucafCollectionIndicator'));
                jsGen.writeStringField('ucafAuthenticationData', liabilityShift.get('ucafAuthenticationData'));
            }
            else
            {
                if(legacyToken==null){
                jsGen.writeStringField('cavv', liabilityShift.get('cavv'));
                jsGen.writeStringField('xid', liabilityShift.get('xid'));
                }
            }
            jsGen.writeStringField('directoryServerTransactionId', liabilityShift.get('directoryServerTransactionId'));
            jsGen.writeStringField('paSpecificationVersion', liabilityShift.get('paSpecificationVersion'));
            jsGen.writeStringField('acsTransactionId', liabilityShift.get('acsTransactionId'));
            
             
            jsGen.writeEndObject();
        }
        //consumer details end
        
        //processingInformation detail
        if(jwtToken !=null){//transactionId==null && 
            jsGen.writeFieldName('processingInformation');
            jsGen.writeStartObject();
            jsGen.writeFieldName('actionList');
            jsGen.writeStartArray ();
            jsGen.writeString('TOKEN_CREATE');
            jsGen.writeEndArray ();
            jsGen.writeFieldName('actionTokenTypes');
            jsGen.writeStartArray ();
            jsGen.writeString('customer');
            jsGen.writeString('paymentInstrument');
            jsGen.writeString('instrumentIdentifier');
            jsGen.writeEndArray ();
            
            jsGen.writeEndObject();
        }
        if(legacyToken !=null)
        {
            jsGen.writeFieldName('paymentInformation');
            jsGen.writeStartObject();
            jsGen.writeFieldName('legacyToken');
            jsGen.writeStartObject();
            jsGen.writeStringField('id', legacyToken);
            jsGen.writeEndObject();
            jsGen.writeEndObject();
        }
        //processingInformation details end
        
        jsGen.writeEndObject();      
        
        return jsGen.getAsString();
    }

    // invoice logic start

    // public static map<string,Object> updateRecieptFunc(map<string,Object> inpMap){
    //     Map<String,Object>  returnData = new Map<String,Object>();
    //     try{
    //         String receiptId = (String)inpMap.get('receiptId');
    //         String inpToken = (String)inpMap.get('token');
    //         Payment_Receipt__c receipt = [SELECT Id, OwnerId, IsDeleted, Name, CurrencyIsoCode, CreatedDate,
    //             CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, 
    //             Receipt_Amount__c, Receipt_Currency_Code__c, Receipt_Date__c, Customer_Number__c, Receipt_Method_ID__c, 
    //             Transaction_Number__c, Customer_Bank_Account_ID__c, Customer_Location__c, Credit_card_holder_Name__c, 
    //             Credit_Card_Number__c, Currency_Code__c, Credit_Card_Expiration_Date__c, Credit_Card_Token__c, Receipt_Status__c 
    //             FROM Payment_Receipt__c WHERE id = :receiptId];
             
    //         System.debug('receipt---- '+ JSON.serialize(receipt));
    //         returnData.put('receiptObj', receipt);
    //         receipt.Credit_Card_Token__c = inpToken;
    //     }catch(Exception e){
    //         throw new AuraHandledException(e.getMessage());
    //     }
    //     return returnData;
    // }

    @AuraEnabled
    public static  Map<String,Object> saveNewCardForInv(String token,String expirationMonth, String expirationYear, String cardholderName, String cardholderNickName, String cardType, String isJWT, String receiptId){
        Map<String,Object>  returnData = new Map<String,Object>();
        try {
            returnData = AuthorizationAPIForInv(null, null, null, token, true, expirationMonth,expirationYear, cardholderName, cardholderNickName, cardType, isJWT, true, false, null, false, receiptId);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return returnData;
    }
    
    public static Map<String,Object> AuthorizationAPIForInv(String orderId, String webstoreId,String cartId,String token,boolean isSaveCard,String expirationMonth, String expirationYear, String cardholderName, String cardholderNickName, String cardType,String isJWT, Boolean saveFromWallet, Boolean hasBillingAddress, String billingAddress, Boolean isStoredPayment, String receiptId)
    {
        Map<String,Object>  returnData=new Map<String,Object>();
            Map<String, Object> paymentInfo = new Map<String, Object>();
            Map<String, Object> selectedBillingAddress = new Map<String, Object>();
            ConnectApi.AuthorizationResponse authResponse;
            ConnectApi.AuthorizationGatewayResponse authGatewayRes;
            ConnectApi.PaymentAuthorizationResponse payAuthResp;
            System.debug('webstoreId----->'+webstoreId);
            ConnectApi.AuthorizationRequest authRequest = new ConnectApi.AuthorizationRequest();
            WebCart cart;
            ContactPointAddress cpa;
            try{
                if(String.isNotBlank(cartId)){
                    cart = [SELECT CurrencyIsoCode, WebStoreId, GrandTotalAmount, Owner.LastName,Owner.email, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, AccountId 
                        FROM WebCart WHERE Id=:cartId];
                        cpa = [SELECT Id,City,Country,PostalCode,State,Street FROM ContactPointAddress WHERE ParentId=:cart.AccountId AND AddressType='Billing' AND IsDefault=true  LIMIT 1];
                }else{
                    String AccountId = [SELECT AccountId FROM User WHERE Id=:UserInfo.getUserId()].AccountId;
                    cpa = [SELECT Id,City,Country,PostalCode,State,Street FROM ContactPointAddress WHERE ParentId=:AccountId AND AddressType='Billing' AND IsDefault=true  LIMIT 1];
                }
                PMStreet = cpa.Street;
                PMCity = cpa.City;
                PMState = cpa.State;
                PMCountry = cpa.Country;
                PMPostalCode = cpa.PostalCode;

                if(hasBillingAddress && String.isNotBlank(billingAddress)) {
                    B2B_Address obj = (B2B_Address)JSON.deserialize(billingAddress, B2B_Address.class);
                    selectedBillingAddress.put('street',obj.street);
                    selectedBillingAddress.put('postalCode',obj.postalcode);
                    selectedBillingAddress.put('city',obj.city);
                    selectedBillingAddress.put('state',obj.province);
                    selectedBillingAddress.put('country',obj.country);
                } else {
                    System.debug('cpa----->'+cpa);
                    selectedBillingAddress.put('street',cpa.Street);
                    selectedBillingAddress.put('postalCode',cpa.PostalCode);
                    selectedBillingAddress.put('city',cpa.City);
                    selectedBillingAddress.put('state',cpa.State);
                    selectedBillingAddress.put('country',cpa.Country);
                }


                String cardNumber = '000000000';
                if(!isStoredPayment) {
                    cardNumber = getMaskedCardValue(token);
                }
                
                paymentInfo.put('cardHolderName', cardholderName);
                paymentInfo.put('cardNumber', cardNumber);
                paymentInfo.put('cardType',cardType);
                paymentInfo.put('cvv','123');
                paymentInfo.put('expiryMonth',expirationMonth);
                paymentInfo.put('expiryYear',expirationYear);
                paymentInfo.put('token',token);

                if(cartId != null){
                    authRequest.amount = cart.GrandTotalAmount;
                    authRequest.accountId = cart.AccountId;
                }else{
                    String AccountId = [SELECT AccountId FROM User WHERE Id=:UserInfo.getUserId()].AccountId;
                    authRequest.amount = 0.0;
                    authRequest.accountId = AccountId;
                }
                authRequest.effectiveDate = Datetime.now();
                authRequest.currencyIsoCode = UserInfo.getDefaultCurrency();
                String paymentGatewayId;
                if(cartId != null) {
                    paymentGatewayId= getPaymentGatewayId(cart.WebStoreId);
                } else {
                    webstoreId = retrieveWebStoreIdByCommunityId();
                    paymentGatewayId= getPaymentGatewayId(webstoreId);
                }

                if (paymentGatewayId == null || paymentGatewayId.equals('')) {
                    throw new AuraHandledException('This store is not authorized to process payments.');
                }

                authRequest.paymentGatewayId = paymentGatewayId;
                authRequest.paymentMethod = getPaymentMethod(paymentInfo, selectedBillingAddress);
                if(cartId != null){
                    authRequest.paymentGroup = getPaymentGroup(cartId);
                }
                Map<String, String> dataMap = new Map<String, String>();
                Integer i = 0;
                String v1Token = '';
                String v2Token = '';
                String legacyToken = '';
                if(isJWT == 'true'){
                    i = token.length();
                    v1Token = token.substring(0,i/2);
                    v2Token = token.substring(i/2,token.length());
                    dataMap.put('v1Token',v1Token);
                    dataMap.put('v2Token',v2Token);
                }else{
                    legacyToken = token;
                    dataMap.put('legacyToken',legacyToken);
                }
                dataMap.put('isJWT',isJWT);
                dataMap.put('webstoreId',webstoreId);
                //dataMap.put('abc','abc');
                if(String.isNotBlank(cartId)){
                    dataMap.put('cartId',cartId);
                }
                if(saveFromWallet){
                    dataMap.put('saveFromWallet','true');
                }
                authRequest.additionalData= dataMap;

                System.debug('::authRequest::'+authRequest);
            
                if(!Test.isRunningTest()){
                    System.debug('___running before____');
                    authResponse = ConnectApi.Payments.authorize(authRequest);
                    System.debug('___running after____');
                    authGatewayRes = authResponse.gatewayResponse;
                    payAuthResp = authResponse.paymentAuthorization;
                    returnData.put('authResponse',authResponse);
                }
                if(String.isNotBlank(cartId)){
                    cart.PaymentMethodId = authResponse.paymentMethod.id;
                    cart.PaymentGroupId = authResponse.paymentGroup.id;

                    if(hasBillingAddress && String.isNotBlank(billingAddress)) { 
                        B2B_Address obj = (B2B_Address)JSON.deserialize(billingAddress, B2B_Address.class);
                        cart.BillingStreet = obj.street;
                        cart.BillingCity = obj.city;
                        cart.BillingStateCode = obj.province;
                        cart.BillingPostalCode = obj.postalcode;
                        cart.BillingCountryCode = obj.country;
                    } else {
                        cart.BillingStreet = cpa.Street;
                        cart.BillingCity = cpa.City;
                        cart.BillingState = cpa.State;
                        cart.BillingPostalCode = cpa.PostalCode;
                        cart.BillingCountry = cpa.Country;
                    }
                    update cart;
                }

                System.debug('____authResponse____'+authResponse);
                System.debug('payAuthResp.get-->'+payAuthResp.id);
                if(isSaveCard){
                    //createPaymentMethodDuringAuth(cartId,authResponse.gatewayResponse.gatewayAuthorizationCode,cardholderName,cardholderNickName,cardType);
                    createPaymentMethodForInvDuringAuth(cartId,authResponse.gatewayResponse.gatewayAuthorizationCode,cardholderName,cardholderNickName,cardType,receiptId, expirationMonth, expirationYear);
                }
                
                if (authResponse!=null && authResponse.error != null) {
                    throw new AuraHandledException('AuthResponseError: ' + authResponse.error.message);
                }
            }catch(Exception e) {
                logger.error(e);
                System.debug('Exception e->'+e+'---Message---'+e.getMessage()+'---Line Number --->'+e.getLineNumber());
            } finally {
                logger.flush();
            }
        return returnData;
        
    }
    
    /*@AuraEnabled
    public static Map<String,Object> AuthorizationAPIForInvOld(String orderId, String webstoreId,String cartId,String token,boolean isSaveCard,String expirationMonth, String expirationYear, String cardholderName, String cardholderNickName, String cardType,String isJWT, Boolean saveFromWallet, String receiptId)
    {
        Map<String,Object>  returnData=new Map<String,Object>();
            Map<String, Object> paymentInfo = new Map<String, Object>();
            Map<String, Object> selectedBillingAddress = new Map<String, Object>();
            ConnectApi.AuthorizationResponse authResponse;
            ConnectApi.AuthorizationGatewayResponse authGatewayRes;
            ConnectApi.PaymentAuthorizationResponse payAuthResp;
            System.debug('webstoreId----->'+webstoreId);
            ConnectApi.AuthorizationRequest authRequest = new ConnectApi.AuthorizationRequest();
            WebCart cart;
            ContactPointAddress cpa;
            try{
                if(String.isNotBlank(cartId)){
                    cart = [SELECT CurrencyIsoCode, WebStoreId, GrandTotalAmount, Owner.LastName,Owner.email, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, AccountId 
                        FROM WebCart WHERE Id=:cartId];
                        cpa = [SELECT Id,City,Country,PostalCode,State,Street FROM ContactPointAddress WHERE ParentId=:cart.AccountId AND AddressType='Billing' AND IsDefault=true  LIMIT 1];
                }else{
                    String AccountId = [SELECT AccountId FROM User WHERE Id=:UserInfo.getUserId()].AccountId;
                    cpa = [SELECT Id,City,Country,PostalCode,State,Street FROM ContactPointAddress WHERE ParentId=:AccountId AND AddressType='Billing' AND IsDefault=true  LIMIT 1];
                }
                PMStreet = cpa.Street;
                PMCity = cpa.City;
                PMState = cpa.State;
                PMCountry = cpa.Country;
                PMPostalCode = cpa.PostalCode;

                System.debug('cpa----->'+cpa);
                selectedBillingAddress.put('street',cpa.Street);
                selectedBillingAddress.put('postalCode',cpa.PostalCode);
                selectedBillingAddress.put('city',cpa.City);
                selectedBillingAddress.put('state',cpa.State);
                selectedBillingAddress.put('country',cpa.Country);

                paymentInfo.put('cardHolderName', cardholderName);
                paymentInfo.put('cardNumber','000000000');
                paymentInfo.put('cardType',cardType);
                paymentInfo.put('cvv','123');
                paymentInfo.put('expiryMonth',expirationMonth);
                paymentInfo.put('expiryYear',expirationYear);
                paymentInfo.put('token',token);

                if(cartId != null){
                    authRequest.amount = cart.GrandTotalAmount;
                    authRequest.accountId = cart.AccountId;
                }else{
                    String AccountId = [SELECT AccountId FROM User WHERE Id=:UserInfo.getUserId()].AccountId;
                    authRequest.amount = 0.0;
                    authRequest.accountId = AccountId;
                }
                authRequest.effectiveDate = Datetime.now();
                authRequest.currencyIsoCode = UserInfo.getDefaultCurrency();
                String paymentGatewayId;
                if(cartId != null) {
                    paymentGatewayId= getPaymentGatewayId(cart.WebStoreId);
                } else {
                    webstoreId = retrieveWebStoreIdByCommunityId();
                    paymentGatewayId= getPaymentGatewayId(webstoreId);
                }

                if (paymentGatewayId == null || paymentGatewayId.equals('')) {
                    throw new AuraHandledException('This store is not authorized to process payments.');
                }

                authRequest.paymentGatewayId = paymentGatewayId;
                authRequest.paymentMethod = getPaymentMethod(paymentInfo, selectedBillingAddress);
                if(cartId != null){
                    authRequest.paymentGroup = getPaymentGroup(cartId);
                }
                Map<String, String> dataMap = new Map<String, String>();
                Integer i = 0;
                String v1Token = '';
                String v2Token = '';
                String legacyToken = '';
                if(isJWT == 'true'){
                    i = token.length();
                    v1Token = token.substring(0,i/2);
                    v2Token = token.substring(i/2,token.length());
                    dataMap.put('v1Token',v1Token);
                    dataMap.put('v2Token',v2Token);
                }else{
                    legacyToken = token;
                    dataMap.put('legacyToken',legacyToken);
                }
                dataMap.put('isJWT',isJWT);
                dataMap.put('webstoreId',webstoreId);
                if(String.isNotBlank(cartId)){
                    dataMap.put('cartId',cartId);
                }
                if(saveFromWallet){
                    dataMap.put('saveFromWallet','true');
                }
                authRequest.additionalData= dataMap;

                System.debug('::authRequest::'+authRequest);
            
                if(!Test.isRunningTest()){
                    System.debug('___running before____');
                    authResponse = ConnectApi.Payments.authorize(authRequest);
                    System.debug('___running after____');
                    authGatewayRes = authResponse.gatewayResponse;
                    payAuthResp = authResponse.paymentAuthorization;
                    returnData.put('authResponse',authResponse);
                }
                if(String.isNotBlank(cartId)){
                    cart.PaymentMethodId = authResponse.paymentMethod.id;
                    cart.PaymentGroupId = authResponse.paymentGroup.id;
                    cart.BillingStreet = cpa.Street;
                    cart.BillingCity = cpa.City;
                    cart.BillingState = cpa.State;
                    cart.BillingPostalCode = cpa.PostalCode;
                    cart.BillingCountry = cpa.Country;
                    update cart;
                }

                System.debug('____authResponse____'+authResponse);
                System.debug('payAuthResp.get-->'+payAuthResp.id);
                if(isSaveCard){
                    createPaymentMethodForInvDuringAuth(cartId,authResponse.gatewayResponse.gatewayAuthorizationCode,cardholderName,cardholderNickName,cardType,receiptId);
                }
                
                if (authResponse!=null && authResponse.error != null) {
                    throw new AuraHandledException('AuthResponseError: ' + authResponse.error.message);
                }
            }catch(Exception e){
                System.debug('Exception e->'+e+'---Message---'+e.getMessage()+'---Line Number --->'+e.getLineNumber());
            }
        return returnData;
        
    }*/

    public static void createPaymentMethodForInvDuringAuth(String cartId,String paymentId,String cardholderName,String cardholderNickName, String cardType, String receiptId, String expirationMonth, String expirationYear)
    {
        if(cartId !=null){

        
            WebCart cart = [SELECT Id, Name,Owner.Firstname,Owner.Lastname,Owner.Email,Owner.Phone,BillingStreet,
                            BillingCity,BillingState,BillingPostalCode, BillingCountry,GrandTotalAmount,CurrencyIsoCode,
                            AccountId,WebStoreId from  WebCart WHERE Id=:cartId];
        System.debug('cart------>'+cart);
        ContactPointAddress cpa = [SELECT Id,City,Country,PostalCode,State,Street FROM ContactPointAddress WHERE ParentId=:cart.AccountId AND AddressType='Billing' AND IsDefault=true  LIMIT 1];
        System.debug('cpa----->'+cpa);
        PMStreet = cpa.Street;
        PMCity = cpa.City;
        PMState = cpa.State;
        PMCountry = cpa.Country;
        PMPostalCode = cpa.PostalCode;
        currencyCode = cart.CurrencyIsoCode;
        
        }
         
        B2B_CybersourcePMInvScheduler obj = new B2B_CybersourcePMInvScheduler();
        obj.cardholderName = cardholderName;
        obj.cardholderNickName = cardholderNickName;
        obj.cardType = cardType;
        //obj.OrderId = orderId;
        obj.PONumber = 'poNumber';
        obj.userId = userInfo.getUserId();
        obj.PMStreet = PMStreet;
        obj.PMCity = PMCity; 
        obj.PMState = PMState;
        obj.PMCountry = PMCountry;
        obj.PMPostalCode = PMPostalCode;
        obj.isUpdateToken=false;
        obj.receiptId=receiptId;
        obj.expirationMonth = expirationMonth;
        obj.expirationYear = expirationYear;
        system.debug('paymentId---'+paymentId);
        // system.debug('chronExpression---'+chronExpression);
        // system.debug('sysTime---'+sysTime);
        if(paymentId!=null){
            obj.paymentId = paymentId;//authGatewayRes.gatewayAuthorizationCode;
            //obj.payAuthId = payAuthResp.Id;
        }
        obj.currencyCode = currencyCode;

        // for(Integer i=0; i<60; i=i+1){
        //     String cronTrigger = '0 ' + i + ' * * * ?';
        //     String jobID = System.schedule('B2B_CybersourcePMInvScheduler' + i, cronTrigger, obj);
        //     System.debug('Scheduled Job ID: ' + jobID);
        // }

        String jobID = System.enqueueJob(obj);
        System.debug('Scheduled Job ID: ' + jobID);
        
    }
    // invoice logic end

    @AuraEnabled
    public static  Map<String,Object>  saveNewCard(String token,String expirationMonth, String expirationYear, String cardholderName, String cardholderNickName, String cardType, String isJWT){
        Map<String,Object>  returnData=new Map<String,Object>();
        try {
            returnData = AuthorizationAPI(null, null, null, token, true, expirationMonth,expirationYear, cardholderName, cardholderNickName, cardType, isJWT, true, false, null, false, null);
        } catch (Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return returnData;
    }

    @AuraEnabled
    public static Map<String,Object>  AuthorizationAPI(String orderId, String webstoreId,String cartId,String token,boolean isSaveCard,String expirationMonth, String expirationYear, String cardholderName, String cardholderNickName, String cardType,String isJWT, Boolean saveFromWallet, Boolean hasBillingAddress, String billingAddress, Boolean isStoredPayment, String storedCardNumber)
    {
        Map<String,Object>  returnData=new Map<String,Object>();
            Map<String, Object> paymentInfo = new Map<String, Object>();
            Map<String, Object> selectedBillingAddress = new Map<String, Object>();
            ConnectApi.AuthorizationResponse authResponse;
            ConnectApi.AuthorizationGatewayResponse authGatewayRes;
            ConnectApi.PaymentAuthorizationResponse payAuthResp;
            System.debug('webstoreId----->'+webstoreId);
            ConnectApi.AuthorizationRequest authRequest = new ConnectApi.AuthorizationRequest();
            WebCart cart;
            ContactPointAddress cpa;
            try{
                if(String.isNotBlank(cartId)){
                    cart = [SELECT CurrencyIsoCode, WebStoreId, GrandTotalAmount, Owner.LastName,Owner.email, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, AccountId 
                        FROM WebCart WHERE Id=:cartId];
                        cpa = [SELECT Id,City,Country,PostalCode,State,Street FROM ContactPointAddress WHERE ParentId=:cart.AccountId AND AddressType='Billing' AND IsDefault=true  LIMIT 1];
                }else{
                    String AccountId = [SELECT AccountId FROM User WHERE Id=:UserInfo.getUserId()].AccountId;
                    cpa = [SELECT Id,City,Country,PostalCode,State,Street FROM ContactPointAddress WHERE ParentId=:AccountId AND AddressType='Billing' AND IsDefault=true  LIMIT 1];
                }
                PMStreet = cpa.Street;
                PMCity = cpa.City;
                PMState = cpa.State;
                PMCountry = cpa.Country;
                PMPostalCode = cpa.PostalCode;

                if(hasBillingAddress && String.isNotBlank(billingAddress)) {
                    B2B_Address obj = (B2B_Address)JSON.deserialize(billingAddress, B2B_Address.class);
                    selectedBillingAddress.put('street',obj.street);
                    selectedBillingAddress.put('postalCode',obj.postalcode);
                    selectedBillingAddress.put('city',obj.city);
                    selectedBillingAddress.put('state',obj.province);
                    selectedBillingAddress.put('country',obj.country);
                } else {
                    System.debug('cpa----->'+cpa);
                    selectedBillingAddress.put('street',cpa.Street);
                    selectedBillingAddress.put('postalCode',cpa.PostalCode);
                    selectedBillingAddress.put('city',cpa.City);
                    selectedBillingAddress.put('state',cpa.State);
                    selectedBillingAddress.put('country',cpa.Country);
                }


                String cardNumber = '';
                if(!isStoredPayment) {
                    cardNumber = getMaskedCardValue(token);
                } else {
                    cardNumber = '000000000000' + storedCardNumber;
                }
                
                paymentInfo.put('cardHolderName', cardholderName);
                paymentInfo.put('cardNumber', cardNumber);
                paymentInfo.put('cardType',cardType);
                paymentInfo.put('cvv','123');
                paymentInfo.put('expiryMonth',expirationMonth);
                paymentInfo.put('expiryYear',expirationYear);
                paymentInfo.put('token',token);

                if(cartId != null){
                    authRequest.amount = cart.GrandTotalAmount;
                    authRequest.accountId = cart.AccountId;
                }else{
                    String AccountId = [SELECT AccountId FROM User WHERE Id=:UserInfo.getUserId()].AccountId;
                    authRequest.amount = 0.0;
                    authRequest.accountId = AccountId;
                }
                authRequest.effectiveDate = Datetime.now();
                authRequest.currencyIsoCode = UserInfo.getDefaultCurrency();
                String paymentGatewayId;
                if(cartId != null) {
                    paymentGatewayId= getPaymentGatewayId(cart.WebStoreId);
                } else {
                    webstoreId = retrieveWebStoreIdByCommunityId();
                    paymentGatewayId= getPaymentGatewayId(webstoreId);
                }

                if (paymentGatewayId == null || paymentGatewayId.equals('')) {
                    throw new AuraHandledException('This store is not authorized to process payments.');
                }

                authRequest.paymentGatewayId = paymentGatewayId;
                authRequest.paymentMethod = getPaymentMethod(paymentInfo, selectedBillingAddress);
                if(cartId != null){
                    authRequest.paymentGroup = getPaymentGroup(cartId);
                }
                Map<String, String> dataMap = new Map<String, String>();
                Integer i = 0;
                String v1Token = '';
                String v2Token = '';
                String legacyToken = '';
                if(isJWT == 'true'){
                    i = token.length();
                    v1Token = token.substring(0,i/2);
                    v2Token = token.substring(i/2,token.length());
                    dataMap.put('v1Token',v1Token);
                    dataMap.put('v2Token',v2Token);
                }else{
                    legacyToken = token;
                    dataMap.put('legacyToken',legacyToken);
                }
                dataMap.put('isJWT',isJWT);
                dataMap.put('webstoreId',webstoreId);
                //dataMap.put('abc','abc');
                if(String.isNotBlank(cartId)){
                    dataMap.put('cartId',cartId);
                }
                if(saveFromWallet){
                    dataMap.put('saveFromWallet','true');
                }
                authRequest.additionalData= dataMap;

                System.debug('::authRequest::'+authRequest);
            
                if(!Test.isRunningTest()){
                    System.debug('___running before____');
                    authResponse = ConnectApi.Payments.authorize(authRequest);
                    System.debug('___running after____');
                    authGatewayRes = authResponse.gatewayResponse;
                    payAuthResp = authResponse.paymentAuthorization;
                    returnData.put('authResponse',authResponse);
                }
                if(String.isNotBlank(cartId)){
                    cart.PaymentMethodId = authResponse.paymentMethod.id;
                    cart.PaymentGroupId = authResponse.paymentGroup.id;
                    cart.BillingStreet = cpa.Street;
                    cart.BillingCity = cpa.City;
                    cart.BillingState = cpa.State;
                    cart.BillingPostalCode = cpa.PostalCode;
                    cart.BillingCountry = cpa.Country;
                    update cart;
                }

                System.debug('____authResponse____'+authResponse);
                System.debug('payAuthResp.get-->'+payAuthResp.id);
                if(isSaveCard){
                    createPaymentMethodDuringAuth(cartId,authResponse.gatewayResponse.gatewayAuthorizationCode,cardholderName,cardholderNickName,cardType);
                }
                
                if (authResponse!=null && authResponse.error != null) {
                    throw new AuraHandledException('AuthResponseError: ' + authResponse.error.message);
                }
            }catch(Exception e){
                logger.error(e);
                System.debug('Exception e->'+e+'---Message---'+e.getMessage()+'---Line Number --->'+e.getLineNumber());
            } finally {
                logger.flush();
            }
        return returnData;
        
    }

    private static String getPaymentGatewayId(String webStoreId) {
        return [SELECT Integration FROM StoreIntegratedService WHERE ServiceProviderType='Payment' AND StoreId=:webStoreId].Integration;
        
    } 
    
    // Set the cc info and the billing address
    private static ConnectApi.AuthApiPaymentMethodRequest getPaymentMethod(Map<String, Object> paymentInfo, Map<String, Object> billingAddress) {
        
        ConnectApi.AuthApiPaymentMethodRequest authApiMethod = new ConnectApi.AuthApiPaymentMethodRequest();
        
        ConnectApi.CardPaymentMethodRequest paymentMethod = new ConnectApi.CardPaymentMethodRequest();
        paymentMethod.cardCategory = ConnectApi.CardCategory.CreditCard;
        paymentMethod.cardHolderName = (String) paymentInfo.get('cardHolderName');
        paymentMethod.cardNumber = (String) paymentInfo.get('cardNumber');
        paymentMethod.cardType = (String) paymentInfo.get('cardType');
        paymentMethod.cvv = (String) paymentInfo.get('cvv');
        paymentMethod.expiryMonth = Integer.valueOf(paymentInfo.get('expiryMonth'));
        paymentMethod.expiryYear = Integer.valueOf(paymentInfo.get('expiryYear'));        
        authApiMethod.cardPaymentMethod = paymentMethod;
        
        ConnectApi.AddressRequest address = new ConnectApi.AddressRequest();
        address.street = (String) billingAddress.get('street');
        address.city = (String) billingAddress.get('city');
        address.state = (String) billingAddress.get('state');
        address.country = (String) billingAddress.get('country');
        address.postalCode = (String) billingAddress.get('postalCode');
        authApiMethod.address = address;

        authApiMethod.saveForFuture = true;
        return authApiMethod;
    }

    private static ConnectApi.PaymentGroupRequest getPaymentGroup(String cartId) {
        ConnectApi.PaymentGroupRequest paymentGroup = new ConnectApi.PaymentGroupRequest();
        
        paymentGroup.createPaymentGroup = true;
        paymentGroup.currencyIsoCode = UserInfo.getDefaultCurrency();
        
        // if(!Test.IsRunningTest()) {
        //     String orderId = getOrderId(cartId);
        //     if (orderId != null && !orderId.equals('')) {
        //         paymentGroup.sourceObjectId = getOrderId(cartId);            
        //     }
        // }
        return paymentGroup;
    }

    private static String getOrderId(String cartId) {
        return [SELECT OrderId FROM CartCheckoutSession WHERE WebCartId=:cartId AND IsArchived=false].OrderId;
    }

    public static void createPaymentMethodDuringAuth(String cartId,String paymentId,String cardholderName,String cardholderNickName,String  cardType)
    {
        if(cartId !=null){

        
            WebCart cart = [SELECT Id, Name,Owner.Firstname,Owner.Lastname,Owner.Email,Owner.Phone,BillingStreet,
                            BillingCity,BillingState,BillingPostalCode, BillingCountry,GrandTotalAmount,CurrencyIsoCode,
                            AccountId,WebStoreId from  WebCart WHERE Id=:cartId];
        System.debug('cart------>'+cart);
        ContactPointAddress cpa = [SELECT Id,City,Country,PostalCode,State,Street FROM ContactPointAddress WHERE ParentId=:cart.AccountId AND AddressType='Billing' AND IsDefault=true  LIMIT 1];
        System.debug('cpa----->'+cpa);
        PMStreet = cpa.Street;
        PMCity = cpa.City;
        PMState = cpa.State;
        PMCountry = cpa.Country;
        PMPostalCode = cpa.PostalCode;
        currencyCode = cart.CurrencyIsoCode;
        
        }
         
        B2B_CybersourcePMScheduler obj = new B2B_CybersourcePMScheduler();
        obj.cardholderName = cardholderName;
        obj.cardholderNickName = cardholderNickName;
        obj.cardType = cardType;
        //obj.OrderId = orderId;
        obj.PONumber = 'poNumber';
        obj.userId = userInfo.getUserId();
        obj.PMStreet = PMStreet;
        obj.PMCity = PMCity;
        obj.PMState = PMState;
        obj.PMCountry = PMCountry;
        obj.PMPostalCode = PMPostalCode;
        obj.isUpdateToken=false;
        system.debug('paymentId---'+paymentId);
        // system.debug('chronExpression---'+chronExpression);
        // system.debug('sysTime---'+sysTime);
        if(paymentId!=null){
            obj.paymentId = paymentId;//authGatewayRes.gatewayAuthorizationCode;
            //obj.payAuthId = payAuthResp.Id;
        }
        obj.currencyCode = currencyCode;

        //for(Integer i=0; i<60; i=i+1){
            // String str = String.valueof(Math.abs(Crypto.getRandomLong()));
            // String randomNumber = str.substring(0, 6);

            // String hour = String.valueOf(Datetime.now().hour());
            // String min = String.valueOf(Datetime.now().minute()); 
            // String ss = String.valueOf(Datetime.now().second() + 5);

            // //parse to cron expression
            // String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
            
            // String jobID = System.schedule('B2B_CybersourcePMScheduler' + ' : ' + randomNumber , nextFireTime, obj);
            

            	
            String jobID = System.enqueueJob(obj);
            System.debug('Scheduled Job ID: ' + jobID);
        //}
        
    }
    
    public static string AuthorizationAPI(String webstoreId,String cartId,String jwtToken,String legacyToken,String transactionId,Map<String,String> liabilityShift)
    {
        try{
            //Order ord=[select id,AccountId,B2B_Payment_Token__c from Order where Cart__c =:cartId order by createddate desc limit 1 ];
            B2B_CYBS_Merchant__mdt cyberSource=B2B_CYBSPaymentContoller.getMerchant();
            //if(cartId != null){
            System.debug('CartId----->'+CartId);
            System.debug('webstoreId----->'+webstoreId);
            WebCart cart = [SELECT Id,GrandTotalAmount,AccountId, CurrencyIsoCode, BillingCountry FROM WebCart WHERE Id=:cartId LIMIT 1];
            System.debug('cart----->'+cart);
            B2B_CybersourceRESTUtility.getCYBSConfiguration(); 
            //}
            String requestBody;
            if(jwtToken !=null)
            {
                requestBody=genrateAuthorizationRequest(cartId,jwtToken,null,transactionId,liabilityShift,webstoreId, null);
            }
            if(legacyToken !=null)
            {
                requestBody=genrateAuthorizationRequest(cartId,null,legacyToken,transactionId,liabilityShift,webstoreId, null);
            }
            
            System.debug('Authorize Request --->'+requestBody);
            HttpRequest request = B2B_CybersourceRESTUtility.generatePostRequest('/pts/v2/payments', requestBody);
            Http http = new Http();
            string responseBody;
            HttpResponse response = http.send(request);
            responseBody = response.getBody();
            System.debug('Authorize Resposne--->'+responseBody);
            Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
            Map<String,String> data=new Map<String,String>();
            System.debug('Authorize (string)resMap.get--->'+(string)resMap.get('status'));
            if((string)resMap.get('status') =='AUTHORIZED')
            {
                data.put('status','Success');
            }
            else {
                data.put('status','Decline');
            }
            
            data.put('amount',String.valueOf(roundAmountValue(cart.GrandTotalAmount)));
            data.put('accountId',cart.AccountId);
            
            createPaymentAuthRecord(requestBody,responseBody,resMap,data);
            //getLegacyTokenUpdateOnOrder(ord,String.valueOf(resMap.get('id')));
            return responseBody;
        }
        catch(Exception e)
        {
            System.debug(e.getMessage());
            logger.error(e);
            return e.getMessage();
        }
         finally {
            logger.flush();
        }
    }
    
    
    public static Map<String,String> getCardDetail(String token)
    {
        String jwtTokenbody = token.split('\\.')[1]; 
        Blob decodedJWTToken = EncodingUtil.base64Decode(jwtTokenbody); 
        Map<String, Object> jwtTokenDataMap = (Map<String, Object>)JSON.deserializeUntyped(decodedJWTToken.toString()); 
        String jtiToken = (String)jwtTokenDataMap.get('jti');
        System.debug('___Decode jti Token -- ' + jtiToken);
        System.debug('___Decode jwtData -- ' + jwtTokenDataMap);
        system.debug('Data--'+jwtTokenDataMap.get('data'));
        map<String,Object >mapData=(Map<String,Object>)jwtTokenDataMap.get('data');
        system.debug('expirationYear--'+mapData.get('expirationYear'));
        system.debug('expirationMonth--'+mapData.get('expirationMonth'));
        system.debug('type--'+mapData.get('type'));
        system.debug('number--'+mapData.get('number'));
        
        Map<String,String> cardData=new Map<String,String> ();
        cardData.put('expirationMonth',String.valueOf(mapData.get('expirationMonth')));
        cardData.put('expirationYear',String.valueOf(mapData.get('expirationYear')));
        String cardType='';
        if(String.valueOf(mapData.get('type'))=='001')
        {
            cardType='Visa';
        }
        if(String.valueOf(mapData.get('type'))=='002')
        {
            cardType='MasterCard';
        }
        
        cardData.put('type',cardType);
        cardData.put('number',String.valueOf(mapData.get('number')));
        return cardData;
        
    }
    
    
    
    
    public static string genrateEnrollmentRequest(String cartId,String token,String legacyToken,string referenceId,string transactionId)
    {
        WebCart cart=[Select id,GrandTotalAmount , CurrencyIsoCode ,Owner.FirstName,Owner.LastName,BillingStreet,BillingCity,AccountId,
                      BillingState,BillingPostalCode,BillingCountry,Owner.Email,Owner.Phone from Webcart where id=:cartId];
        
        
        ContactPointAddress cpa = [SELECT Id,City,Country,PostalCode,State,Street FROM ContactPointAddress WHERE ParentId=:cart.AccountId AND AddressType='Billing' AND IsDefault=true  LIMIT 1];
        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();
        
        jsGen.writeFieldName('clientReferenceInformation');
        jsGen.writeStartObject();
        
        jsGen.writeStringField('code', 'B2B_Commerce');
        jsGen.writeEndObject();
        
        jsGen.writeFieldName('orderInformation');
        
        jsGen.writeStartObject();
        jsGen.writeFieldName('amountDetails');
        jsGen.writeStartObject();
        if(cart.CurrencyIsoCode=='USD')
        {
            jsGen.writeStringField('totalAmount', string.valueOf(roundAmountValue(cart.GrandTotalAmount)));
        }
        else {
            jsGen.writeStringField('totalAmount', string.valueOf(roundAmountValue(cart.GrandTotalAmount)));
        }
        
        //currency has to be dynamic , pick from the quote currency field
        jsGen.writeStringField('currency', cart.CurrencyIsoCode);        
        jsGen.writeEndObject();
        
        jsGen.writeFieldName('billTo');
        jsGen.writeStartObject();
        
        
        //TODO - Update Contact fields to be pulled from request
        if(cart.Owner.Firstname != null){
            String fname = cart.Owner.Firstname;
            jsGen.writeStringField('firstName', fname.escapeUnicode());
        }
        if(cart.Owner.LastName != null) {
            String lname = cart.Owner.LastName;
            jsGen.writeStringField('lastName', lname.escapeUnicode());     
        }
        if(cart.BillingStreet != null){
            jsGen.writeStringField('address1', cpa.Street);
        }
        if(cart.BillingCity != null){
            jsGen.writeStringField('locality',cpa.City); 
        }
        if(cart.BillingState != null){
            jsGen.writeStringField('administrativeArea', cpa.State);
        }
        if(cart.BillingPostalCode != null){
            jsGen.writeStringField('postalCode', cpa.PostalCode);
        }
        if( cart.BillingCountry != null){
            jsGen.writeStringField('country', cpa.Country);
        }
        if(cart.Owner.Email != null){
            jsGen.writeStringField('email', cart.Owner.Email);
        }
        if(cart.Owner.Phone != null){
            jsGen.writeStringField('phoneNumber', cart.Owner.Phone); 
        }
        jsGen.writeEndObject();
        jsGen.writeEndObject();
        
        
        if(legacyToken ==null){
            jsGen.writeFieldName('tokenInformation');
            jsGen.writeStartObject();
            jsGen.writeStringField('transientTokenJwt', token);
            jsGen.writeEndObject();
        }
        else {
            jsGen.writeFieldName('paymentInformation');
            jsGen.writeStartObject();
            jsGen.writeFieldName('legacyToken');
            jsGen.writeStartObject();
            jsGen.writeStringField('id', legacyToken);
            jsGen.writeEndObject();
            jsGen.writeEndObject();
        }
        
        
        //Buyer information -start
        if(cart.Owner.Phone != null){
            jsGen.writeFieldName('buyerInformation');
            jsGen.writeStartObject();
            
            jsGen.writeStringField('mobilePhone', cart.Owner.Phone);
            
            jsGen.writeEndObject();
        }
        //By=uyer Information -end
        
        
        //consumer detail
        jsGen.writeFieldName('consumerAuthenticationInformation');
        jsGen.writeStartObject();
        if(transactionId==null)
        {
            jsGen.writeStringField('referenceId', referenceId);
            jsGen.writeStringField('transactionMode', 'S');
            jsGen.writeStringField('returnUrl', System.Label.B2B_StoreUrl+'/s/paymentprocessing');
            jsGen.writeStringField('challengeCode', '4');
            // jsGen.writeStringField('acsWindowSize', '05');
        }
        else {
            jsGen.writeStringField('authenticationTransactionId', transactionId);
        }
        
        jsGen.writeEndObject();
        //consumer details end
        
        
        //processingInformation detail
        jsGen.writeFieldName('processingInformation');
        jsGen.writeStartObject();
        jsGen.writeFieldName('actionList');
        jsGen.writeStartArray ();
        if(transactionId==null)
        {
            jsGen.writeString('CONSUMER_AUTHENTICATION');
            if(legacyToken ==null){
                jsGen.writeString('TOKEN_CREATE');
            }
           jsGen.writeEndArray ();
            
        }
        else {
            jsGen.writeString('VALIDATE_CONSUMER_AUTHENTICATION');
            jsGen.writeEndArray ();
             
        }
        
        if(transactionId==null && legacyToken ==null)
        {
            jsGen.writeFieldName('actionTokenTypes');
            jsGen.writeStartArray ();
            jsGen.writeString('customer');
            jsGen.writeString('paymentInstrument');
            jsGen.writeString('instrumentIdentifier');
            jsGen.writeEndArray ();
        }
        jsGen.writeEndObject();
        //processingInformation details end
        
        
        jsGen.writeEndObject();      
        
        return jsGen.getAsString();
    }
    
    //this method is for getting list stored wallet of current user
    @AuraEnabled
    public static List<DigitalWallet> getStoredWallet() {
        
        String contactId = [SELECT ContactId FROM User WHERE Id=:userInfo.getuserId()].ContactId;
        return [SELECT Id, IsDefault__c, Card_Type__c,Display_Card_Number__c,Contact__c,ExpiryYear__c,
                Contact__r.Name,ExpiryMonth__c,CardHolderName__c,NickName  FROM 
                DigitalWallet WHERE Contact__c=:contactId AND Status='Active' order by CreatedDate desc];
        
        
        
    }
    
    @AuraEnabled
    public static Map<String,Object>  checkoutUsingStoredPaymentInv(String orderId, String webstoreId, String cartId, String storedPaymentId,string userCurrencyCode, String receiptId) {
        Map<String,Object> returnData = new Map<String,Object>();
        try {
            System.debug('storedPaymentId---->'+storedPaymentId);
            DigitalWallet dw = [SELECT Id, GatewayToken, CardLastFour__c, ExpiryMonth__c, ExpiryYear__c, CardHolderName__c FROM DigitalWallet WHERE Id=:storedPaymentId LIMIT 1];
            returnData.put('DigitalWallet', dw);
            String token = dw.GatewayToken;
            String cardNumber = String.valueOf(dw.CardLastFour__c);
            System.debug('token---->'+token);
            Decimal expYear;
            Decimal expMonth;
            Date expDate;
            if(dw.ExpiryMonth__c != null){
                expMonth = dw.ExpiryMonth__c;
            }else{
                System.debug('stored card doesnot have expiry month');
                //expMonth = Decimal.valueOf((String)expirationMonth);
            }

            if(dw.ExpiryYear__c != null){
                expYear = dw.ExpiryYear__c;
            }else{
                System.debug('stored card doesnot have expiry Year');
                //expMonth = Decimal.valueOf((String)expirationMonth);
            }

            if(expMonth != null || expYear != null){
                expDate = Date.newinstance(Integer.valueOf(expYear), Integer.valueOf(expMonth), 1);
            }else{
                System.debug('stored card doesnot have expiry date');
            }

            Payment_Receipt__c receipt = new Payment_Receipt__c();
                receipt.Id = receiptId;
                receipt.Credit_Card_Expiration_Date__c = expDate;       //Date.newinstance(Integer.valueOf((String)card.get('expirationYear')), Integer.valueOf((String)card.get('expirationMonth')), 1);
                receipt.Credit_card_holder_Name__c = dw.CardHolderName__c;
                receipt.Credit_Card_Number__c = 'XXXXXXXXXXXX'+ (String) cardNumber;
                receipt.Credit_Card_Token__c = (string) token;
                receipt.Receipt_Status__c = 'Initiated';
                update receipt;
                returnData.put('receipt', receipt);

                //call to oracle api 
                B2BOraclePaymentCallout obj = new B2BOraclePaymentCallout();
                obj.receiptId = receiptId;
                String jobID = System.enqueueJob(obj);
                System.debug('Scheduled Job ID: ' + jobID);
                returnData.put('B2BOraclePaymentCalloutJobId', jobID);
        } catch (Exception e) {
            logger.error(e);
            returnData.put('error', e);
        } finally {
            logger.flush();
        }
        return returnData;
    }
    
    @AuraEnabled
    public static Map<String,Object>  checkoutUsingStoredPayment(String orderId, String webstoreId, String cartId, String storedPaymentId,string userCurrencyCode) {
        Map<String,Object> authResponse = null;
        try{
            System.debug('storedPaymentId---->'+storedPaymentId);
            DigitalWallet dw = [SELECT Id, GatewayToken, CardLastFour__c FROM DigitalWallet WHERE Id=:storedPaymentId LIMIT 1];
        
            String token = dw.GatewayToken;
            String cardNumber = String.valueOf(dw.CardLastFour__c);
            System.debug('token---->'+token);
            authResponse = AuthorizationAPI(orderId,webstoreId, cartId,token,false,null,null,null,null,null,null,false, false, null, true, cardNumber);
            // boolean isSaveCard, String cardType,String isJWT)
        }catch(Exception e){
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        
        return authResponse;
    }
    
    
    // @auraEnabled
    // public static List<PaymentMethodElement> getPaymentMethods(){
    //     String contactId = [SELECT ContactId FROM User WHERE Id=:userInfo.getuserId()].ContactId;
    //     List<PaymentMethodElement> payMethElemList = new List<PaymentMethodElement>();
        
    //     List<B2B_PaymentMethod__c> payMethList = [SELECT Id, B2B_Card_Type__c,B2B_Card_Number__c,B2B_Contact__c,B2B_Card_Expiration_Year__c,
    //                                               B2B_Contact__r.Name,B2B_Card_Expiration_Month__c,B2B_Nick_Name__c,B2B_Nameoncard__c,B2B_PaymentGatewayToken__c FROM 
    //                                               B2B_PaymentMethod__c WHERE B2B_Contact__c=:contactId AND B2B_Active__c=true order by CreatedDate desc];
        
        
    //     for(B2B_PaymentMethod__c payMethod: payMethList){
            
    //         PaymentMethodElement payMeth = new PaymentMethodElement();
    //         payMeth.payMethId = payMethod.Id;
    //         payMeth.ccNumber = 'XXXXXXXXXXXX'+payMethod.B2B_Card_Number__c;
    //         payMeth.cardType = payMethod.B2B_Card_Type__c;
    //         payMeth.expMonth = payMethod.B2B_Card_Expiration_Month__c;
    //         payMeth.expYear = payMethod.B2B_Card_Expiration_Year__c;
    //         payMeth.nickName = payMethod.B2B_Nick_Name__c;
    //         payMeth.token = payMethod.B2B_PaymentGatewayToken__c;
            
    //         payMethElemList.add(payMeth);
            
    //     }
    //     return payMethElemList;
    // }
    
    @auraEnabled
    public static String deletePaymentMethod(String storedPaymentId){
        String result;
        System.debug('storedPaymentId----->'+storedPaymentId);
        try{
            System.debug('storesdPaymentId----->'+[SELECT Id FROM DigitalWallet WHERE Id=:storedPaymentId]);
            Delete [SELECT Id FROM DigitalWallet WHERE Id=:storedPaymentId];
            result = 'Delete Successfully';
        }catch(Exception e){
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }
    @auraEnabled
    public static String updateWalletInfo(String storedPaymentId){
        String result;
        System.debug('storedPaymentId----->'+storedPaymentId);
        try{
            System.debug('storesdPaymentId----->'+[SELECT Id FROM DigitalWallet WHERE Id=:storedPaymentId]);
            List<DigitalWallet> digiWalletList =  [SELECT Id,IsDefault__c FROM DigitalWallet Where Status='Active' Order By Createddate Desc Limit 2000];
            if(digiWalletList.size() > 0){
                for(DigitalWallet digiWallet : digiWalletList){
                    if(digiWallet.Id == storedPaymentId){
                        digiWallet.IsDefault__c = true;
                    }else{
                        digiWallet.IsDefault__c = false;
                    }
                }
            }
            update digiWalletList;
            
            result = 'Updated Successfully.';
        }catch(Exception e){
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }
        return result;
    }
//     @auraEnabled
//     public static String checkoutWithPONumber(String cartid,String ponumber)//String orderId,
//     {
//         WebCart cart=[Select id,PoNumber,AccountID from WebCart where Id=:cartid];
        
//         // Get the billingAddresses
//         List<ContactPointAddress>  addresses = 
//             [
//                 SELECT Id, IsDefault, City, Street, State, Country, PostalCode, GeocodeAccuracy, Latitude, Longitude, Name 
//                 FROM ContactPointAddress 
//                 WHERE AddressType='Billing' AND ParentId=:cart.AccountID AND B2B_Bill_To__c=true
                
//             ];
//         if(!addresses.isEmpty())
//         {
//             cart.BillingStreet = addresses[0].Street;
//             cart.BillingCity = addresses[0].City;
//             cart.BillingState = addresses[0].State;
//             cart.BillingCountry = addresses[0].Country;
//             cart.BillingPostalCode = addresses[0].PostalCode;
//             cart.BillingLatitude = addresses[0].Latitude;
//             cart.BillingLongitude = addresses[0].Longitude;
            
//         }
        
        
//         cart.PoNumber=ponumber;
//         update cart;
        
//         /*Order ord=[Select id,PurchaseOrder__c  from Order where Id=:orderId];
// ord.PurchaseOrder__c =ponumber;
// update ord;*/
//         return ponumber;
        
//     }
    
    //this method is used to create new Payment Method record
    @auraEnabled
    public static void createPaymentMethod(String street, String city, String token, String state, String country, String postalCode,String currencySym, String cardName, String cardNickName, String selectedYear, String selectedMonth, String cardType){
        PMStreet = street;
        PMCity = city;
        PMState = state;
        PMCountry = country;
        PMPostalCode = postalCode;
        currencyCode = currencySym;
        try{
        string resp = ZeroAmountAuthorizationAPI(token,cardName,cardNickName,cardType);
         }catch(Exception e)
        {
            System.debug(e.getMessage());
            logger.error(e); 
        }
        finally {
            logger.flush();
        }
         
        //handlePostPayment(null, null, token, null, selectedMonth, selectedYear, cardName, cardNickName, cardType, 'True',true); 
    }
    
    public static String ZeroAmountAuthorizationAPI(String token,String cardholderName,string cardholderNickName,string cardType)
    {
        B2B_CYBS_Merchant__mdt cyberSource=B2B_CYBSPaymentContoller.getMerchant();
        B2B_CybersourceRESTUtility.getCYBSConfiguration(); 
        
        String requestBody=genrateZeroAmountAuthorizationRequest(token);
        System.debug('Authorize Request --->'+requestBody);
            HttpRequest request = B2B_CybersourceRESTUtility.generatePostRequest('/pts/v2/payments', requestBody);
            Http http = new Http();
            string responseBody;
            HttpResponse response = http.send(request);
            responseBody = response.getBody();
            System.debug('Authorize Resposne--->'+responseBody);
            Map<String, Object> resMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
             if((string)resMap.get('status') =='AUTHORIZED')
            {
                 //call save card request
                 String paymentId=String.valueOf(resMap.get('id'));
                // createPaymentMethodDuringAuth(null,null,paymentId,cardholderName,cardholderNickName,cardType);
        
            }

        return '';
    }
    
    public static string genrateZeroAmountAuthorizationRequest(string token)
    {

        
        User u = [select id,FirstName,LastName,Email,Phone from User where id=:UserInfo.getUserId()];
        String AccountId = [SELECT AccountId FROM User WHERE Id=:UserInfo.getUserId()].AccountId;
        ContactPointAddress cpa = [SELECT Id,City,Country,PostalCode,State,Street FROM ContactPointAddress WHERE ParentId=:AccountId AND AddressType='Billing' AND IsDefault=true  LIMIT 1];
        String AccountCyrrency = [SELECT Account.CurrencyIsoCode FROM User WHERE Id=:UserInfo.getUserId()].Account.CurrencyIsoCode;

        PMStreet = cpa.Street;
        PMCity = cpa.City;
        PMState = cpa.State;
        PMCountry = cpa.Country;
        PMPostalCode = cpa.PostalCode;

        System.debug('user----->'+u);
        System.debug('token----->'+token);
        System.debug('PMStreet----->'+PMStreet);
        System.debug('PMCity----->'+PMCity);
        System.debug('PMState----->'+PMState);
        System.debug('PMPostalCode----->'+PMPostalCode);
        System.debug('PMCountry----->'+PMCountry);
        JSONGenerator jsGen = JSON.createGenerator(true);
        jsGen.writeStartObject();

        jsGen.writeFieldName('clientReferenceInformation');
        jsGen.writeStartObject();

        jsGen.writeStringField('code', 'B2B_Commerce');
        jsGen.writeEndObject();

        jsGen.writeFieldName('orderInformation');

        jsGen.writeStartObject();
        jsGen.writeFieldName('amountDetails');
        jsGen.writeStartObject();
        jsGen.writeStringField('totalAmount', string.valueOf(0.0));

        //currency has to be dynamic , pick from the quote currency field
        //Hard code for now arun Sood : 25 aug
        jsGen.writeStringField('currency', AccountCyrrency);        
        jsGen.writeEndObject();

        jsGen.writeFieldName('billTo');
        jsGen.writeStartObject();


        //TODO - Update Contact fields to be pulled from request
         
        jsGen.writeStringField('firstName', u.Firstname);
        
       
        jsGen.writeStringField('lastName', u.LastName);     
        
        
        jsGen.writeStringField('address1', PMStreet);
        
        
        jsGen.writeStringField('locality',PMCity); 
        
         
        jsGen.writeStringField('administrativeArea',PMState);
        
        
        jsGen.writeStringField('postalCode', PMPostalCode);
        
         
        jsGen.writeStringField('country', PMCountry);
        
        System.debug('u.Email----->'+u.Email);
        jsGen.writeStringField('email', u.Email);
        System.debug('u.Phone----->'+u.Phone);
        if(u.Phone !=null) 
         jsGen.writeStringField('phoneNumber', u.Phone); 
        
        jsGen.writeEndObject();
        jsGen.writeEndObject();

         
        jsGen.writeFieldName('tokenInformation');
        jsGen.writeStartObject();
        jsGen.writeStringField('transientTokenJwt', token);
        jsGen.writeEndObject();
        

        System.debug('u.Phone----->');

        //Buyer information -start
        if(u.Phone != null){
        jsGen.writeFieldName('buyerInformation');
        jsGen.writeStartObject();


        jsGen.writeStringField('mobilePhone', u.Phone);

        jsGen.writeEndObject();
        }
        
        //processingInformation detail
          
        jsGen.writeFieldName('processingInformation');
        jsGen.writeStartObject();
        jsGen.writeFieldName('actionList');
        jsGen.writeStartArray ();
        jsGen.writeString('TOKEN_CREATE');
        jsGen.writeEndArray ();
        jsGen.writeFieldName('actionTokenTypes');
        jsGen.writeStartArray ();
        jsGen.writeString('customer');
        jsGen.writeString('paymentInstrument');
        jsGen.writeString('instrumentIdentifier');
        jsGen.writeEndArray ();

        jsGen.writeEndObject();
        
         
        //processingInformation details end

        jsGen.writeEndObject();      

        return jsGen.getAsString();
    }
    
    public static void createPaymentAuthRecord(String request,String responseBody,Map<String, Object> response,Map<String,String> data)
    {
        PaymentAuthorization pa = new PaymentAuthorization();
        pa.Amount =double.valueOf(data.get('amount'));
        pa.status = 'Processed';
        pa.processingmode='External';
        pa.GatewayAuthCode = (string)response.get('id');
        pa.GatewayResultCode = (string)response.get('status');
        pa.GatewayResultCodeDescription = (string)response.get('status');
        pa.GatewayDate = System.now();
        pa.AccountId = data.get('accountId');
        // pa.Order__c= orderId;
        // pa.Request__c=request;
        // pa.Response__c=responseBody;
        insert pa;
        
    }
    
    
    // public static void getLegacyTokenUpdateOnOrder(Order ord,String paymentId)
    // {
    //     //Call scheduler 
    //     System.debug('Create Payment card in Org');
    //     Datetime sysTime = System.now().addSeconds( 10 );
    //     String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
    //     B2B_CybersourcePaymentMethodScheduler obj = new B2B_CybersourcePaymentMethodScheduler();
    //     obj.OrderId =String.valueOf(ord.id);
    //     obj.isUpdateToken=true;
    //     system.debug('paymentId---'+paymentId);
    //     if(paymentId!=null){
    //         obj.paymentId = paymentId; 
    //     }
        
    //     System.schedule( 'B2B_CybersourceUpdateLegacyToken ' + sysTime, chronExpression,obj);
    // }

    public static Decimal roundAmountValue(Decimal amount )
    {   
        //Decimal toround = 6700.788;
        //.info('Autherized Amount Before rounding>>> '+ amount);
        Decimal rounded = amount.setScale(2, RoundingMode.CEILING);
        //logger.info('Autherized Amount After rounding>>> '+ rounded);
        //logger.flush();
        return rounded;
    }
    
    
    public class PaymentMethodElement{
        @auraEnabled public String payMethId;
        @auraEnabled public String ccNumber;
        @auraEnabled public String cardType;
        @auraEnabled public string expMonth;
        @auraEnabled public string expYear;
        @auraEnabled public string nickName;
        @auraEnabled public String token;
        
        
    }

    @AuraEnabled

    public static void deactivatePaymentMethod(String storedPaymentId) {

        try {

            DigitalWallet wallet = new DigitalWallet(Id = storedPaymentId, Status = 'InActive');

            update wallet;

        } catch(Exception e) {
            logger.error(e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            logger.flush();
        }

    }

    // copied from B2BUtils
    private static Map<String, String> communityIdToWebStoreIdCache = new Map<String, String>();

    public static String retrieveWebStoreIdByCommunityId() {
        
        //String communityId = retrieveCommunityId();
        //String webStoreId = null;

        List<Webstore> lstWS = new List<Webstore>();
        lstWS = [Select Id from Webstore where Name='Zimvie'];

        if(lstWS != null && lstWS.size() > 0){
            return String.valueof(lstWS[0].Id);
        } else{
            return null;
        }
        /*System.debug('retrieveWebStoreIdByCommunityId:communityId:  '+communityId);
        if (communityIdToWebStoreIdCache.containsKey(communityId)) {
            return communityIdToWebStoreIdCache.get(communityId);
        } else {
            List<WebStoreNetwork> lstWebStoreNetworks = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId];
            if (lstWebStoreNetworks!=null && lstWebStoreNetworks.size()>0) {
                webStoreId = lstWebStoreNetworks[0].WebStoreId;
                communityIdToWebStoreIdCache.put(communityId, webStoreId);
            }
            System.debug('retrieveWebStoreIdByCommunityId:webStoreId : '+webStoreId);
        }
        return webStoreId;*/
    }
  
    public static String retrieveCommunityId() {
        System.debug('retrieveCommunityId run');

        ConnectApi.CommunityPage communityPageObject = ConnectApi.Communities.getCommunities();
        String communityId = '';
        System.debug('communityPageObject:webStoreId : '+communityPageObject);
        for (ConnectApi.Community communityObj : communityPageObject.communities) {
            System.debug('communityObj.templateName:webStoreId : '+communityObj.templateName);
            if (communityObj.templateName == B2BConstants.COMMUNITY_TEMPLATE_NAME) {
                communityId = communityObj.id;
            }
        }
        return communityId;
    }

    public class B2B_Address {
        public String street;
        public String city;
        public String stateCode;
        public String province;
        public String postalcode;
        public String countryCode;
        public String country;
    }

    public static String getMaskedCardValue(String tempJWTToken) {

        if(String.isNotBlank(tempJWTToken)) {
            String jwtTokenbody = tempJWTToken.split('\\.')[1]; 
            Blob decodedJWTToken = EncodingUtil.base64Decode(jwtTokenbody); 
            Map<String, Object> jwtTokenDataMap = (Map<String, Object>)JSON.deserializeUntyped(decodedJWTToken.toString()); 
            Map<String, Object> issData = (Map<String, Object>)jwtTokenDataMap.get('content');
            Map<String, Object> issData1 = (Map<String, Object>)issData.get('paymentInformation');
            Map<String, Object> issData2 = (Map<String, Object>)issData1.get('card');
            Map<String, Object> issData3 = (Map<String, Object>)issData2.get('number');
            String issData4 = (String)issData3.get('maskedValue');
            issData4 = issData4.replace('X','0');
            System.debug('___Decode issData' + issData4);
            return issData4;
        } 
        return null;
    }

}