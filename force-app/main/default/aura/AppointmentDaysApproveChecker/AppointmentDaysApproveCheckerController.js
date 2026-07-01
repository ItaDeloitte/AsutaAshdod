/**@type {import("AppointmentDaysApproveChecker").Controller} */
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
  onDayConfirmation: function(cmp, event, helper) {
    var isConfirmed = event.getParam('value');
    helper.dayConfirmationHandler(cmp, isConfirmed);
  }
});