import OrthoChart from "c/orthoChart";
import { api } from "lwc";

export default class OrthoChartBar extends OrthoChart {
  @api useGradient;
  @api colorOne;
  @api colorTwo;
  @api chartSource;
  @api reportLink;

  labels = [];

  connectedCallback() {
  }

  dataUpdated(){
    this.labels = [];
  }
  initializeChartJs() {
    const chart = this.template.querySelector(".chart");
    // eslint-disable-next-line no-unused-vars
    this.orthoChart = new this._Chart(chart, {
      type: "bar",
      options: {
        responsive: false,
        legend: {
          display: true,
          labels: {
            filter: (label) => {
              if(!this.labels.includes(label.text)){
                this.labels.push(label.text)
                return true;
              }

            }

          }
        },
        scales: {
          xAxes: [
            {
              stacked: true
            }
          ],
          yAxes: [
            {
              stacked: true,
              ticks: {
                beginAtZero: true,
                maxTicksLimit: 5
              }
            }
          ]
        }
      }
    });

    return this.orthoChart;
  }
}