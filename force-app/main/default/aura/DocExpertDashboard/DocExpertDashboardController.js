/**@type {import("DocExpertDashboard").Controller} */
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
  onAutocompleteSearch: function(cmp, event, helper) {
    /**@type {import("BaseAutocomplete").Cmp} */
    var sourceCmp = event.getSource();
    /**@type {import('DocExpertDashboard').AutocompleteEditFieldName} */
    var name = helper.attribute(sourceCmp, 'name');
    var params = event.getParam('value');
    var term = params.term;
    var done = params.done;
    switch (name) {
      case 'procedure': {
        return helper.searchProcedure(cmp, term).then(done);
      }
      case 'expertise': {
        return helper.searchExpertise(cmp, term).then(done);
      }
      case 'subExpertise': {
        return helper.searchSubExpertise(cmp, term).then(done);
      }
    }
  },
  onAutocompleteInitSearch: function(cmp, event, helper) {
    /**@type {import("BaseAutocomplete").Cmp} */
    var sourceCmp = event.getSource();
    /**@type {import('DocExpertDashboard').AutocompleteEditFieldName} */
    var name = helper.attribute(sourceCmp, 'name');
    var params = event.getParam('value');
    var term = params.term;
    var done = params.done;
    switch (name) {
      case 'procedure': {
        return done(null);
      }
      case 'expertise': {
        return done(null);
      }
      case 'subExpertise': {
        return done(null);
      }
    }
  },
  onChangeAutocomplete: function(cmp, event, helper) {
    /**@type {import("BaseAutocomplete").Cmp} */
    var sourceCmp = event.getSource();
    /**@type {import('DocExpertDashboard').AutocompleteEditFieldName} */
    var name = helper.attribute(sourceCmp, 'name');
    var params = event.getParam('value');
    switch (name) {
      case 'procedure': {
        return helper.changeProcedureHandler(cmp, params.option);
      }
      case 'expertise': {
        return helper.changeExpertiseHandler(cmp, params.option);
      }
      case 'subExpertise': {
        return helper.changeSubExpertiseHandler(cmp, params.option);
      }
    }
  },
  onSearchDoctors: function(cmp, event, helper) {
    helper.searchDoctors(cmp);
  },
  onChangeFilter: function(cmp, event, helper) {
    var target = event.target;
    if (target && target.type === 'checkbox') {
      var name = target.name;
      var value = target.checked;
      helper.filterCheckboxChangeHandler(cmp, name, value);
    }
    helper.changeFilterHandler(cmp);
  },
  onChangeSortBy: function(cmp, event, helper) {
    helper.changeSortHandler(cmp);
  },
  onDoctorAction: function(cmp, event, helper) {
    /**@type {import('DocExpertBase').DoctorActionEventValue} */
    var value = event.getParam('value');
    switch (value.action) {
      case 'select': {
        return helper.selectDoctor(cmp, value.doctor);
      }
      case 'recommend': {
        return helper.recommendDoctor(cmp, value.doctor);
      }
      case 'schedule': {
        return helper.scheduleAppointment(cmp);
      }
    }
  },
  onSubmit: function(cmp, event, helper) {
    var sourceCmp = event.getSource();
    /**@type {import('DocExpertDashboard').SubmitType} */
    var submitType = helper.attribute(sourceCmp, 'name');
    switch (submitType) {
      case 'save': {
        return helper.save(cmp);
      }
      case 'schedule': {
        return helper.scheduleAppointment(cmp);
      }
      case 'sendDocAdv': {
        return helper.sendDocAdv(cmp);
      }
    }
  },
  onResetSearch: function(cmp, event, helper) {
    helper.resetSearchHandler(cmp);
  },
  onSearchLookupFilter: function(cmp, event, helper) {
    event.stopPropagation();
    var lookupCmp = event.getSource();
    var params = event.getParams();
    helper.searchLookupFilterHandler(cmp, lookupCmp, params);
  },
  onChangeLookupFilter: function(cmp, event, helper) {
    var lookupCmp = event.getSource();
    helper.changeLookupFilterHandler(cmp, lookupCmp);
  },
  onTestClick: function(cmp, event, helper) {
    // console.log('testClick');
    // helper.showClinicsModal(cmp, '123');
  }
});