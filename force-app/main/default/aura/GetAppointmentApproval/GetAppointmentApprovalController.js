/**@type {import("GetAppointmentApproval").Controller} */
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
  onActionClicked: function(cmp, event, helper) {
    var params = event.getParams();
    var action = params.value;
    helper.actionClicked(cmp, action);
  }
});