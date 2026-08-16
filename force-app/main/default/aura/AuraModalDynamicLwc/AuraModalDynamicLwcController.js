/**@type {import("AuraModalDynamicLwc").Controller} */
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
  onClose: function(cmp, event, helper) {
    event.stopPropagation();
    helper.close(cmp, event.detail);
  }
});