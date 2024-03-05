import { LightningElement, wire } from 'lwc';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import NAME_FIELD from '@salesforce/schema/User.FirstName';

import userId from '@salesforce/user/Id';

export default class OrthoCurrentUserName extends LightningElement {

    @wire(getRecord, { recordId: userId, fields: [NAME_FIELD] })
    currentUser;
     get name() {
        return getFieldValue(this.currentUser.data, NAME_FIELD);
    }

}