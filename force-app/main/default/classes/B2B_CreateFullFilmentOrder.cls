public class B2B_CreateFullFilmentOrder {
    static final String WAREHOUSE_TYPE = 'Warehouse';
     private static final DCM_Logger logger = DCM_Logger.getInstance('FullFilment Order Creation');
    public class B2B_CreateFullFilmentOrderRequest {
        
        @InvocableVariable(required=true)
        public ID orderSummaryId;
        
        @InvocableVariable(required=true)
        public ID locationid;
    }
    /**
     * @description Maps a cart to an order. Activates it, and closes the cart. Returns the resulting order summary id.
     * @param request The checkout session and cart id.
     * @return The OrderId that resulted from this class.
     */
    @InvocableMethod(label='B2B Create Fulfilment Order' description='Create Fullfilment Order' category='OMS')
    public static List<String> createFulfillmentOrder(List<B2B_CreateFullFilmentOrderRequest> request) {
         List<String> fulfillmentOrderIdList = new List<String>();
         try {
         Id locationId = request[0].locationid;
         Id ordSummaryId = request[0].orderSummaryId;
        
        OrderSummary orderSummary = [SELECT Id, (SELECT Id From OrderDeliveryGroupSummaries),(SELECT Id, Quantity, OrderDeliveryGroupSummaryId FROM OrderItemSummaries) FROM OrderSummary where id =: ordSummaryId LIMIT 1];			
        
       
        for(OrderDeliveryGroupSummary orderDeliveryGroupSummary : orderSummary.OrderDeliveryGroupSummaries){
            List<ConnectApi.OrderItemSummaryInputRepresentation> orderItems = new List<ConnectApi.OrderItemSummaryInputRepresentation>();
            for(OrderItemSummary orderItemSummary : orderSummary.OrderItemSummaries){
               if(orderItemSummary.OrderDeliveryGroupSummaryId == orderDeliveryGroupSummary.Id){
                    ConnectApi.OrderItemSummaryInputRepresentation orderItemSummaryInputRepresentation = new ConnectApi.OrderItemSummaryInputRepresentation();
                    orderItemSummaryInputRepresentation.orderItemSummaryId = orderItemSummary.Id;
                    orderItemSummaryInputRepresentation.quantity = orderItemSummary.Quantity;
    
                    orderItems.add(orderItemSummaryInputRepresentation);
               }
            }
            if (orderItems.size() > 0){
                ConnectApi.FulfillmentGroupInputRepresentation fulfillmentGroup = new ConnectApi.FulfillmentGroupInputRepresentation();
                fulfillmentGroup.fulfilledFromLocationId = locationId; //location.Id;
                fulfillmentGroup.fulfillmentType = WAREHOUSE_TYPE;
                fulfillmentGroup.orderItemSummaries = orderItems;
                
                ConnectApi.FulfillmentOrderInputRepresentation inputRepresentation = new ConnectApi.FulfillmentOrderInputRepresentation();
                inputRepresentation.orderSummaryId = orderSummary.Id;
                inputRepresentation.orderDeliveryGroupSummaryId = orderDeliveryGroupSummary.Id;
                inputRepresentation.fulfillmentGroups = new List<ConnectApi.FulfillmentGroupInputRepresentation>();
                inputRepresentation.fulfillmentGroups.add(fulfillmentGroup);
                
                ConnectApi.FulfillmentOrderOutputRepresentation fulfillmentOrderOutput = ConnectApi.FulfillmentOrder.createFulfillmentOrders(inputRepresentation);
                fulfillmentOrderIdList.addAll(fulfillmentOrderOutput.fulfillmentOrderIds);
            }
        }
        
      
        } catch (Exception ex) {
            logger.error(ex);
        } finally {
            logger.flush();
        }
        System.debug(fulfillmentOrderIdList);
        return fulfillmentOrderIdList;
        
        
    }
    
      
  

}