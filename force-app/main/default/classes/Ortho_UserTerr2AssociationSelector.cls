/**
 * @author Appirio 
 * @date 17 March, 2020
 * @description This is selector class for UserTerritory2Association Standard Object.
 */


public class Ortho_UserTerr2AssociationSelector {
    
    public static List<String> fields = new List<String>{
        'Id', 
    	'RoleInTerritory2',
        'Territory2Id',
        'UserId'
    };
        
    public static List<String> fieldsForUser = new List<String>{
        'Id', 
    	'Territory2Id'
    };
        
    
	/**
    * @description This method returns UserTerritory2Association filtered by TerritoryId(s)
    */
        
        
    public static List<UserTerritory2Association> selectUtaByTerrId(Set<Id> terrIdSet){
		        system.debug('terrIdset passed here-->' + terrIdSet);
        String query = String.format('SELECT {0} FROM UserTerritory2Association where Territory2Id IN :terrIdSet', 
                                     new List<Object>{String.join(fields, ',')});
                system.debug('query inside first method is-->' + query);
        return (List<UserTerritory2Association>) Database.query(query);
    }
    
    /**
    * @description This method returns UserTerritory2Association filtered by current logged in user.
    */
    
    public static List<UserTerritory2Association> selectUtaByUser(){
        string currentUserInfo = UserInfo.getUserId();
        String query = String.format('SELECT {0} FROM UserTerritory2Association where UserId = :currentUserInfo AND Territory2Id != NULL', 
                                     new List<Object>{String.join(fieldsForUser, ',')});
        
        return (List<UserTerritory2Association>) Database.query(query);
    }
    

}