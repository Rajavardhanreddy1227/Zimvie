/* Raja Patnaik */
global virtual class B2BSalesforceAdapter implements commercepayments.PaymentGatewayAdapter {
    
    private static final commercepayments.SalesforceResultCodeInfo RC_SUCCESS = toCodeInfo(commercepayments.SalesforceResultCode.Success);
    private static final commercepayments.SalesforceResultCodeInfo RC_DECLINE = toCodeInfo(commercepayments.SalesforceResultCode.Decline);
    private static final String GATEWAY_RESPONSE_CODE = 'gateway_resp_code';
    private static final String STATUS = 'status';
    private static final String GATEWAY_MESSAGE = 'gateway_message';
    private static final String AMOUNT = 'amount';
    private static final String BANK_MESSAGE = 'bank_message';
    private static final String TRANSACTION_ID = 'transaction_id';
    private static final String BANK_RESPONSE_CODE = 'bank_resp_code';
    private static final String TRANSACTION_TAG = 'transaction_tag';
    private static final String CURRENCY_KEY = 'currency';
    private static final String TRANSACTION_STATUS = 'transaction_status';
    private static final String VALIDATION_STATUS = 'validation_status';
    protected final String PAYMENT_METHOD = 'method';
    private static final String TYPE = 'type';
    
    private static final commercepayments.SalesforceResultCodeInfo SUCCESS_SALESFORCE_RESULT_CODE_INFO =
            new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Success);
    private static final commercepayments.SalesforceResultCodeInfo DECLINE_SALESFORCE_RESULT_CODE_INFO =
            new commercepayments.SalesforceResultCodeInfo(commercepayments.SalesforceResultCode.Decline);
    protected boolean useCustomMetadata = false;

    global B2BSalesforceAdapter() {}


    private static commercepayments.SalesforceResultCodeInfo toCodeInfo(commercepayments.SalesforceResultCode code) {
        return new commercepayments.SalesforceResultCodeInfo(code);
    }

    global commercepayments.GatewayResponse processRequest(commercepayments.paymentGatewayContext gatewayContext) {
        System.debug('--gatewayContext--' + gatewayContext);
        commercepayments.RequestType requestType = gatewayContext.getPaymentRequestType();
        commercepayments.PaymentGatewayRequest paymentRequest = gatewayContext.getPaymentRequest();

        Boolean isDone = false;
        commercepayments.GatewayResponse response;
        String body = null;
        try {
            if (requestType == commercepayments.RequestType.Authorize) {
                response = createAuthResponse((commercepayments.AuthorizationRequest) paymentRequest);
            } else if (requestType == CommercePayments.RequestType.Tokenize) 
            {
                response = createPaymentInstrument((CommercePayments.PaymentMethodTokenizationRequest) paymentRequest);
            }
            return response;
        } catch (Exception e) {
            System.debug('--getStackTraceString--' + e.getStackTraceString());
            return new commercepayments.GatewayErrorResponse('400', e.getMessage());
        }


        // Below Code Commented by Arun Sood
        // To test Flex Form Code.

        // // For Authorize Turn Off all Callout Options in Named Credentials
        // // No Need to Pass Content Type or any Header
        // // Authorize.Net - https://apitest.authorize.net

        // HttpRequest req = new HttpRequest();

        // //req.setHeader('Content-Type', 'text/xml');
        // //req.setHeader('Content-Type', 'application/xml');
        // //req.setHeader('Content-Type', 'text/xml');
        // //req.setHeader('apikey', '{!$Credential.Username}');
        // //req.setHeader('token', '{!$Credential.Password}');
        
        
        // //req.setHeader('apikey', 'rpatnaik');
        // //req.setHeader('token', 'UhzFOauuPe5jkQw5M6Ystrp8W70aTOxJoZSVRdaJRkDR6hxakhZcid1QU85I0P7LFWviDxRSatKEwdALJ0xWI/OV/WTUjvFSw49Ret7fptC40InerekXoGI21WmLvDOq32v5qk6kBjgcOAejbyQKwUmLVcWUzjQtO0lEsPk+mjpsryYrik4yf/4WFCk34Vw9ok4l+OhrBO0eng6ZZpOzTTQ2jS4uTpGZluvA5G+HDkJTA0SS1hLWjz4IAV0KECJGR6yg93Q3tEaYB8ko0fcWcCPziBssiSyiTsPUqz+fiAWj4WpMqdfWel5GB15p5P3PyLEFXvJbPYE7RjdqOXPyvw==');

        // try
        // {
        //     if (requestType == commercepayments.RequestType.Authorize) {
        //          System.debug('RequestType authorization--- ' +requestType);
        //         //body = buildAuthRequest((commercepayments.AuthorizationRequest)gatewayContext.getPaymentRequest());
            
        //         System.debug(' getCommerceContext >>>>> ' + json.serialize(applauncher.CommerceStoreController.getCommerceContext()));
                    
        //             Map<String,Object> mapCurrentUserContext = applauncher.CommerceStoreController.getCommerceContext();

        //             System.debug('mapCurrentUserContext ' + mapCurrentUserContext);
        //             System.debug('mapCurrentUserContext ' + mapCurrentUserContext.get('webstoreId'));

        //             List<Webcart> webCartObj = [SELECT Id, Owner.FirstName, Owner.LastName,Owner.email, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet FROM Webcart WHERE webstoreID=: (String)mapCurrentUserContext.get('webstoreId') AND 
        //             OwnerId =: UserInfo.getUserId() AND Status in ('Active','Checkout')];
                    
        //             List<CartItem> cartItems = [SELECT Product2Id, Name, Id, CartId, Type, Sku, Quantity, 
        //             ListPrice,SalesPrice, TotalListPrice,TotalLineAmount  FROM CartItem WHERE 
        //             CartId =: webCartObj[0].Id];// AND Type = 'Product'];

        //             datetime dt = datetime.now();
        //             Map<String, String> params = new Map<String, String>();
        //             params.put('userName','{!$Credential.Username}');
        //             params.put('password','{!$Credential.Password}');
        //             params.put('merchantId','{!$Credential.Username}');
        //             params.put('mRefernceCode',String.valueOf(dt.gettime()));
                    
        //             params.put('firstName',webCartObj[0].Owner.FirstName);
        //             params.put('lastName',webCartObj[0].Owner.LastName);
        //             params.put('street','5156 S Dale Mabry Hwy');
        //             params.put('city','Tampa');
        //             params.put('state','NY');
        //             params.put('postalCode','33611');
        //             params.put('country','United States');
        //             params.put('email',webCartObj[0].Owner.email);
                   
        //             System.debug('PayeezyAdapter ' +cartItems);
                    
                    
        //             system.debug(' >>>>> '+ (commercepayments.AuthorizationRequest)gatewayContext.getPaymentRequest());
                   
        //             //body = B2BSoapToolKitAPI.ccSOAPAPI();
        //             body = B2BSoapToolKitAPI.getCCSoapXMLBody(params,cartItems,(commercepayments.AuthorizationRequest)gatewayContext.getPaymentRequest());
                    
        //             System.debug('PayeezyAdapter ' +body);
        //             //AuthorizePayment authPay = new AuthorizePayment();
        //             //body = authPay.makePaymentBody();
                    
        //             System.debug('PayeezyAdapter ' +body);
        //             //req.setHeader('Content-length', String.valueOf(body.length()));// For Authorize.Net
                    
        //            //req.setEndpoint('/v1/transactions');
        //            req.setEndpoint('/1.x/transactionProcessor');
        //            //req.setEndpoint('/xml/v1/request.api');
                   

        //     } else if ( requestType == commercepayments.RequestType.Capture) {
        //             //body = buildCaptureRequest((commercepayments.CaptureRequest)gatewayContext.getPaymentRequest(),req);
        //     } else if ( requestType == commercepayments.RequestType.ReferencedRefund) {
        //             //body = buildReferencedRefundRequest((commercepayments.ReferencedRefundRequest)gatewayContext.getPaymentRequest(),req);
        //     } else if ( requestType == commercepayments.RequestType.Tokenize) {
        //             //req.setEndpoint('/v1/transactions/tokens');
        //             //body = buildTokenizeRequest((commercepayments.PaymentMethodTokenizationRequest)gatewayContext.getPaymentRequest());
                    
        //             System.debug('RequestType after if Condition--- ' +requestType);
        //         commercepayments.PaymentMethodTokenizationRequest tokenizeRequest = (commercepayments.PaymentMethodTokenizationRequest)gatewayContext.getPaymentRequest();
        //         checkForRequiredFields(tokenizeRequest.cardPaymentMethod);
        //             Map<String,Object> mapCurrentUserContext = applauncher.CommerceStoreController.getCommerceContext();

        //             List<Webcart> webCartObj = [SELECT Id, Owner.FirstName, Owner.LastName,Owner.email, BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet FROM Webcart WHERE webstoreID=: (String)mapCurrentUserContext.get('webstoreId') AND 
        //             OwnerId =: UserInfo.getUserId() AND Status in ('Active','Checkout')];


        //             List<CartItem> cartItems = [SELECT Product2Id, Name, Id, CartId, Type, Sku, Quantity, 
        //             ListPrice,SalesPrice, TotalListPrice,TotalLineAmount  FROM CartItem WHERE 
        //             CartId =: webCartObj[0].Id];// AND Type = 'Product'];

        //             datetime dt = datetime.now();
        //             Map<String, String> params = new Map<String, String>();
        //             params.put('userName','{!$Credential.Username}');
        //             params.put('password','{!$Credential.Password}');
        //             params.put('merchantId','{!$Credential.Username}');
        //             params.put('mRefernceCode',String.valueOf(dt.gettime()));
                    
        //             params.put('firstName',webCartObj[0].Owner.FirstName);
        //             params.put('lastName',webCartObj[0].Owner.LastName);
        //             params.put('street','5156 S Dale Mabry Hwy');
        //             params.put('city','Tampa');
        //             params.put('state','NY');
        //             params.put('postalCode','33611');
        //             params.put('country','United States');
        //             params.put('email',webCartObj[0].Owner.email);
        //             body = B2BSoapToolKitAPI.getCCSoapXMLTokenizeBody(params,cartItems,tokenizeRequest);
        //             System.debug('PayeezyAdapter ' +body);
        //             req.setEndpoint('/1.x/transactionProcessor');
        //     } else if ( requestType == commercepayments.RequestType.Sale){
        //             //req.setEndpoint('/v1/transactions');
        //             //body = buildSaleRequest((commercepayments.SaleRequest)gatewayContext.getPaymentRequest());
                    
        //     }
        //     else {
        //             commercepayments.GatewayErrorResponse error = new commercepayments.GatewayErrorResponse('501','Unsupported Operation');
        //             return error;
        //     }

        // } catch(B2BSalesforceValidationException e) {
        //     commercepayments.GatewayErrorResponse error = new commercepayments.GatewayErrorResponse('400', e.getMessage());
        //     return error;
        // }
        // req.setBody(body);
        //     req.setMethod('POST');

        // commercepayments.PaymentsHttp http = new commercepayments.PaymentsHttp();
        // HttpResponse res = null;

        // try{
        
        // system.debug('PayeezyAdapter '+req);
        // System.debug('PayeezyAdapter ' +req.getEndpoint());
        //     res = http.send(req);
        //     System.debug('PayeezyAdapter ' +res);
        //     System.debug('resp1 '+ json.serialize(res.getbody()));
        //     if (requestType == commercepayments.RequestType.Tokenize)
        //     {
        //         commercepayments.PaymentMethodTokenizationResponse tokenizeResponse = new commercepayments.PaymentMethodTokenizationResponse();
        //         tokenizeResponse.setGatewayDate(system.now());
           
        //         if (res.getStatusCode() >= 200 && res.getStatusCode() < 300) {
        //             tokenizeResponse.setGatewayResultCode('success');
        //             tokenizeResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
        //         }
                
        //         response = tokenizeResponse;
        //     }
        // } catch(CalloutException ce) {
        //     system.debug('error '+ce.getMessage());
        //     commercepayments.GatewayErrorResponse error = new commercepayments.GatewayErrorResponse('500', ce.getMessage());
        //     system.debug('error '+error);
        //     return error;
        // }

        // //handle isDone
        // if (requestType == commercepayments.RequestType.Authorize) {
        //     response = createCYBSAuthResponse(res);
        // } else if ( requestType == commercepayments.RequestType.Capture) {
        //     //system.debug('capture called');
        //     //response =  createCaptureResponse(res) ;
        // } else if ( requestType == commercepayments.RequestType.ReferencedRefund) {
        //     //response =  createReferencedRefundResponse(res) ;
        // }else if ( requestType == commercepayments.RequestType.Tokenize) {
        //     response =  createTokenizeResponse(res) ;
        // } else if( requestType == commercepayments.RequestType.Sale){
        //    //response = createSaleResponse(res);
        // }
        // system.debug('final response == '+response);
        // return response;
    }
    //Arun Sood 
    // Adding Auth Response

    
    public commercepayments.GatewayResponse createAuthResponse(commercepayments.AuthorizationRequest authRequest) {
        String v1Token = authRequest.additionalData.get('v1Token');
        String v2Token = authRequest.additionalData.get('v2Token');
        String isJWT = authRequest.additionalData.get('isJWT');
        String webstoreId = authRequest.additionalData.get('webstoreId');
        String cartId = authRequest.additionalData.get('cartId');
        String legacyToken = authRequest.additionalData.get('legacyToken');
        String saveFromWallet = authRequest.additionalData.get('saveFromWallet');
        Boolean jwt = isJWT =='true';
        Boolean isSaveFromWallet = saveFromWallet == 'true';
        String token = v1Token + v2Token;
        String currencyIsoCodeLC = authRequest.currencyIsoCode.toLowercase();
        
        Map<String, String> params = new Map<String, String>();
        
        //commercepayments.AuthApiPaymentMethodRequest paymentMethod = authRequest.paymentMethod;
        System.debug('## authRequest ## ' + authRequest);
        System.debug('## authRequest.paymentMethod ## '+ authRequest.paymentMethod);
        System.debug('## authRequest.paymentMethod ## '+ authRequest.paymentMethod.address);
        //System.debug('## address ## ' +  paymentMethod.address);
        //commercepayments.AddressRequest address = paymentMethod.address;
        //TNV_MD_Country__mdt countryMetaData = [SELECT Id, Direct_LE_code__c FROM TNV_MD_Country__mdt WHERE Country_Name__c = :address.Country LIMIT 1];
        //B2B_CybersourceRestForExperience.getCYBSConfiguration(null);//countryMetaData.Direct_LE_code__c,currencyIsoCodeLC
        B2B_CybersourceRESTUtility.getCYBSConfiguration();
        
        HttpRequest req = new HttpRequest();
        String reqBody = '';
        if(jwt){
            if(isSaveFromWallet){
                reqBody = B2B_CYBSPaymentContoller.genrateZeroAmountAuthorizationRequest(token);
            }else{
                reqBody = B2B_CYBSPaymentContoller.genrateAuthorizationRequest(cartId,token,null,null,null,webstoreId, authRequest.paymentMethod.address);
            }
        }else{
            reqBody = B2B_CYBSPaymentContoller.genrateAuthorizationRequest(cartId,null,legacyToken,null,null,webstoreId, authRequest.paymentMethod.address);
        }
        //reqBody = '{\"clientReferenceInformation\":{\"code\":\"TC50171_3\"},\"paymentInformation\":{\"card\":{\"number\":\"4111111111111111\",\"expirationMonth\":\"12\",\"expirationYear\":\"2031\"}},\"orderInformation\":{\"amountDetails\":{\"totalAmount\":\"102.21\",\"currency\":\"USD\"},\"billTo\":{\"firstName\":\"John\",\"lastName\":\"Doe\",\"address1\":\"1MarketSt\",\"locality\":\"sanfrancisco\",\"administrativeArea\":\"CA\",\"postalCode\":\"94105\",\"country\":\"US\",\"email\":\"test@cybs.com\",\"phoneNumber\":\"4158880000\"}}}';
        System.debug(' reqBody   ' + reqBody);
        req = B2B_CybersourceRESTUtility.generatePostRequest('/pts/v2/payments', reqBody);
        commercepayments.PaymentsHttp http = new commercepayments.PaymentsHttp();
        HttpResponse response = new HttpResponse();
        req.setEndpoint('/pts/v2/payments');
        System.debug('___req___'+req);
        if(!Test.isRunningTest()){
            response = http.send(req);
        }

        System.debug('response ----->'+response);
        String body = response.getBody();
        System.debug('body ----->'+body);

        Integer httpStatusCode = response.getStatusCode();
        System.debug('httpStatusCode ----->'+httpStatusCode);

        System.debug(' CYBS results    ' + body);

        Map<String, Object> results = new Map<String, Object>();   
        Map<String, Object> orderInfo = new Map<String, Object>();
        Map<String, Object> amountDetails = new Map<String, Object>();
        
        if(!Test.isRunningTest()){
            results = (Map<String, Object>) JSON.deserializeUntyped(body);               
            orderInfo = (Map<String, Object>) results.get('orderInformation');
            amountDetails = (Map<String, Object>) orderInfo.get('amountDetails');
        }
        commercepayments.AuthorizationResponse authResponse = new commercepayments.AuthorizationResponse();
        authResponse.setGatewayDate(system.now());
        authResponse.setGatewayResultCode((String) results.get('status'));
        authResponse.setGatewayResultCodeDescription((string)results.get('status'));
        authResponse.setGatewayAuthCode((String) results.get('id')); 
        authResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
        authResponse.setAmount(double.valueOf(amountDetails.get('authorizedAmount'))); 
        
        return authResponse;
    }


    public CommercePayments.GatewayResponse createPaymentInstrument(CommercePayments.PaymentMethodTokenizationRequest tokenizeReques) {
        CommercePayments.CardPaymentMethodRequest cardPaymentMethod = tokenizeReques.cardPaymentMethod;
        B2BCybersourceRESTUtility.getCYBSConfiguration();
        String cardNumber = tokenizeReques.additionalData.get('cardNumber');
        JSONGenerator jsGen = JSON.createGenerator(true);
            jsGen.writeStartObject();
                jsGen.writeFieldName('card');
                jsGen.writeStartObject();
                    jsGen.writeStringField('number', cardNumber);
                jsGen.writeEndObject();
            jsGen.writeEndObject();
        String reqBody = jsGen.getAsString();
        System.debug(' reqBody   ' + reqBody);
        //reqBody = '{"card": {"number": "4111111111111111"}}';
        HttpRequest req = B2BCybersourceRESTUtility.generatePostRequest('/tms/v1/instrumentidentifiers', reqBody);
        System.debug(' req   ' + req);
        req.setEndpoint('/tms/v1/instrumentidentifiers');
        CommercePayments.PaymentsHttp http = new CommercePayments.PaymentsHttp();
        String respBody, instIdentifier;
        HttpResponse res;
        //if(!Test.isRunningTest())
        //{
            res = http.send(req);
            respBody = res.getBody();
            System.debug('Token_Response:'+respBody);
            if(res.getStatusCode() == 200 || res.getStatusCode() == 201)
            {
                Map<String,Object> resMap = (Map<String,Object>)JSON.deserializeUntyped(respBody);
                System.debug('customerToken:'+resMap.get('id'));
                if(resMap.containsKey('id') && resMap.get('id') != null)
                {
                    instIdentifier = (String)resMap.get('id');
                }
            }else
            {
                return new CommercePayments.GatewayErrorResponse(String.valueOf(res.getStatusCode()), 'ERROR: ' + respBody);
            }
        /*}
        else{
            instIdentifier = '00000400';
        }*/
        String paymentInstrumentId = null;
        if(String.isNotBlank(instIdentifier))
        {
            req = new HttpRequest();
            System.debug('instIdentifier:'+instIdentifier);
            System.debug('tokenizeRequest :'+tokenizeReques);
            reqBody = B2BCybersourceRESTUtility.buildPaymentInstrumentRequest(instIdentifier, tokenizeReques);
            String customerToken = tokenizeReques.additionalData.get('customerTokenId');
            System.debug('customerToken:'+customerToken);
            System.debug('reqBody:'+reqBody);
            req = B2BCybersourceRESTUtility.generatePostRequest('/tms/v2/customers/'+customerToken+'/payment-instruments', reqBody);
            req.setEndpoint('/tms/v2/customers/'+customerToken+'/payment-instruments');
            //if(!Test.isRunningTest())
            //{
                res = http.send(req);
                respBody = res.getBody();
                System.debug('Payment_Instrument_Response:'+respBody);
                if(res.getStatusCode() == 201)
                {
                    Map<String,Object> resMap = (Map<String,Object>)JSON.deserializeUntyped(respBody);
                    System.debug('paymentInstrumentId:'+resMap.get('id'));
                    if(resMap.containsKey('id') && resMap.get('id') != null){
                        paymentInstrumentId = (String)resMap.get('id');
                    }
                }else{
                    return new CommercePayments.GatewayErrorResponse(String.valueOf(res.getStatusCode()), 'ERROR: ' + System.Label.B2B_Card_Validation_Generic_Error);
                }
            /*}
            else{
                paymentInstrumentId = '00000400';
            }*/
        }

        CommercePayments.PaymentMethodTokenizationResponse tokenizeResponse = new CommercePayments.PaymentMethodTokenizationResponse();
        tokenizeResponse.setGatewayDate(System.now());
        tokenizeResponse.setGatewayResultCode(String.valueOf(res.getStatusCode()));
        if(String.isNotBlank(instIdentifier))
        {
            tokenizeResponse.setGatewayTokenDetails(instIdentifier);
        }
        if(String.isNotBlank(paymentInstrumentId))
        {
            tokenizeResponse.setGatewayToken(paymentInstrumentId);
            tokenizeResponse.setSalesforceResultCodeInfo(RC_SUCCESS);
        }
        else
        {
            tokenizeResponse.setSalesforceResultCodeInfo(RC_DECLINE);
        }
        // TODO: more failure cases?
        return tokenizeResponse;
    }

    protected virtual commercepayments.SalesforceResultCodeInfo getSalesforceResultCodeInfo(String resultCode) {
        if (resultCode == commercepayments.SalesforceResultCode.SUCCESS.name()) {
            return SUCCESS_SALESFORCE_RESULT_CODE_INFO;
        } else {
            return DECLINE_SALESFORCE_RESULT_CODE_INFO;
        }
    }
    
    private String buildTokenizeRequest(commercepayments.PaymentMethodTokenizationRequest tokenizeRequest) {
        JSONGenerator jsonGeneratorInstance = JSON.createGenerator(true);
        jsonGeneratorInstance.writeStartObject();
        jsonGeneratorInstance.writeStringField('type', 'FDToken');
        jsonGeneratorInstance.writeStringField('auth', 'false');
        jsonGeneratorInstance.writeStringField('ta_token', 'NOIW');
        commercepayments.CardPaymentMethodRequest cardPaymentMethod = tokenizeRequest.cardpaymentMethod;
        checkForRequiredFields(cardPaymentMethod);
        jsonGeneratorInstance.writeFieldName('credit_card');
        jsonGeneratorInstance.writeStartObject();
        if(cardPaymentMethod.cardType!=null)
            jsonGeneratorInstance.writeStringField('type',cardPaymentMethod.cardType.name());
        if(cardPaymentMethod.cvv!=null)
            jsonGeneratorInstance.writeStringField('cvv', String.ValueOf(cardPaymentMethod.cvv));
        if(cardPaymentMethod.cardholdername!=null)
            jsonGeneratorInstance.writeStringField('cardholder_name', cardPaymentMethod.cardholdername);
        if(cardPaymentMethod.cardnumber!=null)
            jsonGeneratorInstance.writeStringField('card_number', cardPaymentMethod.cardnumber);
         if(cardPaymentMethod.expiryMonth!=null && cardPaymentMethod.expiryYear!=null ) {
            String expMonth = ((String.ValueOf(cardPaymentMethod.expiryMonth)).length()==1?'0':'') + String.ValueOf(cardPaymentMethod.expiryMonth);
            jsonGeneratorInstance.writeStringField('exp_date', expMonth+(String.ValueOf(cardPaymentMethod.expiryYear)).substring(2));
         }
        jsonGeneratorInstance.writeEndObject();
        jsonGeneratorInstance.writeEndObject();
        return jsonGeneratorInstance.getAsString();
    }
    
    public commercepayments.GatewayResponse createTokenizeResponse(HttpResponse response) {
        String statusCode = String.valueOf(response.getStatusCode());
        Map<String , String> mapCYBSResponse = new Map<String , String>();
        DOM.Document doc = new DOM.Document();
        doc.load(response.getBody());
        DOM.XmlNode rootNode = doc.getRootElement();
        parseXML(rootNode,mapCYBSResponse);
        System.debug('mapCYBSResponse ' + mapCYBSResponse);
        String cybsResponse = json.serialize(mapCYBSResponse);
        cybsResponseWrapperObject cybsRespObj = (cybsResponseWrapperObject)JSON.deserialize(cybsResponse, cybsResponseWrapperObject.class);
        System.debug('cybsRespObj ' + cybsRespObj);
        if(cybsRespObj.decision.equalsIgnoreCase('REJECT')){
            throw new B2BSalesforceValidationException('Invalid Card Details');
        }
        commercepayments.PaymentMethodTokenizationResponse authResponse = new commercepayments.PaymentMethodTokenizationResponse();
        authResponse.setGatewayResultCode(cybsRespObj.reasonCode);
        authResponse.setGatewayResultCodeDescription(cybsRespObj.decision);
        authResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
        authResponse.setGatewayDate(system.now());
        authResponse.setGatewayAvsCode(cybsRespObj.avsCode);
        authResponse.setGatewayToken(cybsRespObj.requestToken);
        return authResponse;
    }

    public static void parseXML(DOM.XMLNode node ,Map<String , String>  mapCYBSResponse) {
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT){
            if(mapCYBSResponse.get(node.getName()) == null){
                mapCYBSResponse.put(node.getName() , node.getText());
            }
        }
        for (Dom.XMLNode child: node.getChildElements()){
            parseXML(child , mapCYBSResponse);
        }
        
    }
    
    
    public Map<String, String> parseResponse(String jsonResponse) {
        Map<String, String> mapOfResponseValuesByKey = new Map<String, String>();
        if (NULL != jsonresponse) {
            Map<String, Object> mapOfjsonResponseByKey = (Map<String, Object>) JSON.deserializeUntyped(jsonResponse);
            // Amount key added to the map irrespective of the response received
            if(mapOfjsonResponseByKey.get(AMOUNT) != null)
                mapOfResponseValuesByKey.put(AMOUNT, String.ValueOf(mapOfjsonResponseByKey.get(AMOUNT)));
            if (mapOfjsonResponseByKey.KeySet().contains(BANK_MESSAGE) || mapOfjsonResponseByKey.KeySet().contains(GATEWAY_MESSAGE)
               || mapOfjsonResponseByKey.KeySet().contains(STATUS)) {
                //Successful transaction with the gateway
                for (String resultKey : mapOfjsonResponseByKey.KeySet()) {
                    if (resultKey == BANK_MESSAGE
                        || resultKey == TRANSACTION_ID
                        || resultKey == BANK_RESPONSE_CODE
                        || resultKey == TRANSACTION_TAG
                        || resultKey == GATEWAY_RESPONSE_CODE
                        || resultKey == GATEWAY_MESSAGE
                        || resultKey == CURRENCY_KEY
                        || resultKey == TRANSACTION_STATUS
                        || resultKey == VALIDATION_STATUS
                        || resultKey == PAYMENT_METHOD
                        || resultKey == STATUS
                        || resultKey == TYPE
                       ) {
                           mapOfResponseValuesByKey.put(resultKey, String.ValueOf(mapOfjsonResponseByKey.get(resultKey)));
                       }
                }
                mapOfResponseValuesByKey.put('gatewayTokenDetails', String.ValueOf(mapOfjsonResponseByKey.get(TYPE)));
                //Token values stored for the payment method used
                if (mapOfjsonResponseByKey.containsKey('token')) {
                    Map<String, Object> mapOfTokenByChild = (Map<String, Object>) mapOfjsonResponseByKey.get('token');
                    mapOfResponseValuesByKey.put('type', String.ValueOf(mapOfTokenByChild.get('type')));
                    mapOfResponseValuesByKey.put('cardholder_name', String.ValueOf(mapOfTokenByChild.get('cardholder_name')));
                    mapOfResponseValuesByKey.put('exp_date', String.ValueOf(mapOfTokenByChild.get('exp_date')));
                    mapOfResponseValuesByKey.put('value', String.ValueOf(mapOfTokenByChild.get('value')));
                    Map<String, Object> mapOfTokenData = (Map<String, Object>) mapOfTokenByChild.get('token_data');
                    if(mapOfTokenData != null){
                        for (String tokenData : mapOfTokenData.KeySet()) {
                            mapOfResponseValuesByKey.put(tokenData, String.ValueOf(mapOfTokenData.get(tokenData)));
                        }
                    }
                }
            }  
            if (jsonresponse.contains('Error')) {
                // Failed transaction with the gateway
                for (String resultKey : mapOfjsonResponseByKey.KeySet()) {
                    if (resultKey != 'Error') {
                        mapOfResponseValuesByKey.put(resultKey, String.ValueOf(mapOfjsonResponseByKey.get(resultKey)));
                    }
                }
                Map<String, Object> mapOfErrors = (Map
                                                   <String, Object>) mapOfjsonResponseByKey.get('Error');
                for (String resultErrorKey : mapOfErrors.KeySet()) {
                    mapOfResponseValuesByKey.put(resultErrorKey, String.ValueOf(mapOfErrors.get(resultErrorKey)));
                }

                list<Object> listofError = (list<object>) mapOfErrors.get('messages');

                for (Object objectRef : listofError) {
                    Map<String, Object> mapOfErrorsByChild = (Map<String, Object>) objectRef;
                    for (String errorResult : mapOfErrorsByChild.KeySet()) {
                        mapOfResponseValuesByKey.put(errorResult, String.ValueOf(mapOfErrorsByChild.get(errorResult)));
                    }
                }
            }  else if (jsonresponse.contains('error')) {
                // Failed transaction with the gateway
                mapOfResponseValuesByKey.put('failed', String.ValueOf(mapOfjsonResponseByKey.get('error')));
            }  
            
            if (jsonresponse.contains('code')) {
                // The error code and error response received in the output
                String code = (string)mapOfjsonResponseByKey.get('code');
                String message = (string)mapOfjsonResponseByKey.get('message');
                mapOfResponseValuesByKey.put('code',code);
                mapOfResponseValuesByKey.put('message',message);
            }
        }
        return mapOfResponseValuesByKey;
    }
    
    public class cybsResponseWrapperObject{
        public String subscriptionID{get;set;}
        public String requestToken{get;set;}
        public String reasonCode{get;set;}
        public String decision{get;set;}
        public String requestID{get;set;}
        public String merchantReferenceCode{get;set;}
        public String authorizationCode {get;set;}
        public Double amount {get;set;}
        public String avsCode {get;set;}
    }
    
    public commercepayments.GatewayResponse createCYBSAuthResponse(HttpResponse response) {
        String statusCode = String.valueOf(response.getStatusCode());
        Map<String , String> mapCYBSResponse = new Map<String , String>();
        DOM.Document doc = new DOM.Document();
        doc.load(response.getBody());
        DOM.XmlNode rootNode = doc.getRootElement();
        parseXML(rootNode,mapCYBSResponse);
        System.debug('mapCYBSResponse ' + mapCYBSResponse);
        String cybsResponse = json.serialize(mapCYBSResponse);
        cybsResponseWrapperObject cybsRespObj = (cybsResponseWrapperObject)JSON.deserialize(cybsResponse, cybsResponseWrapperObject.class);
        System.debug('cybsRespObj ' + cybsRespObj);
        if(cybsRespObj.decision.equalsIgnoreCase('REJECT')){
            throw new B2BSalesforceValidationException('Invalid Card Details');
        }
        commercepayments.AuthorizationResponse authResponse = new commercepayments.AuthorizationResponse();
        authResponse.setGatewayDate(system.now());
        authResponse.setGatewayResultCode(cybsRespObj.reasonCode);
        authResponse.setGatewayResultCodeDescription(cybsRespObj.decision);
        authResponse.setGatewayAuthCode(cybsRespObj.authorizationCode); // "ch_..."
        authResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
        authResponse.setGatewayAvsCode(cybsRespObj.avsCode);
        authResponse.setAmount(cybsRespObj.amount);
        commercepayments.PaymentMethodTokenizationResponse paymentMethodTokenizationResponse = new commercepayments.PaymentMethodTokenizationResponse();
        paymentMethodTokenizationResponse.setGatewayToken(cybsRespObj.requestToken);
        authResponse.setPaymentMethodTokenizationResponse(paymentMethodTokenizationResponse);

        // commercepayments.PaymentMethodTokenizationResponse paymentMethodTokenizationResponse = new commercepayments.PaymentMethodTokenizationResponse();
        // paymentMethodTokenizationResponse.setGatewayResultCode(cybsRespObj.reasonCode);
        // paymentMethodTokenizationResponse.setGatewayResultCodeDescription(cybsRespObj.decision);
        // paymentMethodTokenizationResponse.setSalesforceResultCodeInfo(SUCCESS_SALESFORCE_RESULT_CODE_INFO);
        // paymentMethodTokenizationResponse.setGatewayDate(system.now());
        // paymentMethodTokenizationResponse.setGatewayAvsCode(cybsRespObj.avsCode);
        // paymentMethodTokenizationResponse.setGatewayToken(cybsRespObj.requestToken);
        return authResponse;
        
    }
    private String getRandomNumber(integer stringLength){
        final integer MAX = integer.valueOf(Math.pow(10,stringLength) - 1);
        return String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(stringLength,'0');
    }
       
    private void checkForRequiredFields(commercepayments.CardPaymentMethodRequest cardPaymentMethod){
        if(cardPaymentMethod == null){
            throw new B2BSalesforceValidationException('Invalid Request parameters: Missing Card Details');
        }
        if(cardPaymentMethod.cardnumber == null){
            throw new B2BSalesforceValidationException('Invalid Request parameters: Missing Card Number');
        }
        if(cardPaymentMethod.cvv == null){
            throw new B2BSalesforceValidationException('Invalid Request parameters: Missing Card CVV');
        }
        if(cardPaymentMethod.expiryYear == null || cardPaymentMethod.expiryMonth == null){
            throw new B2BSalesforceValidationException('Invalid Request parameters: Missing Card Expiry date');
        }
        if( cardPaymentMethod.cardholdername == null){
            throw new B2BSalesforceValidationException('Invalid Request parameters: Missing Card Holder Name');
        }
    }
}