@isTest
public class B2BOraclePaymentCallout_Test {
    @testSetup
    static void makeData(){
        Account testAccount = new Account(Name='TestAccount',Customer_Number__c = '123456', CurrencyIsoCode = 'USD');
        insert testAccount;
        Payment_Receipt__c testReceipt = new Payment_Receipt__c(
            Name = 'Test Receipt',
            Receipt_Amount__c = 1000.00,
            CurrencyIsoCode = 'USD',
            Receipt_Date__c = Date.today(),
            Customer_Number__c = '12345',
            Credit_Card_Token__c = 'TestToken',
            Credit_card_holder_Name__c = 'Test Card Holder',
            Credit_Card_Number__c = '1234567890123456' );
        insert testReceipt;
            Invoice__c invoice = new Invoice__c(
            Name = 'Invoice ',
            Status__c = 'In Process', // Assuming you have a status field
            Related_To_Account__c = testAccount.Id // Assuming you have a related account
        );
       
        insert invoice;
      /*  B2B_Invoice_Payment__c invPay = new B2B_Invoice_Payment__c();
        invPay.Invoice__c = invoice.Id;
        insert invPay;*/
           }
    @isTest
    static void oracleExecute(){
         Account testAccount = new Account(Name='TestAccount',Customer_Number__c = '123456', CurrencyIsoCode = 'USD');
        insert testAccount;
        Payment_Receipt__c testReceipt = new Payment_Receipt__c(
            Name = 'Test Receipt',
            Receipt_Amount__c = 1000.00,
            CurrencyIsoCode = 'USD',
            Receipt_Date__c = Date.today(),
            Customer_Number__c = '12345',
            Credit_Card_Token__c = 'TestToken',
            Credit_card_holder_Name__c = 'Test Card Holder',
            Credit_Card_Number__c = '1234567890123456' );
        insert testReceipt;
        List<Invoice__c> testInvoices = new List<Invoice__c>();
        Invoice__c invoice = new Invoice__c(
            Name = 'Invoice ',
            Status__c = 'In Process', // Assuming you have a status field
            Related_To_Account__c = testAccount.Id // Assuming you have a related account
        );
        testInvoices.add(invoice);
        insert testInvoices;
        List<B2BInvoicePayment__c> testInvoicePayments = new List<B2BInvoicePayment__c>();
        B2BInvoicePayment__c invPayment = new B2BInvoicePayment__c(
            Payment_Receipt__c = testReceipt.Id,
            Invoice__c = invoice.Id
        );
        testInvoicePayments.add(invPayment);
        insert testInvoicePayments;
        Map<String, Object> mapParams = new Map<String, Object>();
        mapParams.put('receiptId',testReceipt.Id);
        Test.startTest();
        B2BOraclePaymentCallout.sendInvoiceEmail(mapParams);
        Test.stopTest();
    }
    @isTest
    static void orcalePayment(){
        Payment_Receipt__c rec = [Select id, name from Payment_Receipt__c where Name = 'Test Receipt'];
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse_OraclePayment());
        Test.startTest();
        B2BOraclePaymentCallout.orcalePaymentCallout(rec.Id);
        Test.stopTest();
        
    }
    @isTest
    static void orcalePaymentMethod(){
        Payment_Receipt__c rec = [Select id, name from Payment_Receipt__c where Name = 'Test Receipt'];
        B2BOraclePaymentCallout obj = new B2BOraclePaymentCallout();
            obj.receiptId = rec.Id;
            String jobID = System.enqueueJob(obj);
       
    }
}