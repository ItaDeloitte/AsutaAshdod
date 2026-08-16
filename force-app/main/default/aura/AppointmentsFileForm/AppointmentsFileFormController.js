/**@type {import("AppointmentsFileForm").Controller} */
({
  onInit: function(cmp, event, helper) {
    helper.init(cmp);
  },
  onDestroy: function(cmp, event, helper) {
    helper.destroy(cmp);
  },
  onRender: function(cmp, event, helper) {
    helper.render(cmp);
  },
  onCancel: function(cmp, event, helper) {
    helper.cancel(cmp);
  },
  onFormSuccess: function(cmp, event, helper) {
    var params = event.getParams(cmp);
    var fileData = params.response;
    helper.formSuccessHandler(cmp, fileData);
  },
  onFormError: function(cmp, event, helper) {
    console.log('onFormError', helper.unProxyData(event.getParams()));
  },
  onFormLoad: function(cmp, event, helper) {
    var recordInfo = event.getParam('recordUi');
    helper.formLoadHandler(cmp, recordInfo);
  },
  onSubmit: function(cmp, event, helper) {
    helper.submitForm(cmp);
  },
  onTest: function(cmp, event, helper) {
    var formData = helper.formData(cmp);
    if (!formData) {
      return;
    }
    var createRecordEvent = $A.get(
      helper.BASE_CONSTANTS.forceEventTypes.createRecord
    );
    var params = {
      entityApiName: 'File__c',
      recordTypeId: formData.RecordTypeId
    };
    createRecordEvent.setParams(params);
    createRecordEvent.fire();
  }
});