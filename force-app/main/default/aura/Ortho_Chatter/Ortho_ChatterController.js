({
    onPageReferenceChange: function(component, event, helper){
        var pr = component.get('v.pageReference');
    },
    handleSelection: function(component, event, helper){
        var group = event.getParam('group');
    
        var feedOpts = {type: 'Groups', subjectId: ''};
        if(group){
            feedOpts.type = 'Record';
            feedOpts.subjectId = group.GroupId;
        }

        component.set("v.type", feedOpts.type);
        component.set("v.subjectId", feedOpts.subjectId);

        $A.createComponent("forceChatter:feed", {"type": feedOpts.type, subjectId: feedOpts.subjectId}, function(feed) {
            var feedContainer = component.find("feedContainer");
            feedContainer.set("v.body", feed);
        });
    }
})