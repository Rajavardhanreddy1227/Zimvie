import { LightningElement, api, wire, track } from "lwc";
import loadUserRecords from "@salesforce/apex/listOfRecordsToUpdateController.loadUserRecords";
import toggleUserActivation from "@salesforce/apex/OktaServiceHelper.toggleUserActivation";
import contextApi from "commerce/contextApi";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { refreshApex } from "@salesforce/apex";
import userId from "@salesforce/user/Id";
import Member_Details from "@salesforce/label/c.Member_Details";
import Add_Member from "@salesforce/label/c.Add_Member";
import Activate_User_Confirmation from "@salesforce/label/c.Activate_User_Confirmation";
import Deactivate_User_Confirmation from "@salesforce/label/c.Deactivate_User_Confirmation";
import Activation_Msg from "@salesforce/label/c.Activation_Msg";
import Deactivation_Msg from "@salesforce/label/c.Deactivation_Msg";
import ToastContainer from 'lightning/toastContainer';
import B2B_Manage_Member_Success_Msg from '@salesforce/label/c.B2B_Manage_Member_Success_Msg';
import B2B_Success_Label from '@salesforce/label/c.B2B_Success_Label';

const columns = [
  { label: "Name", fieldName: "Name" },
  { label: "Email", fieldName: "Email", type: "email" },
  { label: "Active", fieldName: "IsActive", type: "boolean" },
];

export default class B2bManageMembers extends LightningElement {
    loader = false;
    records = [];
    error;
    columns = columns;
    _accid;
    labels = {
        Member_Details,
        Add_Member,
        Activate_User_Confirmation,
        Deactivate_User_Confirmation,
        Deactivation_Msg,
        Activation_Msg,
        B2B_Manage_Member_Success_Msg,
        B2B_Success_Label
    };
    @api objectApiName = "User";
    @api fieldsName =
        "Id,Name,Email,ContactId,Contact.Name,Contact.Email,Contact.Okta_Deactivate_Link__c,IsActive";
    @api lookupField = "AccountId";
    userId = userId;
    @api
    set accid(val) {
        console.log("accid in list lwc is " + val);
        this._accid = val;
    }
    get accid() {
        return this._accid;
    }
    isAddMember;
    flowApiName = "B2B_Create_Member"; // api name of your flow
    reqParam = {};
    actionMsg ='';
    isConfirmBox;
    // Setting flow input variables
    @track flowInputVariables = [];

    constructor() {
        super();
        this.columns = this.columns.concat([
        { type: "action", typeAttributes: { rowActions: this.getRowActions } },
        ]);
    }
    // do something when flow status changed
    handleFlowStatusChange(event) {
        console.log("flow status", event.detail.status);

        if (event.detail.status === "FINISHED") {
        this.isAddMember = false;
        this.dispatchEvent(
            new ShowToastEvent({
            title: this.labels.B2B_Success_Label,
            message: this.labels.B2B_Manage_Member_Success_Msg,
            variant: "success",
            }),
        );
        }
    }

    connectedCallback() {
        const toastContainer = ToastContainer.instance();
        toastContainer.maxShown = 5;
        toastContainer.toastPosition = 'top-center';

        console.log("calling members");
        const result = contextApi.getSessionContext();
        result
        .then((response) => {
            console.log("getSessionContext result");
            console.log(response);
            this.accid = response.effectiveAccountId;
            let flowinput = {
            name: "accountId",
            type: "String",
            value: this.accid,
            };
            this.flowInputVariables.push(flowinput);
            this.loadUserRecords();
        })
        .catch((error) => {
            console.log("getSessionContext result");
            console.log(error);
        });
    }

    loadUserRecords() {
       this.records = [];
        this.loader = true;
        loadUserRecords({
        objectApiName: this.objectApiName,
        fieldsName: this.fieldsName,
        accid: this.accid,
        })
        .then((data) => {
            console.log("member records");
            console.log(data);
            let records = JSON.parse(data);
            let tempArr = [];
            let counter = 1;
            records.forEach(function (currentItem, index) {
            let tempobj = {};
            if (userId != currentItem.Id) {
                tempobj.Id = currentItem.Id;
                tempobj.Email = currentItem.Contact.Email;
                tempobj.Name = currentItem.Contact.Name;
                tempobj.IsActive = currentItem.IsActive ? "Active" : "Inactive";
                tempobj.btnLabel = currentItem.IsActive ? "Deactivate" : "Activate";
                tempobj.deactivateLink =
                currentItem.Contact.Okta_Deactivate_Link__c;
                tempobj.index = counter;
                tempobj.indexKey = "index" + counter;
                tempobj.nameKey = "name" + counter;
                tempobj.ActiveKey = "IsActive" + counter;
                tempobj.deactivateLinkKey = "deactivateLink" + counter;
                tempobj.idKey = "id" + counter;
                counter++;
                tempArr.push(tempobj);
            }
            });
            this.records = [...tempArr]; // all records
            console.log("RecordsList");
            console.log(this.records);
            this.loader = false;
            
        })
        .catch((error) => {
            console.log("member records error");
            console.log(error);
            this.error = error;
            this.loader = false;
        });
    }

    getRowActions(row, doneCallback) {
        const actions = [];

        if (row["IsActive"]) {
        actions.push({
            label: "Deactivate",
            iconName: "utility:block_visitor",
            name: "deactivate",
        });
        } else {
        actions.push({
            label: "Activate",
            iconName: "utility:adduser",
            name: "activate",
        });
        }
        setTimeout(() => {
        doneCallback(actions);
        }, 200);
    }

    async toggleUserActivation() {
    
        this.loader = true;
        this.isConfirmBox = false;
        console.log("toggleUserActivation Request ", this.reqParam);
        await toggleUserActivation({ requestParam: this.reqParam })
        .then((data) => {
            console.log("toggleUserActivation response ", data);
             this.loadUserRecords();
             this.loader = false;
            
           
        })
        .catch((error) => {
            console.log("toggleUserActivation error ", error);
            this.loader = false;
        });
        let msg = this.reqParam.action == 'activate' ? this.labels.Activation_Msg  : this.labels.Deactivation_Msg;
        await this.dispatchEvent(
            new ShowToastEvent({
                    title: "Success",
                    message: msg,
                    variant: "success",
                })
            );
             
     
    }

    async handleActionOnRow(event){
        let recId = event.target.dataset.id;
        const foundObject = this.records.find(obj => obj.Id === recId);

        
        this.reqParam.userId = foundObject.Id;
        this.reqParam.deactivateLink = foundObject.deactivateLink;
        this.reqParam.action = foundObject.btnLabel.toLowerCase();

        this.actionMsg = this.reqParam.action == 'activate' ? this.labels.Activate_User_Confirmation : this.labels.Deactivate_User_Confirmation;
        console.log('Action Message',this.actionMsg);
         this.isConfirmBox = true;
        //  await this.toggleUserActivation();

        
        

    }

    handleCancelConfirmation(){
        this.isConfirmBox = false;
    }
  /*testmethod(event) {
    let dataKey = event.target?.getAttribute("data-key");
    let nameElement = this.template.querySelector(
      '[data-key="name' + dataKey + '"]',
    );
    let isActiveElement = this.template.querySelector(
      '[data-key="IsActive' + dataKey + '"]',
    );
    let deactivateLinkElement = this.template.querySelector(
      '[data-key="deactivateLink' + dataKey + '"]',
    );
    let idElement = this.template.querySelector(
      '[data-key="id' + dataKey + '"]',
    );

    console.log("Data Element Key ----", dataKey);
    console.log("Name Element----", nameElement);
    console.log("Event----", event);
    console.log("Name Element innerHTML----", nameElement.innerHTML);
    console.log("Active Element innerHTML----", isActiveElement.innerHTML);
    console.log(
      "DeactiveLink Element innerText----",
      deactivateLinkElement.innerText,
    );
    console.log("idElement Element innerText----", idElement.innerText);
    var actionParam = {};
    actionParam.userId = idElement.innerText.trim();
    actionParam.deactivateLink = deactivateLinkElement.innerText.trim();
    actionParam.action = isActiveElement.innerText.trim();
    this.handleRowActionevent(actionParam);
    // if(deactivateLinkElement!=null){
    // console.log('DeactivateLinkElement Element innerText----',deactivateLinkElement.innerText);
    // }
  }
  handleRowActionevent(actionParam) {
    // const actionName = event.detail.action.name;
    // const row = event.detail.row;
    const actionName = actionParam.action.toLowerCase();
    console.log("selected Row", actionParam);
    var reqParam = {};
    reqParam.userId = actionParam.userId;
    reqParam.deactivateLink = actionParam.deactivateLink;
    reqParam.action = actionName;
    console.log("Action Name", actionName);
    switch (actionName) {
      case "deactivate":
        console.log("Request Param Deactive", reqParam);
        this.toggleUserActivation(reqParam);
        // this.dispatchEvent(
        // 	new ShowToastEvent({
        // 		title: "Success",
        // 		message: "Member is reactivated.",
        // 		variant: "success",
        // 	})
        // );
        // setTimeout(function () {
        //     window.location.reload(true);
        //   }, 5000);
        break;
      case "activate":
        console.log("Request Param active", reqParam);
        this.toggleUserActivation(reqParam);
        // this.dispatchEvent(
        // 	new ShowToastEvent({
        // 		title: "Success",
        // 		message: "Member is deactivated.",
        // 		variant: "success",
        // 	})
        // );
        // setTimeout(function () {
        //     window.location.reload(true);
        //   }, 5000);
        break;
      default:
    }
  }
  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;
    console.log("selected Row", row);
    var reqParam = {};
    reqParam.userId = row.Id;
    reqParam.deactivateLink = row.deactivateLink;
    reqParam.action = actionName;
    switch (actionName) {
      case "deactivate":
        this.toggleUserActivation(reqParam);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Member is deactivated.",
            variant: "success",
          }),
        );
        setTimeout(function () {
          window.location.reload(true);
        }, 5000);
        break;
      case "activate":
        this.toggleUserActivation(reqParam);
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Success",
            message: "Member is reactivated.",
            variant: "success",
          }),
        );
        setTimeout(function () {
          window.location.reload(true);
        }, 5000);
        break;
      default:
    }
  }*/
  handleAddMember() {
    this.isAddMember = true;
  }
  handleClose() {
    this.isAddMember = false;
  }
  /* @wire(loadUserRecords, {objectApiName:'$objectApiName', fieldsName:'$fieldsName', accid:'$accid'})

    loadUserRecords({ error, data })
    {

        if(data)
        {
             console.log('member records');
            console.log(data);
            let records = JSON.parse(data);
            this.records = records; // all records
            console.log(this.records);

        }
        else if (error)
        {
            console.log('member records error');
            console.log(error);
            this.error = error;

        }
    }*/
}