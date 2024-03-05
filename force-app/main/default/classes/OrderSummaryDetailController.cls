public with sharing class OrderSummaryDetailController {
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getOrderSummary(String orderSummaryId) {

        Map<String, Object> responseMap = new Map<String, Object>();

        OrderSummary objOrderSummary  = [SELECT Id, B2B_PO_Number__c, OracleOrderId__c,PoNumber, OrderNumber, OrderedDate, Account.Name, 
                                        CreatedBy.Name, Status,TotalProductAmount,TotalAdjustedProductAmount,TotalAdjDistAmount,Order_Source__c,OriginalOrder.OracleOrderNumber__c,
                                        TotalProductAdjDistAmtWithTax, TotalAdjustedProductTaxAmount,
                                        TotalAdjustedDeliveryAmount, TotalDeliveryAdjDistAmtWithTax, 
                                        TotalAdjustedDeliveryTaxAmount, GrandTotalAmount,CurrencyIsoCode,
                                        (SELECT Id, Status, Quantity, UnitPrice, TotalAdjustmentAmtWithTax,
                                         TotalPrice, Product2Id, Product2.Name, Product2.StockKeepingUnit 
                                         FROM OrderItemSummaries WHERE Type != 'Delivery Charge'),
                                        (SELECT Id, DeliverToName, OrderDeliveryMethod.Name, DeliverToStreet, 
                                        DeliverToCity, DeliverToState, DeliverToPostalCode,DeliverToCountryCode,DeliverToStateCode, DeliverToCountry
                                        FROM OrderDeliveryGroupSummaries ORDER BY CreatedDate DESC LIMIT 1)
                                        FROM OrderSummary WHERE Id =: orderSummaryId LIMIT 1];

        List<Shipment> listOfShipments = [SELECT Id, TrackingNumber, Status, TrackingURL,
                                          (SELECT Id, Product2Id, Product2.Name, Product2.StockKeepingUnit
                                          FROM ShipmentItems)
                                          FROM Shipment
                                          WHERE OrderSummaryId =: orderSummaryId];
        responseMap.put('OrderSummary', objOrderSummary);
        responseMap.put('Shipments', listOfShipments);
        responseMap.put('BaseURL', getCommunityURL());
        responseMap.put('OrderItemSummary', getProductDetails(orderSummaryId));
        return responseMap;
    }

    public static String getProductDetails(String ordSummId){
        User objLoginUser = [SELECT ID, AccountId FROM User WHERE Id =: userInfo.getUserId() LIMIT 1];
        String webstoreId;
        if(!Test.isRunningTest()){
            webstoreId = B2BUtils.resolveCommunityIdToWebStoreId(Network.getNetworkId());
        }else{
            webstoreId = [SELECT Id FROM WebStore LIMIT 1].Id;
        }
		String sfdcURL = URL.getOrgDomainUrl().toExternalForm();
        String endpoint = sfdcURL + '/services/data/v54.0/commerce/webstores/' + webstoreId + 
            '/order-summaries/' + ordSummId +'/items?effectiveAccountId' + objLoginUser.AccountId +
            '&fields=OrderItemSummary.Id';
        system.debug('endpoint'+endpoint);

        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setMethod('GET');
        httpRequest.setHeader('Authorization', 'OAuth ' + UserInfo.getSessionId());        
        httpRequest.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId()); 
        httpRequest.setHeader('Content-Type', 'application/json;charset=UTF-8');
        httpRequest.setEndpoint(endpoint);
        String response;        
        try {
            Http http = new Http();
            HttpResponse httpResponse = http.send(httpRequest);
            Integer statusCode = httpResponse.getStatusCode();
            if(statusCode >= 200 && statusCode <= 204) {
                response = httpResponse.getBody();
            } else {
                throw new CalloutException(httpResponse.getBody());
            }
        } catch (System.Exception e) {
            throw e;
        }
        system.debug('response===='+response);
        return response;
    }
    
    private static String getCommunityURL(){       
        String base = Network.getLoginUrl(Network.getNetworkId());
        base = base.replace('/login', '');
        return base;
    }
}