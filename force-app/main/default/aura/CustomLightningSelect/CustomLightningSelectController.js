/**@type {import("CustomLightningSelect").Controller} */
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
  onChangeSelect: function(cmp, event, helper) {
    helper.emitChange(cmp);
  },
  onShowHelpMessageIfInvalid: function(cmp, event, helper) {
    helper.showHelpMessageIfInvalid(cmp);
  }
});