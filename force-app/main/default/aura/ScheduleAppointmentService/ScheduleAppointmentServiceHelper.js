/**@type {import("ScheduleAppointmentService").Helper} */
({
  init: function(cmp) {},
  destroy: function(cmp) {},
  render: function(cmp) {},

  controllers: {
    LC_Appointment: 'LC_AppointmentController',
    LC_SurgeriesAppointment: 'LC_SurgeriesAppointment'
  },

  service: null,

  appointmentApiRequest: function(cmp, params) {
    return this.apiRequest(cmp, {
      controllerName: this.controllers.LC_Appointment,
      params: params
    });
  },

  surgeriesAppointmentApiRequest: function(cmp, params) {
    return this.apiRequest(cmp, {
      controllerName: this.controllers.LC_SurgeriesAppointment,
      params: params
    });
  },

  apiRequest: function(cmp, params) {
    var that = this;
    var paramsDebug = that.unProxyData(params);
    return this.executeApex(cmp, params)
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(function(res) {
        console.log(paramsDebug, res);
        return res;
      })
      .catch(function(err) {
        console.log(paramsDebug, err);
        throw err;
      });
  },

  searchAppointments: function(cmp, params) {
    var that = this;
    params = Object.assign({ actionName: 'appointmentSearch' }, params);
    return that.appointmentApiRequest(cmp, params).then(function(data) {
      var options = that.buildAppointmentOptions(data);
      return options;
    });
  },

  searchDomains: function(cmp, params, warningDomainsMap) {
    var that = this;
    params = Object.assign({ actionName: 'domainSearch' }, params);
    return that.appointmentApiRequest(cmp, params).then(function(data) {
      var options = data.map(function(item) {
        return that.buildDomainOption(item, warningDomainsMap);
      });
      return options;
    });
  },

  searchCalendars: function(cmp, params) {
    var that = this;
    params = Object.assign(
      {
        actionName: 'calendarSearch'
      },
      params
    );
    return that.appointmentApiRequest(cmp, params).then(function(res) {
      var options = res.map(function(item) {
        return that.buildCalendarOption(item);
      });
      return options;
    });
  },

  searchFiles: function(cmp, params) {
    var that = this;
    params = Object.assign({ actionName: 'fileLookupSearch' }, params);
    return that.appointmentApiRequest(cmp, params).then(function(res) {
      /**@type {import('ScheduleAppointmentService').FileOption[]} */
      var options = res.map(function(item) {
        return that.buildFileOption(item);
      });
      return options;
    });
  },
  searchClinics: function(cmp, params) {
    var that = this;
    params = Object.assign({ actionName: 'clinicSearch' }, params);
    return that.appointmentApiRequest(cmp, params).then(function(res) {
      var options = res.map(function(item) {
        return that.buildClinicOption(item);
      });
      return options;
    });
  },

  searchSequenceSites: function(cmp, params) {
    var that = this;
    params = Object.assign({ actionName: 'siteSequenceSearch' }, params);
    return that.appointmentApiRequest(cmp, params).then(function(res) {
      var options = res.map(function(item) {
        return that.buildSiteOption(item);
      });
      return options;
    });
  },

  searchForcedSites: function(cmp, params) {
    var that = this;
    params = Object.assign({ actionName: 'siteForcedSearch' }, params);
    return that.appointmentApiRequest(cmp, params).then(function(res) {
      var options = res.map(function(item) {
        return that.buildSiteOption(item);
      });
      return options;
    });
  },

  searchProcedures: function(cmp, params, protocolsMap) {
    var that = this;
    params = Object.assign({ actionName: 'procedureSearch' }, params);
    return that.appointmentApiRequest(cmp, params).then(function(res) {
      /**@type {import('ScheduleAppointmentService').ProcedureOption[]} */
      var options = res.map(function(item) {
        var procedure = Object.assign({}, item, { protocols: [] });
        return that.buildProcedureOption(procedure, protocolsMap);
      });
      console.log(options);
      return options;
    });
  },

  searchProceduresByCalendar: function(cmp, params, protocolsMap) {
    var that = this;
    params = Object.assign({ actionName: 'procedureSearchByCalendar' }, params);
    return that.appointmentApiRequest(cmp, params).then(function(res) {
      /**@type {import('ScheduleAppointmentService').ProcedureOption[]} */
      var options = res.map(function(item) {
        var procedure = Object.assign({}, item, {
          protocols: []
        });
        return that.buildProcedureOption(procedure, protocolsMap);
      });
      return options;
    });
  },

  buildAppointmentOptions: function(data) {
    var options = data.map(function(item) {
      return Object.assign(item, { label: item.Name, value: item.Id });
    });
    return options;
  },

  buildDomainOption: function(data, warningDomainsMap) {
    warningDomainsMap = warningDomainsMap || {};
    if (!data) {
      return null;
    }
    var warningText = warningDomainsMap[data.Id] || '';
    /**@type {import('ScheduleAppointmentService').DomainOption} */
    var option = Object.assign({}, data, {
      label: data.Name,
      value: data.Id,
      warning: warningText
    });
    return option;
  },

  buildTechnicianOption: function(data) {
    if (!data) {
      return null;
    }
    /**@type {import('ScheduleAppointmentService').TechnicianOption} */
    var option = Object.assign({}, data, {
      value: data.id,
      label: data.label,
      withProcedures: data.withProcedures
    });
    return option;
  },

  buildCalendarOption: function(data) {
    if (!data) {
      return null;
    }
    /**@type {import('ScheduleAppointmentService').CalendarOption} */
    var option = Object.assign({}, data, {
      label: data.Name,
      value: data.ServiceId__c
    });
    return option;
  },

  buildFileOption: function(data) {
    if (!data) {
      return null;
    }
    /**@type {import('ScheduleAppointmentService').FileOption} */
    var option = Object.assign({}, data, {
      label: data.Name,
      value: data.Id
    });
    return option;
  },

  buildClinicOption: function(data) {
    if (!data) {
      return null;
    }
    /**@type {import('ScheduleAppointmentService').ClinicOption} */
    var option = Object.assign({}, data, {
      label: data.name,
      value: data.siteCode
    });
    return option;
  },

  buildSiteOption: function(data) {
    if (!data) {
      return null;
    }
    var parsedName = this.parseNameWithNote(data.Name);
    /**@type {import('ScheduleAppointmentService').SiteOption} */
    var option = Object.assign({}, data, {
      label: parsedName.name,
      note: parsedName.note,
      transferToDepartment: false,
      value: data.Site_Code__c
    });
    return option;
  },

  buildProcedureOption: function(data, protocolsMap) {
    protocolsMap = protocolsMap || {};
    if (!data) {
      return null;
    }
    var parsedName = this.parseNameWithNote(
      data.Marketing_Procedure_Name__c || data.Name
    );
    var procedureName = parsedName.name;
    var labelHtml =
      '<div class="procedure-option">' +
      '<div class=""><span class="font-weight-bold">' +
      $A.get('$Label.c.Name') +
      '&nbsp;</span>' +
      procedureName +
      '</div>' +
      '<div class=""><span class="font-weight-bold">' +
      $A.get('$Label.c.Code') +
      '&nbsp;</span>' +
      data.Procedure_Code__c +
      '</div>' +
      '</div>';

    var protocols = [];
    if (typeof data.Protocols__c === 'string') {
      protocols = data.Protocols__c.split(';')
        .filter(function(key) {
          return !!key;
        })
        .reduce(function(acc, key) {
          var protocolOption = protocolsMap[key];
          if (protocolOption) {
            acc.push(protocolOption);
          }
          return acc;
        }, []);
    }

    /**@type {import('ScheduleAppointmentService').ProcedureOption} */
    var option = Object.assign({}, data, {
      label: procedureName,
      labelHtml: labelHtml,
      transferToDepartment: false,
      hasSequence: false,
      note: parsedName.note,
      protocols: protocols,
      Waiting_List__c: data.Waiting_List__c || false,
      value: data.Procedure_Code__c
    });
    return option;
  },

  buildUrgentReasonOption: function(data) {
    if (!data) {
      return null;
    }
    /**@type {import('ScheduleAppointmentService').UrgentReasonOption} */
    var option = Object.assign({}, data);
    return option;
  },

  parseNameWithNote: function(name, separator) {
    separator = separator || '__';
    var splittedName = name.split(separator);
    /**@type {import('ScheduleAppointmentService').ParsedNameWithNoteSeparator} */
    var result = {
      name: splittedName[0] || '',
      note: splittedName[1] || ''
    };
    return result;
  },

  checkTransferToDepartmentNote: function(note) {
    var targetNote = 'ע"י המחלקה בלבד';
    return note === targetNote;
  },

  getService: function(cmp) {
    var that = this;
    /**@type {import('ScheduleAppointmentService').Service} */
    var service = {
      appointmentApiRequest: that.appointmentApiRequest.bind(that, cmp),
      surgeriesAppointmentApiRequest: that.surgeriesAppointmentApiRequest.bind(
        that,
        cmp
      ),
      searchAppointments: that.searchAppointments.bind(that, cmp),
      searchDomains: that.searchDomains.bind(that, cmp),
      searchCalendars: that.searchCalendars.bind(that, cmp),
      searchFiles: that.searchFiles.bind(that, cmp),
      searchClinics: that.searchClinics.bind(that, cmp),
      searchSequenceSites: that.searchSequenceSites.bind(that, cmp),
      searchForcedSites: that.searchForcedSites.bind(that, cmp),
      searchProcedures: that.searchProcedures.bind(that, cmp),
      searchProceduresByCalendar: that.searchProceduresByCalendar.bind(
        that,
        cmp
      ),

      buildAppointmentOptions: that.buildAppointmentOptions.bind(that),
      buildDomainOption: that.buildDomainOption.bind(that),
      buildTechnicianOption: that.buildTechnicianOption.bind(that),
      buildCalendarOption: that.buildCalendarOption.bind(that),
      buildFileOption: that.buildFileOption.bind(that),
      buildClinicOption: that.buildClinicOption.bind(that),
      buildSiteOption: that.buildSiteOption.bind(that),
      buildProcedureOption: that.buildProcedureOption.bind(that),
      buildUrgentReasonOption: that.buildUrgentReasonOption.bind(that),

      parseNameWithNote: that.parseNameWithNote.bind(that),
      checkTransferToDepartmentNote: that.checkTransferToDepartmentNote.bind(
        that
      )
    };
    return service;
  }
});