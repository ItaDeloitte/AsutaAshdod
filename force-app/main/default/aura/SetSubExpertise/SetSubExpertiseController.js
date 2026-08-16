/**@type {import("SetSubExpertise").Controller} */
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
  onCancel: function(cmp, event, helper) {
    helper.cancel(cmp);
  },
  onSubmit: function(cmp, event, helper) {
    helper.setLookup(cmp);
  },
  onSearch: function(cmp, event, helper) {
    var params = event.getParam('value');
    helper.searchExpertiseOptions(cmp, params.term).then(function(options) {
      params.done(options);
    });
  }
});