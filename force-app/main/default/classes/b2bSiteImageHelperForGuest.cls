public without sharing class b2bSiteImageHelperForGuest {
    public static List<Product2> getProductDetails(List<String> skuCodes) {
        return [SELECT Id, Name, StockKeepingUnit FROM Product2 
                                       WHERE StockKeepingUnit IN: skuCodes];
    }
}