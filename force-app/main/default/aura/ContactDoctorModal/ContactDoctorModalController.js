/**@type {import("ContactDoctorModal").Controller} */
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
  onNext: function(cmp, event, helper) {
    helper.nextStep(cmp);
  },
  onPrev: function(cmp, event, helper) {
    helper.prevStep(cmp);
  },
  onCancel: function(cmp, event, helper) {
    helper.cancel(cmp);
  },
  onAutocompleteInitSearch: function(cmp, event, helper) {
    var cmpSource = event.getSource();
    var name = helper.attribute(cmpSource, 'name');
    var params = event.getParam('value');
    var term = params.term;
    var done = params.done;
    done(null);
  },

  onAutocompleteSearch: function(cmp, event, helper) {
    var cmpSource = event.getSource();
    var name = helper.attribute(cmpSource, 'name');
    var params = event.getParam('value');
    var term = params.term;
    var done = params.done;
    switch (name) {
      case 'doctor': {
        return helper.searchDoctors(cmp, term).then(done);
      }
      case 'email': {
        return helper.searchEmails(cmp, term).then(done);
      }
      case 'phone': {
        return helper.searchPhones(cmp, term).then(done);
      }
      default: {
        done([]);
        break;
      }
    }
  },
  onAutocompleteChange: function(cmp, event, helper) {
    var cmpSource = event.getSource();
    helper.autocompleteChangedHandler(cmp, cmpSource);
  },
  onSelectQuickText: function(cmp, event, helper) {
    var sourceCmp = event.getSource();
    var textId = helper.attribute(sourceCmp, 'value');
    helper.selectQuickTextHandler(cmp, textId);
  }
});