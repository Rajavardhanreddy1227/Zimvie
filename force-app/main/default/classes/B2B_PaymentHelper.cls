/**
 * @description       : 
 * @author            : asood@rafter.one
 * @group             : 
 * @last modified on  : 07-05-2023
 * @last modified by  : asood@rafter.one
**/
public with sharing class B2B_PaymentHelper {
    private static final String CLASSNAME = 'B2BPaymentHelper';    

    public static void setPayment(Map<String,Object> dataMap) {

        String methodName = 'setPayment';
        // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_ENTRY , 'Started');
        // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , 'input param dataMap');
        // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , JSON.serialize(dataMap));

        if(dataMap != null){        
            String paymentType;
            String cartId;
            Map<String, Object> billingAddress;
            Map<String, Object> paymentInfo;
            String customerToken;
            if(dataMap.containsKey(B2BConstants.PAYMENT_TYPE) && dataMap.get(B2BConstants.PAYMENT_TYPE)!=null){
                paymentType = (String) dataMap.get(B2BConstants.PAYMENT_TYPE);
            }
            if(dataMap.containsKey(B2BConstants.CART_ID) && dataMap.get(B2BConstants.CART_ID)!=null){
                cartId = (String) dataMap.get(B2BConstants.CART_ID);
            }
            if(dataMap.containsKey(B2BConstants.CUSTOMER_TOKEN) && dataMap.get(B2BConstants.CUSTOMER_TOKEN)!=null){
                customerToken = (String) dataMap.get(B2BConstants.CUSTOMER_TOKEN);
            }
            if(dataMap.containsKey(B2BConstants.BILLING_ADDRESS) && dataMap.get(B2BConstants.BILLING_ADDRESS)!=null){
                billingAddress = (Map<String, Object>) JSON.deserializeUntyped((String)dataMap.get(B2BConstants.BILLING_ADDRESS));
            }
            if(dataMap.containsKey(B2BConstants.PAYMENT_INFO) && dataMap.get(B2BConstants.PAYMENT_INFO)!=null){
                paymentInfo = (Map<String, Object>) JSON.deserializeUntyped((String)dataMap.get(B2BConstants.PAYMENT_INFO));
            }
            String webStoreId;
            WebCart cart;
            Boolean billAddressSet = billingAddress != null && !billingAddress.isEmpty();
            if(String.isNotBlank(cartId)){
                String queryFields = 'PONumber, PaymentMethodId, WebStoreId, AccountId,GrandTotalAmount';

                // Billing Address might have been hidden
                if (billAddressSet) {
                    queryFields += ', BillingAddress';
                }

                String soqlQuery = 'SELECT ' + queryFields + ' FROM WebCart WHERE Id=:cartId LIMIT 1';
                cart = Database.query(soqlQuery);

                webStoreId = cart.WebStoreId;

                // Update the billingAddress
                // If it was not set, then set the cart.BillingAddress to empty
                cart.BillingStreet = billAddressSet ? (String) billingAddress.get('street') : '';
                cart.BillingCity = billAddressSet ? (String) billingAddress.get('city') : '';
                cart.BillingState = billAddressSet ? (String) billingAddress.get('state') : '';
                cart.BillingCountry = billAddressSet ? (String) billingAddress.get('country') : '';
                cart.BillingPostalCode = billAddressSet ? (String) billingAddress.get('postalCode') : '';
                cart.BillingLatitude = billAddressSet ? (Double) billingAddress.get('latitude') : null;
                cart.BillingLongitude = billAddressSet ? (Double) billingAddress.get('longitude') : null;
            }
                        
            // Update the payment information
            if (paymentType == B2BConstants.PAYMENT_TYPE_ACCOUNT) {
                if(cart != null){
                    cart.PoNumber = (String) paymentInfo.get('poNumber');
                    cart.PaymentMethodId = null;
                }
            } else {
                if(cart != null){
                    cart.PoNumber = null;
                }
                if(String.isBlank(webStoreId)){
                    webStoreId = B2BUtils.retrieveWebStoreIdByCommunityId();
                }
                // Let's first check that paymentGateway has been setup
                String paymentGatewayId = getPaymentGatewayId(webStoreId);

                // Cannot proceed if paymentGatewayId does not exist
                if (paymentGatewayId == null || paymentGatewayId.equals('')) {
                    throw new AuraHandledException('This store is not authorized to process payments.');
                }

                // Tokenize the paymentInfo
                ConnectApi.PaymentMethodTokenizationRequest tokenizeRequest = new ConnectApi.PaymentMethodTokenizationRequest();
                tokenizeRequest.paymentGatewayId = paymentGatewayId;
                tokenizeRequest.cardPaymentMethod = getCardPaymentMethod(paymentInfo);
                if (billAddressSet) {
                    tokenizeRequest.address = getAddress(billingAddress);                    
                }
                Map<String, String> additionalData = new Map<String, String>();
                if(String.isNotBlank(cartId)){
                    additionalData.put(B2BConstants.CART_ID,cartId);
                }
                System.debug('customerToken:'+customerToken);
                additionalData.put(B2BConstants.CUSTOMER_TOKEN,customerToken);
                additionalData.put(B2BConstants.CARD_NUMBER,(String) paymentInfo.get('cardNumber'));
                tokenizeRequest.additionalData= additionalData;

                ConnectApi.PaymentMethodTokenizationResponse tokenizeResponse;
                
                if(!Test.isRunningTest()){
                    tokenizeResponse = ConnectApi.Payments.tokenizePaymentMethod(tokenizeRequest);      
                }else{
                    tokenizeResponse = new ConnectApi.PaymentMethodTokenizationResponse();
                    ConnectApi.PaymentMethodResponse paymentMethod = new ConnectApi.PaymentMethodResponse();
                    paymentMethod.accountId = cart.AccountId;
                    paymentMethod.status = 'Active';
                    tokenizeResponse.paymentMethod = paymentMethod;
                }        
                
                if (tokenizeResponse.error != null) {
                    System.debug('TokenizeResponse has an error: ' + tokenizeResponse.error.message);
                    throw new AuraHandledException('There are issues finalizing your payment. Try contacting your account rep.');
                }
                // Tokenize was successful, assign the new payment method to the cart.
                if(cart != null){
                    cart.PaymentMethodId = tokenizeResponse.paymentMethod.id;
                }else{
                    dataMap.put(B2BConstants.PAYMENT_METHOD_ID, tokenizeResponse.paymentMethod.id);
                    B2BDigitalWalletHelper.createDigitalWallet(dataMap);
                }
            }

           // Now update the webCart
           if(cart != null && Schema.SObjectType.WebCart.isAccessible()) {
               update cart;                    
           }
        }
    }

    public static void setPaymentThroughWallet(Map<String,Object> dataMap) {

        String methodName = 'setPaymentThroughWallet';
        // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_ENTRY , 'Started');
        // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , 'input param dataMap');
        // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , JSON.serialize(dataMap));

        if(dataMap != null){      
            String cartId;
            String walletId;
            if(dataMap.containsKey(B2BConstants.DIGITAL_WALLET_ID) && dataMap.get(B2BConstants.DIGITAL_WALLET_ID)!=null){
                walletId = (String) dataMap.get(B2BConstants.DIGITAL_WALLET_ID);
            }
            if(dataMap.containsKey(B2BConstants.CART_ID) && dataMap.get(B2BConstants.CART_ID)!=null){
                cartId = (String) dataMap.get(B2BConstants.CART_ID);
            }

            if(String.isNotBlank(cartId) && String.isNotBlank(walletId)){
                List<DigitalWallet> digitalWallets = [SELECT CardHolderName__c,Card_Type__c, CardLastFour__c, Display_Card_Number__c, ExpiryMonth__c, ExpiryYear__c, GatewayToken, PaymentGatewayId, ProcessingMode, Status FROM DigitalWallet WHERE Id = :walletId];
                CardPaymentMethod paymentMethod;
                if(!digitalWallets.isEmpty()){
                    paymentMethod = new CardPaymentMethod();
                    paymentMethod.CardCategory = B2BConstants.CARD_CATEGORY;
                    paymentMethod.CardLastFour = Integer.valueOf(digitalWallets[0].CardLastFour__c);
                    paymentMethod.ExpiryMonth = Integer.valueOf(digitalWallets[0].ExpiryMonth__c);
                    paymentMethod.ExpiryYear = Integer.valueOf(digitalWallets[0].ExpiryYear__c);
                    paymentMethod.PaymentGatewayId = digitalWallets[0].PaymentGatewayId;
                    paymentMethod.ProcessingMode = digitalWallets[0].ProcessingMode;
                    paymentMethod.Status = digitalWallets[0].Status;
                    paymentMethod.GatewayToken = digitalWallets[0].GatewayToken;
                    paymentMethod.CardHolderName = digitalWallets[0].CardHolderName__c;
                    paymentMethod.CardType = digitalWallets[0].Card_Type__c;
                    upsert paymentMethod;
                }
                // Now update the webCart
                if(paymentMethod != null) {
                    WebCart cart = new WebCart(Id = cartId);
                    cart.PaymentMethodId = paymentMethod.Id;
                    update cart;                    
                }
            }
        }
    }

    // public static Map<String,Object> capturePayment(Map<String,Object> dataMap){

    //     String methodName = 'capturePayment';
    //     // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_ENTRY , 'Started');
    //     // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , 'input param dataMap');
    //     // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , JSON.serialize(dataMap));

    //     if(dataMap != null && dataMap.containsKey(B2BConstants.USER_ID) && dataMap.get(B2BConstants.USER_ID) != null &&
    //         dataMap.containsKey(B2BConstants.CAPTURE_AMOUNT) && dataMap.get(B2BConstants.CAPTURE_AMOUNT) != null && 
    //         dataMap.containsKey(B2BConstants.TOKEN_ID) && dataMap.get(B2BConstants.TOKEN_ID) != null
    //     ){

    //         String userId = (String)dataMap.get(B2BConstants.USER_ID);
    //         List<User> userList = [SELECT CurrencyIsoCode, Contact.AccountId FROM USER WHERE Id = :userId];
    //         User customerUser;
    //         if(!userList.isEmpty()){
    //             customerUser = userList[0];
    //         }

    //         if(customerUser == null || (customerUser != null && customerUser.Contact.AccountId == null)){
    //             dataMap.put(B2BConstants.IS_SUCCESS, false);
    //             dataMap.put(B2BConstants.MESSAGE, B2BConstants.CAPTURE_USER_NOT_FOUND);
    //             return dataMap;
    //         }

    //         dataMap.put(B2BConstants.ACCOUNT_ID_STR, customerUser.Contact.AccountId);
    //         dataMap.put(B2BConstants.CURRENCY_ISO_CODE, customerUser.CurrencyIsoCode);
    //         dataMap = authorizePaymentRequest(dataMap);
    //         Boolean isSuccess = false;
    //         if(dataMap.containsKey(B2BConstants.IS_SUCCESS) && dataMap.get(B2BConstants.IS_SUCCESS) != null){
    //             isSuccess = (Boolean)dataMap.get(B2BConstants.IS_SUCCESS);
    //         }
    //         if(isSuccess){
    //             dataMap = capturePaymentRequest(dataMap);
    //         }
    //     }else{
    //         dataMap.put(B2BConstants.IS_SUCCESS, false);
    //         dataMap.put(B2BConstants.MESSAGE, B2BConstants.CAPTURE_DATA_MISSING);
    //     }
    //     return dataMap;
    // }

    // public static Map<String,Object> authorizePaymentRequest(Map<String,Object> dataMap){
    //     String methodName = 'authorizePaymentRequest';
    //     // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_ENTRY , 'Started');
    //     // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , 'input param dataMap');
    //     // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , JSON.serialize(dataMap));

    //     if(dataMap != null && dataMap.containsKey(B2BConstants.ACCOUNT_ID_STR) && dataMap.get(B2BConstants.ACCOUNT_ID_STR) != null &&
    //         dataMap.containsKey(B2BConstants.CAPTURE_AMOUNT) && dataMap.get(B2BConstants.CAPTURE_AMOUNT) != null && 
    //         dataMap.containsKey(B2BConstants.TOKEN_ID) && dataMap.get(B2BConstants.TOKEN_ID) != null &&
    //         dataMap.containsKey(B2BConstants.CURRENCY_ISO_CODE) && dataMap.get(B2BConstants.CURRENCY_ISO_CODE) != null
    //     ){

    //         String accId = (String)dataMap.get(B2BConstants.ACCOUNT_ID_STR);
    //         Double amount = (Double)dataMap.get(B2BConstants.CAPTURE_AMOUNT);
    //         String token = (String)dataMap.get(B2BConstants.TOKEN_ID);
    //         String currencyCode = (String)dataMap.get(B2BConstants.CURRENCY_ISO_CODE);

    //         B2BCybersourceRESTUtility.getCYBSConfiguration(accId);
    //         HttpRequest req = new HttpRequest();
    //         String reqBody = B2BCybersourceRESTUtility.buildPaymentRestRequest(token, amount, currencyCode);
    //         System.debug(' reqBody   ' + reqBody);
    //         req = B2BCybersourceRESTUtility.generatePostRequest(B2BCybersourceRESTUtility.paymentURL, reqBody);
    //         Http http = new Http();
    //         HttpResponse response = new HttpResponse();
    //         response = http.send(req);
    //         String body = response.getBody();
    //         System.debug('resBody:'+body);
    //         Map<String, Object> results = new Map<String, Object>();   
    //         results = (Map<String, Object>) JSON.deserializeUntyped(body); 
    //         String status = (String) results.get('status');
    //         if(!status.equalsIgnoreCase(B2BConstants.AUTHORIZED_STATUS)){
    //             dataMap.put(B2BConstants.IS_SUCCESS, false);
    //             dataMap.put(B2BConstants.MESSAGE, (String)results.get('reason'));
    //             dataMap.put(B2BConstants.HTTP_RESPONSE, results);
    //             return dataMap;
    //         }
    //         String paymentId = (String)results.get('id');
    //         dataMap.put(B2BConstants.PAYMENT_ID, paymentId);
    //         dataMap.put(B2BConstants.IS_SUCCESS, true);
    //     }else{
    //         dataMap.put(B2BConstants.IS_SUCCESS, false);
    //         dataMap.put(B2BConstants.MESSAGE, B2BConstants.CAPTURE_DATA_MISSING);
    //     }
    //     return dataMap;
    // }

    // public static Map<String,Object> capturePaymentRequest(Map<String,Object> dataMap){

    //     String methodName = 'capturePaymentRequest';
    //     // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_ENTRY , 'Started');
    //     // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , 'input param dataMap');
    //     // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , JSON.serialize(dataMap));

    //     if(dataMap != null && dataMap.containsKey(B2BConstants.PAYMENT_ID) && dataMap.get(B2BConstants.PAYMENT_ID) != null &&
    //         dataMap.containsKey(B2BConstants.CAPTURE_AMOUNT) && dataMap.get(B2BConstants.CAPTURE_AMOUNT) != null && 
    //         dataMap.containsKey(B2BConstants.CURRENCY_ISO_CODE) && dataMap.get(B2BConstants.CURRENCY_ISO_CODE) != null &&
    //         dataMap.containsKey(B2BConstants.ACCOUNT_ID_STR) && dataMap.get(B2BConstants.ACCOUNT_ID_STR) != null
    //     ){

    //         String paymentId = (String)dataMap.get(B2BConstants.PAYMENT_ID);
    //         Double amount = (Double)dataMap.get(B2BConstants.CAPTURE_AMOUNT);
    //         String currencyCode = (String)dataMap.get(B2BConstants.CURRENCY_ISO_CODE);
    //         String accId = (String)dataMap.get(B2BConstants.ACCOUNT_ID_STR);

    //         B2BCybersourceRESTUtility.getCYBSConfiguration(accId);

    //         HttpRequest req = new HttpRequest();
    //         String reqBody = B2BCybersourceRESTUtility.buildCaptureRestRequest(amount, currencyCode);
    //         System.debug(' reqBody   ' + reqBody);
    //         req = B2BCybersourceRESTUtility.generatePostRequest('/pts/v2/payments/'+paymentId+'/captures', reqBody);
    //         Http http = new Http();
    //         HttpResponse response = new HttpResponse();
    //         response = http.send(req);
    //         String body = response.getBody();
    //         System.debug('resBody:'+body);
    //         Map<String, Object> results = new Map<String, Object>();  
    //         results = (Map<String, Object>) JSON.deserializeUntyped(body); 
    //         String status = (String) results.get('status');
    //         if(!status.equalsIgnoreCase(B2BConstants.PENDING_STATUS)){
    //             dataMap.put(B2BConstants.IS_SUCCESS, false);
    //             dataMap.put(B2BConstants.MESSAGE, B2BConstants.CAPTURE_FAILED);
    //             dataMap.put(B2BConstants.HTTP_RESPONSE, results);
    //             return dataMap;
    //         }
    //         dataMap.put(B2BConstants.IS_SUCCESS, true);
    //         dataMap.put(B2BConstants.HTTP_RESPONSE, results);
    //     }else{
    //         dataMap.put(B2BConstants.IS_SUCCESS, false);
    //         dataMap.put(B2BConstants.MESSAGE, B2BConstants.CAPTURE_DATA_MISSING);
    //     }
    //     return dataMap;
    // }
    

    private static String getPaymentGatewayId(String webStoreId) {
        String paymentGatewayId = null;
        try {
            paymentGatewayId = [SELECT Integration FROM StoreIntegratedService WHERE ServiceProviderType='Payment' AND StoreId=:webStoreId].Integration;
        } catch (Exception e) {
            // For debug logs
            System.debug('Error querying the payment integration from StoreIntegratedService: ' + e.getMessage());
        }
        return paymentGatewayId;
    }

    private static ConnectApi.CardPaymentMethodRequest getCardPaymentMethod(Map<String, Object> paymentInfo) {
        ConnectApi.CardPaymentMethodRequest paymentMethod = new ConnectApi.CardPaymentMethodRequest();
        paymentMethod.cardCategory = ConnectApi.CardCategory.CreditCard;
        paymentMethod.cardHolderName = (String) paymentInfo.get('cardHolderName');
        paymentMethod.cardNumber = (String) paymentInfo.get('cardNumber');
        paymentMethod.cardType = (String) paymentInfo.get('cardType');
        if (paymentInfo.get('cvv') != null) { //throws special error if this is missing
            paymentMethod.cvv = (String) paymentInfo.get('cvv');            
        }
        paymentMethod.expiryMonth = Integer.valueOf(paymentInfo.get('expiryMonth'));
        paymentMethod.expiryYear = Integer.valueOf(paymentInfo.get('expiryYear'));
        
        return paymentMethod;
    }

    private static ConnectApi.AddressRequest getAddress(Map<String, Object> billingAddress){
        ConnectApi.AddressRequest address = new ConnectApi.AddressRequest();
        address.street = (String) billingAddress.get('street');
        address.city = (String) billingAddress.get('city');
        address.state = (String) billingAddress.get('state');
        address.country = (String) billingAddress.get('country');
        address.postalCode = (String) billingAddress.get('postalCode');        
        return address;
    }
}