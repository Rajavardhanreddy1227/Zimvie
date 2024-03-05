public with sharing class B2B2C_Utils {
    private static Map<String,SObjectType> globalDescribe = Schema.getGlobalDescribe();
  // A cache which maps community Ids to WebStore Ids
  private static Map<String, String> communityIdToWebStoreIdCache = new Map<String, String>();

  // A cache to map a string to ConnectApi.CartItemSortOrder
  private static Map<String, ConnectApi.CartItemSortOrder> sortOrderCache = new Map<String, ConnectApi.CartItemSortOrder>();

  /**
   * @description Given a community ID, returns the relavent webstore ID for use in B2B Commerce on lightning
   * @param  communityId The Id of the community from which the call originated
   * @return weStoreId The webStoreId corresponding to the community Id.
   * @example
   * String webStoreId = B2BUtils.resolveCommunityIdToWebstoreId('0DB2D0000004Xz7');
   */
  @AuraEnabled(cacheable=true)
  public static String resolveCommunityIdToWebstoreId(String communityId) {
    if (communityIdToWebStoreIdCache.containsKey(communityId)) {
      return communityIdToWebStoreIdCache.get(communityId);
    } else {
      String webStoreId = [
        SELECT WebStoreId
        FROM WebStoreNetwork
        WHERE NetworkId = :communityId
        WITH SECURITY_ENFORCED
        LIMIT 1
      ]
      .WebStoreId;
      communityIdToWebStoreIdCache.put(communityId, webStoreId);
      return webStoreId;
    }
  }
    
  public static String getUserAccountID() { 
      return getAccountId(UserInfo.getUserId());
  }

  @AuraEnabled(cacheable=true)
  public static String getAccountId(String userId) {
      Id accountId;
      if(
          User.SObjectType.getDescribe().isAccessible() &&
          Schema.SObjectType.User.fields.ContactId.isAccessible()
      ) {
          accountId = [SELECT id, Contact.AccountId FROM User WHERE Id = :userId].Contact.AccountId;
          return accountId;
      } else {
          return null;
      }
  }

  //Check for empty or null
  public static Boolean isNullOrEmpty(Object obj) {
    return obj == null ||
        (obj instanceof String && String.isBlank((String) obj)) ||
        (obj instanceof Set<Object> && ((Set<Object>) obj).isEmpty()) ||
        (obj instanceof List<Object> && ((List<Object>) obj).isEmpty()) ||
        (obj instanceof Map<String, String> && ((Map<String, String>) obj).isEmpty()) ||
        (obj instanceof Map<Object, Object> && ((Map<Object, Object>) obj).isEmpty()) ||
        (obj instanceof Map<String, Object> && ((Map<String, Object>) obj).isEmpty());
  }

  //Check for NOT empty or null
  public static Boolean isNotNullOrEmpty(Object obj) {
    return !isNullOrEmpty(obj);
  }
  
}