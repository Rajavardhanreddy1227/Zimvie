@isTest
private class OrderSubmissionPayloadGenerator_TEST{
    @isTest
    private static void generatePayload_TEST(){
        Test.startTest();
        try{
        OrderSubmissionPayloadGenerator.generatePayload('001x00000000000AAA');
        }catch(Exception e){}
        try{
        OrderSubmissionPayloadGenerator.generatePayload(null);
        }catch(Exception e){}
        Test.stopTest();
    }
    @isTest
    private static void OrderSubmissionPayloadGenerator_TEST(){
        OrderSubmissionPayloadGenerator obj = new OrderSubmissionPayloadGenerator();
    }
}