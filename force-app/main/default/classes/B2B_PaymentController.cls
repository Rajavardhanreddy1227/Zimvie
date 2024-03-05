/**
 * @description       : 
 * @author            : asood@rafter.one
 * @group             : 
 * @last modified on  : 07-11-2023
 * @last modified by  : asood@rafter.one
**/
public with sharing class B2B_PaymentController {
    private static final String CLASSNAME = 'B2BPaymentController';
    private static final String STOREFRONT = 'AXON';
    private static final String MODULE_NAME = 'Checkout Payment Module';

    @AuraEnabled
    public static Map<String,Object> setPayment(Map<String,Object> dataMap) {
        String methodName = 'setPayment';
        String supportData = '';
        try {
           // B2BLogger.log(LoggingLevel.DEBUG, CLASSNAME, methodName, B2BConstant.MESSAGING_ENTRY, 'Started');
            B2B_PaymentHelper.setPayment(dataMap);
            dataMap.put(B2BConstants.IS_SUCCESS, true);
           // B2BLogger.log(LoggingLevel.DEBUG, CLASSNAME, methodName, B2BConstant.MESSAGING_EXIT, 'End');
        } catch (Exception ex) {
            dataMap = dataMap == null ? new Map<String, Object>() : dataMap ;
            dataMap.put(B2BConstants.IS_SUCCESS, false);
            dataMap.put(B2BConstants.MESSAGE, System.Label.B2B_Card_Validation_Generic_Error);
            //dataMap.put(B2BConstant.MESSAGE, ex.getMessage()+':'+ex.getStackTraceString());
           // B2BExceptionLogs.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        } finally {
            //B2BUtils.handleApplicationLogging(dataMap);
        }
        return dataMap;
    }

    // @AuraEnabled
    // public static Map<String,Object> setPaymentThroughWallet(Map<String,Object> dataMap) {
    //     String methodName = 'setPaymentThroughWallet';
    //     String supportData = '';
    //     try {
    //         B2BLogger.log(LoggingLevel.DEBUG, CLASSNAME, methodName, B2BConstant.MESSAGING_ENTRY, 'Started');
    //         B2B_PaymentHelper.setPaymentThroughWallet(dataMap);
    //         dataMap.put(B2BConstant.IS_SUCCESS, true);
    //         B2BLogger.log(LoggingLevel.DEBUG, CLASSNAME, methodName, B2BConstant.MESSAGING_EXIT, 'End');
    //     } catch (Exception ex) {
    //         dataMap = dataMap == null ? new Map<String, Object>() : dataMap ;
    //         dataMap.put(B2BConstant.IS_SUCCESS, false);
    //         dataMap.put(B2BConstant.MESSAGE, System.Label.B2B_Card_Validation_Generic_Error);
    //         B2BExceptionLogs.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
    //     } finally {
    //         B2BUtils.handleApplicationLogging(dataMap);
    //     }
    //     return dataMap;
    // }

    @AuraEnabled
    public static Map<String,Object> getCustomerToken(Map<String,Object> dataMap) {
        String methodName = 'getCustomerToken';
        String supportData = '';
        System.debug('Inside---getCustomerToken->');
        try {
            //B2BLogger.log(LoggingLevel.DEBUG, CLASSNAME, methodName, B2BConstant.MESSAGING_ENTRY, 'Started');
            System.debug('dataMap---->'+dataMap);
            String customerToken = B2B_CybersourceRESTUtility.getCustomerToken();
            System.debug('customerToken---->'+customerToken);
            dataMap.put(B2BConstants.CUSTOMER_TOKEN,customerToken);
            dataMap.put(B2BConstants.IS_SUCCESS, true);
            //B2BLogger.log(LoggingLevel.DEBUG, CLASSNAME, methodName, B2BConstant.MESSAGING_EXIT, 'End');
        } catch (Exception ex) {
            dataMap = dataMap == null ? new Map<String, Object>() : dataMap ;
            dataMap.put(B2BConstants.IS_SUCCESS, false);
            dataMap.put(B2BConstants.MESSAGE, ex.getMessage()+':'+ex.getStackTraceString());
            System.debug('ex---->'+ex);
            System.debug('ex---->'+ex.getMessage());
           // B2BExceptionLogs.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        } finally {
           // B2BUtils.handleApplicationLogging(dataMap);
        }
        System.debug('dataMap---dataMap->'+dataMap);
        return dataMap;
    }


    @AuraEnabled
    public static Map<String,Object> B2B_PaymentController(Map<String,Object> dataMap) {
        String methodName = 'getDigitalWallets';
        String supportData = '';
        try {
            //B2BLogger.log(LoggingLevel.DEBUG, CLASSNAME, methodName, B2BConstant.MESSAGING_ENTRY, 'Started');
            dataMap = B2B_DigitalWalletHelper.getDigitalWallets(dataMap);
            dataMap.put(B2BConstants.IS_SUCCESS, true);
           // B2BLogger.log(LoggingLevel.DEBUG, CLASSNAME, methodName, B2BConstants.MESSAGING_EXIT, 'End');
        } catch (Exception ex) {
            dataMap = dataMap == null ? new Map<String, Object>() : dataMap ;
            dataMap.put(B2BConstants.IS_SUCCESS, false);
            dataMap.put(B2BConstants.MESSAGE, ex.getMessage()+':'+ex.getStackTraceString());
            //B2BExceptionLogs.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        } finally {
            //B2BUtils.handleApplicationLogging(dataMap);
        }
        return dataMap;
    }

    @AuraEnabled
    public static Map<String,Object> deleteDigitalWallet(Map<String,Object> dataMap) {
        String methodName = 'deleteDigitalWallet';
        String supportData = '';
        try {
            //B2BLogger.log(LoggingLevel.DEBUG, CLASSNAME, methodName, B2BConstant.MESSAGING_ENTRY, 'Started');
            B2B_DigitalWalletHelper.deleteDigitalWallet(dataMap);
            dataMap.put(B2BConstants.IS_SUCCESS, true);
           // B2BLogger.log(LoggingLevel.DEBUG, CLASSNAME, methodName, B2BConstant.MESSAGING_EXIT, 'End');
        } catch (Exception ex) {
            dataMap = dataMap == null ? new Map<String, Object>() : dataMap ;
            dataMap.put(B2BConstants.IS_SUCCESS, false);
            dataMap.put(B2BConstants.MESSAGE, ex.getMessage()+':'+ex.getStackTraceString());
            //B2BExceptionLogs.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
        } finally {
           // B2BUtils.handleApplicationLogging(dataMap);
        }
        return dataMap;
    }

    // /**
    //  * @description To capture payment through cybersource
    //  * @param userId  Cart Owner Id
    //  * @param Amount  Amount to Capture
    //  * @param token Gateway Token from card payment method record
    //    @return map with success/failure result
    //  */

    // public static Map<String,Object> capturePayment(Map<String,Object> dataMap) {
    //     String methodName = 'capturePayment';
    //     String supportData = '';
    //     try {
    //         B2BLogger.log(LoggingLevel.DEBUG, CLASSNAME, methodName, B2BConstant.MESSAGING_ENTRY, 'Started');
    //         dataMap = B2B_PaymentHelper.capturePayment(dataMap);
    //         B2BLogger.log(LoggingLevel.DEBUG, CLASSNAME, methodName, B2BConstant.MESSAGING_EXIT, 'End');
    //     } catch (Exception ex) {
    //         dataMap = dataMap == null ? new Map<String, Object>() : dataMap ;
    //         dataMap.put(B2BConstant.IS_SUCCESS, false);
    //         dataMap.put(B2BConstant.MESSAGE, ex.getMessage()+':'+ex.getStackTraceString());
    //         B2BExceptionLogs.storeExceptionLog(ex, STOREFRONT, MODULE_NAME, CLASSNAME, methodName, supportData);
    //     } finally {
    //         B2BUtils.handleApplicationLogging(dataMap);
    //     }
    //     return dataMap;
    // }


    private static ConnectApi.AuthApiPaymentMethodRequest getPaymentMethod(Map<String, Object> paymentInfo, Map<String, Object> billingAddress) {
        
        ConnectApi.AuthApiPaymentMethodRequest authApiMethod = new ConnectApi.AuthApiPaymentMethodRequest();
        
        ConnectApi.CardPaymentMethodRequest paymentMethod = new ConnectApi.CardPaymentMethodRequest();
        paymentMethod.cardCategory = ConnectApi.CardCategory.CreditCard;
        paymentMethod.cardHolderName = (String) paymentInfo.get('cardHolderName');
        paymentMethod.cardHolderFirstName = (String) paymentInfo.get('cardHolderFirstName');
        paymentMethod.cardHolderLastName = (String) paymentInfo.get('cardHolderLastName');
        paymentMethod.cardType = (String) paymentInfo.get('cardType');
        paymentMethod.cardNumber = (String) paymentInfo.get('cardNumber');
        paymentMethod.cvv = (String) paymentInfo.get('cvv');
        paymentMethod.expiryMonth = Integer.valueOf(paymentInfo.get('expiryMonth'));
        paymentMethod.expiryYear = Integer.valueOf(paymentInfo.get('expiryYear'));   
        paymentMethod.accountId = (String) paymentInfo.get('accountId');
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


    @AuraEnabled
    public static void setPaymentInfo(String token, String expirationMonth, String expirationYear, String cardholderName, String cardholderNickName, String cardType) {
        
        ConnectApi.AuthorizationRequest authRequest = new ConnectApi.AuthorizationRequest();
        Map<String, Object> selectedBillingAddress = new Map<String, Object>();
        Map<String, Object> paymentInfo = new Map<String, Object>();
        try {
            String AccountId = [SELECT AccountId FROM User WHERE Id=:userInfo.getUserId()].AccountId;
            ContactPointAddress cpa = [SELECT Id,City,Country,PostalCode,State,Street FROM ContactPointAddress WHERE ParentId=:AccountId AND AddressType='Billing' AND IsDefault=true LIMIT 1];
            selectedBillingAddress.put('street',cpa.Street);
            selectedBillingAddress.put('postalCode',cpa.PostalCode);
            selectedBillingAddress.put('city',cpa.City);
            selectedBillingAddress.put('state',cpa.State);
            selectedBillingAddress.put('country',cpa.Country);
            
            paymentInfo.put('cardHolderName', cardholderName);
            paymentInfo.put('cardHolderFirstName', 'TestAAAA');
            paymentInfo.put('cardHolderLastName', 'TestBBB');
            paymentInfo.put('cardNumber','4111111111111111');
            paymentInfo.put('cardType',cardType);
            paymentInfo.put('cvv','123');
            paymentInfo.put('expiryMonth', expirationMonth);
            paymentInfo.put('expiryYear', expirationYear);
            paymentInfo.put('accountId', AccountId);
            paymentInfo.put('token',token);

            authRequest.amount = 0;
            authRequest.accountId = AccountId;
            
            Map<String, Object> dataMap = new Map<String, Object>();
            
            dataMap.putAll(selectedBillingAddress);
            dataMap.putAll(paymentInfo);
            authRequest.effectiveDate = Datetime.now();
            authRequest.currencyIsoCode = UserInfo.getDefaultCurrency();
            
            // Cannot proceed if paymentGatewayId does not exist
            String webStoreId = B2BUtils.resolveCommunityIdToWebstoreId('0DB8L000000Cai3WAC');
            String paymentGatewayId = getPaymentGatewayId(webStoreId);
            
            
            if (paymentGatewayId == null || paymentGatewayId.equals('')) {
               throw new AuraHandledException('This store is not authorized to process payments.');
            }
            System.debug('333333333333333333');
            authRequest.paymentGatewayId = paymentGatewayId;
            authRequest.paymentMethod = getPaymentMethod(paymentInfo, selectedBillingAddress);
            //authRequest.comments = JSON.serialize(dataMap);
            
            Map<String, String> additionalDataMap = new Map<String, String>();
            Integer i = 0;
            String v1Token = '';
            String v2Token = '';
            String legacyToken = '';
            i = token.length();
            v1Token = token.substring(0,i/2);
            v2Token = token.substring(i/2,token.length());
            additionalDataMap.put('v1Token',v1Token);
            additionalDataMap.put('v2Token',v2Token);
            additionalDataMap.put('isJWT','true');
            additionalDataMap.put('webstoreId', webStoreId);
            authRequest.additionalData = additionalDataMap;
            
            // Authorize Payment with Payments API
            System.debug('1111111111111111111' + authRequest);
            System.debug('aaaaaaaaaaaaaa' + ConnectApi.Payments.authorize(authRequest));
            ConnectApi.AuthorizationResponse authResponse = ConnectApi.Payments.authorize(authRequest);
            System.debug('!!!!!!!!!!!!!!!!!!!!!'+authResponse);
            ConnectApi.AuthorizationGatewayResponse authGatewayRes = authResponse.gatewayResponse;
            
            System.debug('____authResponse____'+authResponse);
            if (authResponse.error != null) {
                throw new AuraHandledException('AuthResponseError: ' + authResponse.error.message);
            }

                DigitalWalletElement digitalWalletElement = new DigitalWalletElement();
                digitalWalletElement.cardType = (String)dataMap.get('cardType');
                digitalWalletElement.expMonth = double.valueOf((String)dataMap.get('expiryMonth'));
                digitalWalletElement.expYear = double.valueOf((String)dataMap.get('expiryYear'));
                digitalWalletElement.paymentStreet = (String)dataMap.get('street');
                digitalWalletElement.paymentPostalCode = (String)dataMap.get('postalCode');
                digitalWalletElement.paymentCity = (String)dataMap.get('city');
                digitalWalletElement.paymentState = (String)dataMap.get('state');
                digitalWalletElement.paymentCountry = (String)dataMap.get('country');
                digitalWalletElement.cardHolderNickName = cardholderNickName;
                digitalWalletElement.cardHolderName = cardholderName;
                digitalWalletElement.token = authGatewayRes.gatewayAuthorizationCode;
                createDigitalWallet(digitalWalletElement);
            
        } catch(ConnectApi.ConnectApiException e) {
            System.debug('Message: ' + e.getMessage() + ' --- ' + 'Type: ' + e.getTypeName() + '----' + ' _STACK_: ' + e.getStackTraceString());
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            System.debug('Message: ' + e.getMessage() + ' --- ' + 'Type: ' + e.getTypeName() + '----' + ' _STACK_: ' + e.getStackTraceString());
            throw new AuraHandledException('Message: ' + e.getMessage() + ' --- ' + 'Type: ' + e.getTypeName() + '----' + ' _STACK_: ' + e.getStackTraceString());
        }
    }

    private static String getPaymentGatewayId(String webStoreId) {
        return [
            SELECT Integration 
            FROM StoreIntegratedService 
            WHERE ServiceProviderType='Payment' 
            AND StoreId=:webStoreId
        ].Integration;
    }

    public static void createDigitalWallet(DigitalWalletElement newDWData){

        try {
            User user = [
            SELECT Id, 
                    Name, 
                    FirstName, 
                    LastName, 
                    AccountId,
                    ContactId, 
                    Account.Name, 
                    Email 
            FROM User 
            WHERE Id=:UserInfo.getUserId() 
            LIMIT 1
        ];
        
        DigitalWallet digitalWallet = new DigitalWallet();                
        digitalWallet.Email = user.Email;
        digitalWallet.B2B_BillingFirstName__c = user.FirstName;
        digitalWallet.B2B_BillingLastName__c = user.LastName;
        digitalWallet.AccountId = user.AccountId;
        digitalWallet.Contact__c = user.ContactId;
        digitalWallet.NickName = newDWData.cardHolderNickName;
        digitalWallet.Card_Type__c = newDWData.cardType;
        digitalWallet.CardHolderName__c = newDWData.cardHolderName;
        digitalWallet.ExpiryMonth__c = newDWData.expMonth;
        digitalWallet.ExpiryYear__c = newDWData.expYear;    
        digitalWallet.GatewayToken = newDWData.token;
        // digitalWallet.CardLastFour__c = Decimal.valueOf((String) card.get('suffix'));
        // digitalWallet.Display_Card_Number__c = (string)card.get('suffix');
        digitalWallet.B2B_BillingCountry__c = newDWData.paymentCountry;
        digitalWallet.B2B_BillingZipPostal__c = newDWData.paymentPostalCode;
        digitalWallet.B2B_BillingStreet__c = newDWData.paymentStreet;
        digitalWallet.B2B_BillingCity__c = newDWData.paymentCity;
        digitalWallet.Status ='Active';
        digitalWallet.B2B_Active__c = true;
        digitalWallet.ProcessingMode ='External';
        insert digitalWallet;
        } catch (Exception e) {
            throw new AuraHandledException('Message: ' + e.getMessage() + ' --- ' + 'Type: ' + e.getTypeName() + '----' + ' _STACK_: ' + e.getStackTraceString());
        }
        
    }
    
    public class DigitalWalletElement {
        public String token;
        public String cardType;
        public decimal expMonth;
        public decimal expYear;
        public String cardHolderName;
        public String cardHolderNickName;
        public String nickName;
        public String paymentPostalCode;
        public String paymentStreet;
        public String paymentCity;
        public String paymentState;
        public String paymentCountry;
        public String accountId;
        public String displayCardNumber;
    }
}