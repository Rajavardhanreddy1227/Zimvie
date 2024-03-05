({
  doInit: function (component, event, helper) {
    component.set("v.isLoading", true);
    helper.setCurrentPhotoVersionId(component).then(function () {
      component.set("v.isLoading", false);
    });
  },
  handleUploadFinished: function (component, event, helper) {
    component.set("v.isLoading", true);
    var contentDocumentId = event.getParam("files")[0].documentId;
    helper
      .isPhotoSizeAllowed(component, contentDocumentId)
      .then(function () {
        helper.setCurrentPhotoVersionId(component);
      })
      .then(function () {
        component.set("v.isLoading", false);
        $A.get('e.force:refreshView').fire();
      });
  }
});