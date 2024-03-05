import { LightningElement } from 'lwc';
export default class Zimvie_invoicepayment extends LightningElement {
    myAction(event){
        console.log('result=='+JSON.stringify(event.detail));
    }
}