/**@type {import("UpdateAccountApi").Controller} */
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
  onUpdate: function(cmp, event, helper) {
    var args = event.getParam('arguments');
    var accountId = args.accountId;
    return helper.update(cmp, accountId);
  }
});