import { LightningElement, api } from 'lwc';

import Ortho_Communications_Posted_By from '@salesforce/label/c.Ortho_Communications_Posted_By';
export default class OrthoCommunicationsPost extends LightningElement {

  @api communication;

  labels = {
    Ortho_Communications_Posted_By
  }
  get text() {
    const text = this.find(this.communication.body.messageSegments, 'type', 'Text');
    return text;
  }

  get name() {
    return this.communication.actor.displayName;
  }

  get relativeDate() {
    return this.communication.relativeCreatedDate;
  }

  get parentName() {
    return this.communication.parent.name;
  }

  get photoUrl() {
    return this.communication.photoUrl;
  }

  get views() {
    return (this.communication.capabilities.readBy && this.communication.capabilities.readBy.page && this.communication.capabilities.readBy.page.total) || '';
  }

  find(recs, key, value){
    var ret;
    if(recs){
      recs.forEach((rec) => {
        if(rec[key] === value){
          ret = rec;
        }
      })
    }
    
    return ret;
  }
}