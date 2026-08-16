/**@type {import("BaseRelatedAutocomplete").Controller} */
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
  onChangeOption: function(cmp, event, helper) {
    helper.emitChange(cmp);
  }
});