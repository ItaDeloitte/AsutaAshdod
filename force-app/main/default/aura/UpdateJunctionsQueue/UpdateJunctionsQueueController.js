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
    onSubmit: function(cmp, event, helper) {
      helper.submit(cmp);
    },
    onInitSearch: function(cmp, event, helper) {
      var params = event.getParam('value');
      params.done(null);
    },
    onSearch: function(cmp, event, helper) {
      var params = event.getParam('value');
      helper.searchQueues(cmp, params.term).then(params.done);
    }
  });