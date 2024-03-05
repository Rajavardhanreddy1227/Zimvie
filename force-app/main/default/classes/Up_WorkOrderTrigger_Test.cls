@isTest(seeAllData=true)
public class Up_WorkOrderTrigger_Test {
  
   /* static testMethod void Test1_Assets(){
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        insert acc;
        
        Contact con = new Contact();
        con.LastName = 'Test Last Name';
        insert con;  

        SM_Product_Line__c pl = new SM_Product_Line__c();
        pl.Name = 'Test_Product_Line';
        insert pl;
        
        SM_Product_line_Checklist_Type__c ct = new SM_Product_line_Checklist_Type__c();
        ct.SM_Checklist_Record_Type_Name__c = 'Test';
        ct.SM_Product_Line__c = pl.id;
        //ct.SM_Work_Type__c = ;
        ct.SM_Work_Order_Type__c = 'Preventative Maintanance';
        insert ct;
        
        Product2 prod = new Product2();
        prod.Name = 'Test Product';
        prod.CurrencyIsoCode = 'USD';
        prod.ProductCode = 'Test' + String.valueOf(Math.random()) ; 
        prod.SM_Asset_Tracked__c = true;
        prod.SM_Product_Line__c = pl.id;
        insert prod;
        
        Product2 prod_woli = new Product2();
        prod_woli.Name = 'Test Product 2';
        prod_woli.CurrencyIsoCode = 'USD';
        prod_woli.ProductCode = 'Test' + String.valueOf(Math.random()) ; 
        prod_woli.SM_Asset_Tracked__c = true;
        insert prod_woli;
        
        Pricebook2 pb = new pricebook2(name='Test Not Std');
        insert pb;
        
        PricebookEntry std_pbe = new PricebookEntry();
        std_pbe.Pricebook2Id = Test.getStandardPricebookId();
        std_pbe.Product2Id = prod.Id;
        std_pbe.UnitPrice = 1000;
        std_pbe.IsActive = true;
        insert std_pbe;      
        
        PricebookEntry std_pbe2 = new PricebookEntry();
        std_pbe2.Pricebook2Id = Test.getStandardPricebookId();
        std_pbe2.Product2Id = prod_woli.Id;
        std_pbe2.UnitPrice = 1000;
        std_pbe2.IsActive = true;
        insert std_pbe2;       
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.pricebook2id = pb.id; 
        pbe.product2id = prod.id;
        pbe.unitprice = 1.0;
        pbe.isActive = true;
        insert pbe;
        
        PricebookEntry pbe2 = new PricebookEntry();
        pbe2.pricebook2id = pb.id; 
        pbe2.product2id = prod_woli.id;
        pbe2.unitprice = 1.0;
        pbe2.isActive = true;
        insert pbe2;        
        
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;        
        
        Asset asset_wo = new Asset();
        asset_wo.Name = 'Test WO Asset';
        asset_wo.Product2Id = prod.id;
        asset_wo.AccountId = acc.id;
        asset_wo.SerialNumber = '123456789';
        insert asset_wo;    
        
        Asset asset_woli = new Asset();
        asset_woli.Name = 'Test WOLI Asset';
        asset_woli.Product2Id = prod_woli.id;
        asset_woli.AccountId = acc.id;
        asset_woli.SerialNumber = '987654321';
        insert asset_woli;         
        
        Asset asset_woli2 = new Asset();
        asset_woli2.Name = 'Test WOLI Asset 2';
        asset_woli2.Product2Id = prod_woli.id;
        asset_woli2.AccountId = acc.id;
        asset_woli2.SerialNumber = '123456789';
        insert asset_woli2;           
        //list<Asset> assets = [SELECT Id, SM_Product_SN_Key__c FROM Asset WHERE ID IN(:asset_wo.id, :asset_woli.id)];
        //system.debug('* assets: ' + assets);
        
        WorkOrder wo = new WorkOrder();
        wo.Status = 'Open';
        wo.Pricebook2Id = pb.id;
        wo.SVMXA360__BillingType__c = 'Warranty';
        wo.AssetId = asset_wo.id;
        wo.AccountId = acc.id;
        wo.SVMXA360__ProductId__c = prod.id;
        wo.SM_Work_Order_Type__c = 'Preventative Maintanance';
        insert wo;
        
        WorkOrderLineItem woli1 = new WorkOrderLineItem();
        woli1.WorkOrderId = wo.id;
        woli1.SVMXA360__LineType__c = 'Part';
        woli1.PricebookEntryId = pbe2.id;
        woli1.AssetId = asset_woli.id;
        woli1.SM_Calculate_Price__c = true;
        woli1.SM_Serial_Number_Text__c = '987654321';
        woli1.RecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('SM_Consumption').getRecordTypeId();
        insert woli1;
        
        WorkOrderLineItem woli2 = new WorkOrderLineItem();
        woli2.WorkOrderId = wo.id;
        woli2.SVMXA360__LineType__c = 'Part';
        woli2.PricebookEntryId = pbe2.id;
        woli2.AssetId = asset_woli2.id;
        woli2.SM_Calculate_Price__c = true;
        woli2.SM_Serial_Number_Text__c = '123456789';
        woli2.RecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('SM_Child_Asset_Removed').getRecordTypeId();
        insert woli2;        
        
        test.startTest();
        Up_Utility.wo_first_run = true;
        wo.Status = 'Closed';
        update wo;
        test.stopTest();
        
    }
 
    static testMethod void Test2_ServiceReport(){
        
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
        prod.SM_Asset_Tracked__c = true;
        insert prod;
        
        Pricebook2 pb = new pricebook2(name='Test Not Std');
        insert pb;
        
        PricebookEntry std_pbe = new PricebookEntry();
        std_pbe.Pricebook2Id = Test.getStandardPricebookId();
        std_pbe.Product2Id = prod.Id;
        std_pbe.UnitPrice = 1000;
        std_pbe.IsActive = true;
        insert std_pbe;        
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.pricebook2id = pb.id; 
        pbe.product2id = prod.id;
        pbe.unitprice = 1.0;
        pbe.isActive = true;
        insert pbe;
        
        //Instantiate the Pricebook2 record with StandardPricebookId
        Pricebook2 standardPricebook = new Pricebook2(
            Id = Test.getStandardPricebookId(),
            IsActive = true
        );
        //Execute an update DML on the Pricebook2 record, to make IsStandard to true
        Update standardPricebook;        
        
        WorkOrder wo = new WorkOrder();
        wo.Status = 'Open';
        wo.Pricebook2Id = pb.id;
        wo.SVMXA360__BillingType__c = 'Warranty';
        wo.SM_Service_Report_Email_Template__c = 'SM_Service_Report_English';
        wo.ContactId = con.id;
        wo.SM_Contact_Last_Name__c = 'Test';
        wo.SVMXA360__ContactEmail__c = 'testme@apex.com';
        insert wo;
        
        WorkOrderLineItem woli1 = new WorkOrderLineItem();
        woli1.WorkOrderId = wo.id;
        woli1.SVMXA360__LineType__c = 'Part';
        woli1.PricebookEntryId = pbe.id;
        woli1.SM_Calculate_Price__c = true;
        woli1.SM_Serial_Number_Text__c = '9876543210';
        woli1.RecordTypeId = Schema.SObjectType.WorkOrderLineItem.getRecordTypeInfosByDeveloperName().get('SM_Consumption').getRecordTypeId();
        insert woli1;
        
        
        ServiceReport sr = new ServiceReport();
        //sr.ContentVersionDocumentId = documents[0].Id ;
        sr.DocumentBody = Blob.valueOf('Test Content') ; 
        sr.DocumentContentType ='application/pdf';
        sr.DocumentName='Test';
        sr.ParentId = wo.Id ; 
        insert sr;   
        
        
        test.startTest();
        
        wo.SM_Email_Service_Report__c  = true;
        update wo;
        
        test.stopTest();
    } */
   
}