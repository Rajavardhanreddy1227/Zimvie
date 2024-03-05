import { LightningElement, wire } from 'lwc';
import getAnnouncements from '@salesforce/apex/Ortho_CommunicationsController.getAnnouncements';


export default class OrthoCommunications extends LightningElement {
  @wire(getAnnouncements) announcements;
}