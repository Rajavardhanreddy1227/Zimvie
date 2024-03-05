/**
 * @description       : 
 * @author            : asood@rafter.one
 * @group             : 
 * @last modified on  : 09-12-2023
 * @last modified by  : Gaurav Setia
**/
global without sharing class B2B_CybersourcePMScheduler implements Queueable,Database.AllowsCallouts {
    global String paymentId;
    global String payAuthId;
    global String cardholderName;
    global String cardholderNickName;
    global String cardType;
    global String userId;
    global String OrderId;
    global String ContractId;
    global String InvoiceId;
    global String PONumber;
    global string PMStreet;
    global string PMCity;
    global string PMState;
    global string PMCountry;
    global string PMPostalCode;
    global string currencyCode;    
    global string contactId;
    global string email;
    global string accountId;
    global boolean isTemporary = false;
    //global string paymentResponse;
    global boolean isUpdateToken;
    global void execute(QueueableContext sc){
        try{
        if(isUpdateToken){
            updateTokenOnOrder(OrderId,paymentId);
        }else {
            getTransactionDetails(paymentId, payAuthId, cardholderName, cardholderNickName, cardType, userId, OrderId, PONumber, PMStreet, PMCity, PMState, PMCountry, PMPostalCode, currencyCode, isTemporary, accountId, contactId, email);
            
        }
        }
        catch(Exception e)
        {
            System.debug('Exception '+e);
            //logger.error(e);
        }
        
    }

    @future (callout=true)
    public static void getTransactionDetails(String paymentId,
                                             String payAuthId,
                                             String cardholderName,
                                             String cardholderNickName,
                                             String cardType,
                                             String userId, String OrderId, 
                                             String PONumber, String PMStreet, 
                                             String PMCity, String PMState, 
                                             String PMCountry, String PMPostalCode, 
                                             String currencyCode, Boolean isTemporary, 
                                             String accountId, String contactId, 
                                             String email){  
                                                 try{
                                                    System.debug('Inside---->');
                                                     User commU;
                                                     Account acc;
                                                     if(userId != null){
                                                         commU = [SELECT Id, currencyIsoCode, Email, FirstName, LastName, ContactId, AccountId FROM User WHERE Id=:userId];
                                                         acc=[select id,currencyIsoCode from Account where id=:commU.AccountId];
                                                     }
                                                     
                                                     Integer currentYear = System.Today().year();
                                                    //  B2B_CyberSource_Merchant__mdt cyberSource;
                                                    //  if(!test.isRunningTest()){
                                                    //     cyberSource=B2B_PaymentForExperience.getMerchant();
                                                    // }else{
                                                    //     cyberSource=[SELECT Id, Key_ID__c, Private_Key__c, Microflex_Key_Creation_URL__c,Label,
                                                    //                    DeveloperName, Environments_Request_URLs__c, Payment_API_URL__c, Transaction_API_URL__c,Is_3D_Secure_Enable__c FROM B2B_CyberSource_Merchant__mdt limit 1];
                                                    // }
                                                     
                                                     
                                                     
                                                     //TNV_MD_Country__mdt countryMetaData = [SELECT Id, Direct_LE_code__c FROM TNV_MD_Country__mdt WHERE Country_Name__c = :PMCountry LIMIT 1];
                                                     B2B_CybersourceRESTUtility.getCYBSConfiguration();
                                                     String PaymentResponse = B2B_CybersourceRESTUtility.getTransactionDetails(paymentId);
                                                     System.debug('____PaymentResponse__-----__'+PaymentResponse);
                                                     
                                                     Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(PaymentResponse);
                                                     Map<String,Object> paymentInformation = (Map<String,Object>)results.get('paymentInformation');
                                                     Map<String,Object> customer = (Map<String,Object>)paymentInformation.get('customer');
                                                     Map<String,Object> card = (Map<String,Object>)paymentInformation.get('card');
                                                     System.debug('results---->'+results);
                                                     System.debug('paymentInformation---->'+paymentInformation);
                                                     System.debug('customer---->'+customer);
                                                     String respToken = (String)results.get('id');
                                                     System.debug('respToken---->'+respToken);
                                                     DigitalWallet digitalWallet = new DigitalWallet();
                                                     digitalWallet.GatewayToken =respToken;
                                                     if(email != null && accountId != null && contactId != null){
                                                        digitalWallet.Email = email;
                                                        digitalWallet.AccountId = accountId;
                                                        digitalWallet.Contact__c = contactId;
                                                     }
                                                     else{
                                                        digitalWallet.Email = commU.Email;
                                                        digitalWallet.B2B_BillingFirstName__c = commU.FirstName;
                                                        digitalWallet.B2B_BillingLastName__c = commU.LastName;
                                                        digitalWallet.AccountId = commU.AccountId;
                                                        digitalWallet.Contact__c = commU.ContactId;
                                                     }
                                                     
                                                     digitalWallet.NickName = cardholderNickName;
                                                     digitalWallet.Card_Type__c = cardType ;
                                                     digitalWallet.CardHolderName__c = cardholderName;
                                                     digitalWallet.ExpiryMonth__c = Decimal.valueOf((String)card.get('expirationMonth'));
                                                     digitalWallet.ExpiryYear__c = Decimal.valueOf((String)card.get('expirationYear'));//String.valueof(currentYear).substring(0,2)+(string)card.get('expirationYear');
                                                     
                                                     digitalWallet.GatewayToken = (string)customer.get('customerId');
                                                     digitalWallet.CardLastFour__c = Decimal.valueOf((String) card.get('suffix'));
                                                     digitalWallet.Display_Card_Number__c = (string)card.get('suffix');
                                                     digitalWallet.B2B_BillingCountry__c = PMCountry;
                                                     digitalWallet.B2B_BillingZipPostal__c = PMPostalCode;
                                                     digitalWallet.B2B_BillingStreet__c = PMStreet;
                                                     //digitalWallet.B2B_BillingStateProvince__c = PMState;
                                                     digitalWallet.B2B_BillingCity__c = PMCity;
                                                     digitalWallet.Status='Active';
                                                    //  digitalWallet.B2B_Active__c = true;
                                                     digitalWallet.ProcessingMode='External';
                                                     System.debug('digitalWallet---->'+digitalWallet);
                                                     insert digitalWallet;
                                                     //deleteOtherPendingJobs();
                                                    //  Order ord=new Order(id=orderId,Payment_Auth_Token__c=(string)customer.get('customerId'),Payment_Auth_Code__c=(string)results.get('id'),Payment_MID__c=cyberSource.Label);

                                                    //  //Order ord=new Order(id=orderId,B2B_Payment_Token__C=(string)customer.get('customerId'));
                                                    //  update ord;
                                                     
                                                    //  if(payAuthId != null){
                                                    //     PaymentAuthorization pa = new PaymentAuthorization(Id=payAuthId);
                                                    //     pa.B2B_PaymentMethod__c = digitalWallet.Id;
                                                    //     update pa; 
                                                    // }
                                                     
                                                 }
                                                 catch(Exception e){
                                                     System.debug('Exception Payment Creation '+e.getCause() +' --'+e.getMessage()+'---'+e.getLineNumber());
                                                     //dcm_Logger.log(LoggingLevel.ERROR, e, 'CYBS Payment', 'getTransactionDetails', '', '', '', '','', 'getTransactionDetails', 'TNVB2B_CybersourceScheduler', 'getTransactionDetails');
                                                     
                                                 }finally{
                                                    //deleteOtherPendingJobs();
                                                 }
                                                 
                                             }

    @future (callout=true)
    public static void updateTokenOnOrder(String orderId,String paymentId)
    {
        try{
            // B2B_CyberSource_Merchant__mdt cyberSource;
            // if(!test.isRunningTest()){
            //     cyberSource=B2B_PaymentForExperience.getMerchant();
            // }else{
            //     cyberSource=[SELECT Id, Key_ID__c, Private_Key__c, Microflex_Key_Creation_URL__c,Label,
            //                   DeveloperName, Environments_Request_URLs__c, Payment_API_URL__c, Transaction_API_URL__c,Is_3D_Secure_Enable__c FROM B2B_CyberSource_Merchant__mdt limit 1];
            // }
            
            
            B2B_CybersourceRESTUtility.getCYBSConfiguration();
            String PaymentResponse = B2B_CybersourceRESTUtility.getTransactionDetails(paymentId);
            System.debug('____PaymentResponse____'+PaymentResponse);
            
            Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(PaymentResponse);
            Map<String,Object> paymentInformation = (Map<String,Object>)results.get('paymentInformation');
            Map<String,Object> customer = (Map<String,Object>)paymentInformation.get('customer');
            
            // Order ord=new Order(id=orderId,Payment_Auth_Token__c=(string)customer.get('customerId'),Payment_Auth_Code__c=(string)results.get('id'),Payment_MID__c=cyberSource.Label);
            // update ord;
        }
        catch(Exception e)
        {
            System.debug('Exception---'+e);
            //logger.error(e);
        }
        //updateOrderWithPaymentId(string.valueOf(ord.id),);
    }
   
    public static void deleteOtherPendingJobs()
    {
        // Get the ID of the AsyncApexJob representing this batch job from Database.BatchableContext.
        // Query the AsyncApexJob object to retrieve the current job's information.
        // AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];

        //     //then use the active job id and abort it
        //     System.abortJob(a.id);
        List<CronJobDetail> cronJobList = [SELECT Id, Name, JobType FROM CronJobDetail where Name LIKE : '%B2B_CybersourcePMScheduler%'];
        List<String> cronIdList = new List<String>();
        System.debug('cronJobList---->'+cronJobList);
        for(CronJobDetail cJob: cronJobList){
            cronIdList.add(cJob.Id);
        }
        System.debug('cronIdList---->'+cronIdList);
        List <CronTrigger> CronTrigegr = [SELECT Id, CronJobDetailId, TimesTriggered, State FROM CronTrigger where CronJobDetailId IN:cronIdList];
        for(CronTrigger a : CronTrigegr){
                //then use the active job id and abort it
                System.abortJob(a.id);
        }
    }

}