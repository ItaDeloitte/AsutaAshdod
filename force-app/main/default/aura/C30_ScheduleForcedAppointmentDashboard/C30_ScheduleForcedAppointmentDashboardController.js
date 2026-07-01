/**@type {import("C30_ScheduleForcedAppointmentDashboard").Controller} */
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
    event.preventDefault();
    //   helper.submit(cmp);
  },
  onSelectAppointment: function(cmp, event, helper) {
    var params = event.getParams();
    console.log('edit appointment', params.value);
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
        // return helper.searchProcedures(cmp, term).then(done);
        break;
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
  onChangeEditData: function(cmp, event, helper) {
    var params = event.getParams();
    //   helper.editDataChangedHandler(cmp, params);
  },
  onSearchSlots: function(cmp, event, helper) {
    helper.searchSlots(cmp);
  },
  onChangeAutocomplete: function(cmp, event, helper) {
    /**@type {import("BaseAutocomplete").Cmp} */
    var sourceCmp = event.getSource();
    var name = helper.attribute(sourceCmp, 'name');
    var params = event.getParam('value');
    var option = params.option;
    switch (name) {
      case 'domain': {
        return helper.domainChangedHandler(cmp);
      }
      case 'procedure': {
        break;
      }
      case 'site': {
        return helper.siteChangedHandler(cmp);
      }
      case 'calendar': {
        return helper.calendarChangedHandler(cmp);
      }
    }
  },
  onChangeField: function(cmp, event, helper) {
    var sourceCmp = event.getSource();
    var name = helper.attribute(sourceCmp, 'name');
    switch (name) {
      case 'insurerFactor': {
        //   return helper.insurerFactorChangedHandler(cmp);
      }
    }
  },
  onSlotSelect: function(cmp, event, helper) {
    event.stopPropagation();
    var slotKey = event.getParam('value');
    // helper.selectSlotHandler(cmp, slotKey);
  },

  onFieldEdit: function(cmp, event, helper) {
    helper.fieldEditHandler(cmp);
  },
  onTest: function(cmp, event, helper) {},
  onTableRowAction: function(cmp, event, helper) {
    console.log('onTableRowAction');
  },
  onRowSelect: function(cmp, event, helper) {
    helper.rowSelectedHandler(cmp);
  },
  onShowSchedulePopup: function(cmp, event, helper) {
    helper.showSchedulePopupHandler(cmp);
  },
  onAppointmentCreated: function(cmp, event, helper) {
    helper.appointmentCreatedHandler(cmp);
  }
});