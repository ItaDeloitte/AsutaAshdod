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
    onSearchExpertise: function(cmp, event, helper) {
      var params = event.getParam('value');
      helper.searchExpertise(cmp, params.term).then(function(expertises) {
        params.done(expertises);
      });
    },
    onSearchSubExpertise: function(cmp, event, helper) {
      var params = event.getParam('value');
      helper.searchSubExpertise(cmp, params.term).then(function(subExpertises) {
        params.done(subExpertises);
      });
    },
    onSearchProcedure: function(cmp, event, helper) {
      var params = event.getParam('value');
      helper.searchProcedure(cmp, params.term).then(function(procedures) {
        params.done(procedures);
      });
    },
    expertiseIdChanged: function(cmp, event, helper) {
      helper.doSubExpertiseSearch(cmp);
    },
    subExpertiseIdChanged: function(cmp, event, helper) {
      helper.doProcedureSearch(cmp);
    }
});