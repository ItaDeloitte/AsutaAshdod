/**@type {import("OmniUtilityItem").Controller} */
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
  onStatusChanged: function(cmp, event, helper) {},
  onLoginSuccess: function(cmp, event, helper) {},
  onWorkAccepted: function(cmp, event, helper) {
    var params = event.getParams();
    helper.workAcceptedHandler(cmp, params);
  }
});