/**
 * @author Appirio 
 * @date 17 March, 2020
 * @description This is selector class for User_Territory_Association__c custom Object.
 */


public class Ortho_UserTerrAssociationSelector {
    
    public static List<String> customFields = new List<String>{
        'Id', 
    	'Territory__C',
        'User__c',
        'Role__C'
    };
    
    /**
    * @description This method returns User_Territory_Association__c filtered by Territory__c
    */    
        
    public static List<User_Territory_Association__c> selectUtaByTerrId(Set<Id> terrIdSet){
        String query = String.format('SELECT {0} FROM User_Territory_Association__c WHERE Territory__C IN :terrIdSet', 
                                     new List<Object>{String.join(customFields, ',')});
        return (List<User_Territory_Association__c>) Database.query(query);
    }    


}