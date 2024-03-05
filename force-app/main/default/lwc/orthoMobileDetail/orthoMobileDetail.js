import { LightningElement, api, wire } from "lwc";
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';

import getFieldsetByObjectAndName from "@salesforce/apex/Ortho_FieldSets.getFieldsetByObjectAndName";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

import Ortho_Mobile_Detail_Save_Button from '@salesforce/label/c.Ortho_Mobile_Detail_Save_Button'; 
import Ortho_Mobile_Detail_Save_Title from '@salesforce/label/c.Ortho_Mobile_Detail_Save_Title'; 
import Ortho_Mobile_Detail_Save_Success_Message from '@salesforce/label/c.Ortho_Mobile_Detail_Save_Success_Message'; 

import RECORD_TYPE_FIELD from '@salesforce/schema/Opportunity.RecordTypeId';

const readOnly = field => {
  return field.fieldType === "REFERENCE";
};

export default class OrthoMobileDetail extends LightningElement {
  fields;
  loaded = false;
  @api recordId;
  @api objectApiName;
  @api fieldSetName;
  opportunity;

  labels = {
    Ortho_Mobile_Detail_Save_Button
  }


  @wire(getRecord, { recordId: '$recordId', fields: [RECORD_TYPE_FIELD] })
  opportunity;

  @wire(getFieldsetByObjectAndName, {
    sObjectName: "$objectApiName",
    fieldSetName: "$fieldSetName"
  })
  wireFields({ err, data }) {
    if (data) {
      this.fields = data.map(field => {
        const newField = Object.assign({ readOnly: readOnly(field) }, field);
        return newField;
      });
    }
  }

  handleSuccess(event) {
    this.showToast({
      title: Ortho_Mobile_Detail_Save_Title,
      message: Ortho_Mobile_Detail_Save_Success_Message,
      variant: "success"
    });
  }
  handleLoad(){
    this.loaded = true;
  }

  showToast(data) {
    const event = new ShowToastEvent(data);
    this.dispatchEvent(event);
  }

  constructor() {
    super();
  }

  get recordTypeId(){
    return getFieldValue(this.opportunity.data, RECORD_TYPE_FIELD);
  }

  get titleField() {
    if (this.fields && this.fields.length > 0) {
      return this.fields[0];
    }
  }

  get metaFields() {
    const metaFields = [];
    if (this.fields && this.fields.length > 1) {
      for (let i = 1; i < 3 && i < this.fields.length; i++) {
        metaFields.push(this.fields[i]);
      }
    }
    return metaFields;
  }
}