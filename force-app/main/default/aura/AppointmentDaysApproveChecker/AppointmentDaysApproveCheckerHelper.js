/**@type {import("AppointmentDaysApproveChecker").Helper} */
({
  init: function(cmp) {
    this.checkDays(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},

  confirmDaysResolver: function(cmp, value) {
    return this.property(cmp, '_confirmDaysResolver', value);
  },

  overlayLibCmp: function(cmp) {
    return cmp.find('overlayLib');
  },

  scheduleAppointmentServiceCmp: function(cmp) {
    return cmp.find('scheduleAppointmentService');
  },

  scheduleAppointmentService: function(cmp) {
    if (!cmp._scheduleAppointmentService) {
      var service = this.scheduleAppointmentServiceCmp(cmp).getService();
      cmp._scheduleAppointmentService = service;
    }
    return cmp._scheduleAppointmentService;
  },

  config: function(cmp) {},

  checkDays: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var params = {
      actionName: 'checkAppointmentWorkingDaysOnCreate',
      appointmentId: recordId
    };
    this.scheduleAppointmentService(cmp)
      .appointmentApiRequest(params)
      .then(
        $A.getCallback(function(isNeedConfirm) {
          if (!isNeedConfirm) {
            return;
          }
          that.showDaysConfirmation(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.showToast({
            type: 'error',
            title: $A.get('$Label.c.Error'),
            message: that.buildHtmlServerError(err)
          });
        })
      );
  },

  dayConfirmationHandler: function(cmp, isConfirmed) {
    var confirmDaysResolver = this.confirmDaysResolver(cmp);
    if (confirmDaysResolver) {
      confirmDaysResolver(isConfirmed);
    }
  },

  showDaysConfirmation: function(cmp) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var cmpDefinition = that.buildCmpDefinition('AppointmentsConfirmation');
    var confirmResolver = null;
    var confirmPromise = new Promise(
      $A.getCallback(function(resolve) {
        confirmResolver = resolve;
      })
    );

    $A.createComponent(
      cmpDefinition.name,
      {
        message: $A.get('$Label.c.Appointment_Approval_Message'),
        onconfirmation: cmp.getReference('c.onDayConfirmation')
      },
      function(bodyCmp, status) {
        if (status === 'SUCCESS') {
          overlayLibCmp
            .showCustomModal({
              body: bodyCmp,
              cssClass: cmpDefinition.className + ' confirmation-modal',
              showCloseButton: false,
              closeCallback: function() {}
            })
            .then(function(modalRef) {});
        } else {
          console.log(status);
        }
      }
    );
    that.confirmDaysResolver(cmp, confirmResolver);
    confirmPromise.then(
      $A.getCallback(function(isConfirmed) {
        if (isConfirmed) {
          that.approveAppointment(cmp);
        } else {
          that.cancelAppointment(cmp);
        }
      })
    );
  },
  approveAppointment: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var params = {
      actionName: 'approveAppointmentForMoreThan14Days',
      appointmentId: recordId
    };
    that
      .scheduleAppointmentService(cmp)
      .appointmentApiRequest(params)
      .then(
        $A.getCallback(function(message) {
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: message
          });
          that.refreshView();
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.showToast({
            type: 'error',
            title: $A.get('$Label.c.Error'),
            message: that.buildHtmlServerError(err)
          });
        })
      );
  },
  cancelAppointment: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var params = {
      actionName: 'cancelAppointmentForMoreThan14Days',
      appointmentId: recordId
    };
    that
      .scheduleAppointmentService(cmp)
      .appointmentApiRequest(params)
      .then(
        $A.getCallback(function(message) {
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: message
          });
          that.refreshView();
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.showToast({
            type: 'error',
            title: $A.get('$Label.c.Error'),
            message: that.buildHtmlServerError(err)
          });
        })
      );
  }
});