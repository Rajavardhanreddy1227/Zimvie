import { LightningElement, api } from 'lwc';

import Ortho_Filter_Placeholder from '@salesforce/label/c.Ortho_Filter_Placeholder';

export default class OrthoChartFilter extends LightningElement {
  @api filter;
  options;
  filterPlaceholder = Ortho_Filter_Placeholder;
  connectedCallback(){
    if(this.filter && this.filter.options){

      this.options = this.filter.options.map((option) => ({label: option, value: option}))
      this.value = this.filter.options[0];
    }
  }
  handleChange(ev) {
    console.log('Current selected value : '+ev.target.value);
    const data = Object.assign({}, this.filter, {value: ev.target.value});
    this.dispatchEvent(new CustomEvent('filterchange',{detail: {filter: data}})) 
  }
}