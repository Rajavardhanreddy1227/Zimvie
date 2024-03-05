@isTest
public class Ortho_AppMenuItemSelectorTest {
    @isTest
    static public void testSelector(){
        
        Test.startTest();
        List<AppMenuItem> appMenuItems;
        try{
            appMenuItems = Ortho_AppMenuItemSelector.selectAppMenuItemsByName(new Set<String>{'Test'});
        }
        catch(Exception ex){
            System.assert(false, ex.getMessage());
        }

        System.assert(appMenuItems <> null, 'No App MenuItems returned');


        
        
        Test.stopTest();
        
    }
}