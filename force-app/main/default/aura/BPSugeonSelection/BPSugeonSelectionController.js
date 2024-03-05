({
    doInit: function(component, event, helper) {
        helper.doInitHelper(component, event, 'Market_Procedures__c');
    },
    filter: function(component, event, helper) {
        var term = component.get("v.filter");
        var seg = component.get("v.segment");
        console.log('Term-->>' + term);
        console.log('segment-->>' + seg);
        try {
            if(term == ''){
                helper.doInitHelper(component, event, 'Market_Procedures__c', '',seg == '' ? '' : seg);
            }else{
                helper.doInitHelper(component, event, 'Market_Procedures__c', term,seg == '' ? '' : seg);
            }
        } catch(e) {
            // invalid regex, use full list
        }
    },
    /* javaScript function for pagination */
    navigation: function(component, event, helper) {
        var sObjectList = component.get("v.listOfAllAccounts");
        var end = component.get("v.endPage");
        var start = component.get("v.startPage");
        var pageSize = component.get("v.pageSize");
        var whichBtn = event.getSource().get("v.name");
        // check if whichBtn value is 'next' then call 'next' helper method
        if (whichBtn == 'next') {
            component.set("v.currentPage", component.get("v.currentPage") + 1);
            helper.next(component, event, sObjectList, end, start, pageSize);
        }
        // check if whichBtn value is 'previous' then call 'previous' helper method
        else if (whichBtn == 'previous') {
            component.set("v.currentPage", component.get("v.currentPage") - 1);
            helper.previous(component, event, sObjectList, end, start, pageSize);
        }
    },
    
    sortSurgeonName: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.     
        component.set("v.selectedTabsoft", 'Surgeon_Name__r.name');
        // call the helper function with pass sortField Name   
        helper.sortHelper(component, event, 'Surgeon_Name__r.name');
     },
  
     sortSegementation: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.    
        component.set("v.selectedTabsoft", 'Segementation__c');
        // call the helper function with pass sortField Name  
        helper.sortHelper(component, event, 'Segementation__c');
     },
     sortAlignedTeam: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.    
        component.set("v.selectedTabsoft", 'Aligned_Team__c');
        // call the helper function with pass sortField Name  
        helper.sortHelper(component, event, 'Aligned_Team__c');
     },
     sortMarketProcedure: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.        
        component.set("v.selectedTabsoft", 'Market_Procedures__c');
        // call the helper function with pass sortField Name    
        helper.sortHelper(component, event, 'Market_Procedures__c');
     },
     sortZBProcedure: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.        
        component.set("v.selectedTabsoft", 'Zimmer_Biomet_Procedures__c');
        // call the helper function with pass sortField Name    
        helper.sortHelper(component, event, 'Zimmer_Biomet_Procedures__c');
     },
     sortmailingCity: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.        
        component.set("v.selectedTabsoft", 'Surgeon_Name__r.PersonMailingCity');
        // call the helper function with pass sortField Name    
        helper.sortHelper(component, event, 'Surgeon_Name__r.PersonMailingCity');
     },
     
     sortmailingState: function(component, event, helper) {
        // set current selected header field on selectedTabsoft attribute.        
        component.set("v.selectedTabsoft", 'Surgeon_Name__r.PersonMailingState');
        // call the helper function with pass sortField Name    
        helper.sortHelper(component, event, 'Surgeon_Name__r.PersonMailingState');
     },

    selectAllCheckbox: function(component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var updatedAllRecords = [];
        var updatedPaginationList = [];
        var listOfAllAccounts = component.get("v.listOfAllAccounts");
        var PaginationList = component.get("v.PaginationList");
        // play a for loop on all records list 
        for (var i = 0; i < listOfAllAccounts.length; i++) {
            // check if header checkbox is 'true' then update all checkbox with true and update selected records count
            // else update all records with false and set selectedCount with 0  
            if (selectedHeaderCheck == true && listOfAllAccounts[i].bptarget == false) {
                console.log('Check BP target-->'+listOfAllAccounts[i].bptarget );
                listOfAllAccounts[i].isChecked = true;
                component.set("v.selectedCount", listOfAllAccounts.length);
            } else {
                console.log('Check BP target Exp TRUE-->'+listOfAllAccounts[i].bptarget );
                listOfAllAccounts[i].isChecked = false;
                component.set("v.selectedCount", 0);
            }
            updatedAllRecords.push(listOfAllAccounts[i]);
        }
        // update the checkbox for 'PaginationList' based on header checbox 
        for (var i = 0; i < PaginationList.length; i++) {
            if (selectedHeaderCheck == true) {
                PaginationList[i].isChecked = true;
            } else {
                PaginationList[i].isChecked = false;
            }
            updatedPaginationList.push(PaginationList[i]);
        }
        component.set("v.listOfAllAccounts", updatedAllRecords);
        component.set("v.PaginationList", updatedPaginationList);
    },
 
    checkboxSelect: function(component, event, helper) {
        // on each checkbox selection update the selected record count 
        var selectedRec = event.getSource().get("v.value");
        var getSelectedNumber = component.get("v.selectedCount");
        if (selectedRec == true) {
            getSelectedNumber++;
        } else {
            getSelectedNumber--;
            component.find("selectAllId").set("v.value", false);
        }
        component.set("v.selectedCount", getSelectedNumber);
        // if all checkboxes are checked then set header checkbox with true   
        if (getSelectedNumber == component.get("v.totalRecordsCount")) {
            component.find("selectAllId").set("v.value", true);
        }
    },
 
    getSelectedRecords: function(component, event, helper) {
        var allRecords = component.get("v.listOfAllAccounts");
        var selectedRecords = [];
        for (var i = 0; i < allRecords.length; i++) {
            if (allRecords[i].isChecked) {
                selectedRecords.push(allRecords[i].objAccount);
            }
        }
        //alert(JSON.stringify(selectedRecords));
        
        // call the helper function and pass all selected record id's.    
        helper.OpportunitySelectedHelper(component, event, selectedRecords);
    },   
    // this function automatic call by aura:waiting event  
    showSpinner: function(component, event, helper) {
        // make Spinner attribute true for display loading spinner 
         component.set("v.Spinner", true); 
    },
     
    // this function automatic call by aura:doneWaiting event 
    hideSpinner : function(component,event,helper){
    // make Spinner attribute to false for hide loading spinner    
    component.set("v.Spinner", false);
    },
})