/**@type {import("SurgeryAppointmentsCancelButton").Controller} */
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
  onCancelClick: function(cmp, event, helper) {
    helper.cancelClickHandler(cmp);
  }
});