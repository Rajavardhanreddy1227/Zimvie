public class b2BCreateROAndROLI {
    public static ConnectApi.ReturnOrderOutputRepresentation createReturnOrder(){
        ConnectApi.ReturnOrderInputRepresentation returnOrderInput=new ConnectApi.ReturnOrderInputRepresentation();
        returnOrderInput.orderSummaryId='1Os8L000000Go4PSAS';
        returnOrderInput.returnOrderLifeCycleType='Unmanaged';
        List<ConnectApi.ReturnOrderLineItemInputRepresentation> ROLIs=new List<ConnectApi.ReturnOrderLineItemInputRepresentation>();
        ConnectApi.ReturnOrderLineItemInputRepresentation ROLI=new ConnectApi.ReturnOrderLineItemInputRepresentation();
        ROLI.canReduceShipping=false;
        ROLI.orderItemSummaryId='10u8L000000Go7CQAS';
        ROLI.quantityExpected=1;
        ROLIs.add(ROLI);
        returnOrderInput.returnOrderLineItems=ROLIs;
        returnOrderInput.status='Draft';
        return ConnectApi.ReturnOrder.createReturnOrder(returnOrderInput);
    }
}