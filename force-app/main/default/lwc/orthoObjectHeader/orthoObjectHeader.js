import { LightningElement, api, wire } from "lwc";
import { getObjectInfo } from "lightning/uiObjectInfoApi";
import { getRecord, getFieldValue } from "lightning/uiRecordApi";

export default class OrthoObjectHeader extends LightningElement {
  @api iconName;
  @api recordId;
  @api objectApiName;
  nameFields;


  @wire(getRecord, { recordId: '$recordId', fields: "$nameFields" })
  details;

  @wire(getObjectInfo, { objectApiName: "$objectApiName" })
  wireObjectInfo({err, data}){
    if(data){
      this.nameFields = data.nameFields.map(field => `${data.apiName}.${field}`);
    }
  }

  get icon() {
    return this.iconName || `standard:${this.objectApiName.toLowerCase()}`;
  }
   
  get title() {
    if(this.nameFields){
      return getFieldValue(this.details.data, this.nameFields[0]);
    }
  }

  inspectObjectInfo() {
    console.log(JSON.stringify(this.objectInfo));
  }
}