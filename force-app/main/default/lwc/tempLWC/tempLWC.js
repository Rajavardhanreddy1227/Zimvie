import { LightningElement,api } from 'lwc';
export default class TempLWC extends LightningElement {
    _orderdetails;
    @api 
    set OrderDetails(val){
        this._orderdetails = JSON.stringify(val);
        console.log(this._orderdetails);
    }
    get OrderDetails(){
        return this._orderdetails;
    }
}