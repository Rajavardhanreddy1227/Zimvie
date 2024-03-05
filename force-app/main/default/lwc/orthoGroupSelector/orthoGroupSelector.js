import { LightningElement, wire, api } from "lwc";
import getGroups from "@salesforce/apex/Ortho_CommunicationsController.getGroups";
import { NavigationMixin } from "lightning/navigation";


import Ortho_Group_Selector_Label from '@salesforce/label/c.Ortho_Group_Selector_Label'; 
import Ortho_Group_Selector_Placeholder from '@salesforce/label/c.Ortho_Group_Selector_Placeholder'; 

export default class OrthoGroupSelector extends NavigationMixin(
  LightningElement
) {
  @wire(getGroups) groups;
  @api value;
  @api objectApiName;
  @api recordId;

  labels = {
    Ortho_Group_Selector_Placeholder,
    Ortho_Group_Selector_Label
  }

  get options() {
    let options = this.groups.data.map(group => ({
      label: group.Name,
      value: group.GroupId
    }));
    options.unshift({ label: "All", value: "all" });
    return options;
  }

  handleChange(event) {
    this.value = event.detail.value;

    const group = this.groups.data.find(g => g.GroupId === this.value);
 
    let pageRef = { attributes: {} };
    if (group && group.Role === "Admin") {
      pageRef.type = 'standard__recordPage';
      pageRef.attributes = {
        recordId: group.GroupId,
        objectApiName: "CollaborationGroup",
        actionName: "view"
      }
     
      this.navigateTo(pageRef);

    } else if (this.objectApiName === "CollaborationGroup") {
      //navigate home
      pageRef.type = 'standard__navItemPage';
      pageRef.attributes = {
        apiName: "Communications"
      }
      pageRef.state = { c__groupId: 'test'}


      this.navigateTo(pageRef);

    } else {
      this.fireSelectionEvent(group);
    }
  }

  fireSelectionEvent(group){
    const selectionEvent = new CustomEvent("selection", {
      detail: { group }
    });
    this.dispatchEvent(selectionEvent);

  }
  navigateTo(pageRef) {
    this[NavigationMixin.Navigate](pageRef);
  }
}