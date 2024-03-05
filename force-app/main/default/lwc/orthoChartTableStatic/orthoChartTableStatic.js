import { LightningElement , api} from 'lwc';
import OrthoChart from 'c/orthoChart';

import Ortho_Current_Year_Sales from '@salesforce/label/c.Ortho_Current_Year_Sales'; 
import Ortho_Previous_Year_Sales from '@salesforce/label/c.Ortho_Previous_Year_Sales'; 
import Ortho_ADS_Growth from '@salesforce/label/c.Ortho_ADS_Growth'; 
import Ortho_Timeframe from '@salesforce/label/c.Ortho_Timeframe'; 
import Ortho_Mobile_Chart_Year_Over_Year_Title from '@salesforce/label/c.Ortho_Mobile_Chart_Year_Over_Year_Title';
import Ortho_Open_In_Tableau from '@salesforce/label/c.Ortho_Open_In_Tableau';

export default class OrthoChartTableStatic extends OrthoChart {
  @api chartSource;
  @api reportLink;
  linkText = Ortho_Open_In_Tableau;
  title = Ortho_Mobile_Chart_Year_Over_Year_Title;

  _columns = [
    { label: Ortho_Timeframe, fieldName: 'label' },
    { label: Ortho_Current_Year_Sales, fieldName: 'cysales', type: 'currency' , cellAttributes: { alignment: 'left' } },
    { label: Ortho_Previous_Year_Sales, fieldName: 'lysales', type: 'currency' , cellAttributes: { alignment: 'left' } },
    { label: Ortho_ADS_Growth, fieldName: 'ads', type: 'percent'  , cellAttributes: { alignment: 'left' } },
  ]
  

  get columns(){
    return this._columns;
  }

  get data(){
    const filterValue = this.filters[0].value;
    return this.hasChartData && this.chartData.datasets.flatMap((dataset, idx) => {
      //(dataset.data[2]/100).toFixed(2)
      return {label: dataset.label, cysales: dataset.data[0], lysales: dataset.data[1], ads: filterValue !== 'All' ? dataset.data[2]/100 : null};
    });
  }

  get hasChartData(){
    return this.chartData && this.chartData.datasets && this.chartData.datasets.length > 0;
  }
}