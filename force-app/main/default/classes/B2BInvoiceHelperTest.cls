@isTest
public class B2BInvoiceHelperTest {

    @isTest 
    static void generateReceipt(){
        Account testAccount = new Account(Name='TestAccount',Customer_Number__c = '123456', CurrencyIsoCode = 'USD');
        insert testAccount;
        Invoice__c inv = new Invoice__c();
        inv.Related_To_Account__c = testAccount.Id;
        insert inv;
        List<Invoice__c> invList = new List<Invoice__c>();
        List<string> strList = new List<string>();
        strList.add(inv.id);
        invList.add(inv);
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put('selectedInvoices',strList);
        dataMap.put('receiptAmount', 1000.00);
        Test.startTest();
        B2BInvoiceHelper.generateReceiptName(invList);
        B2BInvoiceHelper.processInvoicePayment(dataMap);
        Test.stopTest();
        
        
    }
        
}