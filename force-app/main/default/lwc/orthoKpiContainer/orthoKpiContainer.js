import { LightningElement, api, wire } from 'lwc';

import getProductData from '@salesforce/apex/Ortho_KPIController.getProductData';
import Ortho_Open_In_Tableau from '@salesforce/label/c.Ortho_Open_In_Tableau';
import Ortho_KPI_Quarter_Performance from '@salesforce/label/c.Ortho_KPI_Quarter_Performance';
import Ortho_KPI_Month_Performance from '@salesforce/label/c.Ortho_KPI_Month_Performance';
import Ortho_KPI_Month_Target_Text from '@salesforce/label/c.Ortho_KPI_Month_Target_Text';
import Ortho_KPI_Quarter_Target_Text from '@salesforce/label/c.Ortho_KPI_Quarter_Target_Text';
import Ortho_KPI_Year_Target_Text from '@salesforce/label/c.Ortho_KPI_Year_Target_Text';
import Ortho_KPI_Year_wo_Qtr_Target_Text from '@salesforce/label/c.Ortho_KPI_Year_wo_Qtr_Target_Text';

import { _get , isNumber } from 'c/orthoChartUtility'

export default class OrthoKpiContainer extends LightningElement {
  @api product;
  @api reportLink;
  @api showReportLink;
  linkText = Ortho_Open_In_Tableau;
  
  @wire(getProductData, {product : '$product'})
  kpi;

  

  get show(){
    
    let v = this.showMonthly || this.showQuarterly || this.showYearly || this.showYearlyWithoutQtr;
    console.log('Show - Returning '+ v + ' for product '+ this.product);
    return v;
  }
  //Monthly
  get showMonthly(){
    return isNumber(this.monthlyCurrent) && isNumber(this.monthlyTarget);
  }
  get monthlyCurrent(){
    return _get(()=> this.kpi.data.monthly.KPI_Current__c);
  }

  get monthlyTarget(){
    return _get(()=> this.kpi.data.monthly.KPI_Target__c);
  }

  get monthlyLabel(){
    return _get(()=> Ortho_KPI_Month_Performance);
  }

  get monthlyTargetText(){
    return _get(()=> Ortho_KPI_Month_Target_Text);
  }

  //Quarterly
  get showQuarterly(){
    return isNumber(this.quarterlyCurrent) && isNumber(this.quarterlyTarget);
  }
  get quarterlyCurrent(){
    return _get(()=> this.kpi.data.quarterly.KPI_Current__c);
  }

  get quarterlyTarget(){
    return _get(()=> this.kpi.data.quarterly.KPI_Target__c);
  }

  get quarterlyLabel(){
    return _get(()=> Ortho_KPI_Quarter_Performance);
  }

  get quarterlyTargetText(){
    return _get(()=> Ortho_KPI_Quarter_Target_Text);
  }

  //Yearly
  get showYearly(){
    return isNumber(this.yearlyCurrent) && isNumber(this.yearlyTarget);
  }
  get yearlyCurrent(){
    return _get(()=> this.kpi.data.yearly.KPI_Current__c);
  }

  get yearlyTarget(){
    return _get(()=> this.kpi.data.yearly.KPI_Target__c);
  }

  get yearlyLabel(){
    return _get(()=> Ortho_KPI_Year_Performance);
  }

  get yearlyTargetText(){
    return _get(()=> Ortho_KPI_Year_Target_Text);
  }

  //Yearly Without Quarter
  get showYearlyWithoutQtr(){
    if (isNumber(this.yearlyWithoutQtrCurrent) && isNumber(this.yearlyWithoutQtrTarget))
    console.log('showYearlyWithoutQtr will return TRUE');
    return isNumber(this.yearlyWithoutQtrCurrent) && isNumber(this.yearlyWithoutQtrTarget);
  }
  get yearlyWithoutQtrCurrent(){
    return _get(()=> this.kpi.data.yearlyWithoutQtr.KPI_Current__c);
  }

  get yearlyWithoutQtrTarget(){
    return _get(()=> this.kpi.data.yearlyWithoutQtr.KPI_Target__c);
  }

  get yearlyWithoutQtrLabel(){
    return _get(()=> 'Yearly w/o Qtr');
  }

  get yearlyWithoutQtrTargetText(){
    return _get(()=> Ortho_KPI_Year_wo_Qtr_Target_Text);
  }
}