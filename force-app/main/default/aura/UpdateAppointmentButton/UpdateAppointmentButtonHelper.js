/**@type {import("UpdateAppointmentButton").Helper} */
({
  init: function(cmp) {
    this.fetchAppointment(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},

  CONSTANTS: {},
  controllers: {
    LC_Appointment: 'LC_AppointmentController'
  },

  appointment: function(cmp, value) {
    return this.attribute(cmp, 'appointment', value);
  },
  screenMode: function(cmp, value) {
    return this.attribute(cmp, 'screenMode', value);
  },

  sobjectType: function(cmp, value) {
    return this.attribute(cmp, 'sobjectType', value);
  },

  overlayLibCmp: function(cmp) {
    return cmp.find('overlayLib');
  },

  config: function(cmp) {},

  fetchAppointment: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var params = {
      actionName: 'appointmentSearchById',
      appointmentId: recordId
    };
    that.isLoading(cmp, true);
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_Appointment,
        params: params
      })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(
          /**@type {import('AppointmentsBase').Appointment} */ appointment
        ) {
          console.log(params, appointment);
          that.isLoading(cmp, false);
          that.appointment(cmp, appointment);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
        })
      );
  },
  showUpdateModal: function(cmp) {
    var that = this;
    var appointment = that.appointment(cmp);
    if (!appointment.Accession_Number__c) {
      return that.showEditRecordForm(cmp, appointment);
    }

    var recordId = that.recordId(cmp);
    var componentName = 'c:AppointmentsDashboard';
    var overlayLibCmp = that.overlayLibCmp(cmp);
    /**@type {import('AppointmentsBase').AppointmentMode} */
    var mode = 'update';
    var screenMode = that.screenMode(cmp);
    that.isLoading(cmp, true);
    $A.createComponent(
      componentName,
      {
        recordId: recordId,
        mode: mode,
        screenMode: screenMode,
        selectedAppointment: appointment,
        clinic: null
      },
      function(preparedCmp, status) {
        if (status === 'SUCCESS') {
          overlayLibCmp
            .showCustomModal({
              body: preparedCmp,
              cssClass: 'cAppointmentsDashboard dashboard-modal',
              showCloseButton: true,
              closeCallback: function() {}
            })
            .then(function(modalRef) {
              that.isLoading(cmp, false);
            });
        } else {
          console.log(status);
          that.isLoading(cmp, false);
        }
      }
    );
  },

  showEditRecordForm: function(cmp, appointment) {
    var sobjectType = this.sobjectType(cmp);
    var recordId = this.recordId(cmp);
    var newFieldValues = {};
    if (sobjectType === 'Case') {
      newFieldValues.Case_Hidden__c = recordId;
      newFieldValues.Case__c = recordId;
    }

    var editRecordEvent = $A.get(
      this.BASE_CONSTANTS.forceEventTypes.editRecord
    );
    editRecordEvent.setParams({
      recordId: appointment.Id,
      navigationLocation: 'LOOKUP',
      newFieldValues: newFieldValues
    });
    editRecordEvent.fire();
  }
});