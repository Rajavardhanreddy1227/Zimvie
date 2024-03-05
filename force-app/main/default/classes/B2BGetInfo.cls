public without sharing class B2BGetInfo {
  @AuraEnabled(cacheable=true)
  public static ConnectApi.ProductDetail getProduct(
    String communityId,
    String productId,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId;
      if(!Test.isRunningTest()){
      webstoreId= B2BUtils.resolveCommunityIdToWebstoreId(communityId);
      }else{
      webstoreId = [Select id from WebStore Where Name = 'Zimvie'].id; 
      }
    List<String> lstFields = new List<String>();
    lstFields.add('StockKeepingUnit');
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCatalog_static_methods.htm#apex_ConnectAPI_CommerceCatalog_static_methods
    return ConnectApi.CommerceCatalog.getProduct(
      webstoreId,
      productId,
      effectiveAccountID,
      lstFields,
      false,
      null,
      false,
      true,
      false,
      false,
      false
    );
  }

  @AuraEnabled(cacheable=true)
  public static Boolean checkProductIsInStock(String productId) {
    Id accId = [Select Id,Contact.AccountId from User where Id=:UserInfo.getUserId()].Contact.AccountId;
    List<ContactPointAddress> lstCPA = new List<ContactPointAddress>();
    lstCPA = [Select Country from ContactPointAddress where ParentId=:accId AND AddressType='Billing' AND IsDefault=true];
    String cntryName;
    if(lstCPA != null && lstCPA.size() > 0){
      cntryName = lstCPA[0].Country;
    }
    String invRegion = cntryName == 'United States' || cntryName == 'Canada' || cntryName == 'US' ? 'North America' : (cntryName == 'Spain' || cntryName == 'France' || cntryName == 'Germany' ? 'Europe' : '');
    
    Boolean inStock = false;
    List<Store_Inventory__c> lstStoreInv = new List<Store_Inventory__c>();
    lstStoreInv = [Select Id,Quantity__c,Region__c,Status__c from Store_Inventory__c where Product__c =: productId AND Region__c=:invRegion order by createddate desc];

    if(lstStoreInv != null && lstStoreInv.size() > 0 && lstStoreInv[0].Quantity__c > 0){
      inStock = true;
    } else {
      inStock = false;
    }
    return inStock;
  }

  @AuraEnabled
  public static ConnectApi.CartSummary getCartSummary(
    String communityId,
    String effectiveAccountId
  ) {
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    //'current' is available in version 50.0 and later and indicates a cart with a status that isn’t Closed or PendingDelete
    //This is important for the product detail page since we are using the cart summary to check if the status is "Processing" or "Checkout"
    String activeCartOrId = 'current';

    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm
    return ConnectApi.CommerceCart.getCartSummary(
      webstoreId,
      '0018L00000GssWnQAJ',
      activeCartOrId
    );
  }

  @AuraEnabled
  public static ConnectApi.CartItem addToCart(
    String communityId,
    String productId,
    String quantity,
    String effectiveAccountId
  ) {

    effectiveAccountId = [Select Contact.AccountId from User where Id =: UserInfo.getUserId()].Contact.AccountId;
    system.debug('effectiveAccountId=='+effectiveAccountId);
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    ConnectApi.CartItemInput cartInput = new ConnectApi.CartItemInput();
    cartInput.productId = productId;
    cartInput.quantity = quantity;
    cartInput.type = ConnectApi.CartItemType.PRODUCT;
    system.debug('cartInput=='+cartInput);
    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceCart_static_methods.htm#apex_ConnectAPI_CommerceCart_static_methods
    return ConnectApi.CommerceCart.addItemToCart(
      webstoreId,
      effectiveAccountId,
      'active',
      cartInput
    );
  }

  @AuraEnabled
  public static ConnectApi.Wishlist createAndAddToList(
    String communityId,
    String productId,
    String wishlistName,
    String effectiveAccountId
  ) {
    effectiveAccountId = [Select Contact.AccountId from User where Id =: UserInfo.getUserId()].Contact.AccountId;
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    // Store the product in a WishlistItemInput to pass to the Wishlist
    ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
    wishlistItemInput.productId = productId;

    //Create a wishlistInput to be created
    ConnectApi.WishlistInput wishlistInput = new ConnectApi.WishlistInput();
    wishlistInput.name = wishlistName;
    wishlistInput.products = new List<ConnectApi.WishlistItemInput>{
      wishlistItemInput
    };

    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceWishlist_static_methods.htm#apex_ConnectAPI_CommerceWishlist_static_methods
    return ConnectApi.CommerceWishlist.createWishlist(
      webstoreId,
      effectiveAccountId,
      wishlistInput
    );
  }

  @AuraEnabled(cacheable=true)
  public static ConnectApi.ProductPrice getProductPrice(
    String communityId,
    String productId,
    String effectiveAccountId
  ) {
    
    Id accId = [Select Id,Contact.AccountId from User where Id=:UserInfo.getUserId()].Contact.AccountId;
    effectiveAccountId = accId;
    system.debug('effectiveAccountId in price fetch method=='+effectiveAccountId);
    // Lookup the webstore ID associated with the community
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);

    // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceStorePricing_static_methods.htm#apex_ConnectAPI_CommerceStorePricing_static_methods
    return  ConnectApi.CommerceStorePricing.getProductPrice(
      webstoreId,
      productId,
      effectiveAccountId
    );
  }

  @AuraEnabled
  public static String fetchProductsFromApex(List<Id> records,String communityId){
    String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
    Id accId = [Select Id,Contact.AccountId from User where Id=:UserInfo.getUserId()].Contact.AccountId;
    List<ContactPointAddress> lstCPA = new List<ContactPointAddress>();
    lstCPA = [Select Country from ContactPointAddress where ParentId=:accId AND AddressType='Billing' AND IsDefault=true];
    String cntryName;
    if(lstCPA != null && lstCPA.size() > 0){
      cntryName = lstCPA[0].Country;
    }
    String invRegion = cntryName == 'United States' || cntryName == 'Canada' ? 'North America' : (cntryName == 'Spain' || cntryName == 'France' || cntryName == 'Germany' ? 'Europe' : '');
    List<variantProductStockWrapper> lstWrap = new List<variantProductStockWrapper>();
    List<Store_Inventory__c> lstStoreInv = new List<Store_Inventory__c>();
    lstStoreInv = [Select Id,Product__c,Quantity__c,Region__c,Status__c from Store_Inventory__c where Product__c IN: records AND Region__c =: invRegion];
    Map<Id,Boolean> invMap = new Map<Id,Boolean>();
    for(Store_Inventory__c objInv : lstStoreInv){
      invMap.put(objInv.Product__c,objInv.Quantity__c > 0);
    }

    ConnectApi.PricingInput pricingInput = new ConnectApi.PricingInput();
    List<ConnectApi.PricingLineItemInput> pricingLineItemInputs = new List<ConnectApi.PricingLineItemInput>();
    for(String id : records){
      ConnectApi.PricingLineItemInput pricingLineItemInput = new ConnectApi.PricingLineItemInput();
      pricingLineItemInput.productId = id;
      pricingLineItemInputs.add(pricingLineItemInput);
    }
    pricingInput.pricingLineItems = pricingLineItemInputs;
    ConnectApi.PricingResult pricingResult = Test.isRunningTest() ? null : ConnectApi.CommerceStorePricing.getProductPrices(webstoreId,accId,pricingInput);
    
    for(Product2 objProd  :[Select Id,StockKeepingUnit from Product2 where Id IN:records]){
      variantProductStockWrapper objWrap = new variantProductStockWrapper();
      if(pricingResult != null && pricingResult.pricingLineItemResults != null && pricingResult.pricingLineItemResults.size() != 0){
        objWrap.currencyCode = pricingResult.currencyIsoCode;
        for(ConnectApi.PricingResultLineItem result : pricingResult.pricingLineItemResults){
          if(result.productId == objProd.Id){
            objWrap.unitPrice = result.unitPrice;
          }
        }
      }
      objWrap.prodId = objProd.Id;
      objWrap.StockKeepingUnit = objProd.StockKeepingUnit;
      objWrap.InStock = invMap != null && invMap.size() > 0 && invMap.keyset().contains(objProd.Id) ? invMap.get(objProd.Id) : false;
      lstWrap.add(objWrap);
    }
    return JSON.serialize(lstWrap);
  }

  public class variantProductStockWrapper{
    public Id prodId;
    public String StockKeepingUnit;
    public Boolean InStock;
    public String unitPrice;
    public String currencyCode;
  }



  /****************************************************
   * ****************************************************
   * ****************************************************
   * ****************************************************
   * WISH LIST METHODS START
   * ****************************************************
   * ****************************************************
   * ****************************************************
   * **************************************************/


   @AuraEnabled
   public static List<Wishlist> fetchWishlists(String accId){
    try {
      system.debug('accId=='+accId);
      String storeId = [Select Id from Webstore where Name = 'ZimVie'].Id;
      return [Select Id,Name,WishlistProductCount,CreatedDate from Wishlist where AccountId=:accId AND webstoreId=:storeId Order By CreatedDate Desc];
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
   }
   @AuraEnabled
   public static void createWishlist(String Name,String accId,String storeId){
    try {
      storeId = [Select Id from Webstore where Name = 'ZimVie'].Id;
      wishlist obj = new wishlist();
      obj.Name = Name;
      obj.AccountId = accId;
      obj.WebstoreId = storeId;
      insert obj;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
   }
   @AuraEnabled
   public static void deleteWishlist(String wishlistId){
    try {
      Wishlist objWl = new Wishlist(Id=wishlistId);
      delete objWl;
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
   }
   @AuraEnabled
   public static void addItemToWishlist(String wishlistId,String accId,String storeId,String prodId){
    try {
      storeId = [Select Id from Webstore where Name = 'ZimVie'].Id;
      // Store the product in a WishlistItemInput to pass to the Wishlist
      ConnectApi.WishlistItemInput wishlistItemInput = new ConnectApi.WishlistItemInput();
      wishlistItemInput.productId = prodId;

      // https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/apex_ConnectAPI_CommerceWishlist_static_methods.htm#apex_ConnectAPI_CommerceWishlist_static_methods
      ConnectApi.CommerceWishlist.addItemToWishlist(
        storeId,
        accId,
        wishlistId,
        wishlistItemInput
      );
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
   }
   @AuraEnabled
   public static string fetchWishlistSummary(Integer pageSize,String pageParam,String accId,String wishlistId){
    try {
      if(wishlistId == null){
        return null;
      }
      String storeId = [Select Id from Webstore where Name = 'ZimVie'].Id;
      return JSON.serialize(ConnectApi.CommerceWishlist.getWishlistItems(storeId, accId, wishlistId, 'Name,ProductCode,Description', pageParam, pageSize,null));      
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
   }
   @AuraEnabled
   public static void removeItem(String accId,String wishlistId,String itemId){
    try {
      String storeId = [Select Id from Webstore where Name = 'ZimVie'].Id;
      ConnectApi.CommerceWishlist.removeWishlistItem(storeId, accId, wishlistId, itemId);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
   }
   @AuraEnabled
   public static void updateWishlist(String wishlistId,String newName){
    try {
      String storeId = [Select Id from Webstore where Name = 'ZimVie'].Id;
      ConnectApi.WishlistUpdateInput wishlistItemInput = new ConnectApi.WishlistUpdateInput();
      wishlistItemInput.name = newName;

      ConnectApi.CommerceWishlist.updateWishlist(storeId, wishlistId, wishlistItemInput);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
   }
   @AuraEnabled
   public static void addWishlistToCart(String wishlistId,String accId){
    try {
      String storeId = [Select Id from Webstore where Name = 'ZimVie'].Id;
      ConnectApi.CommerceWishlist.addWishlistToCart(storeId, wishlistId, accId);
    } catch (Exception e) {
      throw new AuraHandledException(e.getMessage());
    }
   }

   //added new
   @AuraEnabled
  public static Map<Id, CartItemWrapper> getCartItemsByCartId(String cartId) {
    List<CartItem> cartItemList;
    Map<Id, CartItemWrapper> result = new Map<Id, CartItemWrapper>();
    try {
      cartItemList = [
        SELECT Id, 
        /*Discount__c,*/ 
        TotalPrice,
        Product2Id,
        Product2.Description/*, 
        B2B_PriceBookEntry_Id__c,
        ProductSellingModel__c */
        FROM CartItem 
        WHERE CartId = :cartId 
        ];

      for(CartItem item : cartItemList) {
        CartItemWrapper resultItem = new CartItemWrapper();
        resultItem.Id = item.Id;
        //resultItem.discount = item.Discount__c;
        resultItem.TotalPrice = item.TotalPrice;
        resultItem.productDescription = item.Product2Id != null ? item.Product2.Description : null;
        //resultItem.priceBookEntryId = item.B2B_PriceBookEntry_Id__c;
        //resultItem.productSellingModel = item.ProductSellingModel__c;

        result.put(item.Id, resultItem);
      }

    } catch (Exception ex) {/*logger.error(ex);*/throw new AuraHandledException(ex.getMessage());
    } finally {
      //logger.flush();
    }

    // return cartItemMap;
    return result;
  }

  @AuraEnabled
  public static CartItem updateCartItems(
    String communityId,
    String effectiveAccountId,
    String cartItemId,
    String quantity
  ) {
    try { 
      String webstoreId;
      if(!Test.isRunningTest()){
        // Lookup the webstore ID associated with the community
        webstoreId = [SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId WITH SECURITY_ENFORCED LIMIT 1].WebStoreId;
      }
      List<CartItem> cartIt = [SELECT Id, Quantity, ListPrice, TotalLineAmount, TotalListPrice, TotalPrice, Product2Id FROM CartItem WHERE Id = :cartItemId WITH SECURITY_ENFORCED LIMIT 1];
      if(cartIt.size() != 0){}
        cartIt[0].quantity = Double.valueOf(quantity);
        cartIt[0].TotalLineAmount = Double.valueOf(quantity) * cartIt[0].ListPrice;
        cartIt[0].TotalListPrice = Double.valueOf(quantity) * cartIt[0].ListPrice;
        cartIt[0].TotalPrice = Double.valueOf(quantity) * cartIt[0].ListPrice;
        //DMLManager.updateAsUser(cartIt[0]);
        return cartIt[0];
    } catch (Exception ex) {
        //logger.error(ex);
        return null;
    } finally {
        //logger.flush();
    }
  }

  public class CartItemWrapper {
    @AuraEnabled
    public String Id {get;set;}
    @AuraEnabled
    public Decimal discount {get;set;}
    @AuraEnabled
    public Decimal TotalPrice {get;set;}
    @AuraEnabled
    public String productDescription {get;set;}
    @AuraEnabled
    public String priceBookEntryId {get;set;}
    @AuraEnabled
    public String productSellingModel {get;set;}
}
}