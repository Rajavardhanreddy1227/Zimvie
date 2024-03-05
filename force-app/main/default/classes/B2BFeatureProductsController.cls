public class B2BFeatureProductsController {
    @AuraEnabled(cacheable=true)
    public static String getFeatureProducts(String webstoreId,String accId){
        List<Account> lstAcc = new List<Account>();
        lstAcc = [Select Id,Customer_Type__c from Account where Id=:accId];
        if(lstAcc[0].Customer_Type__c == '')
        {
            return null;
        }

        List<B2B_Featured_Product__c> lstFeaturedProds = new List<B2B_Featured_Product__c>();
        
        lstFeaturedProds = [Select Id,B2B_Product__c from B2B_Featured_Product__c where B2B_Audience_Type__c=:lstAcc[0].Customer_Type__c AND B2B_Is_Active__c = True];
        
        Set<String> prodIds = new Set<String>();
        List<String> Ids = new List<String>();
        if(lstFeaturedProds != null && lstFeaturedProds.size() > 0){
            for(B2B_Featured_Product__c objFeaturedProd : lstFeaturedProds){
                prodIds.add(objFeaturedProd.B2B_Product__c);
            }
            Ids.addAll(prodIds);
            if(prodIds != null && prodIds.size() > 0){
                 ConnectApi.ProductOverviewCollection results;
                if(!test.isRunningTest()){
                     results = ConnectApi.CommerceCatalog.getProducts(webstoreId, accId, Ids, null, null, false, true);

                }
                return JSON.serialize(results);
            } else {
                return null;
            }
        } else {
            return null;
        }
    }
}