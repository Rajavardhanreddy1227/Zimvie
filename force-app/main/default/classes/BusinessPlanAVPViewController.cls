global with sharing class BusinessPlanAVPViewController {

    @AuraEnabled(cacheable=true)
    public static List<Business_Plan__c> getBusinessPlans() {
        system.debug('Rolename checking'+UserInfo.getUserRoleId());
        String RoleName = [Select u.Name, u.Id From UserRole u where u.Id=:UserInfo.getUserRoleId()].name;
        system.debug('Rolename check:' + RoleName);
        if(RoleName.contains('AVP')){
            return [SELECT Id, Name, AVP_Name__c, Territory_Account_Name__c, Status__c, Year__c, Quarter__c FROM Business_Plan__c WHERE Territory_Account_Name__r.RVP__c = :UserInfo.getUserId() ];
        }else{
            return [SELECT Id, Name, AVP_Name__c, Territory_Account_Name__c, Status__c, Year__c, Quarter__c FROM Business_Plan__c];
        }
    }

    /*public static Map<String, Map<String, List<Product_Sales_Summary__c>>> getAllBusinessPlansByYear(Integer yr) {
        List<Product_Sales_Summary__c> lstPSS = [Select Id, Name, Business_Plan__r.Name, Business_Plan__r.Territory_Account_Name__r.territory__r.Name, Product_Group__c,Business_Plan__r.Year__c from Product_Sales_Summary__c where Business_Plan__r.Active__c = true and Business_Plan__r.Year__c = :yr order by Business_Plan__r.Year__c desc, Product_Group__c asc];
        Map<String,Map<String, List<Product_Sales_Summary__c>>> terrPrdMap = new Map<String,Map<String, List<Product_Sales_Summary__c>>>();

        if (lstPSS != null && lstPSS.size() > 0) {
            for(Product_Sales_Summary__c obj : lstPSS){

                if (obj.Business_Plan__c != null 
                    && obj.Business_Plan__r.Territory_Account_Name__c != null 
                    && obj.Business_Plan__r.Territory_Account_Name__r.territory__c != null
                    && obj.Business_Plan__r.Territory_Account_Name__r.territory__r.Name != null)
                {
                    if(!terrPrdMap.containsKey(obj.Business_Plan__r.Territory_Account_Name__r.territory__r.Name)){
                        terrPrdMap.put(obj.Business_Plan__r.Territory_Account_Name__r.territory__r.Name, new Map<String, List<Product_Sales_Summary__c>>());
                    }

                    if (!terrPrdMap.get(obj.Business_Plan__r.Territory_Account_Name__r.territory__r.Name).containsKey(obj.Product_group__c))
                    {
                        terrPrdMap.get(obj.Business_Plan__r.Territory_Account_Name__r.territory__r.Name).put(obj.Product_group__c, new List<Product_Sales_Summary__c>());
                    }

                    terrPrdMap.get(obj.Business_Plan__r.Territory_Account_Name__r.territory__r.Name).get(obj.Product_group__c).add(obj);
                }
                //terrPrdMap.get(obj.Business_Plan__r.Territory_Account_Name__r.territory__r.Name).add(
                    //new UserTerritoryAssociation(uta2.UserId, uta2.Territory2Id, uta2.RoleInTerritory2));
            }
    
        }

        return terrPrdMap;

    }*/

    public static Map<String, Map<String, List<Product_Sales_Summary__c>>> getAllBusinessPlans() {
        List<Product_Sales_Summary__c> lstPSS = [Select Id, Name, Business_Plan__r.Name, Business_Plan__r.Territory_Account_Name__r.territory__r.Name, Product_Group__c,Business_Plan__r.Year__c from Product_Sales_Summary__c where Business_Plan__r.Active__c = true order by Business_Plan__r.Year__c desc, Product_Group__c asc, Id desc];
        Map<String,Map<String, List<Product_Sales_Summary__c>>> terrPrdMap = new Map<String,Map<String, List<Product_Sales_Summary__c>>>();

        if (lstPSS != null && lstPSS.size() > 0) {
            for(Product_Sales_Summary__c obj : lstPSS){

                if (obj.Business_Plan__c != null 
                    && obj.Business_Plan__r.Territory_Account_Name__c != null 
                    && obj.Business_Plan__r.Territory_Account_Name__r.territory__c != null
                    && obj.Business_Plan__r.Territory_Account_Name__r.territory__r.Name != null)
                {
                    if(!terrPrdMap.containsKey(obj.Business_Plan__r.Territory_Account_Name__r.territory__r.Name)){
                        terrPrdMap.put(obj.Business_Plan__r.Territory_Account_Name__r.territory__r.Name, new Map<String, List<Product_Sales_Summary__c>>());
                    }

                    if (!terrPrdMap.get(obj.Business_Plan__r.Territory_Account_Name__r.territory__r.Name).containsKey(obj.Product_group__c))
                    {
                        terrPrdMap.get(obj.Business_Plan__r.Territory_Account_Name__r.territory__r.Name).put(obj.Product_group__c, new List<Product_Sales_Summary__c>());
                    }

                    terrPrdMap.get(obj.Business_Plan__r.Territory_Account_Name__r.territory__r.Name).get(obj.Product_group__c).add(obj);
                }
                /*terrPrdMap.get(obj.Business_Plan__r.Territory_Account_Name__r.territory__r.Name).add(
                    new UserTerritoryAssociation(uta2.UserId, uta2.Territory2Id, uta2.RoleInTerritory2));*/
            }
    
        }

        return terrPrdMap;

    }

    public static List<string> bgColorCodesForChart = new List<string>{'#FF6384','#36A2EB','#bed2ce','#0abc70','#f5b022','#e85e7f','#e85e7f','#e85e7f','#e85e7f','#e85e7f','#e85e7f','#e85e7f','#e85e7f'};
    
    @AuraEnabled
    public static ChartDataWrapper findDataSetForChart(String recordId){
        ChartDataWrapper cdataSet = new ChartDataWrapper();
        System.debug('recordId:' + recordId);
        string queryString = 'SELECT Product_Group__c, SUM(Planned_Growth__c) FROM Product_Sales_Summary__c GROUP BY Product_Group__c';
        AggregateResult[] groupedResults =  database.query(queryString);
        
        integer count =0;
        for (AggregateResult ar : groupedResults)  
        {
            
            string clabel = string.valueof(ar.get('Product_Group__c'));
            string categorylabel = string.valueof(ar.get('Product_Group__c'));
            decimal amount = (decimal)ar.get('expr0');
            //amount = amount != null ? (amount/1000000).setScale(2) : 0;
            cdataSet.labels.add(clabel + '('+string.valueof(amount)+')');
            cdataSet.dataValues.add(string.valueof(amount));
            if(bgColorCodesForChart[count] != null){
                cdataSet.bgColorValues.add(bgColorCodesForChart[count]);
                count++;
            }
            System.debug('Product_Group__c:' + clabel);
            System.debug('Sum amount' + string.valueof(amount));
        }
        return cdataSet;
    }
    
    public class ChartDataWrapper{
        @AuraEnabled
        public list<string> labels{get;set;}
        @AuraEnabled
        public list<string> dataValues{get;set;}
        @AuraEnabled
        public list<string> bgColorValues{get;set;}
        public ChartDataWrapper(){
            labels =new list<string> ();
            dataValues = new list<string> ();
            bgColorValues = new list<string> ();
        }
    }
}