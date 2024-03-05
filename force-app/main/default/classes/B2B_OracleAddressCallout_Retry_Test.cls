@isTest
public class B2B_OracleAddressCallout_Retry_Test {
    @isTest
    static void B2B_OracleAddress(){
        String body = '<sampleXml></sampleXml>';
        String endpointUrl = 'https://example.com/api';
        String addressId = '12345';
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseOracle());
        B2B_OracleAddressCallout_Retry.WrapperObject wrap = new  B2B_OracleAddressCallout_Retry.WrapperObject();
        B2B_OracleAddressCallout_Retry.Discount dis = new B2B_OracleAddressCallout_Retry.Discount();
        dis.DiscountID = '123';
        dis.DiscountName = 'Test';
        dis.DiscountedAmount = 90.00;
        dis.DiscountedPercent = 80.00;
        List<B2B_OracleAddressCallout_Retry.Discount> disList = new List<B2B_OracleAddressCallout_Retry.Discount>();
        disList.add(dis); 
        B2B_OracleAddressCallout_Retry.OrderLine ordLine = new B2B_OracleAddressCallout_Retry.OrderLine();
        ordLine.LineID = '23t45r';
        ordLine.PricedQuantity = 1.00;
        ordLine.PricedListPrice = 30.00;
        ordLine.PricedSellingPrice = 20.00;
        ordLine.Discounts = disList;
        List<B2B_OracleAddressCallout_Retry.OrderLine> ordlist = new List<B2B_OracleAddressCallout_Retry.OrderLine>();
        ordlist.add(ordLine);
        B2B_OracleAddressCallout_Retry.OrderHeader ordHead = new B2B_OracleAddressCallout_Retry.OrderHeader();
        ordHead.HeaderID ='123trir';
        ordHead.CurrencyCode ='USD';
        ordHead.ERPReferenceID = 90.00;
        B2B_OracleAddressCallout_Retry.RequestResult result = new B2B_OracleAddressCallout_Retry.RequestResult();
        result.Status ='Status';
        result.Message ='Message';
       B2B_OracleAddressCallout_Retry.PricingResult prResult = new B2B_OracleAddressCallout_Retry.PricingResult();
        prResult.RequestResult =result;
        prResult.OrderHeader =ordHead;
        prResult.OrderLines =ordlist;
        B2B_OracleAddressCallout_Retry callout = new B2B_OracleAddressCallout_Retry(body, endpointUrl, addressId);
        Test.startTest();
        JobResult resulting = callout.startJob();
        Test.stopTest();
    }
    @isTest
    static void testStartJob_Retry() {
        // Create test data and set up the environment
        String body = '<sampleXml></sampleXml>';
        String endpointUrl = 'https://example.com/api';
        String addressId = '12345';
        
        // Mock the HTTP callout response to simulate a non-200 status code
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseOracle(500, 'Error Response'));
        
        // Create an instance of B2B_OracleAddressCallout_Retry
        B2B_OracleAddressCallout_Retry callout = new B2B_OracleAddressCallout_Retry(body, endpointUrl, addressId);
        
        // Execute the startJob method
        Test.startTest();
        JobResult result = callout.startJob();
        Test.stopTest();
    }
}