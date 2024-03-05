/**
 * @description       : 
 * @author            : asood@rafter.one
 * @group             : 
 * @last modified on  : 07-17-2023
 * @last modified by  : asood@rafter.one
**/
public with sharing class B2B_CybersourceRESTUtility {

    private static final String CLASSNAME = 'B2B_CybersourceRESTUtility';
    private static final String STOREFRONT = 'Zimvie';
    private static final String MODULE_NAME = 'Payment Module';

    public static String HOST ='HOST';
    public static String MERCHANT_ID='MERCHANT_ID';
    public static String KEY_ID='KEY_ID';
    public static String PRIVATE_KEY='PRIVATE_KEY';
    public static String microURL='microURL';
    public static String paymentURL='Test';
    public static String transactionURL='transactionURL';
    public static String merchantName='merchantName';
    public static String DATETIME_STRING ;//DIGEST_STRING

    public static String getCustomerToken(){
        String custToken;
        String conId = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1].ContactId;
        System.debug('conId------>'+conId);
        if(String.isNotBlank(conId)){
            List<Contact> conLst = [SELECT Id, Name, B2B_CYBS_Customer_Token__c FROM Contact WHERE Id = :conId LIMIT 1];
            System.debug('conLst------>'+conLst);
            if(!conLst.isEmpty() && String.isNotBlank(conLst[0].B2B_CYBS_Customer_Token__c)){
                custToken = conLst[0].B2B_CYBS_Customer_Token__c;
            }else{
                custToken = createCustomerToken(conLst[0]);
                System.debug('custToken---d--->'+custToken);
                if(String.isNotBlank(custToken)){
                    Contact con = new Contact(Id = conId);
                    con.B2B_CYBS_Customer_Token__c = custToken;
                    update con;
                    System.debug('con-----dddd->'+con);
                }else{
                    throw new AuraHandledException('Something went wrong. Please refresh again.');
                }
            }
        }
        System.debug('custToken-----dddd->'+custToken);
        return custToken;
    }

    public static String createCustomerToken(Contact con){
        if(con != null){
            getCYBSConfiguration();
            JSONGenerator jsGen = JSON.createGenerator(true);
            jsGen.writeStartObject();
                jsGen.writeFieldName('objectInformation');
                jsGen.writeStartObject();
                    jsGen.writeStringField('title', con.Name);
                jsGen.writeEndObject();
                jsGen.writeFieldName('buyerInformation');
                jsGen.writeStartObject();
                    jsGen.writeStringField('merchantCustomerID', con.Id);
                jsGen.writeEndObject();
                jsGen.writeFieldName('clientReferenceInformation');
                jsGen.writeStartObject();
                    jsGen.writeStringField('code', con.Id);
                jsGen.writeEndObject();
            jsGen.writeEndObject();
            String reqBody = jsGen.getAsString();
            System.debug('reqBody'+reqBody);
            HttpRequest req = generatePostRequest('/tms/v2/customers', reqBody);
            System.debug('Token_Request:'+req);
            Http http = new Http();
            String respBody, customerToken;
            if(!Test.isRunningTest()){
                HttpResponse res = http.send(req);
                respBody = res.getBody();
                System.debug('Token_Response:'+respBody);
                Map<String,Object> resMap = (Map<String,Object>)JSON.deserializeUntyped(respBody);
                System.debug('resMap:'+resMap);
                System.debug('customerToken:'+resMap.get('id'));
                if(resMap.containsKey('id') && resMap.get('id') != null){
                    customerToken = (String)resMap.get('id');
                }
            }
            else{
                customerToken = '00000400';
            }
            return customerToken;
        }
        return null;
    }

    public static void getCYBSConfiguration(){
        String accId = B2BUtils.getUserAccountID();
        getCYBSConfiguration(accId);
    }

    public static void getCYBSConfiguration(String accId){
        String accbillingCountry = null;
        B2B_CYBS_Merchant__mdt metaConfig, defaultMetaConfig = null;
        try{
            //String accId = B2BUtils.getUserAccountID();
            if(String.isNotBlank(accId))
            {
                List<Account> accLst = [SELECT BillingCountry FROM Account WHERE Id = :accId];
                if(!accLst.isEmpty())
                {
                    accbillingCountry = accLst[0].BillingCountry;
                }
            }
            List<B2B_CYBS_Merchant__mdt> metaConfigs = [SELECT Id, Key_ID__c, Private_Key__c, Microflex_Key_Creation_URL__c,Is_Default__c,
                                                          DeveloperName, Environment_Request_URL__c, Payment_API_URL__c, Transaction_API_URL__c, Storefront_Country__c
                                                          FROM B2B_CYBS_Merchant__mdt];
            if(!metaConfigs.isEmpty())
            {
                List<String> countryCodes;
                for(B2B_CYBS_Merchant__mdt metaRec : metaConfigs)
                {
                    if(metaRec.Is_Default__c)
                    {
                        defaultMetaConfig = metaRec;
                    }
                    if(String.isNotBlank(metaRec.Storefront_Country__c) && String.isNotBlank(accbillingCountry))
                    {
                        countryCodes = metaRec.Storefront_Country__c.split(';');
                        if(countryCodes.contains(accbillingCountry))
                        {
                            metaConfig = metaRec;
                        }
                    }
                }
            }
            if(metaConfig == null)
            {
                metaConfig = defaultMetaConfig;
            }
            
            if(metaConfig != null)
            {
                HOST = metaConfig.Environment_Request_URL__c;
                MERCHANT_ID = metaConfig.DeveloperName;
                KEY_ID = metaConfig.Key_ID__c;
                PRIVATE_KEY = metaConfig.Private_Key__c;
                microURL = metaConfig.Microflex_Key_Creation_URL__c;
                paymentURL = metaConfig.Payment_API_URL__c;
                transactionURL = metaConfig.Transaction_API_URL__c;
                merchantName = metaConfig.DeveloperName;
                System.debug('_______merchantName________'+merchantName);
            }
        }
        catch(Exception e){
            //B2BExceptionLogs.storeExceptionLog(e, STOREFRONT, MODULE_NAME, CLASSNAME, 'getCYBSConfiguration', '');
        }
    }

    // --- HTTP Request Helper Methods ---
    //    
    //Generates a POST request to the specified endpoint and sets the body
    public static HttpRequest generatePostRequest(String reqTarget, String reqBody) {
        HttpRequest req = generateRequestBase(reqTarget, B2BConstants.POST);
        //POST requests
        String digestString = generateDigest(reqBody);
        System.debug('digestString:'+digestString);
        String signatureString = generateSignature('post', reqTarget, digestString);
        System.debug('digestString:'+digestString);
        req.setHeader('digest', digestString);
        req.setHeader('signature', signatureString);
        req.setBody(reqBody);
        return req;
    }

    //Generates a base HTTP Request with common headers set (basic structure for GET and POST methods)
    private static HttpRequest generateRequestBase(String reqTarget, String reqMethod) {
        HttpRequest req = new HttpRequest();
        req.setMethod(reqMethod);
        req.setEndpoint('https://'+ HOST + reqTarget);
        req.setHeader('Host', HOST);
        req.setHeader('v-c-merchant-id', MERCHANT_ID);
        req.setHeader('Content-Type', 'application/json');
        setDateTimeString();
        System.debug('DATETIME_STRING ' +DATETIME_STRING);
        req.setHeader('Date', DATETIME_STRING);
        return req;
    }
    //Sets the DATETIME_STRING to the current time in RCF format
    private static void setDateTimeString() {
        DATETIME_STRING = String.valueOf(Datetime.now().formatGmt('EEE, dd MMM yyyy HH:mm:ss z'));
    }

     //Generates a Hash of the request body (Digest header)
     private static String generateDigest(String reqBody) {
        Blob digestHash = Crypto.generateDigest('SHA-256', Blob.valueOf(reqBody)); 
        String digestString = 'SHA-256=' + EncodingUtil.base64Encode(digestHash);
        return digestString;
    }

    //
    // --- HTTP Request Helper Methods ---
    // --- Signature Helper Methods ---
    //
    //Method wrapping helper methods to create and return the string that will be set for the Signature header
    private static String generateSignature(String reqType, String reqTarget, String digestString) {  
        String signatureHeaders = generateSignatureHeaders(reqType, reqTarget, digestString);
        String signatureHash = generateSignatureHash(signatureHeaders);
        return generateSignatureString(reqType, signatureHash);
    }

    //Generates the (host date (request-target) digest v-c-merchant-id) string
    private static String generateSignatureHeaders(String reqType, String reqTarget, String digestString) {
        String headerFields = '';
        //Add host
        headerFields += ('host: ' + HOST + '\n');
        //Add date (for POST requests only)
        if(reqType == 'post') {
            headerFields += 'date: ' + DATETIME_STRING + '\n';
        }
        //Add (request-target)
        headerFields += ('(request-target): ' + reqType + ' ' + reqTarget + '\n');
        //Add digest (for POST requests only)
        if(reqType == 'post') {
            headerFields += ('digest: ' + digestString + '\n');
        } 
        //Add v-c-merchant-id
        headerFields += ('v-c-merchant-id: ' + MERCHANT_ID);
        return headerFields;
    }
    
    //Creates a HmacSHA256 hash of the Signature Header/Value String
    private static String generateSignatureHash(String data) {        
        Blob hash = Crypto.generateMac('HmacSHA256', Blob.valueOf(data), EncodingUtil.base64Decode(PRIVATE_KEY));
        return EncodingUtil.base64Encode(hash);
    }
    
    //Creates the value to be attached to the Signature on the POST request
    private static String generateSignatureString(String reqType, String signatureHash) {
        String signatureString = '';
        signatureString += 'keyid="' + KEY_ID + '", ';
        signatureString += 'algorithm="HmacSHA256", ';
        signatureString += 'headers="host';
        //Add in 'date' for POST requests (seems to break GET requests)
        if(reqType == 'post') {
            signatureString += ' date';
        }
        signatureString += ' (request-target)';
        //Add in 'digest' for POST requests        
        if(reqType == 'post') {
            signatureString += ' digest';
        }
        signatureString += ' v-c-merchant-id", ';
        signatureString += 'signature="' + signatureHash + '"';
        return signatureString;
    } 

    public static void deletePaymentInstrument(Map<String, Object> dataMap){
        if(dataMap.containsKey(B2BConstants.PAYMENT_INSTRUMENT_ID) && dataMap.get(B2BConstants.PAYMENT_INSTRUMENT_ID) != null
            && dataMap.containsKey(B2BConstants.CUSTOMER_TOKEN) && dataMap.get(B2BConstants.CUSTOMER_TOKEN) != null){

                String customerToken = (String)dataMap.get(B2BConstants.CUSTOMER_TOKEN);
                String paymentInstrumentId = (String)dataMap.get(B2BConstants.PAYMENT_INSTRUMENT_ID);
                getCYBSConfiguration();
                HttpRequest req = generateDeleteRequest('/tms/v2/customers/'+customerToken+'/payment-instruments/'+paymentInstrumentId);
                Http http = new Http();
                //String respBody;
                if(!Test.isRunningTest()){
                    HttpResponse res = http.send(req);
                }
            }
    }
    
    private static HttpRequest generateDeleteRequest(String reqTarget) {
        HttpRequest req = generateRequestBase(reqTarget, 'DELETE');
        //GET requests
        String signatureString = generateSignature('delete', reqTarget, '');
        req.setHeader('signature', signatureString);
        return req;
    }

    public static String getTransactionDetails(String paymentId) {
        String reqTarget = transactionURL + paymentId;
        HttpResponse res ;
        
       
        

        try{
            if(!Test.isRunningTest()){
            
                HttpRequest req = generateGetRequest(reqTarget);
        
                System.debug('Get Token Request '+req);
        
                Http http = new Http();
                res = http.send(req);
                return res.getBody();
            }
            else{
                return '{ "clientReferenceInformation":{"code":"00000400"}, "id":"6213810968596822804006", "merchantId":"test", "orderInformation":{"amountDetails":{"authorizedAmount":"530.00", "currency":"EUR"}}, "paymentInformation":{"customer":{"customerId":"9909000331850373"},"card":{"suffix":"1111","prefix":"411111","expirationMonth":"03","expirationYear":"24","type":"001"}},"processorInformation":{"approvalCode":"831000","responseCode":"00"}}';       
            }
        }
        catch(Exception ex){
            System.debug('resMap ex' +ex);
        }
        
        return null;
    }
    @TestVisible
    private static HttpRequest generateGetRequest(String reqTarget) {
        HttpRequest req = generateRequestBase(reqTarget, 'GET');
        
        //GET requests
        String signatureString = generateSignature('get', reqTarget, '');
        
        req.setHeader('signature', signatureString);
        
        return req;
    }
}