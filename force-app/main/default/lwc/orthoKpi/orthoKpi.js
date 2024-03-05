import { LightningElement, api } from 'lwc';

import Ortho_KPI_On_Target_Color from '@salesforce/label/c.Ortho_KPI_On_Target_Color';
import Ortho_KPI_Off_Target_Color from '@salesforce/label/c.Ortho_KPI_Off_Target_Color';

import {  isNumber } from 'c/orthoChartUtility'

export default class OrthoKpi extends LightningElement {
  @api current;
  @api target;
  @api description;
  @api prd;
  @api targettxt;

  renderedCallback(){
    this.isOnTarget();
  }
  get currentAndTarget(){
    return isNumber(this.current) && isNumber(this.target);
  }

  get reconOrNonRecordPrd(){
    return this.prd === 'Recon' || this.prd === 'Non-Recon';
  }

  isOnTarget(){
    const element = this.template.querySelector('.ortho-kpi');
    element.style = `background-color: ${this.kpiColor}`;

    /*if ((this.prd === 'Recon' || this.prd === 'Non-Recon') && this.targettxt === 'YTD Target')
    this.targettxt = 'YTD excluding Quarter';*/
  }

  get kpiColor(){

    if(this.current > this.target){
      return Ortho_KPI_On_Target_Color;
    }

    return Ortho_KPI_Off_Target_Color;
  }

}