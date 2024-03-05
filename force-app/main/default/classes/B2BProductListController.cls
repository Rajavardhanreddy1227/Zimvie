public without sharing class B2BProductListController {
    /*Step 1: Obtain Search Results (which returns all the products for the PLP)
      Step 2: Loop through products and obtain products ids of variation parents
      step 3: pull all Variations using above Ids
      Step 4: parents -> List<ChildVariation>
      Step 5: ChildIds make connectAPI Call to pull all prices of child variations
      Step 6: Loop through the orginal Search results --> product.get(ParentId)
      Step 7: create wrapper classs to store the parent id and min price value 
    */
    public static final String COMMUNITY_ID = 'communityId';
    public static final String EFFECTIVE_ACCOUNT_ID = 'effectiveAccountId';
    public static final String SEARCH_QUERY = 'searchQuery';
    public static final String SEARCH_RESULT = 'searchResult';
    public static final String VARIATION_INFO = 'variationInfo';
    public static final String SORT_RULES = 'sortRules';

    @AuraEnabled
    public static string getCategoryId(String brandname) {
        return [Select Id from productcategory where name =: brandname Limit 1].Id;
    }

    @AuraEnabled
    public static String getFeatureProducts(Map < String, Object > dataMap) {

        system.debug('dataMap' + dataMap);

        if (dataMap != null && ((dataMap.containsKey(EFFECTIVE_ACCOUNT_ID) && dataMap.get(EFFECTIVE_ACCOUNT_ID) != null) || !dataMap.containsKey(EFFECTIVE_ACCOUNT_ID)) &&
            dataMap.containsKey(COMMUNITY_ID) && dataMap.get(COMMUNITY_ID) != null &&
            dataMap.containsKey(SEARCH_QUERY) && dataMap.get(SEARCH_QUERY) != null) {

            String communityId = (String) dataMap.get(COMMUNITY_ID);
            String searchQuery = (String) dataMap.get(SEARCH_QUERY);
            String effectiveAccountId = dataMap.containsKey(EFFECTIVE_ACCOUNT_ID) ? (String) dataMap.get(EFFECTIVE_ACCOUNT_ID) : null; //'0018L00000GssWnQAJ';
            system.debug('effectiveAccountId=' + effectiveAccountId);
            String webstoreId;
            if (!Test.isRunningTest()) {
                webstoreId = B2BUtils.resolveCommunityIdToWebStoreId(communityId);
            } else {
                webstoreId = [SELECT Id FROM WebStore LIMIT 1].Id;
            }


            List < Account > lstAcc = new List < Account > ();
            List < B2B_Featured_Product__c > lstFeaturedProds = new List < B2B_Featured_Product__c > ();

            if (effectiveAccountId != null) {
                lstAcc = [Select Id, Ecomm_Customer_Type__c from Account where Id =: effectiveAccountId];
                if (lstAcc[0].Ecomm_Customer_Type__c == '') {
                    return null;
                }
                lstFeaturedProds = [Select Id, B2B_Product__c from B2B_Featured_Product__c where B2B_Audience_Type__c =: lstAcc[0].Ecomm_Customer_Type__c AND B2B_Is_Active__c = True];
            } else {
                lstFeaturedProds = [Select Id, B2B_Product__c from B2B_Featured_Product__c where B2B_Is_Active__c = True];
            }
            system.debug('lstFeaturedProds=' + lstFeaturedProds);
            Set < String > prodIds = new Set < String > ();
            if (lstFeaturedProds != null && lstFeaturedProds.size() > 0) {
                for (B2B_Featured_Product__c objFeaturedProd: lstFeaturedProds) {
                    prodIds.add(objFeaturedProd.B2B_Product__c);
                }
            }

            ConnectApi.ProductSearchInput productSearchInput = (ConnectApi.ProductSearchInput) JSON.deserialize(searchQuery, ConnectApi.ProductSearchInput.class);
            ConnectApi.ProductSearchResults searchResults;
            if (!Test.isRunningTest()) {
                searchResults = ConnectApi.Commercesearch.searchProducts(webstoreId, effectiveAccountId, productSearchInput);
            } else {
                searchResults = new ConnectApi.ProductSearchResults();
                searchResults.productsPage = new ConnectApi.ProductSummaryPage();
                searchResults.productsPage.products = new List < ConnectApi.ProductSummary > ();
                ConnectApi.ProductSummary prod = new ConnectApi.ProductSummary();
                prod.productClass = ConnectApi.ProductClass.VARIATIONPARENT;
                prod.id = [SELECT Id FROM Product2 WHERE ProductClass = 'VariationParent'
                    LIMIT 1
                ].Id;
                searchResults.productsPage.products.add(prod);
            }
            if (searchResults != null && searchResults.productsPage != null && searchResults.productsPage.products != null && !searchResults.productsPage.products.isEmpty()) {
                //store standard data from connected API (product summary)

                // store the parent IDS
                //Set<String> prodIds = new Set<String>();
                searchWrapCustom tempsearchResults = new searchWrapCustom();
                tempsearchResults.productsPage = new prodsummpagecustom();
                tempsearchResults.productsPage.products = new List < productSummaryCustom > ();
                for (ConnectApi.ProductSummary prod: searchResults.productsPage.products) {
                    if (prodIds.contains(prod.id)) {
                        String tempStrProd = JSON.serialize(prod);
                        tempsearchResults.productsPage.products.add((productSummaryCustom) JSON.deserialize(tempStrProd, productSummaryCustom.class));
                    }
                }

                dataMap.put(SEARCH_RESULT, tempsearchResults);
            }
        }
        return JSON.serialize(dataMap);
    }

    @AuraEnabled
    public static String getNewProducts(Map < String, Object > dataMap, String selectedbrand) {

        system.debug('dataMap' + dataMap);

        if (dataMap != null && ((dataMap.containsKey(EFFECTIVE_ACCOUNT_ID) && dataMap.get(EFFECTIVE_ACCOUNT_ID) != null) || !dataMap.containsKey(EFFECTIVE_ACCOUNT_ID)) &&
            dataMap.containsKey(COMMUNITY_ID) && dataMap.get(COMMUNITY_ID) != null &&
            dataMap.containsKey(SEARCH_QUERY) && dataMap.get(SEARCH_QUERY) != null) {

            String communityId = (String) dataMap.get(COMMUNITY_ID);
            String searchQuery = (String) dataMap.get(SEARCH_QUERY);
            String effectiveAccountId = dataMap.containsKey(EFFECTIVE_ACCOUNT_ID) ? (String) dataMap.get(EFFECTIVE_ACCOUNT_ID) : null; //'0018L00000GssWnQAJ';
            system.debug('effectiveAccountId=' + effectiveAccountId);
            String webstoreId;
            if (!Test.isRunningTest()) {
                webstoreId = B2BUtils.resolveCommunityIdToWebStoreId(communityId);
            } else {
                webstoreId = [SELECT Id FROM WebStore LIMIT 1].Id;
            }


            List < Account > lstAcc = new List < Account > ();
            List < B2B_New_Product__c > lstNewProds = new List < B2B_New_Product__c > ();
            String countryName = [SELECT Id, Name, City, Country FROM User where Id =: UserInfo.getUserId()].Country;
            if (effectiveAccountId != null) {
                lstAcc = [Select Id, Customer_Type__c from Account where Id =: effectiveAccountId];
                if (lstAcc[0].Customer_Type__c == '') {
                    return null;
                }
                lstNewProds = [Select Id, B2B_Product__c from B2B_New_Product__c where B2B_Brand__c =: selectedbrand AND B2B_Is_Active__c = True AND B2B_Country_Name__c =: countryName];
            } else {
                lstNewProds = [Select Id, B2B_Product__c from B2B_New_Product__c where B2B_Is_Active__c = True];
            }

            Set < String > prodIds = new Set < String > ();
            if (lstNewProds != null && lstNewProds.size() > 0) {
                for (B2B_New_Product__c objNewProd: lstNewProds) {
                    prodIds.add(objNewProd.B2B_Product__c);
                }
            }

            ConnectApi.ProductSearchInput productSearchInput = (ConnectApi.ProductSearchInput) JSON.deserialize(searchQuery, ConnectApi.ProductSearchInput.class);
            ConnectApi.ProductSearchResults searchResults;
            if (!Test.isRunningTest()) {
                searchResults = ConnectApi.Commercesearch.searchProducts(webstoreId, effectiveAccountId, productSearchInput);
            } else {
                searchResults = new ConnectApi.ProductSearchResults();
                searchResults.productsPage = new ConnectApi.ProductSummaryPage();
                searchResults.productsPage.products = new List < ConnectApi.ProductSummary > ();
                ConnectApi.ProductSummary prod = new ConnectApi.ProductSummary();
                prod.productClass = ConnectApi.ProductClass.VARIATIONPARENT;
                prod.id = [SELECT Id FROM Product2 WHERE ProductClass = 'VariationParent'
                    LIMIT 1
                ].Id;
                searchResults.productsPage.products.add(prod);
            }
            if (searchResults != null && searchResults.productsPage != null && searchResults.productsPage.products != null && !searchResults.productsPage.products.isEmpty()) {
                //store standard data from connected API (product summary)

                // store the parent IDS
                //Set<String> prodIds = new Set<String>();
                searchWrapCustom tempsearchResults = new searchWrapCustom();
                tempsearchResults.productsPage = new prodsummpagecustom();
                tempsearchResults.productsPage.products = new List < productSummaryCustom > ();
                for (ConnectApi.ProductSummary prod: searchResults.productsPage.products) {
                    if (prodIds.contains(prod.id)) {
                        String tempStrProd = JSON.serialize(prod);
                        tempsearchResults.productsPage.products.add((productSummaryCustom) JSON.deserialize(tempStrProd, productSummaryCustom.class));
                    }
                }

                dataMap.put(SEARCH_RESULT, tempsearchResults);
            }
        }
        return JSON.serialize(dataMap);
    }


    public class searchWrapCustom {
        public prodsummpagecustom productsPage;
    }
    public class prodsummpagecustom {
        public string currencyIsoCode;
        public Integer pageSize;
        public long total;
        public List < productSummaryCustom > products;
    }
    public class productSummaryCustom {
        public customMedia defaultImage;
        public Map < String, customFields > fields;
        public string id;
        public string name;
    }
    public class customFields {
        public string value;
    }
    public class customMedia {
        public string alternateText;
        public string contentVersionId;
        public string id;
        public String mediaType;
        public string thumbnailUrl;
        public Integer sortOrder;
        public string title;
        public string url;
    }

    @AuraEnabled
    public static String productSearch(Map < String, Object > dataMap) {

        system.debug('dataMap' + dataMap);

        if (dataMap != null && ((dataMap.containsKey(EFFECTIVE_ACCOUNT_ID) && dataMap.get(EFFECTIVE_ACCOUNT_ID) != null) || !dataMap.containsKey(EFFECTIVE_ACCOUNT_ID)) &&
            dataMap.containsKey(COMMUNITY_ID) && dataMap.get(COMMUNITY_ID) != null &&
            dataMap.containsKey(SEARCH_QUERY) && dataMap.get(SEARCH_QUERY) != null) {
            String communityId = (String) dataMap.get(COMMUNITY_ID);
            String searchQuery = (String) dataMap.get(SEARCH_QUERY);
            String effectiveAccountId = dataMap.containsKey(EFFECTIVE_ACCOUNT_ID) ? (String) dataMap.get(EFFECTIVE_ACCOUNT_ID) : null; //'0018L00000GssWnQAJ';
            system.debug('effectiveAccountId=' + effectiveAccountId);
            effectiveAccountId = [Select AccountId from User where Id =: Userinfo.getUserId()].AccountId;
            String webstoreId;
            if (!Test.isRunningTest()) {
                webstoreId = B2BUtils.resolveCommunityIdToWebStoreId(communityId);
            } else {
                webstoreId = [SELECT Id FROM WebStore LIMIT 1].Id;
            }

            ConnectApi.ProductSearchInput productSearchInput = (ConnectApi.ProductSearchInput) JSON.deserialize(searchQuery, ConnectApi.ProductSearchInput.class);
            ConnectApi.ProductSearchResults searchResults;
            if (!Test.isRunningTest()) {
                searchResults = ConnectApi.Commercesearch.searchProducts(webstoreId, effectiveAccountId, productSearchInput);
            } else {
                searchResults = new ConnectApi.ProductSearchResults();
                searchResults.productsPage = new ConnectApi.ProductSummaryPage();
                searchResults.productsPage.products = new List < ConnectApi.ProductSummary > ();
                ConnectApi.ProductSummary prod = new ConnectApi.ProductSummary();
                prod.productClass = ConnectApi.ProductClass.VARIATIONPARENT;
                prod.id = [SELECT Id FROM Product2 WHERE ProductClass = 'VariationParent'
                    LIMIT 1
                ].Id;
                searchResults.productsPage.products.add(prod);
            }
            system.debug('facets :: ' + searchResults.facets);
            dataMap.put(SEARCH_RESULT, searchResults);
            if(searchResults != null && searchResults.productsPage != null && searchResults.productsPage.products != null && !searchResults.productsPage.products.isEmpty()){
                Set<String> prodIds = new Set<String>();

                Set<String> setOfProductIds = new Set<String>();

                if(dataMap.get('selectedCountry') != null && (Boolean)dataMap.get('isGuest') == true){

                    searchWrapCustom tempsearchResults = new searchWrapCustom();
                    tempsearchResults.productsPage = new prodsummpagecustom();
                    tempsearchResults.productsPage.products = new List<productSummaryCustom>();
                    system.debug('searchResults.productsPage.products=='+searchResults.productsPage.products);
                    for(ConnectApi.ProductSummary prod : searchResults.productsPage.products){
                        system.debug('prod='+prod.fields);
                        system.debug('dataMap.get(selectedCountry)=='+dataMap.get('selectedCountry'));
                        String selectedCountryValue = (String)dataMap.get('selectedCountry');
                        String currentProductMarketvalues = prod.fields.get('Available_to_Markets__c')?.value;
                        if(currentProductMarketvalues != null && currentProductMarketvalues.contains(selectedCountryValue)){
                            String tempStrProd = JSON.serialize(prod);
                            tempsearchResults.productsPage.products.add((productSummaryCustom)JSON.deserialize(tempStrProd, productSummaryCustom.class)); 
                            if(prod.productClass == ConnectApi.ProductClass.VARIATIONPARENT){
                                prodIds.add(prod.id);
                            }   
                        }                    
                    }
                    tempsearchResults.productsPage.total = tempsearchResults.productsPage.products.size();
                    if(tempsearchResults.productsPage.total < 21){
                        tempsearchResults.productsPage.pageSize = Integer.valueof(tempsearchResults.productsPage.total);
                    } else {
                        tempsearchResults.productsPage.pageSize = 20;
                    }
                    
                    dataMap.put(SEARCH_RESULT,tempsearchResults);

                    
                } else {
                     //store standard data from connected API (product summary)
                    dataMap.put(SEARCH_RESULT,searchResults);
                    for(ConnectApi.ProductSummary prod : searchResults.productsPage.products){
                        if(prod.productClass == ConnectApi.ProductClass.VARIATIONPARENT){
                            prodIds.add(prod.id);
                        }                    
                    }
                }
                system.debug(dataMap.get(SEARCH_RESULT));
                
                if(!prodIds.isEmpty()){
                    // fetch the parentId and the min price to show on UI 
                    dataMap.put(VARIATION_INFO, fetchVariationCombinedData(communityId, webstoreId, effectiveAccountId, prodIds));
                }
            }      
        }
        return JSON.serialize(dataMap);
    }

    // fecth the min price for the parent products and store the information in wrapper class 
    public static Map < String, B2BProductListVO > fetchVariationCombinedData(String communityId, String webstoreId, String effectiveAccountId, Set < String > prodIds) {

        Map < String, B2BProductListVO > productOptionsDataMap = new Map < String, B2BProductListVO > ();
        //effectiveAccountId = effectiveAccountId == null ? '0018L00000GssWnQAJ' : effectiveAccountId;
        // get all the list of child prods
        List < ProductAttribute > productAttributes = [SELECT Id, VariantParentId, ProductId, product.name FROM ProductAttribute WHERE VariantParentId IN: prodIds AND Product.IsActive = TRUE];
        system.debug('productAttributes=' + productAttributes);
        //store parentId -> realted child prods
        Map < String, Set < String >> parentChildMap = new Map < String, Set < String >> ();
        // store child id and child prod
        Map < String, Product2 > childProdMap = new Map < String, Product2 > ();
        // store childID -> price 
        Map < String, String > priceMap = new Map < String, String > ();
        // store prent id --> list of child prices 
        Map < String, List < Decimal >> priceVariantMap = new Map < String, List < Decimal >> ();

        if (!productAttributes.isEmpty()) {
            System.debug('testing');
            for (ProductAttribute attr: productAttributes) {
                if (!parentChildMap.containsKey(attr.VariantParentId)) {
                    parentChildMap.put(attr.VariantParentId, new Set < String > {
                        attr.ProductId
                    });
                }
                //add all child prod id to praent prod id
                parentChildMap.get(attr.VariantParentId).add(attr.ProductId);
                //add child ids
                childProdMap.put(attr.ProductId, attr.Product);
                system.debug('testing att-->' + childProdMap);
            }
        }
        system.debug('childProdMap=' + childProdMap);
        system.debug('parentChildMap=' + parentChildMap);
        //get the child prod prices and store prices in a map
        ConnectApi.PricingInput pInput = new ConnectApi.PricingInput();
        List < ConnectApi.PricingLineItemInput > priceLineInputs = new List < ConnectApi.PricingLineItemInput > ();

        for (String eachpa: childProdMap.keySet()) {
            ConnectApi.PricingLineItemInput pli = new ConnectApi.PricingLineItemInput();
            pli.productId = eachpa;
            priceLineInputs.add(pli);
        }
        system.debug('priceLineInputs=' + priceLineInputs);
        pInput.pricingLineItems = priceLineInputs;

        ConnectApi.PricingResult prices = ConnectApi.CommerceStorePricing.getProductPrices(webstoreId, effectiveAccountId, pInput);
        system.debug('prices>>>' + prices);

        for (ConnectApi.PricingResultLineItem priceResult: prices.pricingLineItemResults) {
            // store the prices in map with child id as a key 
            priceMap.put(priceResult.productId, priceResult.unitPrice);
        }

        system.debug('priceMap....' + priceMap);

        String shortId;

        for (ProductAttribute attr: productAttributes) {
            system.debug('inside for loop');
            shortId = attr.productId;
            if (priceMap.containsKey(shortId) && priceMap.get(shortId) != null) {
                system.debug('priceMap.containsKey(attr.productId) yes ');
                if (!priceVariantMap.containsKey(attr.VariantParentId)) {
                    system.debug('!priceVariantMap.containsKey(attr.VariantParentId)');
                    priceVariantMap.put(attr.VariantParentId, new List < Decimal > {
                        Decimal.valueOf(priceMap.get(shortId))
                    });
                }
                priceVariantMap.get(attr.VariantParentId).add(Decimal.valueOf(priceMap.get(shortId)));
                priceVariantMap.get(attr.VariantParentId).sort();
            }

        }
        system.debug('priceVariantMap=' + priceVariantMap);
        system.debug('prodIds=' + prodIds);
        // store the info in wrapper class 
        B2BProductListVO prodData;
        String firstChildProdId;
        for (String prodId: prodIds) {
            if (parentChildMap.containsKey(prodId)) {
                prodData = new B2BProductListVO();
                prodData.variantParentId = prodId;
                if (priceVariantMap.containsKey(prodId)) {
                    Decimal minValue = priceVariantMap.get(prodId)[0];
                    Decimal maxValue = priceVariantMap.get(prodId)[0];

                    for (Decimal num: priceVariantMap.get(prodId)) {
                        if (num < minValue) {
                            minValue = num;
                        }

                        if (num > maxValue) {
                            maxValue = num;
                        }
                    }
                    prodData.minPrice = String.valueOf(minValue);
                    prodData.maxPrice = String.valueOf(maxValue);
                }
                // retrun parent id and wrapper class 
                productOptionsDataMap.put(prodId, prodData);
            }
        }

        return productOptionsDataMap;
    }

    @AuraEnabled
    public static Map < String, Object > getSortRules(Map < String, Object > dataMap) {

        String methodName = 'getSortRules';

        if (dataMap != null && dataMap.containsKey(COMMUNITY_ID) && dataMap.get(COMMUNITY_ID) != null) {
            String communityId = (String) dataMap.get(COMMUNITY_ID);
            String webstoreId;
            if (!Test.isRunningTest()) {
                webstoreId = B2BUtils.resolveCommunityIdToWebStoreId(communityId);
            } else {
                webstoreId = [SELECT Id FROM WebStore LIMIT 1].Id;
            }
            ConnectApi.SortRulesCollection sortRulesCollection;
            if (!Test.isRunningTest()) {
                sortRulesCollection = ConnectApi.CommerceSearch.getSortRules(webstoreId);
            } else {
                sortRulesCollection = new ConnectApi.SortRulesCollection();
                sortRulesCollection.sortRules = new List < ConnectApi.SortRule > ();
                ConnectApi.SortRule rule = new ConnectApi.SortRule();
                sortRulesCollection.sortRules.add(rule);
            }
            if (sortRulesCollection != null && sortRulesCollection.sortRules != null && !sortRulesCollection.sortRules.isEmpty()) {
                dataMap.put(SORT_RULES, sortRulesCollection.sortRules);
            }
        }
        return dataMap;
    }


}