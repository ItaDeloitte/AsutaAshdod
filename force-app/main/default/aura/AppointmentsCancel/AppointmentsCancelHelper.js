/**@type {import("AppointmentsCancel").Helper} */
({
  init: function(cmp) {
    this.config(cmp);
    this.fetchFormOptions(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},
  CONSTANTS: {},

  inputData: function(cmp, value) {
    return this.attribute(cmp, 'inputData', value);
  },

  step1FieldCmps: function(cmp) {
    return this.convertCmpsToArray(cmp.find('step1Field'));
  },
  step2FieldCmps: function(cmp) {
    return this.convertCmpsToArray(cmp.find('step2Field'));
  },
  appointmentAutocompleteCmp: function(cmp) {
    var that = this;
    var stepFields = this.step1FieldCmps(cmp);
    var autocompleteCmp = stepFields.find(function(fieldCmp) {
      var name = that.attribute(fieldCmp, 'name');
      return name === 'appointment';
    });
    return autocompleteCmp;
  },
  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },
  steps: function(cmp, value) {
    return this.attribute(cmp, 'steps', value);
  },
  currentStep: function(cmp, value) {
    return this.attribute(cmp, 'currentStep', value);
  },
  currentStepIndex: function(cmp, value) {
    return this.attribute(cmp, 'currentStepIndex', value);
  },
  selectedAppointment: function(cmp, value) {
    return this.attribute(cmp, 'selectedAppointment', value);
  },
  formOptions: function(cmp, value) {
    return this.attribute(cmp, 'formOptions', value);
  },
  sequenceAppointments: function(cmp, value) {
    return this.attribute(cmp, 'sequenceAppointments', value);
  },

  fetchFormOptions: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var params = {
      actionName: 'getCancelFormData',
      recordId: recordId
    };
    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_Appointment,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(
          /**@type {import('AppointmentsCancel').FormOptions} */ formOptions
        ) {
          that.isLoading(cmp, false);
          that.formOptions(cmp, formOptions);
          var appointmentRecord = formOptions.appointmentRecord;
          if (appointmentRecord) {
            /**@type {import('AppointmentsCancel').AppointmentOption} */
            var appointmentOption = Object.assign({}, appointmentRecord, {
              label: appointmentRecord.Name,
              value: appointmentRecord.Id
            });
            var inputData = that.inputData(cmp);
            inputData.appointment = appointmentOption.value;
            that.inputData(cmp, inputData);
            that.selectAppointmentHandler(cmp, appointmentOption);
            that.moveToStep(cmp, 1);
          }
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
          that.serverError(cmp, that.buildHtmlServerError(err));
        })
      );
  },

  submit: function(cmp) {
    var that = this;
    var caseId = that.recordId(cmp);
    var inputData = that.inputData(cmp);

    var params = {
      actionName: 'cancelAppointment',
      caseId: caseId,
      appointmentId: inputData.appointment,
      canceledReason: inputData.reason,
      reasonFreeText: inputData.reasonFreeText
    };
    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_Appointment,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          // console.log(params, res);
          that.isLoading(cmp, false);
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: $A.get('$Label.c.Appointment_cancelled')
          });
          that.refreshView();
          that.close(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
          that.serverError(cmp, that.buildHtmlServerError(err));
        })
      );
  },
  cancel: function(cmp) {
    this.close(cmp);
  },

  selectAppointmentHandler: function(cmp, appointment) {
    this.selectedAppointment(cmp, appointment);
    this.resetSequenceAppointments(cmp);
    if (appointment) {
      this.fetchSequenceAppointments(cmp);
    }
  },
  config: function(cmp) {
    this.configSteps(cmp);
  },
  configSteps: function(cmp) {
    /**@type {import('AppointmentsCancel').Step[]} */
    var steps = [
      { id: 'appointment', label: 'Appointment' },
      { id: 'reason', label: 'Reason' }
    ];
    this.steps(cmp, steps);
    var currentStepIndex = 0;
    this.currentStepIndex(cmp, currentStepIndex);
    this.currentStep(cmp, steps[currentStepIndex]);
  },
  validateStep: function(cmp, stepId) {
    switch (stepId) {
      case 'appointment': {
        return this.validateAppointmentStep(cmp);
      }
      case 'reason': {
        return this.validateReasonStep(cmp);
      }
      default: {
        return false;
      }
    }
  },
  validateAppointmentStep: function(cmp) {
    var that = this;
    var isValid = true;
    var stepFields = that.step1FieldCmps(cmp);
    stepFields.forEach(function(fieldCmp) {
      fieldCmp.showHelpMessageIfInvalid();
      var validity = that.attribute(fieldCmp, 'validity');
      if (validity) {
        isValid = isValid && validity.valid;
      }
    });
    return isValid;
  },
  validateReasonStep: function(cmp) {
    var that = this;
    var isValid = true;
    var stepFields = that.step2FieldCmps(cmp);
    stepFields.forEach(function(fieldCmp) {
      fieldCmp.showHelpMessageIfInvalid();
      var validity = that.attribute(fieldCmp, 'validity');
      if (validity) {
        isValid = isValid && validity.valid;
      }
    });
    return isValid;
  },
  nextStep: function(cmp) {
    var steps = this.steps(cmp);
    var currentStepIndex = this.currentStepIndex(cmp);
    var currentStep = this.currentStep(cmp);
    var isStepValid = this.validateStep(cmp, currentStep.id);
    if (!isStepValid) {
      return;
    }
    if (currentStepIndex >= steps.length - 1) {
      this.submit(cmp);
    } else {
      currentStepIndex += 1;
      this.currentStepIndex(cmp, currentStepIndex);
      this.currentStep(cmp, steps[currentStepIndex]);
      this.changeStepHandler(cmp, currentStepIndex);
    }
  },
  prevStep: function(cmp) {
    this.serverError(cmp, '');
    var steps = this.steps(cmp);
    var stepIndex = this.currentStepIndex(cmp);
    if (stepIndex === 0) {
      return;
    }
    stepIndex -= 1;
    this.currentStepIndex(cmp, stepIndex);
    this.currentStep(cmp, steps[stepIndex]);
    this.changeStepHandler(cmp, stepIndex);
  },
  moveToStep: function(cmp, stepIndex) {
    var steps = this.steps(cmp);
    if (stepIndex >= 0 && stepIndex < steps.length) {
      var targetStep = steps[stepIndex];
      this.currentStepIndex(cmp, stepIndex);
      this.currentStep(cmp, targetStep);
      this.changeStepHandler(cmp, stepIndex);
    }
  },
  fetchSequenceAppointments: function(cmp) {
    var that = this;
    var inputData = that.inputData(cmp);
    var params = {
      actionName: 'getSequenceAppointments',
      operationType: 'cancel',
      appointmentId: inputData.appointment
    };
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_Appointment,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(appointments) {
          // console.log(appointments);
          that.sequenceAppointments(cmp, appointments);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.showToast({
            type: 'error',
            title: $A.get('$Label.c.Error'),
            message: err
          });
        })
      );
  },
  resetSequenceAppointments: function(cmp) {
    this.sequenceAppointments(cmp, []);
  },
  changeStepHandler: function(cmp, stepIndex) {
    // if (stepIndex === 1) {
    //   return this.fetchSequenceAppointments(cmp);
    // }
    // this.resetSequenceAppointments(cmp);
  }
});