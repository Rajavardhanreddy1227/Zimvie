import { LightningElement,api } from 'lwc';

export default class B2b_CheckoutTitles extends LightningElement {

    @api get title()
    {
        return this._title;
    }
    set title(value)
    {
        this._title = value;
    }
}