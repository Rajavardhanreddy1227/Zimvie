import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import chartjs from "@salesforce/resourceUrl/chartjs";
import { loadStyle, loadScript } from "lightning/platformResourceLoader";
import getData from '@salesforce/apex/Ortho_ChartController.getData';


import Ortho_ChartJS_Error from '@salesforce/label/c.Ortho_ChartJS_Error';
import Ortho_Chart_Data_Error from '@salesforce/label/c.Ortho_Chart_Data_Error';
import Ortho_Open_In_Tableau from '@salesforce/label/c.Ortho_Open_In_Tableau';

import { chartDefaults, inspect , addClass } from 'c/orthoChartUtility';

export default class OrthoChart extends LightningElement {
  @api chartSource;
  @api reportLink;
  @track filters = [];
  linkText = Ortho_Open_In_Tableau;
  chartjsInitialized = false;
  _Chart;
  orthoChart;
  chartData;
  chartShown = false;

  @wire(getData, { chartSource : '$chartSource', filters: '$filters'})
  wiredData({ error, data }) {
    if (data) {
      console.log(inspect(data));
      this.chartData = data;
      if(this.filters.length === 0){
        console.log(inspect(data.filters))
        this.filters = data.filters;
      }
      this.addData();
    } else if (error) {
      console.log(inspect(error));
      this.showToast({
        title: Ortho_Chart_Data_Error,
        message: error,
        variant: 'error'
      })
    }
  }
   
  renderedCallback() {
    if (this.chartjsInitialized) {
      return;
    }
    Promise.all([
      loadScript(this, chartjs + "/Chart.bundle.js"),
      loadStyle(this, chartjs + "/Chart.css")
    ]).then(() => {
        return Promise.all([
            loadScript(this, chartjs + "/chartjs.plugin.colorschemes.js"),
            loadScript(this, chartjs + "/chartjs-plugin-datalabels.js")
        ])
      })
      .then(() => {
        this.defaults();
        this.orthoChart = this.initializeChartJs();
        this.chartjsInitialized = true;
        this.addData();
      })
      .catch(error => {
        this.showToast({
          title: Ortho_ChartJS_Error,
          message: error && error.message,
          variant: "error"
        })
      });

  }

  showToast(options){
    this.dispatchEvent(new ShowToastEvent(options))
  }

  addData(){
    if(!this.orthoChart) return;

    if(this.chartData){
      const _data = {
        datasets: JSON.parse(JSON.stringify(this.chartData.datasets)),
        labels: JSON.parse(JSON.stringify(this.chartData.labels))
      }
      this.orthoChart.data = _data;
      
      if(this.chartData.chartTitle){
        this.orthoChart.options.title = {
            display: true,
            text: this.chartData.chartTitle
        }
      }

      if(this.chartData.datasets && this.chartData.datasets.length > 0){
        this.showChart();
      }
      this.dataUpdated();
      this.orthoChart.update();
    }
  }

  handleFilterChange(ev){
    const evFilter = ev.detail.filter;
    const filters = this.filters.map(filter => {
        if(filter.field === evFilter.field){
          return evFilter;
        }
        
        return filter;
    })
    this.filters = filters;
    
  }

  showChart(){
    addClass(this, '.ortho-chart', 'show');
    this.chartShown = true;
  }
  defaults() {
    // eslint-disable-next-line no-undef
    const _Chart = Chart;

    // this.defaults();
    _Chart.platform.disableCSSInjection = true;
    _Chart.defaults = chartDefaults;
    this._Chart = _Chart;



  }
  dataUpdated(){}
  initializeChartJs(){}
}