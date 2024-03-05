import {
  LightningElement,
  api,
  wire,
  track
} from 'lwc';
import {
  updateRecord
} from 'lightning/uiRecordApi';
import {
  ShowToastEvent
} from 'lightning/platformShowToastEvent';

import {
  NavigationMixin
} from 'lightning/navigation';
import fetchTeams from '@salesforce/apex/Ortho_TerritoryLookupController.fetchTeams';
import updateOpportunityWithTeam from '@salesforce/apex/Ortho_TerritoryLookupController.updateOpportunityWithTeam';
import getOpportunityDetail from '@salesforce/apex/Ortho_TerritoryLookupController.getOpportunityDetail';

import selectTeamLabel from '@salesforce/label/c.Ortho_Select_Team';
import submitButton from '@salesforce/label/c.Submit_Button';
import cancelButton from '@salesforce/label/c.Cancel_Button';

import terrNotAvailable from '@salesforce/label/c.Ortho_Reassign_Territories_Not_Available';
import unableToUpdate from '@salesforce/label/c.Ortho_Reassign_unable_to_update';
import teamNotSelected from '@salesforce/label/c.Ortho_Reassign_Team_Not_Selected';
import selectAtleastOneTeam from '@salesforce/label/c.Ortho_Reassign_select_one_team';

export default class Ortho_TerritoryLookupController extends NavigationMixin(LightningElement) {

  label = {
    selectTeamLabel,
    submitButton,
    cancelButton,
    terrNotAvailable,
    unableToUpdate,
    teamNotSelected,
    selectAtleastOneTeam
  };

  @track listOfSearchRecords = [];

  @api recordId;

  @api opportunityid;

  @api oppRecord;

  @track value = "";

  @api showCancelButton = "true";

  @api showButton = "true";

  @api viewFrom = "LC";

  @track
  showTeamSelection = false;

  @track isError = false;

  @track
  errorMessage = this.label.terrNotAvailable;

  get isSuccess() {
    return !this.isError;
  }

  get options() {
    let addList = [];

    // eslint-disable-next-line guard-for-in
    for (let i in this.listOfSearchRecords) {
      addList.push({
        label: this.listOfSearchRecords[i].Name,
        value: this.listOfSearchRecords[i].Id,
        selected: this.listOfSearchRecords[i].Id === this.value ? 0 : 1
      });
    }

    if (addList.length > 0) {
      addList.sort(function (a, b) {
        return a.selected - b.selected;
      });
    }
    return addList;
  }

  connectedCallback() {
    let strRecordId = this.recordId ? (this.recordId + '') : this.opportunityid;
    this.opportunityid = strRecordId;
    console.log('LWC Show Button'+this.showButton);
    console.log('LWC viewFrom'+this.viewFrom);
    this.fetchTeamRecords();
    
  }

  fetchTeamRecords() {
    fetchTeams({
      oppId: this.opportunityid
    }).then(result => {
      this.showTeamSelection = true;
      if (result.length > 0) {
        this.listOfSearchRecords = result;
        this.isError = false;

        getOpportunityDetail({
          oppId: this.opportunityid
        }).then(opp => {
          this.oppRecord = opp;
          this.value = opp.Territory2Id;
        });

      } else {
        this.isError = true;
      }
    }).catch(() => {
      this.isError = true;
    });
  }

  onSubmitClick() {
    console.log('on submit click opp');
    let submitBlock = this.template.querySelector("[data-id=submitBlock]");
    let spinnerBlock = this.template.querySelector("[data-id=spinnerBlock]");
    if (typeof submitBlock !== "undefined" && submitBlock != null) {
      submitBlock.classList.add("slds-hide");
    }
    if (typeof spinnerBlock !== "undefined" && spinnerBlock != null) {
      spinnerBlock.classList.remove("slds-hide");
    }

    let terrId;

    let ipField = this.template.querySelector("[data-id=ipField]");
    terrId = ipField.value;

    if (terrId != null) {

      updateOpportunityWithTeam({
        oppId: this.opportunityid,
        territoryId: terrId
      }).then(() => {
        console.log('updating opp From LWC'); 
        this.refresh();
      }).catch(error => {
        console.log(error);
        this.errorMessage = this.label.unableToUpdate;
        if (typeof error.body != 'undefined' && typeof error.body.pageErrors != 'undefined' && error.body.pageErrors.length > 0) {
          this.errorMessage = error.body.pageErrors[0].message;
        } else if (typeof error.body != 'undefined' && typeof error.body.message != 'undefined') {
          this.errorMessage = error.body.message;
        }

        this.isError = true;
        spinnerBlock.classList.add("slds-hide");
        submitBlock.classList.remove("slds-hide");
      });
    }

     else {
      const evt = new ShowToastEvent({
        title: this.label.teamNotSelected,
        message: this.label.selectAtleastOneTeam,
        variant: 'error'
      });
      this.dispatchEvent(evt);
        
      spinnerBlock.classList.add("slds-hide");
      submitBlock.classList.remove("slds-hide");
    }

  }

  onCancelClick() {
    console.log('oppId in child' + this.opportunityid);
    /*this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.opportunityid,
        actionName: 'view'
      }
    });*/
    this.dispatchEvent(new CustomEvent("close", {}));
    //this.dispatchEvent(new CustomEvent("close", {event:this.opportunityid}));
  }

  refresh() {
    updateRecord({
      fields: {
        Id: this.opportunityid
      }
    });

    console.log('refreshing opp');
    /*this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.opportunityid,
        actionName: 'view'
      }
    });*/
    
    this.dispatchEvent(new CustomEvent("close", {}));
    this.dispatchEvent(new CustomEvent("save", {}));
    
  }


}