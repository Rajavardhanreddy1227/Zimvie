import { LightningElement } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

import Ortho_New_Task from '@salesforce/label/c.Ortho_New_Task'
export default class OrthoNewTask extends NavigationMixin(LightningElement) {
  taskLabel = Ortho_New_Task;

  handleClick(){
    const newTaskPage = {
      type: 'standard__objectPage',
      attributes: {
          objectApiName: 'Task',
          actionName: 'new'
      }
    }

    this[NavigationMixin.Navigate](newTaskPage);
  }
  
}