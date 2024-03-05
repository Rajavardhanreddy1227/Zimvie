global class Ortho_MobileDetailSources extends VisualEditor.DynamicPickList{
    VisualEditor.DesignTimePageContext context;

    global Ortho_MobileDetailSources(VisualEditor.DesignTimePageContext context) {
        this.context = context;
    }
    global override VisualEditor.DataRow getDefaultValue(){
        VisualEditor.DataRow defaultValue = new VisualEditor.DataRow('None', 'None');
        return defaultValue;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows  fieldSetOptions = new VisualEditor.DynamicPickListRows();
                
        String[] types = new String[]{context.entityName};

        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(types);
        if(results.size() > 0){
            Schema.DescribeSobjectResult descr = results.get(0);
			
           Map<String, FieldSet> fieldsetMap =  descr.fieldsets.getMap();
			
           for(String key : fieldsetMap.keySet()){
               FieldSet fs = fieldsetMap.get(key);
               fieldSetOptions.addRow(new VisualEditor.DataRow(fs.getLabel(), fs.getName()));
           }
        }

        return fieldSetOptions;
        
    }
}