/*
*********************************************************
Apex Class Name    : b2BOracleCalloutController
Created Date       : Sep 14, 2023
@description       : This  class is used for Making callouts to Oracle.
@author            : Deepak Kumar Singh
Modification Log:
Ver   Date         Author                               Modification
1.0   09-14-2023   Deepak Singh                        Initial Version
*********************************************************
*/
public class b2BOracleCalloutController{
    //This Method is used for validation RMA line from Oracle
    public static List<oracleLotValidationResponseWrapper> OracleLotValidation(String lotValidationJson){
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
            return (res.getStatusCode() == 200?(List<oracleLotValidationResponseWrapper>) JSON.deserialize(res.getBody(), List<oracleLotValidationResponseWrapper>.class) : null);
            
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }
    
    //This Method is used for creating RMA in Oracle
     public static List<oracleLotValidationResponseWrapper> OracleRmaCreation(String rmaCreationJson){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            Blob headerValue = Blob.valueOf('ZV_OICTEST_BASICAUTH' + ':' + '41f5c6d7-6a07-428e-aad4-bff7bcc10d8a');
            String authorizationHeader = 'BASIC ' +EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('Content-Type','application/json');
            req.setEndpoint('https://zv-test-id5qcg6pakvx-px.integration.ocp.oraclecloud.com:443/ic/api/integration/v1/flows/rest/ZIMVIE_SF_TO_EBS_RMA_CREATION/1.0/createRMA');
            req.setMethod('POST');
            req.setBody(rmaCreationJson);
            res = http.send(req);
            system.debug(res.getbody());
            return null;
            //return (res.getStatusCode() == 200?(List<oracleLotValidationResponseWrapper>) JSON.deserialize(res.getBody(), List<oracleLotValidationResponseWrapper>.class) : null);
            
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }

    //Request Wrapper for Lot Validation
    public class oracleLotValidationRequestWrapper {
        public String OrgId {get; set;}
        public String LotNumber {get; set;}
        public String ItemNumber {get; set;}
        public String AccountNumber {get; set;}
        public String SiteUseId {get; set;}
        public String RecordId {get; set;}
        public String RmaQuantity {get; set;}
        
    }
    
    //Response Wrapper for Lot Validation
    public class oracleLotValidationResponseWrapper{
        public String OrderNumber {get; set;}
        public String OrderType {get; set;}
        public Integer LineNumber {get; set;}
        public String ShippedDate {get; set;}
        public String PriceList {get; set;}
        public String LotExpiryDate {get; set;}
        public String DiscountFlag {get; set;}
        public String LotNumber {get; set;}
        public Integer LotShipQuantity {get; set;}
        public Integer PreviousRMAQuantity {get; set;}
        public String ItemNumber {get; set;}
        public String ErrorMessage{get; set;}
        public String RecordId {get; set;}
        public String UnitSellingPrice {get; set;}    
    }
    
    //Request Wrapper for RMA creation in Oracle
    public class oracleRmaCreationRequestWrapper{
		public String SfRmaId; // Salesforce RMA Id
		public String SfRmaLineId; // Salesforce RMA Line ID
		public String TypeName; // Salesforce RMA_TYPE__c field on RMA Object
		public String OrgId;  // Salesforce Oracle_Operating_Unit__c on user account
		public String AccountNumber; // AccountNumber from Account Object
		public String SiteId; // Salesforce Oracle_Operating_Unit__c from account
		public String CustomerPo; // Salesforce Customer_PO__c from RMA Object
		public String OrderType; // Salesforce Order_Type__c from RMA Line Object
		public String LinePriceList; // Salesforce Price_List__c from RMA Line Object
		public String OriginalOrder; // Salesforce Order_Number__c from RMA Line Object
		public String OriginalOrderLineNum; // Salesforce Line_Number__c from RMA Line Object
		public String Item; // Salesforce Item_Number__c from RMA Line Object
		public Integer Quantity; // Salesforce Return_Quantity__c from RMA Line Object
		public String LotNumber; //Salesforce Lot__c RMA Line Object
		public String ManualModifierName; //Salesforce Manual_Modifier_Name__c RMA Line Object
		public String ManualModifierPercent; //Salesforce Manual_Modifier_Percent__c RMA Line Object
		public String RmaReturnReasonCode; //Salesforce Return_Reason__c RMA Line Object
		public String PatientReference; //Salesforce Patient_Reference__c RMA Line Object
	}
    
    //Reponse Wrapper for RMA creation in Oracle
    public class oracleRmaCreationResponseWrapper{
		//Reponse wrapper Properties
	}
}