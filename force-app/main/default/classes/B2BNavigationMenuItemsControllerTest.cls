@IsTest(SeeAllData=true)
public class B2BNavigationMenuItemsControllerTest {
    @isTest static void testGetNavigationMenuItems() {
        B2B_TestUtils.initialStorefrontSetup();
        //B2B_TestUtils.initB2BData();
        //B2B_TestUtils.createCommunityUser(true);
        // Query for an existing Site
        /*Site s = [SELECT Id, UrlPathPrefix FROM Site WHERE UrlPathPrefix = 'Zimvie' LIMIT 1];
        
        Account testAccount1 = new Account(Name='TestAccount-1');
        insert testAccount1;
        Account testAccount2 = new Account(Name='TestAccount-2');
        insert testAccount2;
        Account testAccount3 = new Account(Name='TestAccount-3');
        insert testAccount3;
        Account testAccount4 = new Account(Name='TestAccount-4');
        insert testAccount4;
        Account testAccount5 = new Account(Name='TestAccount-5');
        insert testAccount5;
        
        WebStore testWebStore = new WebStore(Name='TestWebStore');
        insert testWebStore;
        
        WebCart cart1 = new WebCart(Name='Cart-1', WebStoreId=testWebStore.Id, AccountId=testAccount1.Id);
        insert cart1;
        WebCart cart2 = new WebCart(Name='Cart-2', WebStoreId=testWebStore.Id, AccountId=testAccount2.Id);
        insert cart2;
        WebCart cart3 = new WebCart(Name='Cart-3', WebStoreId=testWebStore.Id, AccountId=testAccount3.Id);
        insert cart3;
        WebCart cart4 = new WebCart(Name='Cart-4', WebStoreId=testWebStore.Id, AccountId=testAccount4.Id);
        insert cart4;
        WebCart cart5 = new WebCart(Name='Cart-5', WebStoreId=testWebStore.Id, AccountId=testAccount5.Id);
        insert cart5;
        
        ProductCatalog prodCatalog = new ProductCatalog();
        prodCatalog.Name = 'Test Catalog';
        insert prodCatalog;
        
        // Create mock data for ProductCategory
        ProductCategory grand2ParentCategory = new ProductCategory(Name = 'TestGrand2ParentCategory', Cat_ID__c = cart5.Id, CatalogId = prodCatalog.Id);
        insert grand2ParentCategory;
        
        ProductCategory grandParentCategory = new ProductCategory(Name = 'TestGrandParentCategory', ParentCategoryId = grand2ParentCategory.Id, Cat_ID__c = cart4.Id, CatalogId = prodCatalog.Id);
        insert grandParentCategory;
        
        ProductCategory parentCategory = new ProductCategory(Name = 'TestParentCategory',ParentCategoryId = grandParentCategory.Id, Cat_ID__c = cart1.Id, CatalogId = prodCatalog.Id);
        insert parentCategory;
        
        ProductCategory childCategory = new ProductCategory(Name = 'TestChildCategory', ParentCategoryId = parentCategory.Id, Cat_ID__c = cart2.Id, CatalogId = prodCatalog.Id);
        insert childCategory;

        ProductCategory grandChildCategory = new ProductCategory(Name = 'TestGrandChildCategory', ParentCategoryId = childCategory.Id, Cat_ID__c = cart3.Id, CatalogId = prodCatalog.Id);
        insert grandChildCategory;

        // Create mock data for ProductCategoryDataTranslation
        ProductCategoryDataTranslation translation = new ProductCategoryDataTranslation(
            ParentId = parentCategory.Id,
            Language = UserInfo.getLanguage(),
            Name = 'TranslatedParentCategory'
        );
        insert translation;*/
		String result;
        // Execute the method
        Profile portalProfile = [SELECT Id FROM Profile WHERE Name='B2B Lightning Community Plus Login' Limit 1];
        User u = [SELECT Id FROM User where ProfileId=:portalProfile.Id and IsActive=true LIMIT 1];
        System.runAs(u)
        {
        result = B2BNavigationMenuItemsController.getNavigationMenuItemsFromConnectAPI();
        }
        // Asserts
        System.assertNotEquals(null, result, 'Expected a result from getNavigationMenuItems');
        
        // You can add more assertions to verify the structure or content of the returned JSON
        
    }
}