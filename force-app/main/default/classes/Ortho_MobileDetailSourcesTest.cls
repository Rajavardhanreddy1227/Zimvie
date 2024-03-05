@isTest
public class Ortho_MobileDetailSourcesTest {
    
    @isTest
    static void testValues(){
        Test.startTest();
        VisualEditor.DesignTimePageContext c =new VisualEditor.DesignTimePageContext();
        c.entityName='Opportunity';
        Ortho_MobileDetailSources mds = new Ortho_MobileDetailSources(c);
        VisualEditor.DataRow dv = mds.getDefaultValue();
        VisualEditor.DynamicPickListRows drows = mds.getValues();
        List<VisualEditor.DataRow> allRows = drows.getDataRows();
 
        Test.stopTest();
        system.assertEquals('None', dv.getLabel());
        system.assertEquals('Ortho Mobile Fields', allRows.get(1).getLabel());
        
    }    
}