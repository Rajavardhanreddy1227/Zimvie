public with sharing class b2bSiteImageController {
    @AuraEnabled(cacheable=true)
    public static List<SiteImageDetail__mdt> getMetadataDetails(String metaConfGroupKey, String country, 
                                                                String brand, String language) {
        String queryString = 'SELECT SortOrder__c, ImageURL__c, NavigationURL__c, ButtonLabel__c, CategoryName__c,' +
            				 ' ImageTitle__c, IsNewProduct__c, ImageDescription__c, ProductSKUCode__c, TargetForURL__c,' +
                             ' SiteImageGroup__r.HeaderTitle__c, SiteImageGroup__r.HeaderDescription__c, SiteImageGroup__r.Brand__c' +
                             ' FROM SiteImageDetail__mdt' +
                             ' WHERE SiteImageGroup__r.GroupKey__c =: metaConfGroupKey' +
                             ' AND SiteImageGroup__r.IsActive__c = TRUE' +
                             ' AND IsActive__c = TRUE';
        
        if(!String.isBlank(brand)){
            queryString += ' AND SiteImageGroup__r.Brand__c =: brand';
        }
        else{
            queryString += ' AND SiteImageGroup__r.Brand__c = \'zimvie\'';
        }
        if(!String.isBlank(language)){
            queryString += ' AND SiteImageGroup__r.Language__c =: language';
        }
        else{
            queryString += ' AND SiteImageGroup__r.Language__c = \'en_US\'';
        }
        if(country != 'LogedinUser'){
            queryString += ' AND SiteImageGroup__r.Country__c =: country';
        }
        else{
            User objLoginUser = [SELECT Id, Country FROM User WHERE Id =: userInfo.getUserId() LIMIT 1];
            queryString += ' AND SiteImageGroup__r.Country__c = \'' + objLoginUser.Country + '\'';
        }
        queryString += ' ORDER BY SortOrder__c ASC';

        List<SiteImageDetail__mdt> imagedetails = Database.query(queryString);
        
        return imagedetails;
    }

    @AuraEnabled(cacheable=true)
    public static List<SiteImageDetail__mdt> getProductDetails(List<SiteImageDetail__mdt> metadaDetails) {
        List<String> skuCodes = new List<String>();
        List<SiteImageDetail__mdt> updatedMetaList = new List<SiteImageDetail__mdt>();
        List<Product2> prodDetails = new List<Product2>();
        
        for(SiteImageDetail__mdt objMeta : metadaDetails){
            if(String.isNotBlank(objMeta.NavigationURL__c)){
                objMeta.TargetForURL__c = '_blank';
                updatedMetaList.add(objMeta);
            }
            else if(String.isNotBlank(objMeta.ProductSKUCode__c)){
                skuCodes.add(objMeta.ProductSKUCode__c);
            }
        }
        
        if(skuCodes.Size() > 0){
            if(Auth.CommunitiesUtil.isGuestUser()){
                prodDetails = b2bSiteImageHelperForGuest.getProductDetails(skuCodes);
            }
            else{
                prodDetails =  [SELECT Id, Name, StockKeepingUnit FROM Product2 
                                WHERE StockKeepingUnit IN: skuCodes];
            }
        }
        
        if(prodDetails.size() == 0){
            return updatedMetaList;
        }
        else{
            for(SiteImageDetail__mdt objMeta : metadaDetails){
                for(Product2 objProd : prodDetails){
                    if(objMeta.ProductSKUCode__c == objProd.StockKeepingUnit &&
                       String.isBlank(objMeta.NavigationURL__c)){
                        objMeta.NavigationURL__c = getCommunityURL()+'/product/'+objProd.Id;
                        objMeta.TargetForURL__c = '_self';
                        updatedMetaList.add(objMeta);
                        break;
                    }
                }
            }
            return updatedMetaList;
        }
    }
    @AuraEnabled(cacheable=true)
    public static List<SiteImageDetail__mdt> getCategoryDetails(List<SiteImageDetail__mdt> metadaDetails) {
        List<String> categortNames = new List<String>();
        List<SiteImageDetail__mdt> updatedMetaList = new List<SiteImageDetail__mdt>();
        String parentCategoryName;
        for(SiteImageDetail__mdt objMeta : metadaDetails){
            parentCategoryName = objMeta.SiteImageGroup__r.Brand__c;
            if(String.isNotBlank(objMeta.NavigationURL__c)){
                objMeta.TargetForURL__c = '_blank';
                updatedMetaList.add(objMeta);
            }
            else if(String.isNotBlank(objMeta.CategoryName__c)){
                categortNames.add(objMeta.CategoryName__c);
            }
        }
        List<ProductCategory> prodCategory =  [SELECT Id, Name FROM ProductCategory 
                                               WHERE ParentCategory.Name like : '%'+parentCategoryName+'%' 
                                               AND Name IN: categortNames];
        if(prodCategory.size() == 0){
            return updatedMetaList;
        }
        else{
            for(SiteImageDetail__mdt objMeta : metadaDetails){
                for(ProductCategory objProdCat : prodCategory){
                    if(objMeta.CategoryName__c == objProdCat.Name &&
                        String.isBlank(objMeta.NavigationURL__c)){
                        objMeta.NavigationURL__c = getCommunityURL()+'/category/'+objProdCat.Id;
                        objMeta.TargetForURL__c = '_self';
                        updatedMetaList.add(objMeta);
                        break;
                    }
                }
            }
            return updatedMetaList;
        }
    }
    public static String getCommunityURL(){       
        String base = Network.getLoginUrl(Network.getNetworkId());
        base = base.replace('/login', '');
        return base;
    }

    @AuraEnabled(cacheable=true)
    public static List<String> getBrandDetails(String country) {
        if(country == 'LogedinUser'){
            User objLoginUser = [SELECT Id, Country FROM User WHERE Id =: userInfo.getUserId() LIMIT 1];
            country = objLoginUser.Country;
        }
        List<String> brandList = new List<String>();
        for(ProductCategory objCategory :  [SELECT Id, Name FROM ProductCategory 
                                            WHERE AvailableForCountry__c INCLUDES (:country)
                                            AND ParentCategoryId = null]){
            brandList.add(objCategory.Name);
        }
        return brandList;
    }
}