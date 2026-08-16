/**@type {import("GetAppointmentApproval").Helper} */
({
  CONSTANTS: {},

  controllers: {
    buttonsController: 'LC_ButtonsController'
  },

  init: function(cmp) {
    this.update(cmp);
  },

  destroy: function(cmp) {},
  render: function(cmp) {},

  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },

  update: function(cmp) {
    var self = this;
    var appointmentId = this.recordId(cmp);
    var params = {
      appointmentId: appointmentId,
      actionName: 'getAppointmentApproval'
    };
    self.isLoading(cmp, true);
    self.serverError(cmp, '');
    return self
      .executeApex(cmp, {
        controllerName: this.controllers.buttonsController,
        params: params
      })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          self.isLoading(cmp, false);
          self.showToast({
            title: $A.get('$Label.c.Success'),
            type: 'success',
            message: 'Appointment Approval Success'
          });
          self.refreshView();
          self.close(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          self.showServerError(cmp, err);
          self.isLoading(cmp, false);
        })
      );
  },
  cancel: function(cmp) {
    this.close(cmp);
  },
  close: function(cmp) {
    this.closeQuickAction();
  },
  showServerError: function(cmp, err) {
    var errMessage = this.buildHtmlServerError(err);
    this.serverError(cmp, errMessage);
  },
  actionClicked: function(cmp, action) {
    switch (action) {
      case 'retry': {
        return this.update(cmp);
      }
      case 'cancel': {
        return this.cancel(cmp);
      }
    }
  }
});