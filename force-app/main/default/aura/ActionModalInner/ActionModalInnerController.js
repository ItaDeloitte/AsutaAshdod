/**@type {import("ActionModalInner").Controller} */ ({
  onInit: function(cmp, event, helper) {
    helper.init(cmp);
  },
  onScrollBody: function(cmp, event, helper) {
    helper.scrollBody(cmp);
  }
});