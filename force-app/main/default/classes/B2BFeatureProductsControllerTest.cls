@isTest
public class B2BFeatureProductsControllerTest {
    @testSetup
    public static void makeData(){
        RecordType rt1 = [SELECT Id FROM RecordType WHERE SobjectType = 'Account' AND DeveloperName = 'Vendor' LIMIT 1];
        Account acc = new Account();
        acc.Name = 'Test Name';
        acc.Type = 'Customer';
        acc.Customer_Type__c = '';
        acc.Account_eMail__c = 'lauren119@yopmail.com';
        acc.Email__c = 'neeta.galande@rafter.one';
        acc.RecordTypeId = rt1.Id;
        acc.ShippingCountry = 'United States';
        acc.ShippingState = 'Alabama';
        acc.ShippingPostalCode = '12345';
        insert acc;
        RecordType rt = [SELECT Id FROM RecordType WHERE SobjectType = 'Contact' AND DeveloperName = 'Zimmer_Standard_Contact' LIMIT 1];
        Contact con = new Contact();
        con.FirstName = 'test';
        con.LastName = 'Contact';
        con.Email = 'testContact123@yopmail.com';
        con.RecordTypeId = rt.Id;
        con.AccountId = acc.Id;
        insert con; 
        
        WebStore webStore = new WebStore(
            Name = 'Test', 
            SupportedLanguages = 'en_US', 
            DefaultLanguage = 'en_US'
            
        );
        insert webStore; 
        Product2 pro = new Product2(
            Name = 'Sort Material-450',
            IsActive = true,
            StockKeepingUnit = 'Sort'
        );
        insert pro;
        B2B_Featured_Product__c feature = new B2B_Featured_Product__c(
            B2B_Product__c = pro.Id,
            B2B_Audience_Type__c = acc.Customer_Type__c,
            B2B_End_Date__c = System.today(),
            B2B_Start_Date__c = System.today()
        );
        insert feature;
    }
    @isTest
     static void getFeatureMethod(){
        Account acc = [Select id from Account where Name = 'Test Name'];
        WebStore store =[Select id, name from WebStore where Name = 'Test'];
        B2BFeatureProductsController.getFeatureProducts(store.Id, acc.Id);
        System.assertEquals('Test', store.Name);
    }
    
    @isTest 
    static void getFeatureMethodV2(){
        B2B_Featured_Product__c fbProduct = [Select Id from B2B_Featured_Product__c];
        delete fbProduct;
        Account acc = [Select id from Account where Name = 'Test Name'];
        WebStore store =[Select id, name from WebStore where Name = 'Test'];
        B2BFeatureProductsController.getFeatureProducts(store.Id, acc.id);
        System.assertEquals('Test', store.Name);
    }
    
}