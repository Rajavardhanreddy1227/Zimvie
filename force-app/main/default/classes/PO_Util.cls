/**
 * @author Manish Vashistha
 * @date 27 November, 2020
 * @description This class Purchase Order Utility Class
 */


public class PO_Util {
    
    public class UserTerritoryAssociation{
        public String userId;
        public String terrtoryId;
        public String role;
        public UserTerritoryAssociation(String userId, String terrtoryId, String role){
            this.userId = userId;
            this.terrtoryId = terrtoryId;
            this.role = role;
        }
        public UserTerritoryAssociation(Object obj){
            UserTerritory2Association sObj;
            User_Territory_Association__c cObj;
            if(obj instanceOf UserTerritory2Association){
                sObj = (UserTerritory2Association) obj;
                this.userId = sObj.UserId;
                this.terrtoryId = sObj.Territory2Id;
                this.role = sObj.RoleInTerritory2;
            }else if(obj instanceOf User_Territory_Association__c){
                cObj = (User_Territory_Association__c) obj;
                this.userId = cObj.User__c;
                this.terrtoryId = cObj.Territory__C;
                this.role = cObj.Role__C;
            }

        }
    }

    @future
    public static void recreatePOSharesForTerritory(List<String> tId) {
        // process each batch of records
        Set<Id> terrIdSet = new Set<Id>();
        
        for (Integer i=0; i<tId.size();i++) {
            terrIdSet.add(tId[i]);
        }
        
        if(!terrIdSet.isEmpty()){
            
            PO_Util.createPOSharesForTerritory(terrIdSet);            
        }
    }

    /**
    * @description Returns all the leaf territories of given territiries
    */
    public static Map<Id, List<UserTerritoryAssociation>> getUserTerritoryAssociations(Set<id> terrIdSet) {
        Map<Id, List<UserTerritoryAssociation>> terrUserMap = new Map<Id, List<UserTerritoryAssociation>>();

       List<UserTerritory2Association> utaList = Ortho_UserTerr2AssociationSelector.selectUtaByTerrId(terrIdSet);

       if (utaList != null) {
            for(UserTerritory2Association uta2 : utaList){
                if(!terrUserMap.containsKey(uta2.Territory2Id)){
                    terrUserMap.put(uta2.Territory2Id, new List<UserTerritoryAssociation>());
                }
                terrUserMap.get(uta2.Territory2Id).add(
                    new UserTerritoryAssociation(uta2.UserId, uta2.Territory2Id, uta2.RoleInTerritory2));
            }
        }

        /*List<User_Territory_Association__c> utaCustomList = Ortho_UserTerrAssociationSelector.selectUtaByTerrId(terrIdSet);

        for(User_Territory_Association__c uta : utaCustomList){
            if(!terrUserMap.containsKey(uta.Territory__C)){
                terrUserMap.put(uta.Territory__C, new List<UserTerritoryAssociation>());
            }
            terrUserMap.get(uta.Territory__C).add(
                new UserTerritoryAssociation(uta.User__c, uta.Territory__C, uta.Role__C));
        }*/

        return terrUserMap;
    }

    /**
    * @description (NOT Used) This method recreates Purchase Order Share Records. 
    * Alternate way - To make it more efficient...
    * Find the new PO Share Records which are not in Existing PO Share List
    */
    /*public static void recreatePOSharesFast() {
        // Find Territories where Users were added.
        Set<Id> terrIdSet = new Set<Id>();
        List<UserTerritory2Association> lstUTA = [SELECT Territory2Id FROM UserTerritory2Association order by LastModifiedDate desc LIMIT 40];
        
        for (Integer i=0; i<lstUTA.size();i++) {
            terrIdSet.add(lstUTA[i].Territory2Id);
        }
        
        System.debug('Territory Set has '+terrIdSet.size()+ ' territories');
        
        // Find Territories where Users were removed. - TBD
        
        //Find Purchase Orders
        List<Purchase_Order__c> lstPOs = [Select Id, Name, Territory2_ID__c, OwnerId from Purchase_Order__c where IsDeleted = false and Territory2_ID__c in :terrIdSet];
        
        System.debug('There are '+lstPOs.size() + ' Purchase Orders in Specified Territories');
        
        //Find Purchase Order Share Records to delete
        map<String, Purchase_Order__Share> delPOShareList = new map<String, Purchase_Order__Share>();
        map<String, List<Purchase_Order__Share>> currPOShareList = new map<String, List<Purchase_Order__Share>>();
        map<String, List<String>> currPOUsers = new map<String, List<String>>();

        for(Purchase_Order__Share pos :[Select Id, ParentId, UserOrGroupId, AccessLevel from Purchase_Order__Share where ParentId IN :lstPOs
                          AND RowCause = 'Manual'])
        {
            delPOShareList.put(pos.Id,pos);

            if(currPOShareList.containsKey(pos.ParentId)){
                currPOShareList.get(pos.ParentId).add(pos);
            }
            
            else {
                currPOShareList.put(pos.ParentId, new Purchase_Order__Share[]{
                        pos
                });
            }

            if(currPOUsers.containsKey(pos.ParentId)){
                currPOUsers.get(pos.ParentId).add(pos.UserOrGroupId);
            }
            else {
                currPOUsers.put(pos.ParentId, new String[]{
                        pos.UserOrGroupId
                });
            }
        }
        
        //Find Territory Users
        Map<Id, List<UserTerritoryAssociation>> terrUserMap = PO_Util.getUserTerritoryAssociations(terrIdSet);
        
        List<Purchase_Order__Share> newPOShareList = new List<Purchase_Order__Share>();
        List<UserTerritoryAssociation> utaList = new List<UserTerritoryAssociation>();
        
        for(Purchase_Order__c po : lstPOs){
            utaList = terrUserMap.get((Id)po.Territory2_ID__c);
            
            for(UserTerritoryAssociation uta : utaList){
                if (uta.userId != po.ownerId ) {

                    if (currPOUsers.get(po.Id).contains(uta.userId))
                    {
                        //This user already exists - No Need to re-create or delete
                    }
                Purchase_Order__Share pos = new Purchase_Order__Share();
                pos.ParentId = po.Id;
                pos.RowCause = 'MANUAL';
                pos.UserOrGroupId = (String)uta.userId;
                pos.AccessLevel =  'Read';
                //System.debug(pos);
                newPOShareList.add(pos);
                }
            }
            
            System.debug('PO : '+po.Id + ' Name : '+ po.Name + ' Territory : '+ po.Territory2_ID__c+ ' will take total shares to '+newPOShareList.size());
        }

        if(!delPOShareList.isEmpty()) {
            System.debug('There are '+delPOShareList.size() +' share records to be deleted');
            delete delPOShareList.values();
        }

        if(!newPOShareList.isEmpty()){
            insert newPOShareList;
        }
        
    }
    */
    

    /**
    * @description This method recreates Share Records for Given Purchase Order List
    */
    public static void createPOSharesForPurchaseOrders(List<Purchase_Order__c> lstPOs) {        
        Set<Id> terrIdSet = new Set<Id>();        
        
        // Find Territories for POs
        for(Purchase_Order__c pos : lstPOs)
        {        
            if (pos.Territory2_ID__c != null)
            terrIdSet.add(pos.Territory2_ID__c);
        }
        System.debug('Territory Set has '+terrIdSet.size()+ ' territories');

        //Find Purchase Order Share Records to delete
        map<String, Purchase_Order__Share> delPOShareList = new map<String, Purchase_Order__Share>();
        
        for(Purchase_Order__Share pos :[Select Id, ParentId, UserOrGroupId, AccessLevel from Purchase_Order__Share where ParentId IN :lstPOs
                          AND RowCause = 'Manual'])
        {
            delPOShareList.put(pos.Id,pos);            
        }        

        try {
            if(!delPOShareList.isEmpty()) {
                System.debug('There are '+delPOShareList.size() +' share records to be deleted');
                //delete delPOShareList.values();
                Database.delete(delPOShareList.values(), false);
            }
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred during deletion of POShare: ' + e.getMessage());
        }
        
        //Find Territory Users
        Map<Id, List<UserTerritoryAssociation>> terrUserMap = PO_Util.getUserTerritoryAssociations(terrIdSet);
        
        List<Purchase_Order__Share> newPOShareList = new List<Purchase_Order__Share>();
        List<UserTerritoryAssociation> utaList = new List<UserTerritoryAssociation>();
        
        for(Purchase_Order__c po : lstPOs){
            utaList = terrUserMap.get((Id)po.Territory2_ID__c);
            
            if (utaList == null)
            System.debug('Territory user list came back as NULL for Territory Id : '+po.Territory2_ID__c);
            else {
                for(UserTerritoryAssociation uta : utaList){
                    if (uta.userId != po.ownerId ) {
                    Purchase_Order__Share pos = new Purchase_Order__Share();
                    pos.ParentId = po.Id;
                    pos.RowCause = 'MANUAL';
                    pos.UserOrGroupId = (String)uta.userId;
                    pos.AccessLevel =  'Read';
                    //System.debug(pos);
                    newPOShareList.add(pos);
                    }
                }
            }
            
            
            //System.debug('PO : '+po.Id + ' Name : '+ po.Name + ' Territory : '+ po.Territory2_ID__c+ ' will take total shares to '+newPOShareList.size());
        }

        if(!newPOShareList.isEmpty()){
            insert newPOShareList;
        }        
    }

    /**
    * @description This method recreates Purchase Order Share Records.
    */
    public static void createPOSharesForTerritory(Set<Id> terrIdSet) {        
        
        System.debug('Territory Set has '+terrIdSet.size()+ ' territories');
        
        //Find Purchase Orders
        List<Purchase_Order__c> lstPOs = [Select Id, Name, Territory2_ID__c, OwnerId from Purchase_Order__c where IsDeleted = false and Territory2_ID__c in :terrIdSet];
        
        System.debug('There are '+lstPOs.size() + ' Purchase Orders in Specified Territories');
        
        //Find Purchase Order Share Records to delete
        map<String, Purchase_Order__Share> delPOShareList = new map<String, Purchase_Order__Share>();
        
        for(Purchase_Order__Share pos :[Select Id, ParentId, UserOrGroupId, AccessLevel from Purchase_Order__Share where ParentId IN :lstPOs
                          AND RowCause = 'Manual'])
        {
            delPOShareList.put(pos.Id,pos);            
        }
        
        try {
            if(!delPOShareList.isEmpty()) {
                System.debug('There are '+delPOShareList.size() +' share records to be deleted');
                //delete delPOShareList.values();
                Database.delete(delPOShareList.values(), false);
            }
        }
        catch(DmlException e) {
            System.debug('The following exception has occurred during deletion of POShare: ' + e.getMessage());
        }
        
        
        //Find Territory Users
        Map<Id, List<UserTerritoryAssociation>> terrUserMap = PO_Util.getUserTerritoryAssociations(terrIdSet);
        
        List<Purchase_Order__Share> newPOShareList = new List<Purchase_Order__Share>();
        List<UserTerritoryAssociation> utaList = new List<UserTerritoryAssociation>();
        
        for(Purchase_Order__c po : lstPOs){
            utaList = terrUserMap.get((Id)po.Territory2_ID__c);
            if (utaList == null) {
                System.debug('Territory user list came back as NULL for Territory Id : '+po.Territory2_ID__c);
            }
            else {
                for(UserTerritoryAssociation uta : utaList) {
                    if (uta.userId != po.ownerId ) {
                    Purchase_Order__Share pos = new Purchase_Order__Share();
                    pos.ParentId = po.Id;
                    pos.RowCause = 'MANUAL';
                    pos.UserOrGroupId = (String)uta.userId;
                    pos.AccessLevel =  'Read';
                    newPOShareList.add(pos);
                    }
                }
            }
            
            //System.debug('PO : '+po.Id + ' Name : '+ po.Name + ' Territory : '+ po.Territory2_ID__c+ ' will take total shares to '+newPOShareList.size());
        }

        if(!newPOShareList.isEmpty()){
            insert newPOShareList;
        }        
    }   
}