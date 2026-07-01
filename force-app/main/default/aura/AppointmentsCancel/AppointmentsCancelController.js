/**@type {import("AppointmentsCancel").Controller} */
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
  onNext: function(cmp, event, helper) {
    helper.nextStep(cmp);
  },
  onPrev: function(cmp, event, helper) {
    helper.prevStep(cmp);
  },
  onInitSearch: function(cmp, event, helper) {
    var params = event.getParam('value');
    params.done(null);
  },
  onSearch: function(cmp, event, helper) {
    var params = event.getParam('value');
    var done = params.done;
    helper.searchAppointments(cmp, params.term, 'cancel').then(done);
  },
  onSelectAppointment: function(cmp, event, helper) {
    var params = event.getParam('value');
    helper.selectAppointmentHandler(cmp, params.option);
  }
});