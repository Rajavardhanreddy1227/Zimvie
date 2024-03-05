@isTest
public class B2BProductListControllerTest {
   @isTest static void test_getCategoryId() {
       // Create a ProductCatalog record first
       ProductCatalog catalog = new ProductCatalog(Name = 'Test Catalog');
       insert catalog;
       // Create a ProductCategory record associated with the ProductCatalog
       ProductCategory cat = new ProductCategory(Name = 'Test Brand', CatalogId = catalog.Id);
       insert cat;

       // Now you can test the getCategoryId method
       String returnedId = B2BProductListController.getCategoryId('Test Brand');
       System.assertEquals(cat.Id, returnedId);
   }

   @isTest static void test_getFeatureProducts() {
       // Create a ProductCatalog record
       ProductCatalog catalog = new ProductCatalog(Name = 'Test Catalog');
       insert catalog;

       Account testAccount = new Account(Name='TestAccount');
        insert testAccount;
       // Simulate the input map
       Map<String, Object> dataMap = new Map<String, Object>{
           B2BProductListController.COMMUNITY_ID => B2b_TestUtils.getCommunityId(),
           B2BProductListController.EFFECTIVE_ACCOUNT_ID => testAccount.Id,
           B2BProductListController.SEARCH_QUERY => '{}' // JSON string
       };
        system.debug(dataMap +'dataMap');       

       // Create any necessary test data for your controller here, such as Product records
       // 
       // 
         String result = B2BProductListController.getFeatureProducts(dataMap);
       System.assertNotEquals(null, result);
   }

   @isTest static void test_getNewProducts() {
       // Create a ProductCatalog record
       ProductCatalog catalog = new ProductCatalog(Name = 'Test Catalog');
       insert catalog;

       // Create a ProductCategory record associated with the ProductCatalog
       ProductCategory cat = new ProductCategory(Name = 'Test Brand', CatalogId = catalog.Id);
       insert cat;

       // Simulate the input map
       Map<String, Object> dataMap = new Map<String, Object>{
           B2BProductListController.COMMUNITY_ID => 'communityId',
            B2BProductListController.EFFECTIVE_ACCOUNT_ID =>'accountId',  
           B2BProductListController.SEARCH_QUERY => '{}' // JSON string
       };
       String selectedBrand = 'Test Brand';

       // Create any necessary test data for your controller here, such as Product records

       String result = B2BProductListController.getNewProducts(dataMap, selectedBrand);
       System.assertNotEquals(null, result);
   }

   @isTest static void test_productSearch() {
       // Create a ProductCatalog record
       ProductCatalog catalog = new ProductCatalog(Name = 'Test Catalog');
       insert catalog;

       // Create a ProductCategory record associated with the ProductCatalog
       ProductCategory cat = new ProductCategory(Name = 'Test Brand', CatalogId = catalog.Id);
       insert cat;

       // Simulate the input map
       Map<String, Object> dataMap = new Map<String, Object>{
           B2BProductListController.COMMUNITY_ID => 'communityId',
           B2BProductListController.SEARCH_QUERY => '{}' // JSON string
       };

       // Create any necessary test data for your controller here, such as Product records

       String result = B2BProductListController.productSearch(dataMap);
       System.assertNotEquals(null, result);
   }

   @isTest static void test_getSortRules() {
       // Simulate the input map
       Map<String, Object> dataMap = new Map<String, Object>{
           B2BProductListController.COMMUNITY_ID => 'communityId'
       };

       // Create any necessary test data for your controller here

       Map<String, Object> resultMap = B2BProductListController.getSortRules(dataMap);
       System.assertNotEquals(null, resultMap);
   }
}