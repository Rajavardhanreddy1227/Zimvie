public with sharing class Ortho_ChartDataYOYTable implements Ortho_IChart {

    public Ortho_ChartFilter productFilter =  new Ortho_ChartFilter('Product__c', 'Product', new List<String>{
        'All'
    }, 'All', 'All');

    public Ortho_ChartFilter [] filters = new List<Ortho_ChartFilter>{productFilter};

    public String getName(){
        return System.Label.Ortho_Mobile_Chart_Year_Over_Year_Title;
    }

    public Ortho_ChartData getData(){
        return getData(this.filters);
    }

    private void setKPIValue(Map<String, Decimal> kpiMap, String timeframe, Decimal value){
        Decimal current = getKPIValue(kpiMap, timeframe);
        kpiMap.put(timeframe, value+current);
    }
    private Decimal getKPIValue(Map<String, Decimal> kpiMap, String timeframe){
        Decimal current = kpiMap.get(timeframe);
        if(current == null){
            current = 0;
        }

        return current;
    }
    public Ortho_ChartData getData(Ortho_ChartFilter[] filters){
        if(filters.size() == 0){
            filters = this.filters;
        }

        Set<String> products = new Set<String>();
        
        Ortho_ChartData chartData = new Ortho_ChartData();

        List<Ortho_KPI__c> kpis = Ortho_KPISelector.getKPIByUserAndType(new Set<Id>{UserInfo.getUserId()}, new Set<String>{'Year-Over-Year'});

        chartData.addLabel(System.Label.Ortho_Current_Year_Sales);
        chartData.addLabel(System.Label.Ortho_Previous_Year_Sales);
        chartData.addLabel(System.Label.Ortho_ADS_Growth);



        Map<String, Decimal> currentKPIMap = new Map<String, Decimal>();
        Map<String, Decimal> previousKPIMap = new Map<String, Decimal>();
        Map<String, Decimal> adsKPIMap = new Map<String, Decimal>();
        Set<String> timeframes = new Set<String>();
        for(Ortho_KPI__c kpi : kpis){
            if(Ortho_ChartFilter.matches(kpi, filters)){
                String timeframe = kpi.Timeframe__c;

                setKPIValue(currentKPIMap, timeframe, kpi.KPI_Current__c);
                setKPIValue(previousKPIMap, timeframe, kpi.KPI_Previous__c);
                setKPIValue(adsKPIMap, timeframe, kpi.KPI_Target__c);
                timeframes.add(timeframe);
            }
            products.add(kpi.Product__c);
        }

        for(String timeframe : timeframes){
            Ortho_ChartDataset dataset = new Ortho_ChartDataset();
            dataset.label = timeframe;
            
            Decimal current = getKPIValue(currentKPIMap,  timeframe);
            Decimal previous = getKPIValue(previousKPIMap,  timeframe);
            Decimal ads = getKPIValue(adsKPIMap, timeframe);

            dataset.addDataValue(current);
            dataset.addDataValue(previous);
            dataset.addDataValue(ads);
            chartData.addDataset(dataset);
        }



        chartData.chartTitle = System.Label.Ortho_Mobile_Chart_Year_Over_Year_Title;

        productFilter.addOptions(products);
        chartData.filters = filters;


        return chartData;
    }


}