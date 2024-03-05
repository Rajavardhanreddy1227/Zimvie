import { LightningElement } from 'lwc';
import BackToCart from '@salesforce/label/c.BackToCart';
export default class B2b_backToCart extends LightningElement {
    labels = {BackToCart};
    handleCancel(event){
        var url = window.location.href;
        var value = url.substr(0,url.lastIndexOf('/') + 1);
        window.history.back();
        return false;
    }
}