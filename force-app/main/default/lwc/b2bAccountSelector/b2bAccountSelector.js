import { LightningElement, api } from 'lwc';
import loadUserRecords from '@salesforce/apex/listOfRecordsToUpdateController.loadUserRecords';
import contextApi from 'commerce/contextApi';
import Id from "@salesforce/user/Id";

export default class B2bAccountSelector extends LightningElement {
value ;
records = [];
@api objectApiName = 'User';
@api fieldsName = 'Id,Name,Email,ContactId,Contact.Name,Is_Buyer_Manager__c';

isBuyerManager;
_accid;  
@api 
set accid(val){
    console.log('accid in Account selector list lwc is '+val);
    this._accid = val;
}
get accid(){
    return this._accid;
}
get options() {
     console.log('in options');
        console.log(this.records);
        let options = [];
        console.log('IsBuyerManager ', this.isBuyerManager);
        if(this.isBuyerManager){
            options = [...options, { value: 'All', label: 'All' }];

        }
         for (let i = 0; i < this.records.length; i++) 
            {
                options = [...options, { value: this.records[i].Contact.Name, label: this.records[i].Contact.Name }];
            }
          
        return options;     
    }

connectedCallback() {
    console.log('connected AS');
      const result = contextApi.getSessionContext();
        result.then((response) => {
            console.log("getSessionContext result AS");
            console.log(response);
            this.accid = response.effectiveAccountId;
            this.loadUserRecords();
            //}
        }).catch((error) => {
            console.log("getSessionContext result AS");
            console.log(error);
        });
 
}

loadUserRecords(){
      loadUserRecords({objectApiName:this.objectApiName, fieldsName:this.fieldsName, accid:this.accid})
     .then(data =>{
            console.log('member records in AS');
            console.log(data);
            let records = JSON.parse(data);
            this.records = records; // all records
            for(let i=0;i< this.records.length; i++){
                if(this.records[i].Id == Id && this.records[i].Is_Buyer_Manager__c){
                    this.isBuyerManager = true;
                    this.value = 'All';
                    break;
                }
                if(this.records[i].Id == Id){
                    this.value = this.records[i].Contact.Name;
                    break;
                }
                
                    
            }
            this.changeOrderView();
     })
     .catch(error=>{
          console.log('member records error AS');
            console.log(error);
            this.error = error;
     });
}
    handleChange(event) {
        this.value = event.detail.value;
        console.log('selected value '+this.value);
        this.changeOrderView();
    }

    changeOrderView(){
        console.log('this.value ', this.value);
        let selectedId;
        if(this.value == 'All'){
            selectedId = 'All';
        }else{
         selectedId = this.records.find(opt => opt.Contact.Name == this.value).Id;

        }
        console.log('selectedId ', selectedId);
        const custEvent = new CustomEvent(
            'changeselectedmember', {
                detail: selectedId 
            });
        this.dispatchEvent(custEvent);
    }

    renderedCallback(){
        const combobox = this.template.querySelector('lightning-combobox');
        console.log('combobox', combobox);
        if(this.options && this.options.length && !combobox.value) {
          combobox.value = this.options[0].value; 
          this.value = this.options[0].value;
          this.changeOrderView();
        }
    }
}