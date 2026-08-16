/**@type {import("AppointmentsBase").Helper} */
({
  init: function(cmp) {},
  destroy: function(cmp) {},
  render: function(cmp) {},
  controllers: {
    LC_Appointment: 'LC_AppointmentController',
    LC_SurgeriesAppointment: 'LC_SurgeriesAppointment'
  },
  staticData: function(cmp, value) {
    return this.attribute(cmp, 'staticData', value);
  },
  selectedDayData: function(cmp, value) {
    return this.attribute(cmp, 'selectedDayData', value);
  },
  selectedSlot: function(cmp, value) {
    return this.attribute(cmp, 'selectedSlot', value);
  },
  lockedSlot: function(cmp, value) {
    return this.attribute(cmp, 'lockedSlot', value);
  },

  overlayLibCmp: function(cmp) {
    return cmp.find('overlayLib');
  },

  searchAppointments: function(cmp, term, operationType) {
    var that = this;
    var caseId = that.recordId(cmp);
    var params = {
      actionName: 'appointmentSearch',
      operationType: operationType,
      caseId: caseId,
      keyWord: term
    };
    console.log(params);
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_Appointment,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(data) {
          var options = that.buildAppointmentOptions(data);
          console.log(options);
          return options;
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          return [];
        })
      );
  },
  buildAppointmentOptions: function(data) {
    var options = data.map(function(item) {
      return Object.assign(item, { label: item.Name, value: item.Id });
    });
    return options;
  },
  close: function(cmp) {
    var overlayLibCmp = this.overlayLibCmp(cmp);
    overlayLibCmp.notifyClose();
  },
  request: function(cmp, params) {
    return this.executeApex(cmp, params).then(this.BASE_RES_PIPES.statusPipe);
  }
});