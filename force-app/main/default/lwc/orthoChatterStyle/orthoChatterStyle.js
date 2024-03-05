import { LightningElement } from 'lwc';
import { loadStyle } from "lightning/platformResourceLoader";
import orthoStyle from "@salesforce/resourceUrl/ortho";

export default class OrthoChatterStyle extends LightningElement {
  renderedCallback() {
    loadStyle(this, orthoStyle)
  }
}