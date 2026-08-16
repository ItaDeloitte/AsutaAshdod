/**@type {import("OneClickActionModal").Controller} */
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
  onRetry: function(cmp, event, helper) {
    helper.emitActionClicked(cmp, 'retry');
  },
  onCancel: function(cmp, event, helper) {
    helper.emitActionClicked(cmp, 'cancel');
  }
});