/**@type {import("AuraLwcBridge").Controller} */

({
  onInit: function (cmp, event, helper) {
    helper.init(cmp);
  },
  onDestroy: function (cmp, event, helper) {
    helper.destroy(cmp);
  },
  onRender: function (cmp, event, helper) {
    helper.render(cmp);
  },
  onDetachedInit: function (cmp, event, helper) {
    helper.registerAuraBridgeService(cmp, true);
  }
});