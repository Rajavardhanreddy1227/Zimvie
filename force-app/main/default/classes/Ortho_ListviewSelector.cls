public with sharing class Ortho_ListviewSelector {
    public static List<String> fields = new List<String>{
        'Name',
        'DeveloperName',
        'IsSoqlCompatible',
        'LastReferencedDate',
        'LastViewedDate',
        'NamespacePrefix',
        'SobjectType'
    };

    public static List<Listview> selectListviewsBySObject(Set<Schema.SObjectType> sObjects){
        Set<String> sObjectNames = getNamesFromType(sObjects);
        String query = String.format('SELECT {0} FROM Listview WHERE SobjectType in: sObjectNames', 
            new List<Object>{
                String.join(fields, ',')
            }
        );
        System.debug(query);
        System.debug(sObjectNames);
        return (List<Listview>) Database.query(query);
    } 

    public static Set<String> getNamesFromType(Set<Schema.SObjectType> sObjects){
        Set<String> sObjectNames = new Set<String>();
        for(Schema.SObjectType sobjType : sObjects){
            sObjectNames.add(sobjType.getDescribe().getName());
        }

        return sObjectNames;
    }
}