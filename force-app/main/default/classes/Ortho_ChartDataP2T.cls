public with sharing class Ortho_ChartDataP2T implements Ortho_IChart {

    public Ortho_ChartFilter [] filters = new List<Ortho_ChartFilter>{
        new Ortho_ChartFilter('Timeframe__c', 'Timeframe', new List<String>{'Monthly', 'Quarterly'}, 'Monthly', null),
        new Ortho_ChartFilter('Product__c', 'Product', new List<String>{
            'All',
            'Early Intervention',
            'Extremeties',
            'Cement',
            'F&A',
            'Hips',
            'Knees'
        }, 'All', 'All')
    };

    public String getName(){
        return System.Label.Ortho_Mobile_Chart_Performance_to_Target_Title;
    }


    public Ortho_ChartData getData(){
        return getData(new List<Ortho_ChartFilter>());

    }

    public Ortho_ChartData getData(Ortho_ChartFilter[] filters){
        if(filters == null || filters.size() == 0){
            filters = this.filters;
        }

        List<Ortho_KPI__c> kpis = Ortho_KPISelector.getKPIByUserAndType(new Set<Id>{UserInfo.getUserId()}, new Set<String>{'Target'});
        Ortho_ChartData chartData = new Ortho_ChartData();

        Ortho_KPI__c currentKPI;

        List<Ortho_KPI__c> matchingKPIs = new List<Ortho_KPI__c>();
        for(Ortho_KPI__c kpi : kpis){
            if(Ortho_ChartFilter.matches(kpi, filters)){
                matchingKPIs.add(kpi);
            }
        }
        
        Decimal current = 0;
        Decimal target = 0;

        for(Ortho_KPI__c kpi : matchingKpis){
            current+= kpi.KPI_Current__c;
            target+= kpi.KPI_Target__c;
        }

        Ortho_ChartDataset performance = new Ortho_ChartDataset();
        
        Decimal targetRemaining = target - current;
        performance.data = new List<Decimal>{current, targetRemaining};

        chartData.addDataset(performance);
        chartData.labels = System.Label.Ortho_Mobile_Chart_Performance_to_Target_Labels.split(',');

        chartData.chartTitle = System.Label.Ortho_Mobile_Chart_Performance_to_Target_Title;
    


        chartData.filters = this.filters;

        return chartData;
    }

   


}