@isTest
public class Up_ServiceContractTrigger_Test {
    
    static testMethod void TestCurrent(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Last Name';
        insert con;  
        
        Product2 prod = new Product2();
        prod.Name = 'Test Product';
        prod.CurrencyIsoCode = 'USD';
        prod.ProductCode = 'Test' + String.valueOf(Math.random()) ; 
        insert prod;
        
        Pricebook2 pb = new pricebook2(name='Test');
        insert pb;
        
        PricebookEntry standardpbe = new PricebookEntry();
        standardpbe.Pricebook2Id = Test.getStandardPricebookId();
        standardpbe.Product2Id = prod.Id;
        standardpbe.UnitPrice = 1000;
        standardpbe.IsActive = true;
        insert standardPBE;        
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.pricebook2id = pb.id; 
        pbe.product2id = prod.id;
        pbe.unitprice = 1.0;
        pbe.isActive = true;
        insert pbe;
        
        Asset asset = new Asset();
        asset.Name = 'Test Asset';
        asset.Product2Id = prod.id;
        asset.AccountId = acc.id;
        //asset.Status = 'Customer Owned';
        insert asset;     
        
        SM_Service_Contract_Template__c template = new SM_Service_Contract_Template__c();
        template.Name = 'Test Template';
        template.SM_Duration_in_Months__c = 12;
        insert template;
        
        SM_Service_Contract_Discounts__c scd = new SM_Service_Contract_Discounts__c();
        scd.SM_Discount__c = 50;
        scd.SM_Service_Contract_Discounts__c = template.id;
        insert scd;
        
        ServiceContract sc = new ServiceContract();
        sc.Name = 'Test ServiceContract';
        sc.SM_Service_Contract_Template__c = template.id;
        sc.Pricebook2Id = pb.id;
        insert sc;
        
        ContractLineItem cli1 = new ContractLineItem();
        cli1.ServiceContractId = sc.id;
        cli1.AssetId = asset.id;
        cli1.StartDate = date.today().addDays(-10);
        cli1.EndDate = date.today().addDays(10);
        cli1.Quantity = 1;
        cli1.UnitPrice = 100;
        cli1.PricebookEntryId = pbe.id;
        insert cli1;
        
        test.startTest();
        
        sc.SM_Contract_Status__c = 'Active';
        update sc;
        
        sc.SM_Contract_Status__c = 'Draft';
        update sc;        
        
        test.stopTest();
        
    }
    
    static testMethod void TestFuture(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Last Name';
        insert con;  
        
        Product2 prod = new Product2();
        prod.Name = 'Test Product';
        prod.CurrencyIsoCode = 'USD';
        prod.ProductCode = 'Test' + String.valueOf(Math.random()) ; 
        insert prod;
        
        Pricebook2 pb = new pricebook2(name='Test');
        insert pb;
        
        PricebookEntry standardpbe = new PricebookEntry();
        standardpbe.Pricebook2Id = Test.getStandardPricebookId();
        standardpbe.Product2Id = prod.Id;
        standardpbe.UnitPrice = 1000;
        standardpbe.IsActive = true;
        insert standardPBE;        
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.pricebook2id = pb.id; 
        pbe.product2id = prod.id;
        pbe.unitprice = 1.0;
        pbe.isActive = true;
        insert pbe;
        
        Asset asset = new Asset();
        asset.Name = 'Test Asset';
        asset.Product2Id = prod.id;
        asset.AccountId = acc.id;
        //asset.Status = 'Customer Owned';
        insert asset;     
        
        SM_Service_Contract_Template__c template = new SM_Service_Contract_Template__c();
        template.Name = 'Test Template';
        template.SM_Duration_in_Months__c = 12;
        insert template;
        
        ServiceContract sc = new ServiceContract();
        sc.Name = 'Test ServiceContract';
        sc.SM_Service_Contract_Template__c = template.id;
        sc.Pricebook2Id = pb.id;
        insert sc;
        
        ContractLineItem cli1 = new ContractLineItem();
        cli1.ServiceContractId = sc.id;
        cli1.AssetId = asset.id;
        cli1.StartDate = date.today().addDays(10);
        cli1.EndDate = date.today().addDays(20);
        cli1.Quantity = 1;
        cli1.UnitPrice = 100;
        cli1.PricebookEntryId = pbe.id;
        insert cli1;
        
        test.startTest();
        
        sc.SM_Contract_Status__c = 'Active';
        update sc;
        
        sc.SM_Contract_Status__c = 'Draft';
        update sc;             
        
        test.stopTest();
        
    }
    
}