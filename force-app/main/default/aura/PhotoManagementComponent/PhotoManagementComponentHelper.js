({
  setCurrentPhotoVersionId: function (component) {
    return new Promise(
      $A.getCallback((resolve, reject) => {
        var action = component.get("c.getCurrentPhotoVersionIdCtr");
        action.setParams({ recordId: component.get("v.recordId") });
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state == "SUCCESS") {
            let attachmentId = response.getReturnValue();
            component.set("v.attachmentId", attachmentId);
            resolve();
          } else if (state === "ERROR") {
            this.handleActionErrors(response.getError());
            reject();
          }
        });
        $A.enqueueAction(action);
      })
    );
  },

  isPhotoSizeAllowed: function (component, contentDocumentId) {
    return new Promise(
      $A.getCallback((resolve, reject) => {
        var action = component.get("c.isPhotoSizeAllowedCtr");
        action.setParams({
          contentDocumentId: contentDocumentId,
          recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
          var state = response.getState();
          if (state == "SUCCESS") {
            let isPhotoSizeAllowed = response.getReturnValue();
            if (isPhotoSizeAllowed) {
              this.showToast("Success", "Photo uploaded sucessfully");
              resolve(true);
            } else {
              this.showToast(
                "Warning",
                "File size can't be greater than 5 MB"
              );
              resolve(false);
            }
          } else if (state === "ERROR") {
            this.handleActionErrors(response.getError());
            reject();
          }
        });
        $A.enqueueAction(action);
      })
    );
  },

  showToast: function (type, message) {
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      type: type,
      message: message
    });
    toastEvent.fire();
  },

  handleActionErrors: function (errors) {
    if (errors) {
      if (errors[0] && errors[0].message) {
        this.showToast("Error", "Error: " + errors[0].message);
      }
    }
  }
});