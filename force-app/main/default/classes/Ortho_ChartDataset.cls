public class Ortho_ChartDataset {
    @AuraEnabled public Decimal[] data {get; set;}
    @AuraEnabled public String label {get; set;}
    @AuraEnabled public Integer order {get; set;}
    @AuraEnabled public Object meta{get;set;}
    @AuraEnabled public String stack{get;set;}

    public Ortho_ChartDataset(){
        
    }
    public Ortho_ChartDataset(String label){
        this.label = label;
    }

    public void addDataValue(Decimal value){
        if(data == null){
            data = new List<Decimal>();
        }

        data.add(value);
    }

    public Boolean isEmpty(){
        return data == null || data.size() == 0;
    }
}