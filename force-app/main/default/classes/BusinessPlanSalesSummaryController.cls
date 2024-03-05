public with sharing class BusinessPlanSalesSummaryController {
    @AuraEnabled(cacheable=true)
    public Static List<Product_Sales_Summary__c> getSalesSummary(string recordId) {
        system.debug('check recordID--> '+recordId);
        String RoleName = [Select u.Name, u.Id From UserRole u where u.Id=:UserInfo.getUserRoleId()].Name;
        if(RoleName.contains('AVP')){
            return [ SELECT     Id 
                            , NAME
                            , Business_Plan__c
                            , Business_Plan__r.Territory_Account_Name__r.RVP__c
                            , Product_Group__c
                            , Annual_Sales_Data__r.Y_2_Sales__c
                            , Y_2_Sales__c
                            , Annual_Sales_Data__r.Y_2_Percentage_Growth__c
                            , Annual_Sales_Data__r.Y_1_Sales__c
                            , Y_1_Sales__c
                            , Annual_Sales_Data__r.Y_1_Percentage_Growth__c
                            , Annual_Sales_Data__r.Y_1_YTD_Sales_Thru_Month__c
                            , Annual_Sales_Data__r.This_Year_YTD_Target_Thru_Month__c
                            , Annual_Sales_Data__r.This_Year_YTD_Sales_Thru_Month__c
                            , Annual_Sales_Data__r.This_Year_YTD_to_Target__c
                            , Annual_Sales_Data__r.This_Year_ADS_Growth__c
                            , Annual_Sales_Data__r.Full_Year_Target__c
                            , Full_Year_Estimate__c
                            , Full_Year_Target_Attainment__c
                            , This_year_Growth_Percent__c
                            , Sales_Plan__c
                            , Planned_Growth__c
                            , Planned_Growth_Percent__c
                            , ADS__c
                            , ADS_Dollar_Growth__c
                            , ADS_Growth__c
                FROM        Product_Sales_Summary__c
                WHERE       Business_Plan__c = :recordId
                AND         Business_Plan__r.Territory_Account_Name__r.RVP__c = :UserInfo.getUserId()
                AND         Product_Group__c != 'ROSA'
                AND         Product_Group__c != 'My Mobility'
                ORDER by    Full_Year_Estimate__c desc
                ];        
        }
        else{
            return [ SELECT     Id 
                                , NAME
                                , Business_Plan__c
                                , Business_Plan__r.Territory_Account_Name__r.RVP__c
                                , Product_Group__c
                                , Annual_Sales_Data__r.Y_2_Sales__c
                                , Y_2_Sales__c
                                , Annual_Sales_Data__r.Y_2_Percentage_Growth__c
                                , Annual_Sales_Data__r.Y_1_Sales__c
                                , Y_1_Sales__c
                                , Annual_Sales_Data__r.Y_1_Percentage_Growth__c
                                , Annual_Sales_Data__r.Y_1_YTD_Sales_Thru_Month__c
                                , Annual_Sales_Data__r.This_Year_YTD_Target_Thru_Month__c
                                , Annual_Sales_Data__r.This_Year_YTD_Sales_Thru_Month__c
                                , Annual_Sales_Data__r.This_Year_YTD_to_Target__c
                                , Annual_Sales_Data__r.This_Year_ADS_Growth__c
                                , Annual_Sales_Data__r.Full_Year_Target__c
                                , Full_Year_Estimate__c
                                , Full_Year_Target_Attainment__c
                                , This_year_Growth_Percent__c
                                , Sales_Plan__c
                                , Planned_Growth__c
                                , Planned_Growth_Percent__c
                                , ADS__c
                                , ADS_Dollar_Growth__c
                                , ADS_Growth__c
                    FROM        Product_Sales_Summary__c
                    WHERE       Business_Plan__c = :recordId
                    AND         Product_Group__c != 'ROSA'
                    AND         Product_Group__c != 'My Mobility'
                    ORDER by    Full_Year_Estimate__c desc
                    ];   
        }
    }
}