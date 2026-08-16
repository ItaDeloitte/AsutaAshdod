/**@type {import("Case360LinkModal").Controller} */
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
  onTableRowAction: function(cmp, event, helper) {
    var params = event.getParams();
    var row = params.row;
    helper.linkAppointment(cmp, row);
  }
});