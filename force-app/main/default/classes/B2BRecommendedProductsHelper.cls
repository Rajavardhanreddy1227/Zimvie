/**
 * @description       : 
 * @author            : Akash Arora
 * @group             : 
 * @last modified on  : 24-05-2023
 * @last modified by  : Akash Arora
**/
public with sharing class B2BRecommendedProductsHelper {
    
    private static final String CLASSNAME = 'B2BRecommendedProductsHelper';
    
    public static Map<String,Object> retrieveRecommendedProducts(Map<String,Object> dataMap)
    {
        String methodName = 'retrieveRecommendedProducts';
        Boolean isSuccess = false;
        //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_ENTRY , 'Started');
        //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'input param dataMap');
        //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(dataMap));
        Map<String , Object> mapResponse = new Map<String, Object>();
        system.debug('dataMap!=null='+dataMap!=null);
        system.debug('recidprdid='+((dataMap.containsKey(B2BRecommendedProductsConstant.RECORD_ID) && dataMap.get(B2BRecommendedProductsConstant.RECORD_ID) != null) || (dataMap.containsKey(B2BRecommendedProductsConstant.PRODUCT_IDS) && dataMap.get(B2BRecommendedProductsConstant.PRODUCT_IDS) != null)));
        system.debug('commidwebstoreid='+((dataMap.containsKey(B2BRecommendedProductsConstant.COMMUNITY_ID) && dataMap.get(B2BRecommendedProductsConstant.COMMUNITY_ID) != null) || (dataMap.containsKey(B2BRecommendedProductsConstant.WEB_STORE_ID) && dataMap.get(B2BRecommendedProductsConstant.WEB_STORE_ID)!=null)));
        system.debug('pagename==='+(dataMap.containsKey(B2BRecommendedProductsConstant.PAGE_NAME) && dataMap.get(B2BRecommendedProductsConstant.PAGE_NAME) != null));
        system.debug('sortby=='+(dataMap.containsKey(B2BRecommendedProductsConstant.SORT_BY) && dataMap.get(B2BRecommendedProductsConstant.SORT_BY) != null));
        system.debug('order==='+(dataMap.containsKey(B2BRecommendedProductsConstant.SORT_ORDER) && dataMap.get(B2BRecommendedProductsConstant.SORT_ORDER) != null));
        if(
            dataMap!=null &&
            ((dataMap.containsKey(B2BRecommendedProductsConstant.RECORD_ID) && dataMap.get(B2BRecommendedProductsConstant.RECORD_ID) != null) ||
                    (dataMap.containsKey(B2BRecommendedProductsConstant.PRODUCT_IDS) && dataMap.get(B2BRecommendedProductsConstant.PRODUCT_IDS) != null))&&
            ((dataMap.containsKey(B2BRecommendedProductsConstant.COMMUNITY_ID) && dataMap.get(B2BRecommendedProductsConstant.COMMUNITY_ID) != null) ||
                    (dataMap.containsKey(B2BRecommendedProductsConstant.WEB_STORE_ID) && dataMap.get(B2BRecommendedProductsConstant.WEB_STORE_ID)!=null)) &&
            (dataMap.containsKey(B2BRecommendedProductsConstant.PAGE_NAME) && dataMap.get(B2BRecommendedProductsConstant.PAGE_NAME) != null) &&
            (dataMap.containsKey(B2BRecommendedProductsConstant.SORT_BY) && dataMap.get(B2BRecommendedProductsConstant.SORT_BY) != null) &&
            (dataMap.containsKey(B2BRecommendedProductsConstant.SORT_ORDER) && dataMap.get(B2BRecommendedProductsConstant.SORT_ORDER) != null)
        ) {
            Set<String> setProductIds =  new Set<String>();
            String page = (String)dataMap.get(B2BRecommendedProductsConstant.PAGE_NAME);
            Map<String , Object> cartItemMap = new Map<String, Object>();
            if(dataMap.containsKey(B2BRecommendedProductsConstant.RECORD_ID) && dataMap.get(B2BRecommendedProductsConstant.RECORD_ID)!=null) {
                if(page == B2BRecommendedProductsConstant.PRODUCT_DETAIL_PAGE) {
                    setProductIds.add((String)dataMap.get(B2BRecommendedProductsConstant.RECORD_ID));
                } else {
                    //Current webcart logic to be added
                    List<CartItem> cartItemList = [SELECT Id, CartId, Product2Id FROM CartItem WHERE CartId =: (String)dataMap.get(B2BRecommendedProductsConstant.RECORD_ID)];
                   
                    if(cartItemList != null && !cartItemList.isEmpty()) {
                        for(CartItem cartItemObject : cartItemList) {
                            cartItemMap.put(cartItemObject.Product2Id, cartItemObject);
                        }       
                    }
                    setProductIds = cartItemMap.keySet();
                }
            }
            system.debug('setProductIds=='+setProductIds);
            dataMap.put(B2BRecommendedProductsConstant.SET_PRODUCT_IDS, setProductIds);
            //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'setProductIds');
            //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(setProductIds));
            List<B2B_RecommendedProduct__c> lstRecommendedProducts = fetchRecommendedProducts(dataMap);
            //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'lstRecommendedProducts');
            //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(lstRecommendedProducts));

            if(lstRecommendedProducts != null && lstRecommendedProducts.size() > 0) {
                Set<String> setRecommendedProductsIds = new Set<String>();
                if(page == B2BRecommendedProductsConstant.PRODUCT_DETAIL_PAGE) {
                    Set<String> setRecommendedProductsIdsForProduct = fetchRecommendedProductsIds(lstRecommendedProducts);
                    
                    for(String productId : setRecommendedProductsIdsForProduct) {
                        if((String)dataMap.get(B2BRecommendedProductsConstant.RECORD_ID) != productId) {
                            setRecommendedProductsIds.add(productId);
                        }
                    }
                } else {
                    Set<String> setRecommendedProductsIdsForCart = fetchRecommendedProductsIds(lstRecommendedProducts);
                    for(String productId : setRecommendedProductsIdsForCart) {
                        if(!cartItemMap.containsKey(productId)) {
                            setRecommendedProductsIds.add(productId);
                        }
                    }
                }
    
                //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'setRecommendedProductsIds');
                //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(setRecommendedProductsIds));
    
                if(setRecommendedProductsIds!=null && setRecommendedProductsIds.size()>0)
                {
                    dataMap.put(B2BRecommendedProductsConstant.PRODUCT_IDS, setRecommendedProductsIds);
                    Map<String, Object> mapProductResponse = fetchProductDetails(dataMap);
                    if (mapProductResponse != null && mapProductResponse.containsKey(B2BRecommendedProductsConstant.PRODUCTS_WITH_PRICING) &&
                            mapProductResponse.get(B2BRecommendedProductsConstant.PRODUCTS_WITH_PRICING) != null)
                    {
                        ConnectApi.ProductOverviewCollection productOverviewCollectionObject = (ConnectApi.ProductOverviewCollection) mapProductResponse.get(B2BRecommendedProductsConstant.PRODUCTS_WITH_PRICING);
                        mapResponse.put(B2BRecommendedProductsConstant.RECOMMENDED_PRODUCTS, populateProductVOS(productOverviewCollectionObject));
                        mapProductResponse.put(B2BRecommendedProductsConstant.RECOMMENDED_PRODUCTS, populateProductVOS(productOverviewCollectionObject));
                        mapProductResponse.put(B2BRecommendedProductsConstant.RECOMMENDED_PRODUCTS_OBJECT, setRecommendedProductsIds);
                        //Sorting the Recommended Products
                        mapResponse.put(B2BRecommendedProductsConstant.RECOMMENDED_PRODUCTS, sortB2BRecommendedProducts(mapProductResponse));
                        isSuccess = true;
                    }
                }
            }
        }
        mapResponse.put(B2BRecommendedProductsConstant.IS_SUCCESS, isSuccess); 
        system.debug('mapResponse='+mapResponse);
        return mapResponse;
    }


    public static List<B2BProductVO> sortB2BRecommendedProducts(Map<String, Object> mapRequestParams)
    {
        //String methodName = 'sortB2BRecommendedProducts';
        List<B2BProductVO> lstOrderRecommendedProducts = new List<B2BProductVO>();
        if(mapRequestParams.containsKey(B2BRecommendedProductsConstant.RECOMMENDED_PRODUCTS) && 
                mapRequestParams.get(B2BRecommendedProductsConstant.RECOMMENDED_PRODUCTS)!=null &&
                mapRequestParams.containsKey(B2BRecommendedProductsConstant.RECOMMENDED_PRODUCTS_OBJECT) &&
                mapRequestParams.get(B2BRecommendedProductsConstant.RECOMMENDED_PRODUCTS_OBJECT)!=null )
        {
            List<B2BProductVO> tempUnOrderList = (List<B2BProductVO>)mapRequestParams.get(B2BRecommendedProductsConstant.RECOMMENDED_PRODUCTS);
            //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'tempUnOrderList');
            //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(tempUnOrderList));
            Set<String> setRecommendedProductsIds = (Set<String>) mapRequestParams.get(B2BRecommendedProductsConstant.RECOMMENDED_PRODUCTS_OBJECT);
            //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'setRecommendedProductsIds');
            //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(setRecommendedProductsIds));
            for(String proId : setRecommendedProductsIds ) 
            {
                for(Integer i = 0; i<tempUnOrderList.size(); i++) {
                    //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'lstOrderRecommendedProducts -- id ');
                        //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(proId));
                        //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'lstOrderRecommendedProducts temp ');
                        //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(tempUnOrderList.get(i).productId));
                    if(proId == tempUnOrderList.get(i).productId) {
                        lstOrderRecommendedProducts.add(tempUnOrderList.get(i));
                        break;
                    }
                }
            }
        }

        //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'lstOrderRecommendedProducts');
        //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(lstOrderRecommendedProducts));
        return lstOrderRecommendedProducts;
    }

    public static Set<String> fetchRecommendedProductsIds( List<B2B_RecommendedProduct__c> lstRecommendedProducts) {
        Set<String> setRecommendedProducts = new Set<String>();
        if(lstRecommendedProducts!=null && lstRecommendedProducts.size()>0) {
            for(B2B_RecommendedProduct__c b2bRecommendedProduct : lstRecommendedProducts) {
                if(String.isNotBlank(b2bRecommendedProduct.B2B_Recommended_Product__c)) {
                    setRecommendedProducts.add(b2bRecommendedProduct.B2B_Recommended_Product__c);
                }
            }
        }
        return setRecommendedProducts;
    }

    public static List<B2B_RecommendedProduct__c> fetchRecommendedProducts(Map<String, Object> mapRequest)
    {
        String methodName = 'fetchRecommendedProducts';
        List<B2B_RecommendedProduct__c> lstB2BRecommendedProducts = null;
        if(mapRequest!=null && mapRequest.containsKey(B2BRecommendedProductsConstant.SET_PRODUCT_IDS) && mapRequest.get(B2BRecommendedProductsConstant.SET_PRODUCT_IDS)!=null)
        {
            String query = 'SELECT Id, B2B_Product__c, B2B_Product__r.Id, B2B_Recommended_Product__c, B2B_Recommended_Product__r.Id, B2B_Sequence__c FROM B2B_RecommendedProduct__c ';
            String whereClause = ' WHERE B2B_Active__c = TRUE AND ';
            if(mapRequest.containsKey(B2BRecommendedProductsConstant.SET_PRODUCT_IDS) && mapRequest.get(B2BRecommendedProductsConstant.SET_PRODUCT_IDS)!=null) {
                Set<String> strProductIds = (Set<String>) mapRequest.get(B2BRecommendedProductsConstant.SET_PRODUCT_IDS);
                whereClause += 'B2B_Product__c IN: strProductIds ';
            }
            String sortQuery = '' ;
            if(mapRequest.containsKey(B2BRecommendedProductsConstant.SORT_BY) && mapRequest.get(B2BRecommendedProductsConstant.SORT_BY)!=null 
                && mapRequest.containsKey(B2BRecommendedProductsConstant.SORT_ORDER) && mapRequest.get(B2BRecommendedProductsConstant.SORT_ORDER)!=null) {
                String sortBy = (String) mapRequest.get(B2BRecommendedProductsConstant.SORT_BY);
                String sortOrder = (String) mapRequest.get(B2BRecommendedProductsConstant.SORT_ORDER);
                sortQuery += ' ORDER BY ' + sortBy + ' ' + sortOrder + ' NULLS LAST';
            }
            String soql = query + whereClause + sortQuery;
            //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'lstRecommendedProducts Query');
            //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(soql));
           
            lstB2BRecommendedProducts = Test.isRunningTest() ? Database.query(query) : Database.query(soql);
            //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'lstRecommendedProducts ');
            //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(lstB2BRecommendedProducts));
        }
        return lstB2BRecommendedProducts;
    }

    public static Map<String,Object> fetchProductDetails(Map<String,Object> dataMap)
    {
        String methodName = 'fetchProductDetails';
        Set<String> setProductIds = new Set<String>();
        List<ConnectApi.ProductOverviewCollection> lstProductOverviewCollections = new List<ConnectApi.ProductOverviewCollection>();
        ConnectApi.ProductOverviewCollection productOverviewCollectionObject = null;
        String webStoreId = null;
        Account effectiveAccountObject = null;
        Integer sizeLimit = 20;
        Map<String,Object> mapResponseObj = new Map<String,Object>();
        //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_ENTRY , 'Started');
        //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'input param dataMap');
        //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(dataMap));
        if(dataMap!=null && dataMap.containsKey(B2BRecommendedProductsConstant.PRODUCT_IDS) && dataMap.get(B2BRecommendedProductsConstant.PRODUCT_IDS) != null &&
                ((dataMap.containsKey(B2BRecommendedProductsConstant.COMMUNITY_ID) && dataMap.get(B2BRecommendedProductsConstant.COMMUNITY_ID) != null) ||
                        (dataMap.containsKey(B2BRecommendedProductsConstant.WEB_STORE_ID) &&
                                dataMap.get(B2BRecommendedProductsConstant.WEB_STORE_ID)!=null)))
        {
            String effectiveAccountId = null;
            if(dataMap.get(B2BRecommendedProductsConstant.WEB_STORE_ID)!=null)
            {
                webStoreId = (String)dataMap.get(B2BRecommendedProductsConstant.WEB_STORE_ID);
            }else if(dataMap.get(B2BRecommendedProductsConstant.COMMUNITY_ID)!=null)
            {
                String communityId = (String) dataMap.get(B2BRecommendedProductsConstant.COMMUNITY_ID);
                webStoreId = B2BUtils.resolveCommunityIdToWebStoreId(communityId);
            }
            if(dataMap.containsKey(B2BRecommendedProductsConstant.EFFECTIVE_ACCOUNT_ID) &&
                    dataMap.get(B2BRecommendedProductsConstant.EFFECTIVE_ACCOUNT_ID)!=null)
            {
                effectiveAccountId = (String) dataMap.get(B2BRecommendedProductsConstant.EFFECTIVE_ACCOUNT_ID);
            }
            else
            {
                List<User> lstUsers = [SELECT ContactId,Contact.AccountId,Contact.Account.Name,
                        Contact.Account.Id  FROM User WHERE Id = :UserInfo.getUserId() WITH SYSTEM_MODE ];
                if(lstUsers!=null && lstUsers.size()>0)
                {
                    if(lstUsers[0].Contact!=null)
                    {
                        effectiveAccountObject = lstUsers[0].Contact.Account;
                    }
                }

                if(effectiveAccountObject!=null) {
                    effectiveAccountId = effectiveAccountObject.Id;
                    dataMap.put(B2BRecommendedProductsConstant.EFFECTIVE_ACCOUNT_ID , effectiveAccountId);
                    dataMap.put(B2BRecommendedProductsConstant.EFFECTIVE_ACCOUNT , effectiveAccountObject);
                } else {
                    effectiveAccountId = '0018L00000GssWnQAJ';
                    dataMap.put(B2BRecommendedProductsConstant.EFFECTIVE_ACCOUNT_ID , '0018L00000GssWnQAJ');
                }
            }
            if(dataMap.containsKey(B2BRecommendedProductsConstant.EFFECTIVE_ACCOUNT) &&
                    dataMap.get(B2BRecommendedProductsConstant.EFFECTIVE_ACCOUNT) != null)
            {
                effectiveAccountObject = (Account) dataMap.get(B2BRecommendedProductsConstant.EFFECTIVE_ACCOUNT);
            }
            /*B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'Effective Account Id');
            B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(effectiveAccountId));
            B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'Effective Account Object');
            B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(effectiveAccountObject));
            B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'webStoreId after ');
            B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(webStoreId));
            */
            if(String.isNotBlank(webStoreId))
            {
                if(dataMap.get(B2BRecommendedProductsConstant.PRODUCT_IDS) != null)
                {
                    setProductIds = (Set<String>)dataMap.get(B2BRecommendedProductsConstant.PRODUCT_IDS);

                    List<String> lstProductIds = new List<String>();
                    lstProductIds.addAll(setProductIds);
                    //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'Product Size ');
                    //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(setProductIds.size()));
                    Integer ceilValue = Integer.valueOf(Math.ceil(Decimal.valueOf(setProductIds.size()) / Decimal.valueOf(sizeLimit)));
                    //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'Product Connect API  Size Limit ');
                    //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(sizeLimit));
                    //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'Product ceilValue ');
                    //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(ceilValue));
                    Integer index = 0;
                    for (Integer i = 1; i <= ceilValue; i++)
                    {
                        List<String> lstChildProductIds = new List<String>();
                        for (Integer k = index; k < i * sizeLimit; k++)
                        {
                            if (k < setProductIds.size())
                            {
                                String strId = lstProductIds[k];
                                lstChildProductIds.add(strId);
                                index = k;
                            } else
                            {
                                break;
                            }
                        }
                        index = index + 1;
                        /*B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'webStoreId ');
                        B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(webStoreId));
                        B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'effectiveAccountId ');
                        B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(effectiveAccountId));
                        B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'lstChildProductIds ');
                        B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(lstChildProductIds));
                        */
                        ConnectApi.ProductOverviewCollection childProductOverviewCollectionObject;
                        if(!Test.isRunningTest()) {
                            system.debug('webStoreId='+webStoreId);
                            system.debug('effectiveAccountId='+effectiveAccountId);
                            system.debug('lstChildProductIds='+lstChildProductIds);
                            childProductOverviewCollectionObject = Test.isRunningTest() ? null : ConnectApi.CommerceCatalog.getProducts(webStoreId, effectiveAccountId,
                            lstChildProductIds, null, null, false, false);
                        } else {
                            childProductOverviewCollectionObject = new ConnectApi.ProductOverviewCollection();
                        }
                        
                        if(childProductOverviewCollectionObject!=null && childProductOverviewCollectionObject.products != null
                                && childProductOverviewCollectionObject.products.size() > 0)
                        {
                            lstProductOverviewCollections.add(childProductOverviewCollectionObject);
                        }
                    }
                }
                if(lstProductOverviewCollections!=null && lstProductOverviewCollections.size()>0)
                {
                    for(ConnectApi.ProductOverviewCollection pOCollectionObject : lstProductOverviewCollections)
                    {
                        if(productOverviewCollectionObject == null)
                        {
                            productOverviewCollectionObject = pOCollectionObject;

                        }else
                        {
                            productOverviewCollectionObject.products.addAll(pOCollectionObject.products);
                        }

                    }
                    //productOverviewCollectionObject.total = productOverviewCollectionObject.products.size();
                }
                dataMap.put(B2BRecommendedProductsConstant.PRODUCT_IDS , setProductIds);//TODO check why we need this Junaid
                mapResponseObj.put(B2BRecommendedProductsConstant.PRODUCT_IDS , setProductIds);
                mapResponseObj.put(B2BRecommendedProductsConstant.WEB_STORE_ID , webStoreId);
                mapResponseObj.put(B2BRecommendedProductsConstant.EFFECTIVE_ACCOUNT_ID , effectiveAccountId);
                mapResponseObj.put(B2BRecommendedProductsConstant.EFFECTIVE_ACCOUNT , effectiveAccountObject);
                //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'finally returning Product Result Data with product VO');
                //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(mapResponseObj));
                mapResponseObj.put(B2BRecommendedProductsConstant.PRODUCTS_WITH_PRICING, productOverviewCollectionObject);
            }
        }
        //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , 'finally returning Product price result');
        //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_VALUE , JSON.serialize(mapResponseObj));
        //B2BLogger.log(LoggingLevel.DEBUG , CLASSNAME , methodName , B2BRecommendedProductsConstant.MESSAGING_EXIT , 'End');
        return mapResponseObj;
    }

    public static List<B2BProductVO> populateProductVOS(ConnectApi.ProductOverviewCollection productOverviewCollectionObject)
    {
        system.debug('productOverviewCollectionObject=='+JSON.serialize(productOverviewCollectionObject));
        List<B2BProductVO> lstB2BProducts = new List<B2BProductVO>();
        if(productOverviewCollectionObject!=null && productOverviewCollectionObject.products!=null
                && productOverviewCollectionObject.products.size()>0)
        {
            for (ConnectApi.ProductOverview productOverviewObject : productOverviewCollectionObject.products)
            {
                if(productOverviewObject.success)
                {
                    Map<String, String> mapProductFieldValues = productOverviewObject.fields;
                    B2BProductVO B2BProductVO = new B2BProductVO();
                    B2BProductVO.productId = productOverviewObject.id;
                    B2BProductVO.productName = productOverviewObject.fields.get(Product2.fields.Name + '');
                    B2BProductVO.productCode = productOverviewObject.fields.get(Product2.fields.ProductCode + ''); //productOverviewObject.sku ;
                    B2BProductVO.productShortDescription = productOverviewObject.fields.get(Product2.fields.Description + '');
                    B2BProductVO.quantityOfMeasure = productOverviewObject.fields.get(Product2.fields.QuantityUnitOfMeasure + '');

                    List<User> lstUsers = [SELECT Contact.Account.CurrencyIsoCode FROM User WHERE Id = :UserInfo.getUserId() WITH SYSTEM_MODE ];
                    if(lstUsers!=null && lstUsers.size()>0)
                    {
                        if(lstUsers[0].Contact!=null)
                        {
                            B2BProductVO.currencyIsoCode = lstUsers[0].Contact.Account.CurrencyIsoCode;
                        }
                    }

                    if( productOverviewObject.fields.get(Product2.fields.ProductClass + '') == B2BRecommendedProductsConstant.PRODUCT_VARIATION_PARENT)
                    {
                        B2BProductVO.variant = true;
                    }
                    if(productOverviewObject.defaultImage!=null)
                    {
                        ConnectApi.ProductMedia productMediaObject = productOverviewObject.defaultImage;
                        B2BProductVO.image = productMediaObject.url;
                    }
                    system.debug('calling PricingResultLineItem api with '+productOverviewObject.prices);
                    ConnectApi.PricingResultLineItem priceLineItemObject = productOverviewObject.prices;
                    
                    system.debug('priceLineItemObject.listPrice;=='+priceLineItemObject.listPrice);
                    B2BProductVO.listPrice = priceLineItemObject.listPrice;
                    B2BProductVO.unitPrice = priceLineItemObject.unitPrice;
                    lstB2BProducts.add(B2BProductVO);
                }
            }
        }
        system.debug('lstB2BProducts='+lstB2BProducts);
        return lstB2BProducts;
    }
}