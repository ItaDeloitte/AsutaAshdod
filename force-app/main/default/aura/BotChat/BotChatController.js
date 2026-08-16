({
  onInit: function(cmp, event, helper) {
    helper.init(cmp);
  },
  onDestroy: function(cmp, event, helper) {
    helper.destroy(cmp);
  },
  onStart: function(cmp, event, helper) {
    helper.startChat(cmp);
  }
});