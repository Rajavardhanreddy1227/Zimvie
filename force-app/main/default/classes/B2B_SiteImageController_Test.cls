@isTest
private class B2B_SiteImageController_Test {
    @TestSetup
    public static void testSetupData()
    {
		Map<string,string> response = B2B_TestUtils.initialStorefrontSetup();
    }

    @isTest
    static void testGetMetadataDetails() {
        // Create test data for testing
        String metaConfGroupKey = 'TestGroup';
        String country = 'LogedinUser';
        String brand = 'TestBrand';
        String language = 'TestLanguage';
   
        Test.startTest();
        List<SiteImageDetail__mdt> result = b2bSiteImageController.getMetadataDetails(metaConfGroupKey, country, brand, language);
        Test.stopTest();
    }
    
    @isTest
    static void testListGetMetaData(){
        
        String metaConfGroupKey = 'Carousel';
        String country = 'LogedinUser';
        
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        testAccount.Available_Terms__c='30 Days';
        testAccount.Ecomm_Payment_Options__c = 'Credit Card';
        Contact testContact =[SELECT Id FROM Contact LIMIT 1];
        testContact.AccountId = testAccount.Id;
        User testUser = [SELECT Id FROM User LIMIT 1];
        testUser.ContactId = testContact.Id;
        
        
        Test.startTest();
        // Set the current user context to the test user
        System.runAs(testUser) {
            List<SiteImageDetail__mdt> result4 = b2bSiteImageController.getMetadataDetails(metaConfGroupKey, 'country', null, null);

            List<String> result3 = b2bSiteImageController.getBrandDetails(country);
        }
        Test.stopTest();
    }

    @IsTest
    public static void testGetProductDetails() {
        
        Account testAccount = [SELECT Id FROM Account LIMIT 1];
        testAccount.Available_Terms__c='30 Days';
        testAccount.Ecomm_Payment_Options__c = 'Credit Card';
        Contact testContact =[SELECT Id FROM Contact LIMIT 1];
        testContact.AccountId = testAccount.Id;
        User testUser = [SELECT Id FROM User LIMIT 1];
        testUser.ContactId = testContact.Id;

        // Create test data: SiteImageDetail__mdt records
        List<SiteImageDetail__mdt> testMetadataList = new List<SiteImageDetail__mdt>{
            new SiteImageDetail__mdt(
                ImageURL__c = 'https://example.com/image1.jpg',
                NavigationURL__c = 'https://example.com/page1'
            ),
            new SiteImageDetail__mdt(
                ImageURL__c = 'https://example.com/image2.jpg',
                ProductSKUCode__c = 'SKU123'
            ),
            new SiteImageDetail__mdt(
                ImageURL__c = 'https://example.com/image3.jpg',
                ProductSKUCode__c = 'SKU456'
            )
        };

        // Create mock data for query results
        /*List<Product2> mockProductList = new List<Product2>{
            new Product2(Name = 'Product1', StockKeepingUnit = 'SKU123'),
            new Product2(Name = 'Product2', StockKeepingUnit = 'SKU456')
        };
        insert mockProductList;*/


    	
        
        System.runAs(testUser) {
        	Test.startTest();
            //Test.setMock(b2bSiteImageController.class, B2B_SiteImageController_Test.NetworkUtilityMock.class);
        	List<SiteImageDetail__mdt> updatedMetadataList = b2bSiteImageController.getProductDetails(testMetadataList);
        	List<SiteImageDetail__mdt> result2 = b2bSiteImageController.getCategoryDetails(updatedMetadataList);
        	Test.stopTest();
        }
    }
    /*public class NetworkUtilityMock {
    	public String getCommunityURL() {
        	Network[] networks = [SELECT Id FROM Network LIMIT 1];	
            String base = networks[0].Id;
        	base = base.replace('/login', '');
        	return base;
    	}
	}*/

}