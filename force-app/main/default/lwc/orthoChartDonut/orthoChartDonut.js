import OrthoChart from "c/orthoChart";
import GaugePlugin from './gauge.plugin.js';
import { api } from "lwc";

import Ortho_Chart_Donut_Color_Scheme from '@salesforce/label/c.Ortho_Chart_Donut_Color_Scheme';
import { sfdcColors } from 'c/orthoChartUtility'

export default class OrthoChartBar extends OrthoChart {
  @api chartSource;
  @api reportLink;


  connectedCallback(){
  }

  dataUpdated(){
    if(this.orthoChart.data){
      const data = this.orthoChart.data;

      this.orthoChart.data.datasets = data.datasets.map((dataset) => {
        const total = dataset.data.reduce((acc, curr) => {
          return acc+curr;
        }, 0);
        const percent = Math.round((dataset.data[0] / total)*100);

        const label = `${percent}%`


        dataset.data = dataset.data.map((d) => {
          if(d < 0){
            d = 0;
            dataset.pLabel = label;
          }
          return d;
        })
        return dataset;
      })
    }
  }

  initializeChartJs() {
    const chart = this.template.querySelector(".chart");
    // eslint-disable-next-line no-unused-vars
    this.orthoChart = new this._Chart(chart, {
      type: "doughnut",
      plugins: [GaugePlugin],
      options: {
        cutoutPercentage: 60,
        responsive: false,
        legend: {
          display: false
        },
        rotation: (11/12) * Math.PI,
        circumference: (7/6) * Math.PI,
        plugins: {
          colorschemes: {
            scheme: sfdcColors,
            reverse: false
          },
          datalabels: {
            font: {
              size: 12
            },
						backgroundColor: function(context) {
							return context.dataset.backgroundColor;
						},
						borderColor: 'white',
						borderRadius: 25,
						borderWidth: 1,
						color: 'white',
            display: true, 
            formatter: function(value, context) {
              if(value <= 0) return null;
              if(context.dataset.pLabel){
                return context.dataset.pLabel;
              }
              const data = context.dataset.data;
              const total = data.reduce((acc, curr) => {
                return acc+curr;
              }, 0);
              return Math.round((value/total) * 100) + '%';
            }
          },
          gaugeplugin: {
            display: true,
            text: function(data){
              const total = data.reduce((acc, curr) => {
                return acc+curr;
              }, 0);
              const percent = Math.round((data[0] / total)*100);

              return `${percent}%`
            }
          }
        }
      }
    });

    return this.orthoChart;
  }
}