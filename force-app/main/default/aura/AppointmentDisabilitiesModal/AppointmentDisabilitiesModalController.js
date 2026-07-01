/**@type {import('AppointmentDisabilitiesModal').Controller} */
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
  onSubmit: function(cmp, event, helper) {
    helper.submitHandler(cmp);
  },
  onCancel: function(cmp, event, helper) {
    helper.cancelHandler(cmp);
  },
  onCloseErrors: function(cmp, event, helper) {
    helper.closeErrorsHandler(cmp);
  },
  onGroupChange: function(cmp, event, helper) {
    helper.groupChangeHandler(cmp);
  },
  onBack: function(cmp, event, helper) {
    helper.backHandler(cmp);
  },
  onGoToDisabilityStepHandler: function(cmp, event, helper) {
    helper.goToDisabilityStepHandler(cmp);
  },
  onAppointmentSearch: function(cmp, event, helper) {
    var lookupCmp = event.getSource();
    var params = event.getParams();
    var searchTerm = params.searchTerm;
    helper.appointmentSearchHandler(cmp, searchTerm, lookupCmp);
  },
  onAppointmentSelect: function(cmp, event, helper) {
    var lookupCmp = event.getSource();
    var selection = lookupCmp.getSelection();
    helper.appointmentSelectHandler(cmp, selection);
  }
});