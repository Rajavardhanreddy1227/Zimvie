global class Ortho_ListviewSources extends VisualEditor.DynamicPickList{

    global static Set<sObjectType> listviewObjects = new Set<sObjectType>{
        Opportunity.sObjectType,
        Task.sObjectType
    };
    
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('Recent', 'Recent');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  listviewOptions = new VisualEditor.DynamicPickListRows();

        List<Listview> listViews = Ortho_ListviewSelector.selectListviewsBySObject(listviewObjects);

        for(Listview lv : listViews){
            listviewOptions.addRow(new VisualEditor.DataRow(lv.SobjectType + ' - ' + lv.Name, lv.sObjectType +';'+ lv.DeveloperName));
        }
        return listviewOptions;
    }
}