/**@type {import("AppointmentsUpdate").Controller} */
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
    helper.next(cmp);
  },
  onInitSearch: function(cmp, event, helper) {
    var params = event.getParam('value');
    params.done(null);
  },
  onSearch: function(cmp, event, helper) {
    var params = event.getParam('value');
    var term = params.term;
    var done = params.done;
    helper.searchAppointments(cmp, term, 'update').then(done);
  },
  onSelectAppointment: function(cmp, event, helper) {
    var params = event.getParam('value');
    helper.selectAppointment(cmp, params.option);
  }
});