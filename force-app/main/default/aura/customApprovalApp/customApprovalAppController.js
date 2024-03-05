({
    doInit : function(component, event, helper) {
        helper.approvalStatusChecker(component, event, helper);
    },
    handleClick : function (component, event, helper) {
        helper.goToSubmitApproval(component, event, helper);
    }
})