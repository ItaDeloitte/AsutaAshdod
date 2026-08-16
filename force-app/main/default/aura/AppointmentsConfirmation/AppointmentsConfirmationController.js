/**@type {import("AppointmentsConfirmation").Controller} */
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
  onConfirm: function(cmp, event, helper) {
    helper.confirm(cmp);
  },
  onCancel: function(cmp, event, helper) {
    helper.cancel(cmp);
  }
});