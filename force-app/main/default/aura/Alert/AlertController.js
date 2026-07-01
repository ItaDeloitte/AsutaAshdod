/**@type {import("Alert").Controller} */
({
  onInit: function(cmp, event, helper) {
    helper.init(cmp);
  },
  onClose: function(cmp, event, helper) {
    helper.emitClose(cmp);
  }
});