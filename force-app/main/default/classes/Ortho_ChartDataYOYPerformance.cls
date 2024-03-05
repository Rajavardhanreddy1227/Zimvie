public with sharing class Ortho_ChartDataYOYPerformance implements Ortho_IChart {

    public Ortho_ChartFilter [] filters = new List<Ortho_ChartFilter>{
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
        return System.Label.Ortho_Mobile_Chart_Year_Over_Year_Title;
    }


    public Ortho_ChartData getData(){
        return getData(this.filters[0]);
    }
    public Ortho_ChartData getData(Ortho_ChartFilter[] filters){
        System.debug(filters);
        if(filters.size() == 0){
            return getData(this.filters[0]);
        }
        
        return getData(filters[0]);
    }

    public Ortho_ChartData getData(Ortho_ChartFilter filter){
        if(filter == null){
            filter = filters[0];
            filter.value = 'All';
        }

        Ortho_ChartData chartData = new Ortho_ChartData();

        List<Ortho_KPI__c> kpis = Ortho_KPISelector.getKPIByUserAndType(new Set<Id>{UserInfo.getUserId()}, new Set<String>{'Year-Over-Year'});

        Map<String, List<Ortho_KPI__c>> groupedKpis = groupBy(kpis, 'KPI_Label__c');

        Map<String, ProductDataset> productDatasetMap = new Map<String, ProductDataset>();

        Set<String> products = new Set<String>();
        for(Ortho_KPI__c kpi : kpis){
            if(String.isNotBlank(kpi.Product__c)){
                products.add(kpi.Product__c);
            }
        }



        for(String key : groupedKpis.keySet()){
            chartData.addLabel(key);

            List<Ortho_KPI__c> kpiList = groupedKpis.get(key);

            Map<String, List<Ortho_KPI__c>> productKpiMap = groupBy(kpiList, 'Product__c');

            for(String product : products){
                if(filter.value == 'All' || filter.value == product){
                    ProductDataset pdataset = productDatasetMap.get(product);
                    if(pdataset == null){
                        pdataset = new ProductDataset(product);
                    }
                    List<Ortho_KPI__c> productKPIs = productKpiMap.get(product);
                    if(productKPIs <> null){
                        for(Ortho_KPI__c productKPI : productKPIs){
                            pdataset.lastYear.addDataValue(productKPI.KPI_Previous__c);
                            pdataset.thisYear.addDataValue(productKPI.KPI_Current__c);
                        }
                    }
                    else{
                        pdataset.lastYear.addDataValue(0);
                        pdataset.thisYear.addDataValue(0);
                    }
                    productDatasetMap.put(product, pdataset);
                }
            }

        }

        for(String product : products){
            ProductDataset pdataset = productDatasetMap.get(product);
            if(pdataset <> null){
                chartData.addDataset(pdataset.lastYear);
                chartData.addDataset(pdataset.thisYear);
            }
        }



        chartData.chartTitle = System.Label.Ortho_Mobile_Chart_Year_Over_Year_Title;

        chartData.filters = filters;

        return chartData;
    }

    private Map<String, List<Ortho_KPI__c>> groupBy(List<Ortho_KPI__c> kpis, String field){
        Map<String, List<Ortho_KPI__c>> kpiMap = new Map<String, List<Ortho_KPI__c>>();
        for(Ortho_KPI__c kpi : kpis){
            String key = (String)kpi.get(field);
            if(String.isNotBlank(key)){
                List<Ortho_KPI__c> groupedKPIs = kpiMap.get(key);
                if(groupedKPIs == null){
                    groupedKPIs = new List<Ortho_KPI__c>();
                }

                groupedKPIs.add(kpi);

                kpiMap.put(key, groupedKPIs);
            }
        }

        return kpiMap;
    }

    public Class ProductDataset {
        public Ortho_ChartDataset thisYear {get; set;}
        public Ortho_ChartDataset lastYear {get; set;}

        public ProductDataset(String productName){
            lastYear = new Ortho_ChartDataset(productName);
            lastYear.stack = 'Last Year';
            thisYear = new Ortho_ChartDataset(productName);
            thisYear.stack = 'This Year';
        }
    }

}