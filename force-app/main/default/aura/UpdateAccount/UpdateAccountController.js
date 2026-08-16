/**@type {import("UpdateAccount").Controller} */
({
  onInit: function(cmp, event, helper) {
    helper.init(cmp);
  },
  onDestroy: function(cmp, event, helper) {
    helper.destroy(cmp);
  },
  onActionClicked: function(cmp, event, helper) {
    var params = event.getParams();
    var action = params.value;
    helper.actionClicked(cmp, action);
  }
});