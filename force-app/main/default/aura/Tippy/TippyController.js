/**@type {import("Tippy").Controller} */
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
  onScriptsLoaded: function(cmp, event, helper) {
    helper.config(cmp);
  }
});