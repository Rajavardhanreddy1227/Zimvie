public with sharing class Ortho_ChartFilter {
    @AuraEnabled
    public String field {get; set;}
    @AuraEnabled
    public String label {get; set;}
    @AuraEnabled
    public List<String> options {get; set;}
    @AuraEnabled
    public String value {get; set;}
    @AuraEnabled
    public string allValue {get;set;}


    public Ortho_ChartFilter(){

    }
    public Ortho_ChartFilter(String field, String label, List<String> options) {
        this.field = field;
        this.label = label;
        this.options = options;

    }
    
    public Ortho_ChartFilter(String field, String label, List<String> options, String defaultValue,  String allValue) {
        this.field = field;
        this.label = label;
        this.options = options;
        if(!String.isBlank(defaultValue)){
            value = defaultValue;
        }
        this.allValue = allValue;
    }

    public void addOption(String value){
        options.add(value);
    }

    public void addOptions(Set<String> values){
        options.addAll(values);
    }

    public Boolean matches(sObject sobj){
        String sobjValue = (String) sobj.get(field);
        
        System.debug(sobjValue);
        System.debug(value);
        System.debug(allValue);
        if(sobjValue == value){
            return true;
        }
        if(String.isNotBlank(allValue) && value == allValue){
            return true;
        }
        return false;
    }

    public static Boolean matches(Ortho_KPI__c kpi, Ortho_ChartFilter[] filters){
        Boolean matches = false;
        for(Ortho_ChartFilter filter : filters){
            if(filter <> null){
                if(!filter.matches(kpi)){
                    matches = false;
                    break;
                }
                if(filter.matches(kpi)){
                    matches = true;
                }
            }
        }
        return matches;
    }


}