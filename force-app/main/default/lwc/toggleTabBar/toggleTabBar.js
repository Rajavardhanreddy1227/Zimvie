import { LightningElement,api } from 'lwc';
import { FlowAttributeChangeEvent } from 'lightning/flowSupport';
import NewToZimvie from '@salesforce/label/c.NewToZimvie';
import AlreadyCustomer from '@salesforce/label/c.AlreadyCustomer';
export default class ToggleTabBar extends LightningElement {

@api selectedTab;
labels = {NewToZimvie,AlreadyCustomer};


renderedCallback(){
     console.log(' this.selectedTab',  this.selectedTab);
    if(this.selectedTab == 'existingCustomer'){
        var divblock = this.template.querySelector('[data-id="existingCustomer"]');
        if(divblock){
            this.template.querySelector('[data-id="existingCustomer"]').className='TabButton activeTab';
        } 
        var divblock = this.template.querySelector('[data-id="newCustomer"]');
        if(divblock){
            this.template.querySelector('[data-id="newCustomer"]').className='TabButton passiveTab';
        }  
    }
}
handleAlreadyCustomer(){
    this.selectedTab = 'existingCustomer';
    console.log(' this.selectedTab',  this.selectedTab);
      this.dispatchEvent(new FlowAttributeChangeEvent('selectedTab', this.selectedTab));
     var divblock = this.template.querySelector('[data-id="existingCustomer"]');
        if(divblock){
            this.template.querySelector('[data-id="existingCustomer"]').className='TabButton activeTab';
        } 
        var divblock = this.template.querySelector('[data-id="newCustomer"]');
        if(divblock){
            this.template.querySelector('[data-id="newCustomer"]').className='TabButton passiveTab';
        }    
}
handleNewCustomer(){
     this.selectedTab = 'newCustomer';
    console.log(' this.selectedTab',  this.selectedTab);

    this.dispatchEvent(new FlowAttributeChangeEvent('selectedTab', this.selectedTab));
     var divblock = this.template.querySelector('[data-id="newCustomer"]');
        if(divblock){
            this.template.querySelector('[data-id="newCustomer"]').className='TabButton activeTab';
        }  

     var divblock = this.template.querySelector('[data-id="existingCustomer"]');
        if(divblock){
            this.template.querySelector('[data-id="existingCustomer"]').className='TabButton passiveTab';
        }   
}
}