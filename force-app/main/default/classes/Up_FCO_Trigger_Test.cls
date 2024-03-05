@isTest
public class Up_FCO_Trigger_Test {
   
    static testMethod void Test1_NoFile(){
        
        SM_FCO__c fco = new SM_FCO__c();
        insert fco;
        
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
        
        Asset asset = new Asset();
        asset.Name = 'Test Asset';
        asset.Product2Id = prod.id;
        asset.AccountId = acc.id;
        //asset.ContactId = con.id;
        insert asset;
        
        test.startTest();
        
        fco.SM_Create_FCO_Lines__c = true;
        update fco;
        
        test.stopTest();
       
    }
 
    static testMethod void Test2_FileWithAsset(){
        
        SM_FCO__c fco = new SM_FCO__c();
        insert fco;
        
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
        
        Asset asset = new Asset();
        asset.Name = 'Test Asset';
        asset.Product2Id = prod.id;
        asset.AccountId = acc.id;
        //asset.ContactId = con.id;
        insert asset;
        
        ContentVersion contentVersion1 = new ContentVersion(
            Title = 'TestFile',
            PathOnClient = 'Text.csv',
            VersionData = Blob.valueOf('Asset ID' + '\n' + asset.id),
            IsMajorVersion = true
        );
        insert contentVersion1;
        
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        system.debug('* TEST documents :' + documents);
        
        ContentDocumentLink contentlink = new ContentDocumentLink(
            LinkedEntityId = fco.id,
            ContentDocumentId = documents[0].id,
            ShareType = 'V'
        );
        insert contentlink;         
        
        test.startTest();
        
        fco.SM_Create_FCO_Lines__c = true;
        update fco;
        
        test.stopTest();
       
    }    
   
}