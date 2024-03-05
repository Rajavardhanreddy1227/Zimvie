import { LightningElement, track } from 'lwc';

export default class UnsupportedBrowser extends LightningElement {
  @track isUnsupportedBrowser = false;

  connectedCallback() {
    const isIE = this.detectInternetExplorer();
    this.isUnsupportedBrowser = isIE;
  }

  detectInternetExplorer() {
    const ua = window.navigator.userAgent;
    const msie = ua.indexOf('MSIE ');
    const trident = ua.indexOf('Trident/');
    const edge = ua.indexOf('Edge/');

    return msie > -1 || trident > -1 || edge > -1;
  }
}