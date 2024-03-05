trigger BPUpdateProductSalesTotal on Product_Sales_Summary__c  (after update) {

    Set<String> BusinessPlanID = new Set<String> () ; 
    for(Product_Sales_Summary__c prdsales : trigger.new){
        if(prdsales.Full_Year_Estimate__c  != null && prdsales.BD_Y__c != null && prdsales.Sales_Plan__c != null && prdsales.BD_Y_1__c != null){
            BusinessPlanID.add(prdsales.Business_Plan__c);    
        }
    }
    if(BusinessPlanID.size() > 0){
        
        List<Business_Plan__c> prodsalesTotalUpdateList = new List<Business_Plan__c>();
        Map<String,Map<String,Product_Sales_Summary__c>> ExistingProdSalesSum = new Map<String,Map<String,Product_Sales_Summary__c>> () ; 
        for(Product_Sales_Summary__c prod : [SELECT ID
                                                    , Full_Year_Estimate__c
                                                    , Sales_Plan__c
                                                    , BD_Y__c
                                                    , BD_Y_1__c
                                                    , Business_Plan__c
                                                    , Product_Group__c
                                                    , Pricing_Impact__c 
                                                    , Vol_Mix_Impact__c 
                                                    , Opportunities__c 
                                                    , Risks__c
                                                    , Annual_Sales_Data__r.This_Year_YTD_Sales_Thru_Month__c 
                                                    , This_Quarter_Projection__c
                                                    , Annual_Sales_Data__r.Y_1_Sales__c
                                            FROM    Product_Sales_Summary__c
                                            WHERE   Business_Plan__c IN :BusinessPlanID
                                            AND     ( Product_Group__c!= 'ROSA'
                                            OR      Product_Group__c!= 'My Mobility'
                                            OR      Product_Group__c!= 'Surgical')]){
            Map<String,Product_Sales_Summary__c> tempsum = new Map<String,Product_Sales_Summary__c>(); 
            tempsum.put(prod.Product_Group__c, prod); 
            if(ExistingProdSalesSum.isEmpty() == TRUE || ! ExistingProdSalesSum.containskey(prod.Business_Plan__c) ) {    
                ExistingProdSalesSum.put(prod.Business_Plan__c, tempsum);
            }
            else if( ExistingProdSalesSum.containskey(prod.Business_Plan__c) 
                     && !ExistingProdSalesSum.get(prod.Business_Plan__c).containskey(prod.Product_Group__c) ){
                ExistingProdSalesSum.get(prod.Business_Plan__c).put(prod.Product_Group__c, prod); 
            }                                                 
        }
        if(ExistingProdSalesSum.size() > 0){
            for(String Bpid : BusinessPlanID){
                Decimal FULLYESTIMATE = 0; 
                Decimal SALESPLAN = 0;
                Decimal Y_1Sales = 0 ; 
                Decimal BDY = 0; 
                Decimal BDY_1 = 0; 
                for(String prodgroup : ExistingProdSalesSum.get(Bpid).keyset()){
                    if(prodgroup != 'Total' && prodgroup!= 'ROSA' && prodgroup!= 'My Mobility' && prodgroup!= 'Surgical'){
                        System.debug('Full Year'+prodgroup+'-->'+ExistingProdSalesSum.get(Bpid).get(prodgroup).Full_Year_Estimate__c);
                        FULLYESTIMATE += ExistingProdSalesSum.get(Bpid).get(prodgroup).Full_Year_Estimate__c ; 
                        SALESPLAN += ExistingProdSalesSum.get(Bpid).get(prodgroup).Sales_Plan__c; 
                        BDY = ExistingProdSalesSum.get(Bpid).get(prodgroup).BD_Y__c ; 
                        BDY_1 = ExistingProdSalesSum.get(Bpid).get(prodgroup).BD_Y_1__c ; 
                        Y_1Sales += ExistingProdSalesSum.get(Bpid).get(prodgroup).Annual_Sales_Data__r.Y_1_Sales__c; 
                    }
                }
                Business_Plan__c bp = new Business_Plan__c (id = Bpid); 
                bp.BP_Full_Year_Estimate__c = FULLYESTIMATE; 
                bp.BP_Sales_Plan__c = SALESPLAN; 
                bp.BP_Y_BD__c = BDY ; 
                bp.BP_Y_1_BD__c = BDY_1 ; 
                bp.Y_1_full_Year_sales__c = Y_1Sales;
                prodsalesTotalUpdateList.add(bp);  
            }
        }
        try{
            
            if(prodsalesTotalUpdateList.size() > 0){
                update prodsalesTotalUpdateList;
            }
        } catch (Exception ex) {
                // for handle Exception
                
        }    
    }
}