({
    doInit : function(component, event, helper) {
        console.log('--Show Button1--'+component.get("v.showButton"));
        console.log('--View From1--'+component.get("v.viewFrom"));
        
        var view = component.get("v.viewFrom");
        var recId = component.get("v.recordId");
        console.log('-Record Id Passed-'+recId);
        console.log('-Record Id length-'+recId.length);
        
        if(recId != 'undefined' && recId.length != 0 && view == 'VFPage' ){
            component.set("v.showButton",false);
        }
        console.log('--Show Button2--'+component.get("v.showButton"));
    },
    
    handleOnClose: function (component) {
        
        var view = component.get("v.viewFrom");
        console.log('-Close viewFrom-'+view);
        
        if(view == 'LC'){
            $A.get("e.force:closeQuickAction").fire();
        }
    },
    
    handleOnSave: function (component) {
        
        var view = component.get("v.viewFrom");
        console.log('-Save viewFrom-'+view);
        
        if(view == 'VFPage'){
            var msg = component.get("v.showMsg");
            component.set("v.showMsg",true);
            console.log('-showMsg-'+component.get("v.showMsg"));
        }
        else{
            $A.get("e.force:closeQuickAction").fire();
            $A.get("e.force:refreshView").fire();
        }
    }
})