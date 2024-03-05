/**
 * @description       : 
 * @author            : Gaurav Setia
 * @group             : 
 * @last modified on  : 09-18-2023
 * @last modified by  : Gaurav Setia
**/
public with sharing class B2BOrderConfirmationHelper {
    
    public static Map<String, Object> getOrderProductSummary(Map<String, Object> mapParams){
        system.debug('getOrderProductSummary');
        List<OrderSummary> orderSummaryList = B2BOrderSummarySelector.getOrderSummary(mapParams);
        system.debug('orderSummaryList'+json.serializePretty(orderSummaryList));
        if(!orderSummaryList.isEmpty()){
            OrderSummary orderSummaryObj = orderSummaryList.get(0);
            List<OrderItemSummary> orderItemSummaryList = B2BOrderSummarySelector.getOrderProductSummary(mapParams);
            if(!orderItemSummaryList.isEmpty()){
                mapParams.put(B2BConstants.ORDER_ITEM_SUMMARY_LIST,orderItemSummaryList);
            }
            mapParams.put(B2BConstants.ORDER_SUMMARY,orderSummaryObj);
            
            
        }
        
        return mapParams;
    }

    public static Map<String, Object> getAddressInformation(Map<String, Object> mapParams){
        List<OrderSummary> orderSummaryList = B2BOrderSummarySelector.getOrderSummary(mapParams);
        if(!orderSummaryList.isEmpty()){
            OrderSummary orderSummaryObj = orderSummaryList.get(0);
            mapParams.put(B2BConstants.ORDER_SUMMARY,orderSummaryObj);
            List<OrderDeliveryGroupSummary> orderDeliveryGroupList = B2BOrderSummarySelector.getOrderDeliveryGroupSummary(mapParams);
            if(!orderDeliveryGroupList.isEmpty()){
                OrderDeliveryGroupSummary orderDeliveryGroupObj = orderDeliveryGroupList.get(0);
                mapParams.put(B2BConstants.ORDER_DELIVERY_GROUPS,orderDeliveryGroupObj);
            }
            CardPaymentMethod cardPaymentObj = getOrderPaymentSummary(mapParams);
            if(cardPaymentObj != null){
                mapParams.put(B2BConstants.ORDER_PAYMENT,cardPaymentObj);
            }
        }
        return mapParams;
    }

    public static CardPaymentMethod getOrderPaymentSummary(Map<String, Object> mapParams){
        CardPaymentMethod cardPaymentObj = null;
        String orderSummaryNumber = (String)mapParams.get(B2BConstants.ORDER_SUMMARY_NUMBER);
        OrderSummary orderSummary = [SELECT Id FROM OrderSummary WHERE OriginalOrder.OrderReferenceNumber=:orderSummaryNumber];
        List<OrderPaymentSummary> orderPaymentList = [SELECT Id, PaymentMethodId, PaymentMethod.Name, OrderSummaryId, OrderSummary.OrderNumber 
                                                        FROM OrderPaymentSummary WHERE OrderSummaryId =:orderSummary.Id];
        if(!orderPaymentList.isEmpty()){
            OrderPaymentSummary orderPaymentObj = orderPaymentList.get(0);
            List<CardPaymentMethod> cardPaymentList = [SELECT Id, DisplayCardNumber FROM CardPaymentMethod WHERE Id=:orderPaymentObj.PaymentMethodId];
            cardPaymentObj = cardPaymentList.get(0);
        }
        return cardPaymentObj;
    }


    public static Boolean sendOrderConfirmEmail(Map<String, Object> mapParams){

        Boolean isSent = false;
        if(mapParams != null && mapParams.containsKey(B2BConstants.ORDER_SUMMARY_NUMBER) && mapParams.get(B2BConstants.ORDER_SUMMARY_NUMBER) != null) {

            String orderSummaryNumber = (String)mapParams.get(B2BConstants.ORDER_SUMMARY_NUMBER);
            OrderSummary orderSummary = [SELECT Id, B2B_Email_Sent__c FROM OrderSummary WHERE OriginalOrder.OrderReferenceNumber=:orderSummaryNumber];

            if(orderSummary != null && !orderSummary.B2B_Email_Sent__c) {

                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.setTargetObjectId(UserInfo.getUserId());  
                message.setReplyTo(System.Label.B2B_Sender_Email);
                message.setUseSignature(false); 
                message.setBccSender(false); 
                message.setSaveAsActivity(false); 
                EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body from EmailTemplate where name = 'B2B Order Confirmation'];
                message.setTemplateID(emailTemplate.Id); 
                message.setWhatId(orderSummary.Id); //This is important for the merge fields in template to work
                OrgWideEmailAddress owa = [SELECT Id FROM OrgWideEmailAddress WHERE Address =: System.Label.B2B_Sender_Email LIMIT 1];
                message.setOrgWideEmailAddressId(owa.Id);
                message.toAddresses = new String[] { UserInfo.getUserEmail()};
                Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                
                if(results[0].success) {
                    System.debug('The email was sent successfully.');
                    orderSummary.B2B_Email_Sent__c = true;
                    update orderSummary;
                    isSent = true;
                } else {
                    System.debug('The email failed to send: ' +  results[0].errors[0].message);
                    isSent = false;
                }
            }
        }
        return isSent;
    }
}