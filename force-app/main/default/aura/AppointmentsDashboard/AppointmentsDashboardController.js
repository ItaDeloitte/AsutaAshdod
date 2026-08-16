/**@type {import("AppointmentsDashboard").Controller} */
({
  onInit: function(cmp, event, helper) {
    helper.init(cmp);
  },
  onClose: function(cmp, event, helper) {
    helper.closeF(cmp)
  },
  onDestroy: function(cmp, event, helper) {
    helper.destroy(cmp);
  },
  onRender: function(cmp, event, helper) {
    helper.render(cmp);
  },
  onSubmit: function(cmp, event, helper) {
    event.preventDefault();
    helper.submit(cmp);
  },
  onRefreshLock: function(cmp, event, helper) {
    helper.refreshSlotsHandler(cmp);
  },
  onUnLock: function(cmp, event, helper) {
    helper.unlockSlotButton(cmp);
  },
  onFilterChanged: function(cmp, event, helper) {
    var params = event.getParams();
    helper.filtersChangedHandler(cmp, params.value);
  },
  onSelectAppointment: function(cmp, event, helper) {
    var params = event.getParams();
    console.log('edit appointment', params.value);
  },
  onAutocompleteSearch: function(cmp, event, helper) {
    /**@type {import("BaseAutocomplete").Cmp} */
    var sourceCmp = event.getSource();
    var cmpNameAttr = helper.attribute(sourceCmp, 'name');
    var parsedFieldName = helper.parseFieldName(cmp, cmpNameAttr);
    var name =
      /**@type {import('AppointmentsDashboard').AutocompleteEditFieldName} */ (parsedFieldName.name);
    var params = event.getParam('value');
    var term = params.term;
    var done = params.done;
    switch (name) {
      case 'domain': {
        return helper.searchDomains(cmp, term).then(done);
      }
      case 'procedure': {
        var staticData = helper.staticData(cmp);
        if (helper.isForDocExpert(cmp) && staticData.alertProcedureCodes.find(function (code) { return code === term})) {
          sourceCmp.setCustomMessage(staticData.alertMessage)
          return done([])
        } else {
          sourceCmp.resetCustomMessage()
          return helper.searchProcedures(cmp, term).then(done);
        }
      }
      case 'clinic': {
        return helper.searchClinics(cmp, term).then(done);
      }
      case 'sequenceSite': {
        return helper.searchSequenceSites(cmp, term).then(done);
      }
      case 'calendar': {
        return helper.searchCalendars(cmp, term).then(done);
      }
      case 'file': {
        return helper.searchFiles(cmp, term).then(done);
      }
      case 'sequenceFile': {
        return helper.searchFiles(cmp, term).then(done);
      }
      case 'sequenceProcedure': {
        return helper.searchProcedures(cmp, term, parsedFieldName).then(done);
      }
      case 'technician': {
        return helper.searchTechnician(cmp, term).then(done);
      }
      case 'technicianProcedure': {
        return helper.searchTechnicianProcedure(cmp, term).then(done);
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
    helper.editDataChangedHandler(cmp, params);
  },
  onSearchSlots: function(cmp, event, helper) {
    helper.searchSlots(cmp);
  },
  onChangeAutocomplete: function(cmp, event, helper) {
    /**@type {import("BaseAutocomplete").Cmp} */
    var sourceCmp = event.getSource();
    var cmpNameAttr = helper.attribute(sourceCmp, 'name');
    var parsedFieldName = helper.parseFieldName(cmp, cmpNameAttr);
    var name =
      /**@type {import('AppointmentsDashboard').AutocompleteEditFieldName} */ (parsedFieldName.name);
    var params = event.getParam('value');
    var option = params.option;
    switch (name) {
      case 'domain': {
        return helper.domainChangedHandler(cmp, option);
      }
      case 'procedure': {
        return helper.procedureChangedHandler(cmp, option);
      }
      case 'clinic': {
        return helper.clinicChangedHandler(cmp, option);
      }
      case 'calendar': {
        return helper.calendarChangedHandler(cmp, option);
      }
      case 'file': {
        return;
      }
      case 'sequenceProcedure': {
        return helper.sequenceProcedureChangedHandler(
          cmp,
          option,
          parsedFieldName
        );
      }
      case 'technician': {
        return helper.technicianChangedHandler(cmp, option);
      }
    }
  },
  onChangeField: function(cmp, event, helper) {
    var sourceCmp = event.getSource();
    var cmpNameAttr = helper.attribute(sourceCmp, 'name');
    var parsedFieldName = helper.parseFieldName(cmp, cmpNameAttr);
    var name = parsedFieldName.name;
    switch (name) {
      case 'insurerFactor': {
        return helper.insurerFactorChangedHandler(cmp);
      }
      case 'urgent': {
        return helper.urgentChangedHandler(cmp);
      }
      case 'protocol': {
        return helper.protocolChangedHandler(cmp);
      }
      case 'sequenceProtocol': {
        return helper.sequenceProtocolChangedHandler(cmp, parsedFieldName);
      }
      case 'calendarQflow': {
        var calendar = cmp.get("v.editData.qflowCalendar")
        var caldenarList =cmp.get("v.editData.qflowCalendarOptions")
        return helper.calendarQflowChangedHandler(cmp,calendar,caldenarList);
      }
    }
  },
  onAutocompleteCreate: function(cmp, event, helper) {
    /**@type {import("BaseAutocomplete").Cmp} */
    var sourceCmp = event.getSource();
    var cmpNameAttr = helper.attribute(sourceCmp, 'name');
    var parsedFieldName = helper.parseFieldName(cmp, cmpNameAttr);
    var name =
      /**@type {import('AppointmentsDashboard').AutocompleteEditFieldName} */ (parsedFieldName.name);
    switch (name) {
      case 'file': {
        return helper.showFileForm(cmp);
      }
    }
  },
  onSlotSelect: function(cmp, event, helper) {
    event.stopPropagation();
    var params = event.getParam('value');
    helper.selectSlotHandler(cmp, params.slotKey, params.rowIndex);
  },
  onSlideMove: function(cmp, event, helper) {
    helper.isTimeGroupVisible(cmp, false);
  },
  onDaySelect: function(cmp, event, helper) {
    var data = event.getParam('value');
    helper.selectDayHandler(cmp, data);
  },
  onFieldEdit: function(cmp, event, helper) {
    helper.fieldEditHandler(cmp, '');
  },
  onDayConfirmation: function(cmp, event, helper) {
    var isConfirmed = event.getParam('value');
    helper.dayConfirmationHandler(cmp, isConfirmed);
  },
  onCreateFile: function(cmp, event, helper) {
    var fileData = event.getParam('value');
    helper.fileCreatedHandler(cmp, fileData);
  },
  onAddSequenceProcedure: function(cmp, event, helper) {
    helper.addSequenceProcedure(cmp);
  },
  onTest: function(cmp, event, helper) {
    /* TEST */
    console.log('test');
    // helper
    //   .showAppointmentDisabilitiesModal(cmp)
    //   .then(
    //     $A.getCallback(function(data) {
    //       console.log(helper.unProxyData({ data: data }));
    //     })
    //   )
    //   .catch($A.getCallback(function(err) {}));
  },
  onShowForcedAppointment: function(cmp, event, helper) {
    helper.showForcedAppointmentScreen(cmp);
  },
  onTransferToDepartment: function(cmp, event, helper) {
    var row = event.getParam('value');
    helper.transferToDepartment(cmp, row, null);
  },
  onSelectModality: function(cmp, event, helper) {
    var params = event.getParams();
    var value = params.value;
    helper.selectModalityHandler(cmp, value);
  },
  onCopyAvailableTimeSlot: function (cmp, event, helper) {
    helper.copyAvailableTimeSlot(cmp)
  }
});