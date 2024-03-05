/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-14-2022
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class B2BDigitalWalletHelper {
    
    private static final String CLASSNAME = 'B2BDigitalWalletHelper';

    public static void createDigitalWallet(Map<String,Object> dataMap){
        String methodName = 'createDigitalWallet';
		if(dataMap != null){
            String paymentMethodId;
            if(dataMap.containsKey('paymentMethodId') && dataMap.get('paymentMethodId')!=null){
                paymentMethodId = (String) dataMap.get('paymentMethodId');
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
                    //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BConstant.MESSAGING_VALUE , 'Wallet Record: '+JSON.serialize(walletRec));
                }
            }
        }
    }
}