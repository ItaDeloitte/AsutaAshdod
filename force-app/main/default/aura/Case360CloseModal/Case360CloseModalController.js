/**@type {import("Case360CloseModal").Controller} */
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

  onSubmit: function(cmp, event, helper) {
    helper.submit(cmp);
  },

  onCancel: function(cmp, event, helper) {
    helper.cancel(cmp);
  }
});