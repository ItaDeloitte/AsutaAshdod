/**@type {import("SearchAccount").Controller} */
({
  onInit: function(cmp, event, helper) {
    helper.init(cmp);
  },
  onDestroy: function(cmp, event, helper) {
    helper.destroy(cmp);
  },
  onSubmit: function(cmp, event, helper) {
    event.preventDefault();
    helper.submit(cmp);
  },
  onCancel: function(cmp, event, helper) {
    helper.cancel(cmp);
  },
  onSearch: function(cmp, event, helper) {
    var params = event.getParam('value');
    var term = params.term;
    helper.searchAccounts(cmp, term).then(function(accounts) {
      params.done(accounts);
    });
  },
  onChangeData: function(cmp, event, helper) {
    var data = helper.data(cmp);
    if (data.idNumber) {
      helper.validateForm(cmp);
    }
    helper.checkAccountOption(cmp);
  },
  onChangeAutocomplete: function(cmp, event, helper) {
    var params = event.getParam('value');
    helper.changeAutocompleteHandler(cmp, params);
  },
  onChangeRoute: function(cmp, event, helper) {}
});