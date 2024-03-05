@isTest
public class b2bSiteImageHelperForGuest_Test {
@isTest
    static void testGetProductDetails() {
        // Create test data
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Product 1', StockKeepingUnit = 'SKU001'),
            new Product2(Name = 'Product 2', StockKeepingUnit = 'SKU002')
        };
        insert products;

        List<String> skuCodes = new List<String>{ 'SKU001', 'SKU002' };

        // Call the method being tested
        List<Product2> returnedProducts = b2bSiteImageHelperForGuest.getProductDetails(skuCodes);

        // Verify results
        System.assertEquals(2, returnedProducts.size(), 'Expected 2 products to be returned');

    }
}