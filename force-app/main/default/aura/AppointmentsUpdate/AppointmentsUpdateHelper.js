/**@type {import("AppointmentsUpdate").Helper} */
({
  init: function (cmp) {
    this.config(cmp);
    // this.checkAutoSelectedAppointment(cmp);
  },
  destroy: function (cmp) {},
  render: function (cmp) {},
  CONSTANTS: {},

  inputData: function (cmp, value) {
    return this.attribute(cmp, 'inputData', value);
  },
  closeCallback: function (cmp, value) {
    return this.attribute(cmp, 'closeCallback', value);
  },
  selectedAppointment: function (cmp, value) {
    return this.attribute(cmp, 'selectedAppointment', value);
  },
  sequenceAppointments: function (cmp, value) {
    return this.attribute(cmp, 'sequenceAppointments', value);
  },
  formFieldCmps: function (cmp) {
    return this.convertCmpsToArray(cmp.find('formField'));
  },
  appointmentAutocompleteCmp: function (cmp) {
    var fieldCmps = this.formFieldCmps(cmp);
    return fieldCmps[0];
  },
  cancel: function (cmp) {
    this.close(cmp);
  },
  next: function (cmp) {
    var isFormValid = this.validateForm(cmp);
    if (!isFormValid) {
      return;
    }

    this.emitShowUpdateDashboard(cmp);
  },
  validateForm: function (cmp) {
    var self = this;
    var isValid = true;
    var formFieldCmps = this.formFieldCmps(cmp);
    formFieldCmps.forEach(function (fieldCmp) {
      fieldCmp.showHelpMessageIfInvalid();
      var validity = self.attribute(fieldCmp, 'validity');
      if (validity) {
        isValid = isValid && validity.valid;
      }
    });
    return isValid;
  },
  selectAppointment: function (cmp, appointment) {
    this.resetSequenceAppointments(cmp);
    this.selectedAppointment(cmp, appointment);
    this.fetchSequenceAppointments(cmp);
  },
  config: function (cmp) {},
  emitShowUpdateDashboard: function (cmp) {
    var selectedAppointment = this.selectedAppointment(cmp);
    var params = {
      value: selectedAppointment
    };

    this.emitEvent(cmp, 'onShowUpdateDashboard', params);
    var closeCallback = this.closeCallback(cmp);
    if (closeCallback) {
      closeCallback(params);
    }
    this.close(cmp);
  },
  checkAutoSelectedAppointment: function (cmp) {
    var that = this;
    var caseId = that.recordId(cmp);
    var params = {
      actionName: 'getUpdateFormData',
      caseId: caseId
    };
    that.isLoading(cmp, true);
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_Appointment,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function (
          /**@type {import('AppointmentsCancel').FormOptions} */ formOptions
        ) {
          // console.log(params, formOptions);
          that.isLoading(cmp, false);
          // var appointmentRecord = formOptions.appointmentRecord;
          // if (formOptions.appointmentRecord) {
          //   /**@type {import('AppointmentsCancel').AppointmentOption} */
          //   var appointmentOption = Object.assign({}, appointmentRecord, {
          //     label: appointmentRecord.Name,
          //     value: appointmentRecord.Id
          //   });
          //   that.selectedAppointment(cmp, appointmentOption);
          //   that.emitShowUpdateDashboard(cmp);
          // }
        })
      )
      .catch(
        $A.getCallback(function (err) {
          console.log(err);
          that.close(cmp);
          that.showToast({
            type: 'error',
            title: $A.get('$Label.c.Error'),
            message: that.buildHtmlServerError(err)
          });
          that.isLoading(cmp, false);
        })
      );
  },
  fetchSequenceAppointments: function (cmp) {
    var that = this;
    var inputData = that.inputData(cmp);
    var params = {
      actionName: 'getSequenceAppointments',
      operationType: 'update',
      appointmentId: inputData.appointment
    };
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_Appointment,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function (appointments) {
          // console.log(that.unProxyData(appointments));
          that.sequenceAppointments(cmp, appointments);
        })
      )
      .catch(
        $A.getCallback(function (err) {
          console.log(err);
          that.showToast({
            type: 'error',
            title: $A.get('$Label.c.Error'),
            message: err
          });
        })
      );
  },
  resetSequenceAppointments: function (cmp) {
    this.sequenceAppointments(cmp, []);
  }
});