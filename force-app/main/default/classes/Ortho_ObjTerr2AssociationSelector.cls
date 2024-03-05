/**
 * @author Appirio 
 * @date 17 March, 2020
 * @description This is selector class for ObjectTerritory2Association standard Object.
 */

public class Ortho_ObjTerr2AssociationSelector {
	public static List<String> fields = new List<String>{
        'ObjectId', 
    	'Territory2Id',
        'Territory2.Name'
    };
        
    /**
    * @description This method returns ObjectTerritory2Association filtered by AccountId(s) and non-null Territories
    */    
        
    public static List<ObjectTerritory2Association> selectObjectTerritory2AssociationById(Set<Id> AccountIds){
        String query = String.format('SELECT {0} from ObjectTerritory2Association where ObjectId IN :AccountIds and Territory2Id!=Null', 
                                     new List<Object>{String.join(fields, ',')});
        return (List<ObjectTerritory2Association>) Database.query(query);
    }
    
    /**
    * @description This method returns ObjectTerritory2Association filtered by AccountId(s) and user territories
    */
    
    public static List<ObjectTerritory2Association> selectOtaByObjAndTerrId(Set<Id> accIdSet,Set<Id> userTerritoryIdSet){
        String query = String.format('SELECT {0} FROM ObjectTerritory2Association WHERE ObjectId IN :accIdSet AND Territory2Id IN :userTerritoryIdSet', 
                                     new List<Object>{String.join(fields, ',')});
        return (List<ObjectTerritory2Association>) Database.query(query);
    } 
}