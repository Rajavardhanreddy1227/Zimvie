/********************************************************************************************************
    Created by:     Prosenjit Saha
    Created Date:   5/22/2019
    Trigger Name:   BusinessPlanCreation
    purpose:        This trigger does 2 primary jobs:
                        1. It creates all the sections in the business plan
                            a. Executive Summary
                            b. Sales Summary
                            c. Headcount Summary
                        2. It creates the link between the Product Sales Summary 
                            and the Annual sales summary 

*********************************************************************************************************/

trigger BusinessPlanCreation on Business_Plan__c (after insert) {
    
    //variable declaration
    List<Business_Plan__c> triggeredBP = new List<Business_Plan__c>();
    List<Executive_Summary__c> insertExeSum = new List<Executive_Summary__c>();
    List<Product_Sales_Summary__c> insertProdSalesSum = new List<Product_Sales_Summary__c>();
    List<Headcount_Summary__c> insertHeadcountSum = new List<Headcount_Summary__c>();
    Map<String, Business_Plan_Settings__c> productgroups = Business_Plan_Settings__c.getAll();
    Map<ID,Map<String, Annual_Sales_Data__c>> annualSalesDataMap =  new Map<ID,Map<String, Annual_Sales_Data__c>> ();
    Map<String,String> territoryAnnualSalesMap = new Map<String,String> ();
    List<String> territoryAccountIds = new List<String> (); 

    // Sort them by name
    List<String> CustomSettingsNames = new List<String>();
    CustomSettingsNames.addAll(productgroups.keySet());
    CustomSettingsNames.sort();
    
    Business_Plan__share bpshareAVP = new Business_Plan__share();
    for(Business_Plan__c bp : [SELECT id, name,Territory_Account_Name__c,Territory_Account_Name__r.RVP__c, Quarter__c,Year__c  from Business_Plan__c where ID IN :trigger.newMap.keyset()]) {
        triggeredBP.add(bp);
        if(bp.Territory_Account_Name__c != null && bp.Territory_Account_Name__r.RVP__c != null ){
            bpshareAVP.ParentId = bp.id ; 
            bpshareAVP.UserOrGroupId = bp.Territory_Account_Name__r.RVP__c ; 
            bpshareAVP.AccessLevel = 'Read';
            bpshareAVP.RowCause = Schema.Business_Plan__share.RowCause.Manual;
        }
        string qtrval = (bp.Quarter__c!= null)?bp.Quarter__c : '' ; 
        String keystr = bp.Territory_Account_Name__c+ qtrval +bp.Year__c ;
        territoryAnnualSalesMap.put(keystr, bp.id);
        territoryAccountIds.add(bp.Territory_Account_Name__c);
    }

    //Annual Sales Data query
    for(Annual_Sales_Data__c annualSales: [SELECT    id
                                                    ,name
                                                    ,Territory_Name__c
                                                    ,Product_Group__c
                                                    ,Quarter__c
                                                    ,Year__c 
                                            FROM    Annual_Sales_Data__c 
                                            WHERE   Territory_Name__c 
                                            IN      :territoryAccountIds]){
        string qtrvalue = (annualSales.Quarter__c!= null)?annualSales.Quarter__c : ''  ; 
        if(territoryAnnualSalesMap.containsKey(annualSales.Territory_Name__c + qtrvalue + annualSales.Year__c )){
            Map<String, Annual_Sales_Data__c> tempMap = new Map<String, Annual_Sales_Data__c> ();
            tempMap.put(annualSales.Product_Group__c , annualSales);
            annualSalesDataMap.put(territoryAnnualSalesMap.get(annualSales.Territory_Name__c + qtrvalue + annualSales.Year__c),tempMap);
        }
    }

    for(Business_Plan__c bp : triggeredBP){
        //Create executive summary
        Executive_Summary__c exsumtemp = new Executive_Summary__c ();
            exsumtemp.Business_Plan__c = bp.id ; 
            exsumtemp.IsActive__c = TRUE;
        insertExeSum.add(exsumtemp);

        //Create Product Sales Summary
        for(String prodgroup : CustomSettingsNames){
            if(prodgroup.contains('Product Group')){
                Product_Sales_Summary__c prosalesTemp = new Product_Sales_Summary__c ();
                    prosalesTemp.Business_Plan__c = bp.id;
                    prosalesTemp.Product_Group__c = productgroups.get(prodgroup).Product_Group__c ; 
                    prosalesTemp.National_Average__c = productgroups.get(prodgroup).National_Average__c;
                    prosalesTemp.YTD_Price_Impact__c = productgroups.get(prodgroup).Pricing_Impact__c;
                    prosalesTemp.YTD_Vol_Mix_Impact__c = productgroups.get(prodgroup).YTD_Vol_Mix_Impact__c;
                    /*
                    prosalesTemp.Annual_Sales_Data__c = annualSalesDataMap.size() != null && annualSalesDataMap.containsKey(bp.id) ? 
                                                            annualSalesDataMap.get(bp.id).ContainsKey(productgroups.get(prodgroup).Product_Group__c)?
                                                                annualSalesDataMap.get(bp.id).get(productgroups.get(prodgroup).Product_Group__c).id
                                                                : ''
                                                            : '' ; */
                insertProdSalesSum.add(prosalesTemp);
            }
        }

        //Create  Headcount Summary 
        for(String prodgroup : CustomSettingsNames){
            if(prodgroup.contains('Headcount Summary')){
                Headcount_Summary__c headcountTemp = new Headcount_Summary__c ();
                    headcountTemp.Business_Plan__c = bp.id;
                    headcountTemp.Specialty__c = productgroups.get(prodgroup).Product_Group__c ; 
                insertHeadcountSum.add(headcountTemp);
            }
        }

    }
    try{
        if(insertExeSum.size()>0){
            insert insertExeSum ;
        }
        if(insertProdSalesSum.size()>0){
            insert insertProdSalesSum ; 
        }
        if(insertHeadcountSum.size()>0){
            insert insertHeadcountSum ; 
        }
        //share the business plan record with AVP when created 
        if(bpshareAVP != null ){
            Database.SaveResult sr = Database.insert(bpshareAVP,false);
        }

    }Catch(Exception e){}
}