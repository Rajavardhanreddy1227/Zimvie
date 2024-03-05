@isTest
private class SubmitBatchImportASNsTest {

    @isTest
    static void testDoPost() {
        // Create test data (list of AdvanceShippingNotice objects)
        List<AdvanceShippingNotice> asnList = new List<AdvanceShippingNotice>();
   /*     AdvanceShippingNotice asn1 = new AdvanceShippingNotice(
            FulfillmentOrderNumber = '010789',
            FulfillmentOrderItemNumber = '1',
            QuantityFulfilled = 15,
            QuantityCancelled = 0
        );
        AdvanceShippingNotice asn2 = new AdvanceShippingNotice(
            FulfillmentOrderNumber = '217895',
            FulfillmentOrderItemNumber = '2',
            QuantityFulfilled = 20,
            QuantityCancelled = 1
        );
        asnList.add(asn1);
        asnList.add(asn2); */
        String jsonPayload = '{"asn": ' + JSON.serialize(asnList) + '}';
        Test.startTest();
        RestRequest request = new RestRequest();
        request.requestURI = '/services/apexrest/Fulfillment/ImportASNs';
        request.httpMethod = 'POST';
        request.requestBody = Blob.valueOf(jsonPayload);
        RestContext.request = request;
        RestContext.response = new RestResponse();
        SubmitBatchImportASNs.doPost(asnList);
        RestResponse response = RestContext.response;
        Test.stopTest();
    }
}