/**@type {import("C30_SubmitForcedAppointmentModal").Controller} */
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
  onCancel: function(cmp, event, helper) {
    helper.cancel(cmp);
  },
  onNext: function(cmp, event, helper) {
    helper.nextStep(cmp);
  },
  onPrev: function(cmp, event, helper) {
    helper.prevStep(cmp);
  },

  onAutocompleteInitSearch: function(cmp, event, helper) {
    /**@type {import("BaseAutocomplete").Cmp} */
    var sourceCmp = event.getSource();
    /**@type {import('AppointmentsDashboard').AutocompleteEditFieldName} */
    var name = helper.attribute(sourceCmp, 'name');
    var params = event.getParam('value');
    var term = params.term;
    var done = params.done;
    done(null);
  },

  onAutocompleteSearch: function(cmp, event, helper) {
    /**@type {import("BaseAutocomplete").Cmp} */
    var sourceCmp = event.getSource();
    var name = helper.attribute(sourceCmp, 'name');
    var params = event.getParam('value');
    var term = params.term;
    var done = params.done;
    switch (name) {
      case 'domain': {
        return helper.searchDomains(cmp, term).then(done);
      }
      case 'procedure': {
        return helper.searchProcedures(cmp, term).then(done);
      }
      case 'site': {
        return helper.searchSites(cmp, term).then(done);
      }
      case 'calendar': {
        return helper.searchCalendars(cmp, term).then(done);
      }
    }

    return done([]);
  },

  onChangeAutocomplete: function(cmp, event, helper) {
    /**@type {import("BaseAutocomplete").Cmp} */
    var sourceCmp = event.getSource();
    var name = helper.attribute(sourceCmp, 'name');
    var params = event.getParam('value');
    var option = params.option;
    switch (name) {
      case 'domain': {
        // return helper.domainChangedHandler(cmp);
        break;
      }
      case 'procedure': {
        return helper.procedureChangedHandler(cmp);
      }
      case 'site': {
        return helper.siteChangedHandler(cmp);
      }
      case 'calendar': {
        // return helper.calendarChangedHandler(cmp);
        break;
      }
    }
  },
  onRowSelect: function(cmp, event, helper) {
    helper.rowSelectedHandler(cmp);
  }
});