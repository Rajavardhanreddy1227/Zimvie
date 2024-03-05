/**
 * Created by junaidm on 10/11/21.
 */
/**
 * @description Util methods for B2B commerce on Lightning Samples
 *
 * @see B2BUtils
 */
public with sharing class B2BUtils {
     

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

  /**
   * @description Given a sortParam string, return null or the relavent ConnectApi.CartItemSortOrder enum value
   * See https://developer.salesforce.com/docs/atlas.en-us.apexcode.meta/apexcode/connectAPI_enums.htm#cartItemSortOrderEnum for the enum values
   * @param  sortParam A string representing a sort Param.
   * @return resolvedSortParam A ConnectApi.CartItemSortOrder enum value or null
   * @example
   * ConnectApi.CartItemSortOrder sortParam = B2BUtils.resolveSortParam('CreatedDateAsc');
   */
  public static ConnectApi.CartItemSortOrder resolveSortParam(
    String sortParam
  ) {
      if (sortOrderCache.isEmpty()) {
        for (
          ConnectApi.CartItemSortOrder sortOrder : ConnectApi.CartItemSortOrder.values()
        ) {
            sortOrderCache.put(sortOrder.name(), sortOrder);
          }
      }
      return sortOrderCache.get(sortParam);
  }
    
  public static String getUserAccountID() {
      String userId = UserInfo.getUserId();
      String contactId = [SELECT ContactId FROM User WHERE Id = :userId].ContactId;
      return [SELECT AccountId FROM Contact WHERE Id = :contactId].AccountId; 
  }
    
   /**
     * @description Given a community ID, returns the relavent webstore ID for use in B2B Commerce on lightning
     * @return weStoreId The webStoreId corresponding to the community Id.
     * @example
     * String webStoreId = B2BUtils.resolveCommunityIdToWebstoreId('0DB2D0000004Xz7');
     */
    public static String retrieveWebStoreIdByCommunityId() {
      String communityId = retrieveCommunityId();
      String webStoreId = null;
      System.debug('retrieveWebStoreIdByCommunityId:communityId:  '+communityId);
      if (communityIdToWebStoreIdCache.containsKey(communityId))
      {
          return communityIdToWebStoreIdCache.get(communityId);
      } 
      else 
      {
          List<WebStoreNetwork> lstWebStoreNetworks = [ SELECT WebStoreId FROM WebStoreNetwork WHERE NetworkId = :communityId];
          if(lstWebStoreNetworks!=null && lstWebStoreNetworks.size()>0)
          {
              webStoreId = lstWebStoreNetworks[0].WebStoreId;
              communityIdToWebStoreIdCache.put(communityId, webStoreId);
          }
          System.debug('retrieveWebStoreIdByCommunityId:webStoreId : '+webStoreId);
      }
      return webStoreId;
  }

  public static String retrieveCommunityId()
    {
        ConnectApi.CommunityPage communityPageObject = ConnectApi.Communities.getCommunities();
        String communityId = '';
        System.debug('communityPageObject:webStoreId : '+communityPageObject);
        for(ConnectApi.Community communityObj : communityPageObject.communities)
        {
          System.debug('communityObj.templateName:webStoreId : '+communityObj.templateName);
            if(communityObj.templateName == B2BConstants.COMMUNITY_TEMPLATE_NAME)
            {
                communityId = communityObj.id;
            }
        }
        return communityId;
    }
    
     @AuraEnabled
    public static List<B2B_Country_Config__mdt> fetchAllCountryConfigs(){
        return new List<B2B_Country_Config__mdt>([SELECT Id, DeveloperName,MasterLabel,Country_Code__c,Terms_Condition_URL__c FROM B2B_Country_Config__mdt]);
    }

    @Future
    public static void assignPermissionSet(Map<String, String> dataMap){
        String uId = null;
        if(dataMap != null && dataMap.containsKey('userId') && dataMap.get('userId') != null){
            uId = dataMap.get('userId');
        }

        //Permission Set Assignment
        List<PermissionSet> ps = [SELECT ID, Name FROM PermissionSet WHERE Name = 'B2B_Commerce_Buyer' ];

        if( ps.size()!=0 && uId != null){
            List<Id> psId = new List<Id>(new Map<Id,PermissionSet>(ps).keySet());

            //check if old user has permission set
            List<PermissionSetAssignment> existingPsetList = null;
            existingPsetList = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId IN :psId AND AssigneeId=:uId ];

            if((existingPsetList != null && existingPsetList.isEmpty() )){
                List<PermissionSetAssignment> psaList = new List<PermissionSetAssignment>();

                for(Id p : psId){
                  PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = p, AssigneeId = uId);
                  psaList.add(psa);
                }

                insert psaList;
            }

        }
    }
}