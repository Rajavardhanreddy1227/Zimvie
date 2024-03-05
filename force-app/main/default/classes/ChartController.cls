public class ChartController {
   public Decimal min {get;set;}
   public Decimal SegMax { get; set; }
   public class Sale {
        public decimal amount {get; set;}       
        public String fieldNames {get; set; }
        sale(decimal amount, String fieldNames) {
            this.amount = amount;
            this.fieldNames = fieldNames;
        }
    }
  public class Data {
        public Integer MarketProcedure { get; set; }
        public Integer ZBProcedures { get; set; }
        public String Name { get; set; }
        public String SegmentName { get; set; }
        public Data(Integer MarketProcedure,Integer ZBProcedures, String Name, String SegmentName) {
            this.MarketProcedure = MarketProcedure;
            this.ZBProcedures = ZBProcedures;
            this.Name = Name;
            this.SegmentName = SegmentName;
        }
    }
    @AuraEnabled
    public Data[] getMktData(){
        String queryString ='';
        String businessPlanId = '';
        businessPlanId = ApexPages.currentPage().getParameters().get('bpid');
        queryString = ApexPages.currentPage().getParameters().get('productgroup');
        queryString = queryString == 'Foot Ankle'? 'Foot & Ankle' : queryString ; 
        Data[] MktData = new Data[]{};
        SegMax = 0;
        Set<ID> SurgeonID = new Set<ID>();
        for(Opportunity opps: [select Surgeon_Name__c from Opportunity where Product_Sales_Summary__r.Business_Plan__c = :businessPlanId
                               AND Product_Sales_Summary__r.Product_Group__c = :queryString]){
          SurgeonID.add(opps.Surgeon_Name__c);                               
        }
        
        for(Market_Segmentation__c segments : [SELECT Zimmer_Biomet_Procedures__c
                                                    , Market_Procedures__c
                                                   , Surgeon_Name__c
                                                   , Product_Group__c
                                                   , Surgeon_Name__r.name
                                                    , Segementation__c
                                             FROM  Market_Segmentation__c
                                             where  Surgeon_Name__c 
                                             IN    :SurgeonID
                                             AND  Product_Group__c = :queryString]){
            if(SegMax < segments.Market_Procedures__c) SegMax = segments.Market_Procedures__c + 100;
          MktData.add(new Data((Integer)segments.Market_Procedures__c
                                , (Integer)segments.Zimmer_Biomet_Procedures__c
                                , segments.Surgeon_Name__r.name
                                , segments.Segementation__c));                                                     
        }
        return MktData ;
    }
    public Sale[] getSales() {
        Sale[] Sales = new Sale[] {};
        String queryString ='';
        String businessPlanId = '';
        businessPlanId = ApexPages.currentPage().getParameters().get('bpid');
        queryString = ApexPages.currentPage().getParameters().get('productgroup');
        queryString = queryString == 'Foot Ankle'? 'Foot & Ankle' : queryString ; 
        for (Product_Sales_Summary__c pss : [
                select
                        Y_3_Sales__c,
                        Y_2_Sales__c, 
                        Last_Year_Actual__c ,
                        This_Year_Target__c  ,
                        Full_Year_Estimate__c , 
                        Sales_Plan__c ,
                        Business_Plan__c,
                        Product_Group__c
                from Product_Sales_Summary__c
                where  Business_Plan__c = :businessPlanId
                AND Product_Group__c = :queryString]) {
            IF(min == null || min <=0 ){
                min = pss.Last_Year_Actual__c - 1000000;
            }
            Sales.add(new Sale(
                    (decimal) pss.get('Y_3_Sales__c'),
                    '2017 Sales'
            ));
            Sales.add(new Sale(
                    (decimal) pss.get('Y_2_Sales__c'),
                    '2018 Sales'
            ));
            Sales.add(new Sale(
                    (decimal) pss.get('Last_Year_Actual__c'),
                    'Last Year Actual'
            ));
            Sales.add(new Sale(
                    (decimal) pss.get('This_Year_Target__c'),
                    'This Year Target'
            ));
            Sales.add(new Sale(
                    (decimal) pss.get('Full_Year_Estimate__c'),
                    'Full Year Estimate'
            ));
            Sales.add(new Sale(
                    (decimal) pss.get('Sales_Plan__c'),
                    'Sales Plan'
            ));
        }
        return Sales;
    }
}