global without sharing class B2BOraclePaymentCallout implements Queueable,Database.AllowsCallouts{

    global string receiptId;
    private static B2B_Oracle_Settings__mdt oraclePricingApi = B2B_Oracle_Settings__mdt.getInstance('Oracle_Invoice_Api');
    //oraclePricingApi.key__c
    global void execute(QueueableContext sc){
        try {
            orcalePaymentCallout(receiptId);
        } catch(Exception e) {
            System.debug('Exception '+e);
            //logger.error(e);
        }
        
    }

    public B2BOraclePaymentCallout() {
        
    }
    
    public static void orcalePaymentCallout(String receiptId){
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        string endPoint = oraclePricingApi.key__c;
        string authToken = oraclePricingApi.Auth_bearer_token__c;
        authToken = 'Basic ' + authToken;
        String accOrgId;
        //request.setEndpoint('https://zv-test-id5qcg6pakvx-px.integration.ocp.oraclecloud.com:443/ic/api/integration/v1/flows/rest/ZIMVIE_CC_PAYMEN_TO_EBS/1.0/CreatePayments');
        request.setEndpoint(endPoint);
        request.setHeader('Acccept','*/*');
        request.setHeader('Content-Type','application/json');
        //request.setHeader('Authorization','Basic WlZfT0lDVEVTVF9CQVNJQ0FVVEg6NDFmNWM2ZDctNmEwNy00MjhlLWFhZDQtYmZmN2JjYzEwZDhh');
        request.setHeader('Authorization',authToken);
        request.setMethod('POST');

        Payment_Receipt__c receipt = [SELECT Id, Name, Receipt_Amount__c, CurrencyIsoCode, Receipt_Date__c, Request_JSON__c,
            Customer_Number__c, Credit_Card_Token__c, Credit_card_holder_Name__c, Credit_Card_Number__c,
            Credit_Card_Expiration_Date__c, (Select id, Invoice__c, Name, Invoice__r.Name, Invoice__r.Status__c, 
                Invoice__r.Related_To_Account__r.Oracle_Operating_Unit__c from B2B_Invoice_Payments__r ) 
                FROM Payment_Receipt__c WHERE Id = :receiptId LIMIT 1];
        list<JSONToApexOraclePayment> paymentRequestBodyList = new list<JSONToApexOraclePayment>();
        JSONToApexOraclePayment paymentRequestBody = new JSONToApexOraclePayment();
        paymentRequestBody.SfPaymentId = receipt.Id;
        paymentRequestBody.ReceiptNumber = receipt.Name;
        paymentRequestBody.ReceiptAmount = receipt.Receipt_Amount__c;
        paymentRequestBody.ReceiptCurrency = receipt.CurrencyIsoCode;
        paymentRequestBody.ReceiptDate = receipt.Receipt_Date__c;
        paymentRequestBody.CustomerNumber = receipt.Customer_Number__c; 
        paymentRequestBody.CreditCardToken = receipt.Credit_Card_Token__c;
        paymentRequestBody.CardHolderName = receipt.Credit_card_holder_Name__c;
        
        /*
            *requested by murali from Oracle. they need the card token instead of masked card number.
        */
        paymentRequestBody.CardNumber = receipt.Credit_Card_Token__c;
        paymentRequestBody.CardCurrency = receipt.CurrencyIsoCode;
        paymentRequestBody.CardExpirationDate = receipt.Credit_Card_Expiration_Date__c;
        
        List<JSONToApexOraclePayment.TrxNums> transNumList = new List<JSONToApexOraclePayment.TrxNums>();
        for(B2BInvoicePayment__c inv : receipt.B2B_Invoice_Payments__r){
            JSONToApexOraclePayment.TrxNums transNum = new JSONToApexOraclePayment.TrxNums();
            transNum.TransactionNumber = inv.Invoice__r.Name;    //inv.Name;
            transNum.SfInvoiceId = inv.Invoice__c;
            transNumList.add(transNum);
            accOrgId = (String)inv.Invoice__r.Related_To_Account__r.Oracle_Operating_Unit__c;
        }
        
        paymentRequestBody.TrxNums = transNumList;
        if(accOrgId != null || accOrgId != ''){
            paymentRequestBody.Org_id = accOrgId;
        }
        
        paymentRequestBodyList.add(paymentRequestBody);
        String jsonStringRequest = JSON.serialize(paymentRequestBodyList);        
		System.debug('jsonStringRequest '+jsonStringRequest);
        request.setBody(jsonStringRequest);
        HttpResponse response = http.send(request);
        System.debug('response '+ response);
        System.debug('results '+ response.getBody());
        

        //update the reciept with the request payload
        receipt.Request_JSON__c = jsonStringRequest;
        update receipt;

        list<Invoice__c> invsToUpdate = new list<Invoice__c>();
        if(response.getStatusCode() == 202 || response.getStatus() == 'Accepted'){

            //update the invoice status to in-progress
            for(B2BInvoicePayment__c invPayment : receipt.B2B_Invoice_Payments__r){
                Invoice__c inv = new Invoice__c();
                inv.Id = invPayment.Invoice__c;
                inv.Status__c = 'In Process';
                invsToUpdate.add(inv);
            }
            if(!invsToUpdate.isEmpty()){
                update invsToUpdate;
            }

            //send invoice email
            Map<String, Object> mapParams = new Map<String, Object>();
            mapParams.put('receiptId', receiptId);
            sendInvoiceEmail(mapParams);
        }
    }

    public static void sendInvoiceEmail(Map<String, Object> mapParams){
        try{
            Boolean isSent = false;
            String receiptId = (String)mapParams.get('receiptId');
            Payment_Receipt__c receipt = [SELECT Id FROM Payment_Receipt__c WHERE Id = :receiptId];
           
            if(receipt != null){
    
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(UserInfo.getUserId());  
                message.setSenderDisplayName('Company Support'); 
                message.setReplyTo('no-reply@company.com');
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(false); 
                EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'B2B Invoice Payment In Process'];
                message.setTemplateID(emailTemplate.Id); 
                message.setWhatId(receipt.Id); //This is important for the merge fields in template to work
                message.toAddresses = new String[] { UserInfo.getUserEmail()};
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                if(results[0].success) {
                    System.debug('The email was sent successfully.');
                    isSent = true;
                } else {
                    System.debug('The email failed to send: ' +  results[0].errors[0].message);
                    isSent = false;
                }
            }
        }catch(Exception e){
            System.debug('Exception--- '+ e);
        }
    }
}