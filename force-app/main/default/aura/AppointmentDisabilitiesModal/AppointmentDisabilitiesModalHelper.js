/**@type {import('AppointmentDisabilitiesModal').Helper} */
({
  init: function(cmp) {
    this.configLabels(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {
    var isRendered = this.isRendered(cmp);
    if (isRendered) {
      return;
    }
    this.isRendered(cmp, true);
    this.checkModalData(cmp);
  },

  modalParams: function(cmp, value) {
    return this.attribute(cmp, 'modalParams', value);
  },
  caseId: function(cmp, value) {
    return this.attribute(cmp, 'caseId', value);
  },
  appointmentIds: function(cmp, value) {
    return this.attribute(cmp, 'appointmentIds', value);
  },

  disabilityData: function(cmp, value) {
    return this.attribute(cmp, 'disabilityData', value);
  },

  disabilityFields: function(cmp, value) {
    return this.attribute(cmp, 'disabilityFields', value);
  },

  selectedAppointment: function(cmp, value) {
    return this.attribute(cmp, 'selectedAppointment', value);
  },
  appointmentsList: function(cmp, value) {
    return this.attribute(cmp, 'appointmentsList', value);
  },

  stepIndex: function(cmp, value) {
    return this.attribute(cmp, 'stepIndex', value);
  },

  isReady: function(cmp, value) {
    return this.attribute(cmp, 'isReady', value);
  },
  errors: function(cmp, value) {
    return this.attribute(cmp, 'errors', value);
  },

  getCustomLabels: function() {
    return {
      AppointmentDisabilities: $A.get('$Label.c.Appointment_Disabilities'),
      Cancel: $A.get('$Label.c.Cancel'),
      Back: $A.get('$Label.c.Back'),
      Next: $A.get('$Label.c.Next'),
      Submit: $A.get('$Label.c.Submit'),
      Appointment: $A.get('$Label.c.Appointment'),
      Date: $A.get('$Label.c.Date'),
      MedicalProcedure: $A.get('$Label.c.Medical_Procedure'),
      Site: $A.get('$Label.c.Site'),
      AppointmentUpdated: $A.get('$Label.c.Appointment_updated')
    };
  },

  checkModalData: function(cmp) {
    var that = this;
    var modalParams = that.modalParams(cmp);
    var modalData = modalParams.modalData;
    var caseId = modalData.caseId || '';
    var appointmentIds = modalData.appointmentIds || [];
    that.caseId(cmp, caseId);
    that.appointmentIds(cmp, appointmentIds);

    if (modalData.search) {
      that.stepIndex(cmp, 0);
    } else {
      that.stepIndex(cmp, 1);
      that.fetchDisabilities(cmp);
    }
  },

  configDisabilities: function(cmp, data) {
    var that = this;
    var disabilityData = that.buildDisabilityData(cmp, data);
    that.disabilityData(cmp, disabilityData);
    var fields = that.buildDisabilityFields(cmp, disabilityData);
    this.disabilityFields(cmp, fields);
  },

  buildDisabilityFields: function(cmp, disabilityData) {
    var that = this;

    var disabilityFields = disabilityData.data.map(function(item) {
      var assistOptions = item.assists.map(function(assist) {
        return {
          label: assist.label,
          value: assist.value
        };
      });

      var selectedAssists = item.assists
        .filter(function(assist) {
          return assist.isSelected;
        })
        .map(function(assist) {
          return assist.value;
        });

      return {
        label: item.type.label,
        id: item.disabilityId,
        assistOptions: assistOptions,
        selectedAssists: selectedAssists
      };
    });

    return disabilityFields;
  },

  configLabels: function(cmp) {
    var customLabels = this.getCustomLabels();
    this.labels(cmp, customLabels);
  },

  hasAppointmentIds: function(cmp) {
    var appointmentIds = this.appointmentIds(cmp);
    return appointmentIds.length > 0;
  },

  submitHandler: function(cmp) {
    var that = this;
    that.resetErrors(cmp);
    var labels = that.labels(cmp);
    var modalParams = that.modalParams(cmp);
    var modalData = modalParams.modalData;
    var caseId = that.caseId(cmp);
    var appointmentIds = that.appointmentIds(cmp);
    var preparedData = that.buildPreparedDataForSubmit(cmp);

    var submitData = {
      disabilities: preparedData,
      appointmentIds: appointmentIds
    };

    if (!modalData.search) {
      return that.emitCloseModal(cmp, submitData);
    }
    var globalServiceCmp = that.globalServiceCmp(cmp);
    var services = that.globalServices(cmp);
    var errorsService = services.errorsService;
    var toastService = services.toastService;
    var appointmentDisabilitiesService =
      services.appointmentDisabilitiesService;
    that.isLoading(cmp, true);
    appointmentDisabilitiesService
      .setDisabilities(caseId, appointmentIds, preparedData)
      .then(
        $A.getCallback(function() {
          that.isLoading(cmp, false);
          globalServiceCmp.callWithLwcContext(function(lwc) {
            toastService.success(lwc, { message: labels.AppointmentUpdated });
          });
          that.emitCloseModal(cmp, submitData);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isLoading(cmp, false);
          var errors = errorsService.buildServerErrorsArray(err);
          that.errors(cmp, errors);
        })
      );
  },

  cancelHandler: function(cmp) {
    this.emitCloseModal(cmp);
  },

  fetchDisabilities: function(cmp) {
    var that = this;
    var services = that.globalServices(cmp);
    var errorsService = services.errorsService;
    var toastService = services.toastService;
    var appointmentDisabilitiesService =
      services.appointmentDisabilitiesService;
    var caseId = that.caseId(cmp);
    var appointmentIds = that.appointmentIds(cmp);
    that.isLoading(cmp, true);
    appointmentDisabilitiesService
      .getDisabilities(caseId, appointmentIds)
      .then(
        $A.getCallback(function(res) {
          that.isLoading(cmp, false);
          that.configDisabilities(cmp, res);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isLoading(cmp, false);
          var errors = errorsService.buildServerErrorsArray(err);
          that.errors(cmp, errors);
        })
      );
  },

  buildDisabilityData: function(cmp, data) {
    var dataMap = data.reduce(function(acc, item) {
      acc[item.disabilityId] = item;
      return acc;
    }, {});

    var disabilityData = {
      data: data,
      dataMap: dataMap
    };
    return disabilityData;
  },

  buildPreparedDataForSubmit: function(cmp) {
    var that = this;
    var fields = this.disabilityFields(cmp);
    var disabilitiesData = this.disabilityData(cmp);
    var dataMap = disabilitiesData.dataMap;
    var preparedData = fields.map(function(field) {
      var disability = dataMap[field.id];
      var assists = disability.assists.map(function(item) {
        return Object.assign({}, item, {
          isSelected: field.selectedAssists.indexOf(item.value) > -1
        });
      });

      return Object.assign({}, disability, { assists: assists });
    });
    return preparedData;
  },

  emitCloseModal: function(cmp, result) {
    var modalParams = this.modalParams(cmp);
    modalParams.resolvers.close(result);
    this.close(cmp);
  },
  resetErrors: function(cmp) {
    this.errors(cmp, []);
  },
  closeErrorsHandler: function(cmp) {
    this.resetErrors(cmp);
  },
  groupChangeHandler: function(cmp, event) {},
  goToDisabilityStepHandler: function(cmp) {
    this.stepIndex(cmp, 1);
    this.disabilityData(cmp, null);
    this.fetchDisabilities(cmp);
  },
  backHandler: function(cmp) {
    var stepIndex = this.stepIndex(cmp);
    if (stepIndex <= 0) {
      return;
    }
    this.resetErrors(cmp);
    this.stepIndex(cmp, stepIndex - 1);
  },
  appointmentSearchHandler: function(cmp, term, lookupCmp) {
    var that = this;
    var caseId = this.caseId(cmp);
    var services = that.globalServices(cmp);
    var appointmentDisabilitiesService =
      services.appointmentDisabilitiesService;
    appointmentDisabilitiesService
      .searchAppointments(term, caseId)
      .then(
        $A.getCallback(function(options) {
          lookupCmp.setSearchResults(options);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          lookupCmp.setSearchResults([]);
        })
      );
  },
  appointmentSelectHandler: function(cmp, appointment) {
    this.selectedAppointment(cmp, appointment);
    this.appointmentsList(cmp, []);
    this.appointmentIds(cmp, []);
    if (appointment) {
      this.fetchSequenceAppointments(cmp);
    }
  },
  fetchSequenceAppointments: function(cmp) {
    var that = this;
    var services = that.globalServices(cmp);
    var selectedAppointment = that.selectedAppointment(cmp);
    var errorsService = services.errorsService;
    var appointmentDisabilitiesService =
      services.appointmentDisabilitiesService;
    that.resetErrors(cmp);
    that.isLoading(cmp, true);
    appointmentDisabilitiesService
      .getSequenceAppointments(selectedAppointment.Id)
      .then(
        $A.getCallback(function(list) {
          that.isLoading(cmp, false);
          var appointmentIds = list.map(function(item) {
            return item.Id;
          });
          that.appointmentsList(cmp, list);
          that.appointmentIds(cmp, appointmentIds);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isLoading(cmp, false);
          that.errors(cmp, errorsService.buildServerErrorsArray(err));
        })
      );
  }
});