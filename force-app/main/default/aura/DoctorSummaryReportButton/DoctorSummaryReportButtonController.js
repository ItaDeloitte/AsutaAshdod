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
  onRefresh: function(cmp, event, helper) {
    helper.fetchConfig(cmp);
  },
  onSendReportClick: function(cmp, event, helper) {
    helper.sendReport(cmp);
  }
})