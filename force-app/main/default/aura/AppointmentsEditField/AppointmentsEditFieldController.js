/**@type {import("AppointmentsEditField").Controller} */
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
  onEdit: function(cmp, event, helper) {
    helper.editClickHandler(cmp);
  }
});