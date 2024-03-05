global class Ortho_ChartSources extends VisualEditor.DynamicPickList {
    private static List<Type> sources = new List<Type> {
        // Ortho_ChartDataYOYPerformance.class,
        Ortho_ChartDataYOYTable.class,
        Ortho_ChartDataP2T.class
    };

    global override VisualEditor.DataRow getDefaultValue(){
        return null;
    }
    global override VisualEditor.DynamicPickListRows getValues() {
        VisualEditor.DynamicPickListRows myValues = new VisualEditor.DynamicPickListRows();
        for(Type t : sources){
            Ortho_IChart chartDataset = (Ortho_IChart) t.newInstance();
            VisualEditor.DataRow row = new VisualEditor.DataRow(chartDataset.getName(),t.getName());
            myValues.addRow(row);
        }
        return myValues;
    }
}