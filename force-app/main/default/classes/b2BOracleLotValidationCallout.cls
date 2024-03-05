public class b2BOracleLotValidationCallout {
    
    public static List<oracleResponseWrapper> makeCallout(String lotValidationJson){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            Blob headerValue = Blob.valueOf('ZV_OICTEST_BASICAUTH' + ':' + '41f5c6d7-6a07-428e-aad4-bff7bcc10d8a');
            String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type','application/json');
            req.setEndpoint('https://zv-test-id5qcg6pakvx-px.integration.ocp.oraclecloud.com:443/ic/api/integration/v1/flows/rest/ZIMVIE_RMA_GET_LOT_DETAIL/1.0/getLotDetails');
            req.setMethod('POST');
            req.setBody(lotValidationJson);
            res = http.send(req);
            return (List<oracleResponseWrapper>) JSON.deserialize(res.getBody(), List<oracleResponseWrapper>.class);
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }
    
    public class oracleRequestWrapper {
        public String OrgId {get; set;}
        public String LotNumber {get; set;}
        public String ItemNumber {get; set;}
        public String AccountNumber {get; set;}
        public String SiteUseId {get; set;}
        
    }
    public class oracleResponseWrapper{
        public String OrderNumber {get; set;}
        public String OrderType {get; set;}
        public Integer LineNumber {get; set;}
        public String ShippedDate {get; set;}
        public String PriceList {get; set;}
        public String LotExpiryDate {get; set;}
        public String DisplayFlag {get; set;}	
        public Integer LotShipQuantity {get; set;}
        public Integer PreviousRMAQuantity {get; set;}
        public String ErrorMessage{get; set;}
    }
}