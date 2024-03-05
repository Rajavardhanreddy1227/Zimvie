/**
 * @description       : 
 * @author            : asood@rafter.one
 * @group             : 
 * @last modified on  : 09-01-2023
 * @last modified by  : asood@rafter.one
**/
public class b2B_CustomAddressComponentController {
    /*public static final String FIELDS_PARAM = 'fields';
    public static final String NUMBER_OF_RECORDS_PARAM = 'numberOfRecords';
    public static final String RECORD_ID_PARAM = 'recordId';
    public static final String SOBJECT_API_NAME_PARAM = 'sobjectApiName';
    public static final String SOBJECT_LABEL_PARAM = 'sobjectLabel';
    public static final String SOBJECT_LABEL_PLURAL_PARAM = 'sobjectLabelPlural';
    public static final String PARENT_RELATIONSHIP_API_NAME_PARAM = 'parentRelationshipApiName';
    public static final String RELATED_FIELD_API_NAME_PARAM = 'relatedFieldApiName';
    public static final String SORTED_DIRECTION_PARAM = 'sortedDirection';
    public static final String SORTED_BY_PARAM = 'sortedBy';
    public static final String RECORDS_PARAM = 'records';
    public static final String ICON_NAME_PARAM = 'iconName';*/

    @AuraEnabled
    public static void removeFav(String addId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            Id conId = [Select ContactId from User where Id=:UserInfo.getUserId()].ContactId;

            if(conId == null){
                conId = '0038L00000B7kq4QAB';
            }

            delete [Select Id from Favorite_Address__c where Contact_Point_Address__c =: addId AND Contact__c=:conId];
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
    }
    
    @AuraEnabled
    public static void addFav(String addId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            Id conId = [Select ContactId from User where Id=:UserInfo.getUserId()].ContactId;

            if(conId == null){
                conId = '0038L00000B7kq4QAB';
            }
            Favorite_Address__c objFav = new Favorite_Address__c();
            objFav.Contact_Point_Address__c = addId;
            objFav.Contact__c = conId;
            insert objFav;
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
    }
    
    @AuraEnabled
    public static void addDefault(String addId){
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        try {
            Id conId = [Select ContactId from User where Id=:UserInfo.getUserId()].ContactId;

            if(conId == null){
                conId = '0038L00000B7kq4QAB';
            }
            
            List<Default_Address__c> lstDef = new List<Default_Address__c>();
            lstDef = [Select Id from Default_Address__c where Contact__c=:conId limit 1];

            Default_Address__c objDef;

            if(lstDef != null && lstDef.size() > 0){
                objDef = new Default_Address__c(Id=lstDef[0].Id);
            } else {
                objDef = new Default_Address__c();
            }

            objDef.Contact_Point_Address__c = addId;
            objDef.Contact__c = conId;
            upsert objDef;
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        
    }

    @AuraEnabled(cacheable=true)
    public static String fetchAddressRecords(String recordId) {
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        AddWrapper objWrap = new AddWrapper();
        try {
            Set<Id> setFavAdd = new Set<Id>();
        Set<Id> setDefAdd = new Set<Id>();
        Id conId = [Select ContactId from User where Id=:UserInfo.getUserId()].ContactId;
        
        if(conId == null){
            conId = '0038L00000B7kq4QAB';
        }
        if(recordId == null){
            recordId = '0018L00000GssWnQAJ';
        }
        
        for(Favorite_Address__c objFavAdd : [Select Id,Contact_Point_Address__c,Contact__c from Favorite_Address__c where Contact__c =:conId ]){
            setFavAdd.add(objFavAdd.Contact_Point_Address__c);
        }
        for(Default_Address__c objDefAdd : [Select Id,Contact_Point_Address__c,Contact__c from Default_Address__c where Contact__c =:conId ]){
            setDefAdd.add(objDefAdd.Contact_Point_Address__c);
        }

        system.debug('setFavAdd='+setFavAdd);
        system.debug('setDefAdd='+setDefAdd);


        
        List<ContactPointAddress> lstAdd = new List<ContactPointAddress>();
        lstAdd = [SELECT Id,Name, CreatedById,AddressType,Street,City,State,StateCode,PostalCode,Country,CountryCode FROM ContactPointAddress Where ParentId = : recordId AND AddressType = 'Shipping' AND (ActiveToDate > TODAY OR ActiveToDate = null)];

        System.debug('lstAdd='+lstAdd);
        List<ContactPointAddress> lstFavAdd = new List<ContactPointAddress>();
        List<ContactPointAddress> lstNonFavAdd = new List<ContactPointAddress>();

        for(ContactPointAddress objAddress : lstAdd){
            if(setFavAdd.contains(objAddress.Id) && setDefAdd.contains(objAddress.Id)){
                objAddress.isDefault = true;
                lstFavAdd.add(objAddress);
            }
        }

        system.debug('lstFavAdd='+lstFavAdd);

        for(ContactPointAddress objAddress : lstAdd){
            if(setFavAdd.contains(objAddress.Id) && !setDefAdd.contains(objAddress.Id)){
                objAddress.isDefault = false;
                lstFavAdd.add(objAddress);
            }
        }

        system.debug('lstFavAdd='+lstFavAdd);
        
        for(ContactPointAddress objAddress :  lstAdd){
            if(!setFavAdd.contains(objAddress.Id) && setDefAdd.contains(objAddress.Id)){
                objAddress.isDefault = true;
                lstNonFavAdd.add(objAddress);
            }
        }

        system.debug('lstNonFavAdd='+lstNonFavAdd);

        for(ContactPointAddress objAddress :  lstAdd){
            if(!setFavAdd.contains(objAddress.Id) && !setDefAdd.contains(objAddress.Id)){
                objAddress.isDefault = false;
                lstNonFavAdd.add(objAddress);
            }
        }

        system.debug('lstNonFavAdd='+lstNonFavAdd);

       
        objWrap.lstFavAdd = lstFavAdd;
        objWrap.lstDefAdd = lstNonFavAdd;
        
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return JSON.serialize(objWrap);
    }

    @AuraEnabled
    public static String fetchCheckoutAddressRecords(String recordId, String cartId) {
        final DCM_Logger logger = DCM_Logger.getInstance(B2B_SetupConstants.PAYMENT_TERM);
        AddWrapper objWrap = new AddWrapper();
        try {
            Set<Id> setFavAdd = new Set<Id>();
            Set<Id> setDefAdd = new Set<Id>();
            Id conId = [Select ContactId from User where Id=:UserInfo.getUserId()].ContactId;
            
            if(cartId != null){
                //CartDeliveryGroup cartDeliveryGroup = [SELECT Id, DeliverToStreet, DeliverToName, DeliverToCity, IsDefault, DeliverToState, CartId FROM CartDeliveryGroup where CartId =: cartId];
                WebCart cartObj = [SELECT Id, Selected_Contact_Point_Address__c FROM WebCart WHERE Id = :cartId LIMIT 1];
                if(cartObj != null && String.isNotBlank(cartObj.Selected_Contact_Point_Address__c) ){
                    objWrap.selectedAddressId = cartObj.Selected_Contact_Point_Address__c;
                }
            }

            if(conId == null){
                conId = '0038L00000B7kq4QAB';
            }
            if(recordId == null){
                recordId = '0018L00000GssWnQAJ';
            }
            
            for(Favorite_Address__c objFavAdd : [Select Id,Contact_Point_Address__c,Contact__c from Favorite_Address__c where Contact__c =:conId ]){
                setFavAdd.add(objFavAdd.Contact_Point_Address__c);
            }
            for(Default_Address__c objDefAdd : [Select Id,Contact_Point_Address__c,Contact__c from Default_Address__c where Contact__c =:conId ]){
                setDefAdd.add(objDefAdd.Contact_Point_Address__c);
            }

            system.debug('setFavAdd='+setFavAdd);
            system.debug('setDefAdd='+setDefAdd);


        
            List<ContactPointAddress> lstAdd = [SELECT Id,Name, ORAAddressId__c,CreatedById,AddressType,Street,City,State,StateCode,PostalCode,Country,CountryCode FROM ContactPointAddress Where ParentId = : recordId AND AddressType = 'Shipping' AND (ActiveToDate > TODAY OR ActiveToDate = null)];

            System.debug('lstAdd='+lstAdd);
            List<ContactPointAddress> lstFavAdd = new List<ContactPointAddress>();
            List<ContactPointAddress> lstNonFavAdd = new List<ContactPointAddress>();

            for(ContactPointAddress objAddress : lstAdd){
                if(setFavAdd.contains(objAddress.Id) && setDefAdd.contains(objAddress.Id)){
                    objAddress.isDefault = true;
                    lstFavAdd.add(objAddress);
                }
            }

            system.debug('lstFavAdd='+lstFavAdd);

            for(ContactPointAddress objAddress : lstAdd){
                if(setFavAdd.contains(objAddress.Id) && !setDefAdd.contains(objAddress.Id)){
                    objAddress.isDefault = false;
                    lstFavAdd.add(objAddress);
                }
            }

            system.debug('lstFavAdd='+lstFavAdd);
            
            for(ContactPointAddress objAddress :  lstAdd){
                if(!setFavAdd.contains(objAddress.Id) && setDefAdd.contains(objAddress.Id)){
                    objAddress.isDefault = true;
                    lstNonFavAdd.add(objAddress);
                }
            }

            system.debug('lstNonFavAdd='+lstNonFavAdd);

            for(ContactPointAddress objAddress :  lstAdd){
                if(!setFavAdd.contains(objAddress.Id) && !setDefAdd.contains(objAddress.Id)){
                    objAddress.isDefault = false;
                    lstNonFavAdd.add(objAddress);
                }
            }

            system.debug('lstNonFavAdd='+lstNonFavAdd);

        
            objWrap.lstFavAdd = lstFavAdd;
            objWrap.lstDefAdd = lstNonFavAdd;
        
        }
        catch(exception e){
            logger.error(e);
        }
        finally{
            logger.flush();
        }
        return JSON.serialize(objWrap);
    }


    public class AddWrapper {
        public List<ContactPointAddress> lstFavAdd;
        public List<ContactPointAddress> lstDefAdd;
        public String selectedAddressId;
    }
    

    /*@AuraEnabled
    public static String initData(String jsonData){
        system.debug(jsonData);
        Map<String, Object> requestMap = (Map<String, Object>)JSON.deserializeUntyped(jsonData);  
        Map<String, Object> responseMap = new Map<String, Object>();
        responseMap.put(RECORDS_PARAM, getRecords(jsonData));
        
        String sobjectApiName = (String)requestMap.get(SOBJECT_API_NAME_PARAM);
        responseMap.put(ICON_NAME_PARAM, getIconName(sobjectApiName));
        String recordId = (String)requestMap.get(RECORD_ID_PARAM);
        String relatedFieldApiName = (String)requestMap.get(RELATED_FIELD_API_NAME_PARAM);
        responseMap.put(PARENT_RELATIONSHIP_API_NAME_PARAM, getParentRelationshipName(recordId, sobjectApiName, relatedFieldApiName));

        Schema.SObjectType sobjectType = Schema.getGlobalDescribe().get(sobjectApiName);
        Schema.DescribeSObjectResult sobjectDescribe = sobjectType.getDescribe();
        responseMap.put(SOBJECT_LABEL_PARAM, sobjectDescribe.getLabel());
        responseMap.put(SOBJECT_LABEL_PLURAL_PARAM, sobjectDescribe.getLabelPlural());
        return JSON.serialize(responseMap);
    }
    
	@AuraEnabled
    public static List<Sobject> getRecords(String jsonData){
		Map<String, Object> root = (Map<String, Object>)JSON.deserializeUntyped(jsonData);  
        String fields = (String)root.get(FIELDS_PARAM);
		Integer numberOfRecords = (Integer)root.get(NUMBER_OF_RECORDS_PARAM);
        String recordId = (String)root.get(RECORD_ID_PARAM);
		String relatedFieldApiName = (String)root.get(RELATED_FIELD_API_NAME_PARAM);
		String sobjectApiName = (String)root.get(SOBJECT_API_NAME_PARAM);        
		String orderBy = (String)root.get(SORTED_BY_PARAM) + ' ' + (String)root.get(SORTED_DIRECTION_PARAM);        
        
        String query = 'Select '+fields+' From '+sobjectApiName+' WHERE ' +relatedFieldApiName+ '= :recordId ORDER BY ' +orderBy+' Limit :numberOfRecords';
        return Database.query(String.escapeSingleQuotes(query));
	}
        
    private static String getParentRelationshipName(Id recordId, String childSobjectApiName, String relatedFieldApiName){
        Schema.DescribeSObjectResult descrRes = recordId.getSObjectType().getDescribe();
        String name;
        for (Schema.ChildRelationship cr: descrRes.getChildRelationships()){ 
            if(cr.getChildSObject().getDescribe().getName() == childSobjectApiName
            && cr.getField().getDescribe().getName() == relatedFieldApiName){
          	 	name = cr.getRelationshipName();
                break;
            }
        }     
        return name;
    }      
    
    @AuraEnabled
    public static String getIconName(String sobjectApiName){
        String iconName;
        List<Schema.DescribeTabSetResult> tabSetDesc = Schema.DescribeTabs();
        List<Schema.DescribeTabResult> tabDesc = new List<Schema.DescribeTabResult>();
        List<Schema.DescribeIconResult> iconDesc = new List<Schema.DescribeIconResult>();

        for(Schema.DescribeTabSetResult tsr : tabSetDesc) { 
            tabDesc.addAll(tsr.getTabs()); 
        }

        for(Schema.DescribeTabResult tr : tabDesc) {
            if( sobjectApiName == tr.getSobjectName() ) {
                if( tr.isCustom() ) {
                    iconDesc.addAll(tr.getIcons());
                } else {
                    iconName = 'standard:' + sobjectApiName.toLowerCase();
                }
            }
        }
        for (Schema.DescribeIconResult ir : iconDesc) {
            if (ir.getContentType() == 'image/svg+xml'){
                iconName = 'custom:' + ir.getUrl().substringBetween('custom/','.svg').substringBefore('_');
                break;
            }
        }
        return iconName;
    }    */
    
}