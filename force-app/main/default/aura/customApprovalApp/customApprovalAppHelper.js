({
	approvalStatusChecker : function(component, event, helper){
        var getID = component.get("v.recordId");
        var action = component.get('c.approvalProcessStatus');
        console.log('Calling approvalProcessStatus - for : '+component.get("v.recordId"));
        action.setParams({"recordId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('state::'+state);
            if(state === "SUCCESS") {
                var resp = response.getReturnValue();
                if(resp == 'failure'){
                    console.log('response:::'+resp);
                    helper.showToast(component, event, helper, 'error', 'This record is already submitted','Error Message');
                    $A.get("e.force:closeQuickAction").fire(); 
                }
                else if (resp == 'failure-headcount'){
                    console.log('response:::'+resp);
                    helper.showToast(component, event, helper, 'error', 'There are no headcount added. Please add them before submission.','Error Message');
                    $A.get("e.force:closeQuickAction").fire(); 
                }
            } else {
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);
                    }
                } else {
                    console.log("Unknown error");
                }
                console.log('Problem getting account, response state: ' + state);
            }
        });
        $A.enqueueAction(action);        
    },
    goToSubmitApproval : function(component, event, helper){
        component.set('v.loaded', false);
        var getID = component.get("v.recordId");
        //console.log('Id:::'+getID);
        var getComment = component.get("v.comment");
        //alert('comments:::'+getComment);
        var action = component.get('c.submitAndProcessApprovalRequest');
        action.setParams({"recordId": component.get("v.recordId"), "comment": component.get("v.comment")});//need modification
        
        // Configure response handler
        
        console.log('action::'+JSON.stringify(action));
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                
                var resp = response.getReturnValue();
                console.log('response:::'+resp);
                if(!$A.util.isEmpty(resp) && resp == 'success') {
                    helper.showToast(component, event, helper, 'success', 'Your approval process successfully submitted!', 'Success Message');
                    $A.get("e.force:closeQuickAction").fire();
                    $A.get('e.force:refreshView').fire();
                }
                if((!$A.util.isEmpty(resp)) && (!$A.util.isUndefined(resp)) && resp.includes('first error:')) {
                    var showErrorList = [];
                    showErrorList = resp.split('first error: ');
                    helper.showToast(component, event, helper, 'error', showErrorList[1], 'Error Message');
                    var erromessage = showErrorList[1];
                    console.log('erromessage==='+erromessage);
                    $A.get("e.force:closeQuickAction").fire();
                }
                if(resp == 'failure'){
                    helper.showToast(component, event, helper, 'error', 'No Active Approval Process Found.','Error Message');
                    $A.get("e.force:closeQuickAction").fire();                    
                }
                component.set('v.loaded', false);
            } else {
                component.set('v.loaded', true);
                var errors = response.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log("Error message: " +
                                    errors[0].message);     
                    }
                } else {
                    console.log("Unknown error");
                }
                console.log('Problem getting account, response state: ' + state);
            }
        });
        $A.enqueueAction(action);
    }, 
    
    showToast : function(c, e, h, messageType, message, title) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            messageTemplate: '',
            duration:' 10000',
            key: 'info_alt',
            type: messageType,
            mode: 'dismissible'
        });
        toastEvent.fire();
    }
})