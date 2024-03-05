public with sharing class Ortho_ChartData {
    @AuraEnabled public String[] labels {get; set;}
    @AuraEnabled public Ortho_ChartDataset[] datasets {get; set;}
    @AuraEnabled public String chartTitle {get; set;}
    @AuraEnabled public Ortho_ChartFilter[] filters {get;set;}

    public Ortho_ChartData(){
        datasets = new List<Ortho_ChartDataset>();
        labels = new List<String>();
        filters = new List<Ortho_ChartFilter>();
    }

    public void addDataset(Ortho_ChartDataset dataset){
        datasets.add(dataset);
    }

    public void addLabel(String label){
        labels.add(label);
    }


}