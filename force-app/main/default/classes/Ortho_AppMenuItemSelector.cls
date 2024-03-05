public with sharing class Ortho_AppMenuItemSelector {
    public static List<String> fields = new List<String>{
        'ApplicationId',
        'Description',
        'IconUrl',
        'Id',
        'InfoUrl',
        'IsAccessible',
        'IsDeleted',
        'IsVisible',
        'Label',
        'LogoUrl',
        'MobileStartUrl',
        'Name',
        'SortOrder',
        'StartUrl',
        'Type' 
    };

    public static List<AppMenuItem> selectAppMenuItemsByName(Set<String> names){
        String query = String.format('SELECT {0} FROM AppMenuItem WHERE Name in: names', 
            new List<Object>{String.join(fields, ',')});
        return (List<AppMenuItem>) Database.query(query);
    } 
}