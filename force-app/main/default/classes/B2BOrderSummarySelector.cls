public with sharing class B2BOrderSummarySelector {
    
    public static Set<String> getOrderSummaryDefaultFields() {
        return new Set<String>{
            'Id',
            'Order_Number__c',
            'OwnerId, Owner.Email',
            'OrderNumber',
            'OriginalOrderId',
            'OrderedDate',
            'AccountId',
            'TotalProductAdjDistAmtWithTax',
            'TotalAdjustedProductAmount',
            'GrandTotalAmount',
            'TotalAdjustedDeliveryAmount',
            'TotalTaxAmount',
            'BillToContactId',
            'PoNumber',
            'TotalProductAmount',
            'TotalAdjDistAmount',
            'TotalDeliveryAdjDistAmount',
            'TotalProductTaxAmount',
            'TotalDeliveryAdjDistTaxAmount',
            'TotalDeliveryAmount',
            'TotalAdjustedDeliveryTaxAmount',
            'CurrencyIsoCode',
            'BillingStreet, BillingCity, BillingState, BillingPostalCode, BillingCountry','BillingCountryCode','BillingStateCode'
        };
    }

    public static Set<String> getOrderProductSummaryDefaultFields() {
        return new Set<String>{
            'Id',
            'Name',
            'Type', 
            'Quantity', 
            'UnitPrice', 
            'Product2Id', 
            'Product2.Name',
            'Product2.DisplayUrl',
            'ProductCode', 
            'TotalPrice',
            'OrderSummaryId',
            'OrderSummary.OrderNumber',
            'OriginalOrderItemId',
            'OrderDeliveryGroupSummaryId',
            'CurrencyIsoCode'
        };
    }

    public static Set<String> getOrderDeliveryGroupSummaryDefaultFields() {
        return new Set<String>{
            'Id', 
            'DeliverToName', 
            'OrderSummaryId',
            'OrderSummary.OrderNumber',
            'DeliverToStreet, DeliverToCity, DeliverToState, DeliverToPostalCode, DeliverToCountry','DeliverToCountryCode','DeliverToStateCode',
            'OrderDeliveryMethodId, OrderDeliveryMethod.Name',
            'DesiredDeliveryDate',
            'CurrencyIsoCode'
        };
    }

    public static String getQueryFieldString(Set<String> defaultFieldSet) {
    List<String> queryFieldsList = new List<String>(defaultFieldSet);        
        return String.join(queryFieldsList, ',');
    }

    public static List<OrderSummary> getOrderSummary(Map<String, Object> dataMap){
        List<OrderSummary> orderSummaryList = new List<OrderSummary>();
        String orderSummaryNumber = (String)dataMap.get(B2BConstants.ORDER_SUMMARY_NUMBER);
        String queryStr = 'SELECT '+getQueryFieldString(getOrderSummaryDefaultFields())+' FROM OrderSummary WHERE OriginalOrder.OrderReferenceNumber=:orderSummaryNumber';
        orderSummaryList = Test.isRunningTest() ? B2B_testUtils.getOrderSummary() : Database.query(queryStr);
        return orderSummaryList;
    }

    public static List<OrderItemSummary> getOrderProductSummary(Map<String, Object> dataMap){
        List<OrderItemSummary> orderItemSummaryList = new List<OrderItemSummary>();
        String orderSummaryNumber = (String)dataMap.get(B2BConstants.ORDER_SUMMARY_NUMBER);
        String orderType = B2BConstants.ORDER_PRODUCT;
        String queryStr = 'SELECT '+getQueryFieldString(getOrderProductSummaryDefaultFields())+' FROM OrderItemSummary WHERE OrderSummary.OriginalOrder.OrderReferenceNumber=:orderSummaryNumber AND Type=:orderType';
        orderItemSummaryList = Test.isRunningTest() ? B2B_testUtils.getOrderProductSummary() : Database.query(queryStr);
        return orderItemSummaryList;
    }

    public static List<OrderDeliveryGroupSummary> getOrderDeliveryGroupSummary(Map<String, Object> dataMap){
        List<OrderDeliveryGroupSummary> orderDeliveryList = new List<OrderDeliveryGroupSummary>();
        String orderSummaryNumber = (String)dataMap.get(B2BConstants.ORDER_SUMMARY_NUMBER);
        String queryStr = 'SELECT '+getQueryFieldString(getOrderDeliveryGroupSummaryDefaultFields())+' FROM OrderDeliveryGroupSummary WHERE OrderSummary.OriginalOrder.OrderReferenceNumber=:orderSummaryNumber';
        orderDeliveryList = Test.isRunningTest() ? B2B_testUtils.getOrderDeliveryGroupSummary() : Database.query(queryStr);
        return orderDeliveryList;
    }

    
}