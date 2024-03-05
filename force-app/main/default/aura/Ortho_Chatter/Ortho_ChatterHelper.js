({
    getGroups : function(cmp) {
        var action = cmp.get("c.getGroups");
        return new Promise((resolve,reject) => {
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                if (state === "ERROR"){
                    reject(response);
                }
            });
            $A.enqueueAction(action);
        })
    },
    isGroupAdmin : function(cmp, groupId){
        var action = cmp.get("c.isGroupAdmin");
        action.setParams({ groupId });

        return new Promise((resolve,reject) => {
            action.setCallback(this, function(response){
                var state = response.getState();
                if (state === "SUCCESS") {
                    resolve(response.getReturnValue());
                }
                if (state === "ERROR"){
                    reject(response);
                }
            });
            $A.enqueueAction(action);
        })
    }
})