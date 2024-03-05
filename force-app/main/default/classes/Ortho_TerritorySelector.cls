/**
 * @author Appirio
 * @date 17 March, 2020
 * @description This is selector class for Territory2 Standard Object.
 */


public class Ortho_TerritorySelector{

    public static List<String> fields = new List<String>{
        'Id',
    	'Name',
        'ParentTerritory2Id',
        'ParentTerritory2.ParentTerritory2Id',
        'ParentTerritory2.ParentTerritory2.ParentTerritory2.Name',
        'ParentTerritory2.ParentTerritory2.ParentTerritory2Id'
    };

    public static List<String> fieldset2 = new List<String>{
        'Id',
        'Name',
        'ParentTerritory2Id'
    };


    /**
    * @description This method returns Territories filtered by TerritoryId(s) and non-null parent values
    */
    public static List<Territory2> selectTerritoryById(Set<Id> territoryIds){
        String query = String.format('SELECT {0} FROM Territory2 WHERE Id IN: territoryIds AND ParentTerritory2Id != NULL AND ParentTerritory2.ParentTerritory2Id != NULL AND ParentTerritory2.ParentTerritory2.ParentTerritory2Id != NULL',
                                     new List<Object>{String.join(fields, ',')});
        return (List<Territory2>) Database.query(query);
    }


    /**
    * @description This method returns all Territories
    */

    public static List<Territory2> selectAllTerritories(){
        String query = String.format('SELECT {0} FROM Territory2',
                                     new List<Object>{String.join(fieldset2, ',')});
        return (List<Territory2>) Database.query(query);
    }

    /**
    * @description This method returns Territories filtered by TerritoryId(s)
    */

    public static List<Territory2> selectAllTerritoriesByTerrId(Set<Id> terrIdSet){
        String query = String.format('SELECT {0} FROM Territory2 WHERE Id IN :terrIdSet',
                                     new List<Object>{String.join(fieldset2, ',')});
        return (List<Territory2>) Database.query(query);
    }

}