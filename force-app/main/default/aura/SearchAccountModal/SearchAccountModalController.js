/**@type {import("SearchAccountModal").Controller} */
({
  onInit: function(cmp, event, helper) {
    helper.init(cmp);
  },
  onDestroy: function(cmp, event, helper) {
    helper.destroy(cmp);
  },
  onCancel: function(cmp, event, helper) {
    helper.cancel(cmp);
  }
});