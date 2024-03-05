/**
 * @description       : 
 * @author            : asood@rafter.one
 * @group             : 
 * @last modified on  : 07-11-2023
 * @last modified by  : asood@rafter.one
**/
public with sharing class B2B_DigitalWalletHelper {

    private static final String CLASSNAME = 'B2B_DigitalWalletHelper';

    public static void createDigitalWallet(Map<String,Object> dataMap){
        String methodName = 'createDigitalWallet';
        // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_ENTRY , 'Started');
        // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , 'input param dataMap');
        // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , JSON.serialize(dataMap));
        if(dataMap != null){
            String paymentMethodId;
            if(dataMap.containsKey(B2BConstants.PAYMENT_METHOD_ID) && dataMap.get(B2BConstants.PAYMENT_METHOD_ID)!=null){
                paymentMethodId = (String) dataMap.get(B2BConstants.PAYMENT_METHOD_ID);
            }
            if(String.isNotBlank(paymentMethodId)){
                List<CardPaymentMethod> cardPayments = [SELECT Id, AccountId, CardHolderName, CardLastFour, CardType, DisplayCardNumber, ExpiryMonth, ExpiryYear, GatewayToken, GatewayTokenDetails, PaymentGatewayId FROM CardPaymentMethod WHERE ID = :paymentMethodId];
                if(!cardPayments.isEmpty()){
                    CardPaymentMethod cardPayment = cardPayments[0];
                    String userId = UserInfo.getUserId();
                    String accId = B2BUtils.getUserAccountID();
                    DigitalWallet walletRec;
                    List<DigitalWallet> duplicateRecs = [SELECT ID FROM DigitalWallet WHERE GatewayTokenDetails = :cardPayment.GatewayTokenDetails AND CreatedById = :userId AND AccountId = :accId];
                    if(!duplicateRecs.isEmpty()){
                        walletRec = duplicateRecs[0];
                    }else{
                        walletRec = new DigitalWallet();
                        walletRec.PaymentGatewayId = cardPayment.PaymentGatewayId;
                        walletRec.Status = 'Active';
                        walletRec.ProcessingMode = 'External';
                        walletRec.Type = 'Card';
                        walletRec.CardLastFour__c = cardPayment.CardLastFour;
                        walletRec.Card_Type__c = cardPayment.CardType;
                        walletRec.Display_Card_Number__c = cardPayment.DisplayCardNumber;
                        walletRec.GatewayTokenDetails = cardPayment.GatewayTokenDetails;
                        walletRec.AccountId = accId;
                    }                
                    walletRec.CardHolderName__c = cardPayment.CardHolderName;
                    walletRec.ExpiryMonth__c = cardPayment.ExpiryMonth;
                    walletRec.ExpiryYear__c = cardPayment.ExpiryYear;
                    walletRec.GatewayToken = cardPayment.GatewayToken;
                    upsert walletRec;
                    //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , 'Wallet Record: '+JSON.serialize(walletRec));
                }
            }
        }
    }

    public static Map<String,Object> getDigitalWallets(Map<String,Object> dataMap){
        String methodName = 'getDigitalWallets';
        // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_ENTRY , 'Started');
        // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , 'input param dataMap');
        // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , JSON.serialize(dataMap));
        if(dataMap == null){
            dataMap = new Map<String, Object>();
        }
        String userId = UserInfo.getUserId();
        String walletQuery = 'SELECT ID, CardHolderName__c, Display_Card_Number__c, GatewayToken, ExpiryMonth__c, ExpiryYear__c, Card_Type__c FROM DigitalWallet WHERE CreatedById = :userId';
        List<DigitalWallet> wallets = Database.query(walletQuery);
       // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , 'Wallet Records: '+JSON.serialize(wallets));
        dataMap.put(B2BConstants.DIGITAL_WALLETS, wallets);
        return dataMap;
    }

    public static void deleteDigitalWallet(Map<String,Object> dataMap){
        String methodName = 'deleteDigitalWallet';
        // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_ENTRY , 'Started');
        // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , 'input param dataMap');
        // B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstants.MESSAGING_VALUE , JSON.serialize(dataMap));
        if(dataMap != null){
            String digitalWalletId;
            if(dataMap.containsKey(B2BConstants.DIGITAL_WALLET_ID) && dataMap.get(B2BConstants.DIGITAL_WALLET_ID) != null){
                digitalWalletId = (String)dataMap.get(B2BConstants.DIGITAL_WALLET_ID);
            }
            if(String.isNotBlank(digitalWalletId)){
                B2B_CybersourceRESTUtility.deletePaymentInstrument(dataMap);
                DigitalWallet walletRec = new DigitalWallet(Id=digitalWalletId, Status='Inactive');
                update walletRec;
                delete walletRec;
            }
        }
    }
    
}