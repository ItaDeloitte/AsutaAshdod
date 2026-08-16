/**@type {import("DocExpertShowButton").Controller} */
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
  onShowModal: function(cmp, event, helper) {
    helper.showModalByMode(cmp);
  },
  onShowUpdateDashboard: function(cmp, event, helper) {
    var appointment = event.getParam('value');
    helper.showAppointmentsUpdate(cmp, appointment);
  }
});