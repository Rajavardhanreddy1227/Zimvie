@isTest
private class OrderEnvelope_TEST{
    @isTest
    private static void OrderEnvelope_TEST(){
        OrderEnvelope obj = new OrderEnvelope();
    }
    @isTest
    private static void OrderHeader_TEST(){
        OrderEnvelope.OrderHeader obj = new OrderEnvelope.OrderHeader();
    }
    @isTest
    private static void DataArea_TEST(){
        OrderEnvelope.DataArea obj = new OrderEnvelope.DataArea();
    }
    @isTest
    private static void AcknowledgeOrder_TEST(){
        OrderEnvelope.AcknowledgeOrder obj = new OrderEnvelope.AcknowledgeOrder();
    }
    @isTest
    private static void ApplicationArea_TEST(){
        OrderEnvelope.ApplicationArea obj = new OrderEnvelope.ApplicationArea();
    }
}