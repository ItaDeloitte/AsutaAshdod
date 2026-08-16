/**@type {import("AppointmentsDashboardDemo").Helper} */
({
  init: function(cmp) {},
  controllers: {
    LC_AppointmentController: 'LC_AppointmentController'
  },
  CONSTANTS: {},

  inputData: function(cmp, value) {
    return this.attribute(cmp, 'inputData', value);
  },
  slots: function(cmp, value) {
    return this.attribute(cmp, 'slots', value);
  },
  lockedSlots: function(cmp, value) {
    return this.attribute(cmp, 'lockedSlots', value);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},

  submit: function(cmp) {
    console.log('submitted');

    this.getSlots(cmp);
  },

  getSlots: function(cmp) {
    var self = this;
    var inputData = this.inputData(cmp);
    var params = {
      actionName: 'getSlots',
      siteId: inputData.siteId,
      patientId: inputData.patientId,
      procedureCode: inputData.procedureCode,
      idType: inputData.idType
    };
    console.log(params);
    self.isLoading(cmp, true);
    self
      .executeApex(cmp, {
        controllerName: self.controllers.LC_AppointmentController,
        params: params
      })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(slots) {
          console.log(slots);
          self.slots(cmp, slots);
          self.isLoading(cmp, false);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          self.isLoading(cmp, false);
          self.slots(cmp, []);
          self.showToast({
            type: 'error',
            title: 'Error',
            message: err.responseObj
          });
        })
      );
  },
  lockSlot: function(cmp, slot) {
    var self = this;
    var params = {
      actionName: 'lockSlot',
      slot: JSON.stringify(slot)
    };
    console.log(params);
    self.isLoading(cmp, true);
    self
      .executeApex(cmp, {
        controllerName: self.controllers.LC_AppointmentController,
        params: params
      })
      .then(self.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          console.log(res);
          var slots = self.slots(cmp).slice();
          slot.SlotLockId = res.SlotLockId;
          slot.ExtCalendarId = res.ExtCalendarId;
          self.slots(cmp, slots);
          self.isLoading(cmp, false);
          self.showToast({
            type: 'success',
            title: 'Success',
            message: 'Slot locked'
          });
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          self.isLoading(cmp, false);
          self.showToast({
            type: 'error',
            title: 'Error',
            message: err.responseObj
          });
        })
      );
  },
  refreshLockSlot: function(cmp, slot) {
    var self = this;
    var params = {
      actionName: 'refreshLockSlot',
      slot: JSON.stringify(slot),
      slotLockId: slot.SlotLockId
    };
    console.log(params);
    self.isLoading(cmp, true);
    self
      .executeApex(cmp, {
        controllerName: self.controllers.LC_AppointmentController,
        params: params
      })
      .then(self.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          console.log(res);
          self.isLoading(cmp, false);
          self.showToast({
            type: 'success',
            title: 'Success',
            message: 'Lock refreshed'
          });
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          self.isLoading(cmp, false);
          self.showToast({
            type: 'error',
            title: 'Error',
            message: err.responseObj
          });
        })
      );
  },
  unlockSlot: function(cmp, slot) {
    var self = this;
    var params = {
      actionName: 'unlockSlot',
      slotLockId: slot.SlotLockId,
      slot: JSON.stringify(slot)
    };
    console.log(params);
    self.isLoading(cmp, true);
    self
      .executeApex(cmp, {
        controllerName: self.controllers.LC_AppointmentController,
        params: params
      })
      .then(self.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          console.log(res);
          self.isLoading(cmp, false);
          var slots = self.slots(cmp).slice();
          slot.SlotLockId = null;
          slot.ExtCalendarId = null;
          self.slots(cmp, slots);
          self.showToast({
            type: 'success',
            title: 'Success',
            message: 'Slot unlocked'
          });
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          self.isLoading(cmp, false);
          self.showToast({
            type: 'error',
            title: 'Error',
            message: err.responseObj
          });
        })
      );
  },
  setAppointment: function(cmp, slot) {
    var self = this;
    var inputData = this.inputData(cmp);
    var caseId = this.recordId(cmp);
    var params = {
      actionName: 'setAppointment',
      slot: JSON.stringify(slot),
      paitinetId: inputData.patientId,
      idType: inputData.idType,
      procedureCode: inputData.procedureCode,
      caseId: caseId,
      siteId: inputData.siteId
    };
    console.log(params);
    self.isLoading(cmp, true);
    self
      .executeApex(cmp, {
        controllerName: self.controllers.LC_AppointmentController,
        params: params
      })
      .then(self.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          console.log(res);
          self.isLoading(cmp, false);
          self.showToast({
            type: 'success',
            title: 'Success',
            message: 'Appointment setted'
          });
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          self.isLoading(cmp, false);
          self.showToast({
            type: 'error',
            title: 'Error',
            message: err.responseObj
          });
        })
      );
  }
});