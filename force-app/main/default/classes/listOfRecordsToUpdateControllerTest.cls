/**
 * @description       : Test Class For listOfRecordsToUpdateController
 * @author            : Mayank Srivastava
 * @group             : 
 * @last modified on  : 
 * @last modified by  : 
**/
@isTest
public class listOfRecordsToUpdateControllerTest 
{
   	 @isTest
     public static  void loadRecMethodTest()
    {
        Account testAccount = new Account(Name='TestAccount',Customer_Number__c = '123456', CurrencyIsoCode = 'USD');
        insert testAccount;
        Invoice__c inv = new Invoice__c();
        inv.Related_To_Account__c = testAccount.Id;
        insert inv;
        Payment_Receipt__c payRec = new Payment_Receipt__c();
        payRec.Receipt_Status__c = 'Initiated';
        insert payRec;
        B2BInvoicePayment__c invPay = new B2BInvoicePayment__c();
        invPay.Invoice__c = inv.Id;
        invPay.Payment_Receipt__c = payRec.Id;
        insert invPay;
        Test.startTest();
        listOfRecordsToUpdateController.loadRecords('Invoice__c','Id,Name',testAccount.Id);
        listOfRecordsToUpdateController.loadUserRecords('Invoice__c','Id,Name',testAccount.Id);
        Test.stopTest();
        
    }
    
    @isTest
    public static void loadUserRecordsTest()
    {
       Account testAccount = new Account(Name='TestAccount',Customer_Number__c = '123456', CurrencyIsoCode = 'USD');
        insert testAccount;
        Invoice__c inv = new Invoice__c();
        inv.Related_To_Account__c = testAccount.Id;
        insert inv;
        List<Invoice__c> invList = new List<Invoice__c>();
        List<string> strList = new List<string>();
        strList.add(inv.id);
        Map<String,Object> dataMap = new Map<String,Object>();
        dataMap.put('selectedInvoices',strList);
        dataMap.put('receiptAmount', 1000.00);
        Test.startTest();
        listOfRecordsToUpdateController.processPayment(dataMap);
        Test.stopTest();
        
        
    }
    
   
}