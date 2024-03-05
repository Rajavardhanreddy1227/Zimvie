public class ZMVE_ReturnsOrders{
   
       public static void returnOrder(){
        ConnectApi.ChangeInputRepresentation changeInput = new ConnectApi.ChangeInputRepresentation();
        String orderSummaryId = '1Os8L000000Go5DSAS';
        List<ConnectApi.ChangeItemInputRepresentation> changeItems = new List<ConnectApi.ChangeItemInputRepresentation>();
        ConnectApi.ChangeItemInputRepresentation itm = new ConnectApi.ChangeItemInputRepresentation();
        itm.orderItemSummaryId	= '10u8L000000Go80QAC';
        itm.quantity = 1.0;
        itm.reason = 'Not Satisfied';
        itm.shippingReductionFlag = false;
        changeItems.add(itm);
        changeInput.changeItems = changeItems;
        ConnectApi.SubmitReturnOutputRepresentation output = ConnectApi.OrderSummary.submitReturn(orderSummaryId, changeInput);
        System.debug('ZMVE_ReturnsOrders:output'+output);
    }
    
}