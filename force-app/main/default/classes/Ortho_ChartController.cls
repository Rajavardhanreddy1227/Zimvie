public with sharing class Ortho_ChartController {
    public Ortho_ChartController() {

    }

    @AuraEnabled (cacheable = true)
    public static Ortho_ChartData getData(String chartSource){
        Type t = Type.forName(chartSource);
        Ortho_IChart chartDataset = (Ortho_IChart) t.newInstance();
        return chartDataset.getData();
    }

    @AuraEnabled (cacheable = true)
    public static Ortho_ChartData getData(String chartSource, Ortho_ChartFilter[] filters){
        Type t = Type.forName(chartSource);
        Ortho_IChart chartDataset = (Ortho_IChart) t.newInstance();
        return chartDataset.getData(filters);
    }
}