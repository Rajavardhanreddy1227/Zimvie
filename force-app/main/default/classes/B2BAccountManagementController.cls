public without sharing class B2BAccountManagementController {
    @AuraEnabled(cacheable=true)
    public static String fetchAddresses(String AccId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            return JSON.serialize([Select Id,Address,AddressType,IsDefault from ContactPointAddress where ParentId=:AccId]);
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }
     @AuraEnabled(cacheable=true)
    public static String fetchOrderDetails(String contactId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            return JSON.serialize([select Id,Status,OrderNumber, OrderedDate,Account.Name,CreatedBy.Name,CreatedById  from order where CreatedById=:contactId]);
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }
    @AuraEnabled(cacheable=true)
    public static String retrieveLoyalty(String accId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        loyaltyWrapper objLoyaltyWrap = new loyaltyWrapper();
        try {
            //String accId,Boolean isGuest,String otherParam
        //system.debug('accId='+accId);
        //system.debug('isGuest='+isGuest);
        //system.debug('otherParam='+otherParam);
        //if(isGuest == true){
        //    return null;
        //} 
        system.debug('accId='+accId);
        
        // return JSON.serialize([select Id,PointsBalance__c, Enrollment_Status__c, Status_Tier__c, Enrollment_Date__c, Expiration_Date__c from Account where Id='0018L00000GssWnQAJ']);
        List<Account> acc=[select Id,Name,PointsBalance__c, Enrollment_Status__c, Status_Tier__c,Customer_Number__c, Coordinator_Name__c,Email__c,Enrollment_Date__c, Expiration_Date__c from Account where Id=:accId]; 
        String userId = UserInfo.getUserId();
        User usr = [Select id,name,Contact.Name,ContactId,AccountId,Account.Name, Country from User where Id=:userId];
        
          
          objLoyaltyWrap.loyaltypoints = acc[0].PointsBalance__c;
          objLoyaltyWrap.enrollmentStatus =  acc[0].Enrollment_Status__c;
          objLoyaltyWrap.statusTier =  acc[0].Status_Tier__c;
          objLoyaltyWrap.loyaltyStartDate =  acc[0].Enrollment_Date__c;
          objLoyaltyWrap.loyaltyEndDate =  acc[0].Expiration_Date__c;
          objLoyaltyWrap.accountName = acc[0].Name;
          objLoyaltyWrap.customerNumber = acc[0].Customer_Number__c;
          objLoyaltyWrap.coordinatorName = acc[0].Coordinator_Name__c;
          objLoyaltyWrap.coordinatorEmail = acc[0].Email__c;
          objLoyaltyWrap.firstName = UserInfo.getFirstName();
          objLoyaltyWrap.lastName = UserInfo.getLastName();
          objLoyaltyWrap.email = UserInfo.getUserEmail();
          if(usr != null){
             objLoyaltyWrap.userCountry = usr.Country;
          }
 
          if(acc[0].Expiration_Date__c != null){
             Date todayDate = Date.today();
             Integer daysForExpiration = todayDate.daysBetween(acc[0].Expiration_Date__c);
             
             if((acc[0].Enrollment_Status__c == 'Active' || acc[0].Enrollment_Status__c == 'Expired' || acc[0].Enrollment_Status__c == 'Enrolled') && ((daysForExpiration<= 30 && daysForExpiration>=1) || (daysForExpiration <=0 && daysForExpiration >= -60))){
                 objLoyaltyWrap.loyaltyStatus = 'Renew';
             }else if((acc[0].Enrollment_Status__c == null || acc[0].Enrollment_Status__c == 'Inactive' || acc[0].Enrollment_Status__c == 'Expired') || (daysForExpiration < -60)){
                 objLoyaltyWrap.loyaltyStatus = 'Enroll';
             }else{
                 objLoyaltyWrap.loyaltyStatus = 'None';
             }
          }else{
             if((acc[0].Enrollment_Status__c == null || acc[0].Enrollment_Status__c == 'Inactive' || acc[0].Enrollment_Status__c == 'Expired')){
                 objLoyaltyWrap.loyaltyStatus = 'Enroll';
             }else{
                 objLoyaltyWrap.loyaltyStatus = 'None';
             }
             
          }
          
 
          
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return JSON.serialize(objLoyaltyWrap);
    }
    @AuraEnabled(cacheable=true)
    public static String retrieveWallet(String accId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            system.debug('accId='+accId);
        
        return JSON.serialize([Select Id,CardHolderName,CardLastFour,CardType,GatewayToken,ExpiryMonth,ExpiryYear from CardPaymentMethod where AccountId=:accId]);
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }
    public class loyaltyWrapper {
        public Double loyaltypoints;
        public String loyaltyName;
        public date loyaltyStartDate;
        public date loyaltyEndDate;
        public String enrollmentStatus;
        public String statusTier;
        public String loyaltyStatus;
        public String accountName;
        public String customerNumber;
        public String firstName;
        public String lastName;
        public String email;
        public String userCountry;
        public String coordinatorName;
        public String coordinatorEmail;
    }
    public static String getCartId(String communityId, String effectiveAccountId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
        String activeCartOrId = 'current';
        ConnectApi.CartSummary cartSum =  ConnectApi.CommerceCart.getOrCreateActiveCartSummary(
            webstoreId,
            effectiveAccountId,
            activeCartOrId
        );
        return cartSum.cartId;
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }
    
    @AuraEnabled
    public static Map<String,Object> updateLoyaltyOnCart(Map<String,Object> tempmapParams){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        Map<String,Object> mapParams = tempmapParams;
        try {
            if(mapParams.containsKey('coordinatorName') && String.isNotBlank(String.valueOf(mapParams.get('coordinatorName')))
        && mapParams.containsKey('coordinatorPhone') && String.isNotBlank(String.valueOf(mapParams.get('coordinatorPhone')))
        && mapParams.containsKey('coordinatorEmail') && String.isNotBlank(String.valueOf(mapParams.get('coordinatorEmail')))){
            String coordinatorName = String.valueOf(mapParams.get('coordinatorName'));
            String coordinatorPhone = String.valueOf(mapParams.get('coordinatorPhone'));
            String coordinatorEmail = String.valueOf(mapParams.get('coordinatorEmail'));
            String communityId = String.valueOf(mapParams.get('communityId'));
            String effectiveAccountId = String.valueOf(mapParams.get('effectiveAccountId'));
            String cartId = getCartId( communityId, effectiveAccountId);
            if(String.isNotBlank(cartId)){
                WebCart cartObj = [SELECT Id,AccountId FROM WebCart WHERE Id=:cartId];
                if(cartObj!=null){
                    cartObj.Coordinator_Name__c = coordinatorName;
                    cartObj.Contact_Number__c = coordinatorPhone;
                    cartObj.Email__c = coordinatorEmail;
                    update cartObj;
                }
                

                Account acc = [SELECT Id FROM Account WHERE Id=:cartObj.AccountId];
                if(acc!=null){
                    acc.Coordinator_Name__c = coordinatorName;
                    acc.Contact_Number__c = coordinatorPhone;
                    acc.Email__c = coordinatorEmail;
                    update acc;
                }
                

                mapParams.put('cart',cartObj);
                mapParams.put('isSuccess',true);
                mapParams.put('account',acc);
            } 
        }
        else{
            mapParams.put('isSuccess',false);
        }
        
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return mapParams;
    }

    @AuraEnabled
    public static  ConnectApi.ProductDetail getLoyaltyProduct(String sku,String communityId,String effectiveAccountId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        ConnectApi.ProductDetail result;
        try {
            String webstoreId = B2BUtils.resolveCommunityIdToWebstoreId(communityId);
            List<String> fields = new List<String>{'Id','Name','StockKeepingUnit','Description'};
            List<String> skus = new List<String>{sku};
            List<String> ids = new List<String>();
            //ConnectApi.ProductOverviewCollection result = ConnectApi.CommerceCatalog.getProducts(webstoreId,effectiveAccountId,ids,skus,fields,false,true);
            //System.debug('res>>'+JSON.serializePretty(result));
            Product2 loyaltyProduct = [Select id,name,StockKeepingUnit,Description From Product2 where StockKeepingUnit=:sku];
            result =  ConnectApi.CommerceCatalog.getProduct(webstoreId,loyaltyProduct.id,effectiveAccountId,fields,false,new List<String>(),false,false,false);
            
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return result;
    }
      @AuraEnabled(cacheable=true)
     public static String fetchConditions(String accId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            List<Boolean> lstResults = new List<Boolean>();
            lstResults.add([Select Id,Name,Customer_is_Consignments__c from Account where Id=:AccId].Customer_is_Consignments__c);
            lstResults.add([Select Id,Name,Is_Buyer_Manager__c from User where Id=:UserInfo.getUserId()].Is_Buyer_Manager__c);
            return JSON.serialize(lstResults);
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }
    
    /*@AuraEnabled(cacheable=true)
     public static String getLoggedInUserDetail(){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            return JSON.serialize([Select Id,Name,Is_Buyer_Manager__c from User where Id=:UserInfo.getUserId()]);
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return null;
    }*/

    @AuraEnabled(cacheable=true)
public static String retrieveRMAStatus(
    String accId,
    Integer pageSize,
    String pageToken,
    Boolean ownerScoped,
    Date startDateFilter,
    Date endDateFilter,
    String rmaTypeFilter,
    String statusFilter
) {
    System.debug(accId+'--'+pageSize+'--'+pageToken+'--'+ownerScoped+'--'+startDateFilter+'--'+endDateFilter+'--'+rmaTypeFilter+'--'+statusFilter);
    
    Map<String, Object> resultMap = new Map<String, Object>();
    
    Map<String, Object> bindVariables = new Map<String, Object>();

    List<RMAStatusWrapper> rmaStatusWrapList = new List<RMAStatusWrapper>();

    final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.RMA_STATUS);

    // Calculate the offset based on the pageToken and pageSize
    Integer offset = 0;
    System.debug('pageToken--'+pageToken);
    if (!String.isBlank(pageToken)) {
        offset = Integer.valueOf(pageToken);
    }
    System.debug('offset--'+offset);

    // Start building the SOQL query
    //accId = '0018L00000GssWnQAJ';
    System.debug(accId+'--'+pageSize+'---'+pageToken+'---'+ownerScoped+'---'+startDateFilter+'----'+endDateFilter+'----'+rmaTypeFilter+'-----'+statusFilter);

    // Create a base query string
    String baseQueryString = 'SELECT Id, Name, AccountId__c, RMA_TYPE__c, CreatedDate, Status__c FROM RMA__c WHERE AccountId__c = :accId';
    bindVariables.put('accId', accId);
    // Create a count query string to get the total number of records
    String countQueryString = 'SELECT COUNT() FROM RMA__c WHERE AccountId__c = :accId';

    // Apply Date filters if they are provided
    if (startDateFilter != null) {
        baseQueryString += ' AND CreatedDate >= :startDateFilter';
        countQueryString += ' AND CreatedDate >= :startDateFilter';
        bindVariables.put('startDateFilter', startDateFilter);
    }
    if (endDateFilter != null) {
        baseQueryString += ' AND CreatedDate <= :endDateFilter';
        countQueryString += ' AND CreatedDate <= :endDateFilter';
        bindVariables.put('endDateFilter', endDateFilter);
    }

    // Apply RMA_TYPE__c filter if provided
    if (String.isNotBlank(rmaTypeFilter) && !'--Select--'.equalsIgnoreCase(rmaTypeFilter)) {
        baseQueryString += ' AND RMA_TYPE__c = :rmaTypeFilter';
        countQueryString += ' AND RMA_TYPE__c = :rmaTypeFilter';
        bindVariables.put('rmaTypeFilter', rmaTypeFilter);
    }

    // Apply Status__c filter if provided
    if (String.isNotBlank(statusFilter) && !'--Select--'.equalsIgnoreCase(statusFilter)) {
        baseQueryString += ' AND Status__c = :statusFilter';
        countQueryString += ' AND Status__c = :statusFilter';
        bindVariables.put('statusFilter', statusFilter);
    }

    // Get the total count of records
    Integer totalCount = Database.countQuery(countQueryString);
    System.debug('totalCount:' + totalCount);
    // Calculate the previous and next tokens
    Integer prevToken = Math.max(0, offset - pageSize);
    Integer nextToken = (offset + pageSize < totalCount) ? offset + pageSize : null;
    // Check if this is the first page and disable the "Previous" button if needed
    if (offset == 0) {
        prevToken = null; // Disable the "Previous" button
    }
    System.debug('prevToken:' + prevToken);
    System.debug('nextToken:' + nextToken);
    // Create the final SOQL query with LIMIT and OFFSET
    String queryString = baseQueryString + ' ORDER BY Name DESC LIMIT :pageSize OFFSET :offset';

    try {
        System.debug('queryString:' + queryString);
        bindVariables.put('pageSize', pageSize);
        bindVariables.put('offset', offset);
        System.debug('bindVariables:' + bindVariables);
        List<RMA__c> rmaDetails = Database.queryWithBinds(
            queryString,
            bindVariables,
            AccessLevel.SYSTEM_MODE
        );
        
        System.debug('rmaDetails:' + rmaDetails);
        System.debug('rmaDetails size:' + rmaDetails.size());
        
        if (rmaDetails != null && rmaDetails.size() > 0) {
            for (RMA__c rmaObj : rmaDetails) {
                RMAStatusWrapper rmaStatusWrap = new RMAStatusWrapper();
                rmaStatusWrap.rmaName = rmaObj.Name;
                Date originalDate = Date.valueOf(rmaObj.CreatedDate);
                Datetime dateTimeOb = DateTime.newInstance(originalDate.year(), originalDate.month(), originalDate.day());
                String formattedDate = dateTimeOb.format('MMM dd, yyyy');
                rmaStatusWrap.createdDate = formattedDate;
                rmaStatusWrap.recordId = rmaObj.Id;
                rmaStatusWrap.rmaType = rmaObj.RMA_TYPE__c;
                rmaStatusWrap.rmaStatus = rmaObj.Status__c;
                rmaStatusWrapList.add(rmaStatusWrap);
            }
        }
    } catch (Exception e) {
        logger.error(e);
        System.debug('exception caught: ' + e);
    } finally {
        logger.flush();
    }


    System.debug('rmaStatusWrapList:' + rmaStatusWrapList);
    resultMap.put('rmaStatusWrapList', rmaStatusWrapList);
    resultMap.put('nextPageToken', (nextToken != null) ? String.valueOf(nextToken) : null);
    resultMap.put('previousPageToken', (prevToken != null) ? String.valueOf(prevToken) : null);
    resultMap.put('totalCount', totalCount);
    return JSON.serializePretty(resultMap);
}


    public class RMAStatusWrapper {
        public String rmaName{ get; set; }
        public String createdDate{ get; set; }
        public String rmaType{ get; set; }
        public String rmaStatus{ get; set; }
        public String recordId{ get; set; }
        public String recordLink{ get; set; }
    }

    
    @AuraEnabled(cacheable=true)
    public static List<RmaTypeItem> getRmaTypes() {
        List<RmaTypeItem> picklistValues = new List<RmaTypeItem>();
        
        Schema.DescribeFieldResult fieldResult = RMA__c.RMA_TYPE__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        picklistValues.add(new RmaTypeItem('--Select--', '--Select--'));
        for (Schema.PicklistEntry entry : picklistEntries) {
            RmaTypeItem item = new RmaTypeItem(entry.getLabel(), entry.getValue());
            picklistValues.add(item);
        }
        
        return picklistValues;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<RmaTypeItem> getRmaStatuses() {
        List<RmaTypeItem> picklistValues = new List<RmaTypeItem>();
        
        Schema.DescribeFieldResult fieldResult = RMA__c.Status__c.getDescribe();
        List<Schema.PicklistEntry> picklistEntries = fieldResult.getPicklistValues();
        picklistValues.add(new RmaTypeItem('--Select--', '--Select--'));
        for (Schema.PicklistEntry entry : picklistEntries) {
            RmaTypeItem item = new RmaTypeItem(entry.getLabel(), entry.getValue());
            picklistValues.add(item);
        }
        
        return picklistValues;
    }
    public class RmaTypeItem {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String value { get; set; }
        
        public RmaTypeItem(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }
    
          @AuraEnabled(cacheable=true)
    public static Map<String, Object> getOrderSummariesForAccount(String accountId) {
    
        Map<String, Object> responseMap = new Map<String, Object>();

        List<OrderSummary> objOrderSummaries  = [SELECT Id, OriginalOrderId, GrandTotalAmount, PoNumber, Order_Source__c, 
                                        OracleOrderId__c, Order_Number__c,CreatedById,CurrencyIsoCode,OwnerId,
                                        TotalProductAdjDistAmtWithTax, TotalAdjustedProductTaxAmount,OrderedDate,
                                        TotalAdjustedDeliveryAmount, TotalDeliveryAdjDistAmtWithTax,Status, 
                                        TotalAdjustedDeliveryTaxAmount
                                        FROM OrderSummary WHERE AccountId =: accountId order by OrderedDate desc NULLS LAST];
    
        responseMap.put('orderSummaries', objOrderSummaries);

        return responseMap;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getRMAStatusDetail(String recordId) {
        
        Map<String, Object> responseMap = new Map<String, Object>();
        
        List<RMA__c> rmaRecordList = [SELECT Id, Name, CurrencyIsoCode, CreatedDate, RMA_TYPE__c, Raised_By__r.Name, Status__c, Cancellation_Reason__c, RMA_Number__c, Ship_To_Address__c, RMA_Order_Type__c, RMA_Total_Including_Tax__c FROM RMA__c where Id=:recordId];
        System.debug('rmaRecordList---'+rmaRecordList);
        if(rmaRecordList!=null && rmaRecordList.size()>0){
            RMA__c rmaRecord = rmaRecordList.get(0);
            System.debug('rmaRecord---'+rmaRecord);
            RMAStatusDetailWrapper rmaStatusDetailWrapperObj =new RMAStatusDetailWrapper();
            rmaStatusDetailWrapperObj.rmaName = rmaRecord.Name;
            rmaStatusDetailWrapperObj.rmaType = rmaRecord.RMA_TYPE__c;
            rmaStatusDetailWrapperObj.rmaStatus = rmaRecord.Status__c;
            rmaStatusDetailWrapperObj.raisedBy = rmaRecord.Raised_By__r.Name;
            rmaStatusDetailWrapperObj.currencyISOCode = rmaRecord.CurrencyIsoCode;
            rmaStatusDetailWrapperObj.cancellationReason = rmaRecord.Cancellation_Reason__c;
            rmaStatusDetailWrapperObj.rmaNumber = rmaRecord.RMA_Number__c;
            rmaStatusDetailWrapperObj.shipToAddress = rmaRecord.Ship_To_Address__c;
            rmaStatusDetailWrapperObj.rmaOrderType = rmaRecord.RMA_Order_Type__c;
            rmaStatusDetailWrapperObj.rmaTotalIncludingTax = rmaRecord.RMA_Total_Including_Tax__c;
            Date originalDate = Date.valueOf(rmaRecord.CreatedDate);
            Datetime dateTimeOb = DateTime.newInstance(originalDate.year(), originalDate.month(), originalDate.day());
            String formattedDate = dateTimeOb.format('MMM dd, yyyy');
            rmaStatusDetailWrapperObj.createdDate = formattedDate;
            responseMap.put('RMAStatusDetailRecord', rmaStatusDetailWrapperObj);
            System.debug('1 responseMap:'+responseMap);
        }else{
            responseMap.put('RMSStatusDetailRecord', null);
        }
        
        responseMap.put('BaseURL', getCommunityURL());
        System.debug('responseMap:'+responseMap);
        return responseMap;
    }
    public class RMAStatusDetailWrapper {
        @AuraEnabled
        public String rmaName{ get; set; }
        @AuraEnabled
        public String createdDate{ get; set; }
        @AuraEnabled
        public String rmaType{ get; set; }
        @AuraEnabled
        public String rmaStatus{ get; set; }
        @AuraEnabled
        public String raisedBy{ get; set; }
        @AuraEnabled
        public String currencyISOCode{ get; set; }
        @AuraEnabled
        public String cancellationReason{ get; set; }
        @AuraEnabled
        public String rmaNumber{ get; set; }
        @AuraEnabled
        public String shipToAddress{ get; set; }
        @AuraEnabled
        public String rmaOrderType{ get; set; }
        @AuraEnabled
        public Decimal rmaTotalIncludingTax{ get; set; }
    }   
    private static String getCommunityURL(){       
        String base = Network.getLoginUrl(Network.getNetworkId());
        if(String.isNotBlank(base))
            base = base.replace('/login', '');
        return base;
    } 
}