@isTest
public with sharing class B2BRecommendedProductsControllerTest {
   
    @isTest
    static void testFetchRecommendedProducts() {
     
        // Set up mock data for the method
        Map<String, Object> mockDataMap = new Map<String, Object>();
        // Add necessary data to the mockDataMap based on your controller's requirements
        
        // Call the method
        String result = B2BRecommendedProductsController.fetchRecommendedProducts(mockDataMap);
        Map<String, Object> resultMap = (Map<String, Object>) JSON.deserializeUntyped(result);
        
        // Asserts to ensure method is behaving as expected
        System.assert(resultMap.containsKey('isSuccess'), 'The result map should contain an isSuccess key');
        System.assertEquals(false, resultMap.get('isSuccess'), 'The operation should not be successful in test context.');
    }

    @isTest
    static void testRetrieveRecommendedProducts() {
      
         Map<String, Object> dataMap = new Map<String, Object>{
            B2BRecommendedProductsConstant.RECORD_ID => 'mockId',
            B2BRecommendedProductsConstant.PRODUCT_IDS => new Set<String>{'mockId'},
            B2BRecommendedProductsConstant.COMMUNITY_ID => 'mockCommunityId',
            B2BRecommendedProductsConstant.PAGE_NAME => 'mockPageName',
            B2BRecommendedProductsConstant.SORT_BY => 'mockSortBy',
            B2BRecommendedProductsConstant.SORT_ORDER => 'mockSortOrder',
            B2BRecommendedProductsConstant.PRODUCT_DETAIL_PAGE => 'mockPageName',
            B2BRecommendedProductsConstant.WEB_STORE_ID => 'mockCommunityId'
        };

        // Test the method
        Test.startTest();
        Map<String,Object> result = B2BRecommendedProductsHelper.retrieveRecommendedProducts(dataMap);
        Test.stopTest();

        // Asserts to validate the result
        System.assert(result != null, 'Result should not be null');
        // Add more assertions as needed
    }
    
     @isTest
    static void testConstants() {
        
        String testVal;
        testVal = B2BRecommendedProductsConstant.MESSAGING_LOG;
        testVal = B2BRecommendedProductsConstant.MESSAGING_ENTRY;
        testVal = B2BRecommendedProductsConstant.MESSAGING_EXIT;
        testVal = B2BRecommendedProductsConstant.MESSAGING_VALUE;
        testVal = B2BRecommendedProductsConstant.IS_SUCCESS;
        testVal = B2BRecommendedProductsConstant.MESSAGE;
        testVal = B2BRecommendedProductsConstant.PRODUCT_IDS;
        testVal = B2BRecommendedProductsConstant.PRODUCT_ID_STR;
        testVal = B2BRecommendedProductsConstant.RECORD_ID;
        testVal = B2BRecommendedProductsConstant.COMMUNITY_ID;
        testVal = B2BRecommendedProductsConstant.WEB_STORE_ID;
        testVal = B2BRecommendedProductsConstant.PAGE_NAME;
        testVal = B2BRecommendedProductsConstant.SORT_BY;
        testVal = B2BRecommendedProductsConstant.SORT_ORDER;
        testVal = B2BRecommendedProductsConstant.LIMIT_SIZE;
        testVal = B2BRecommendedProductsConstant.PRODUCT_DETAIL_PAGE;
        testVal = B2BRecommendedProductsConstant.SET_PRODUCT_IDS;
        testVal = B2BRecommendedProductsConstant.PRODUCTS_WITH_PRICING;
        testVal = B2BRecommendedProductsConstant.RECOMMENDED_PRODUCTS;
        testVal = B2BRecommendedProductsConstant.RECOMMENDED_PRODUCTS_OBJECT;
        testVal = B2BRecommendedProductsConstant.EFFECTIVE_ACCOUNT_ID;
        testVal = B2BRecommendedProductsConstant.EFFECTIVE_ACCOUNT;
        testVal = B2BRecommendedProductsConstant.PRODUCT_VARIATION_PARENT;
    }
    @isTest
    static void fetchRecommeded(){
        Map<String, Object> dataMap = new Map<String, Object>();
        dataMap.put(null,null);
        Test.startTest();
        Map<String,Object> result = B2BRecommendedProductsHelper.retrieveRecommendedProducts(dataMap);
        Test.stopTest();
    }
    @isTest
    static void fakeData(){
        Test.startTest();
        B2BRecommendedProductsController.fakeDummyData();
        Test.stopTest();
        
    }
}