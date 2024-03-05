@isTest
global  class MockHttpResponse_OraclePayment implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
       // res.setBody('{"TrxNums":[],"SfPaymentId":"a888L0000008RMbQAM","ReceiptNumber":"a888L0000008RMb","ReceiptDate":null,"ReceiptCurrency":"USD","ReceiptAmount":null,"CustomerNumber":null,"CreditCardToken":null,"CardNumber":null,"CardHolderName":null,"CardExpirationDate":null,"CardCurrency":"USD"}');
          res.setBody('{"TrxNums":[{"TransactionNumber":"Invoice","SfInvoiceId":"a7Z8L0000005WWEUA2"}],"SfPaymentId":"a888L0000008RN5QAM","ReceiptNumber":"Test Receipt","ReceiptDate":"2023-09-18","ReceiptCurrency":"USD","ReceiptAmount":1000.00,"CustomerNumber":"12345","CreditCardToken":"TestToken","CardNumber":"1234567890123456","CardHolderName":"Test Card Holder","CardExpirationDate":null,"CardCurrency":"USD"}');
        res.setStatusCode(200);
        return res;
    }
}