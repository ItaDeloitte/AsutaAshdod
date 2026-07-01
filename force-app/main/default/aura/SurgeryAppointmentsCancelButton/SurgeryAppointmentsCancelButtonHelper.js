/**@type {import("SurgeryAppointmentsCancelButton").Helper} */
({
  init: function(cmp) {
    this.fetchInitData(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},

  controllers: {
    LC_SurgeryCancel: 'LC_SurgeryCancel'
  },
  CONSTANTS: {},

  isAvailable: function(cmp, value) {
    return this.attribute(cmp, 'isAvailable', value);
  },
  sobjectType: function(cmp, value) {
    return this.attribute(cmp, 'sobjectType', value);
  },

  overlayLibCmp: function(cmp) {
    return cmp.find('overlayLib');
  },

  config: function(cmp) {},

  fetchInitData: function(cmp) {
    var that = this;
    var params = {};
  },

  cancelClickHandler: function(cmp) {
    var sobjectType = this.sobjectType(cmp);
    switch (sobjectType) {
      case 'Case': {
        return this.showCancelModal(cmp);
      }
      case 'Appointment': {
        return this.cancelRequest(cmp);
      }
    }
  },
  showCancelModal: function(cmp) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var caseId = that.recordId(cmp);
    var cmpDefinition = this.buildCmpDefinition(
      'SurgeryAppointmentsCancelModal'
    );
    that.isLoading(cmp, true);

    $A.createComponent(
      cmpDefinition.name,
      {
        caseId: caseId
      },
      function(preparedCmp, status) {
        if (status === 'SUCCESS') {
          overlayLibCmp
            .showCustomModal({
              body: preparedCmp,
              cssClass: cmpDefinition.className + ' modal',
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
  cancelRequest: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var params = {
      actionName: 'cancelAppointment',
      recordId: recordId
    };
    that.isLoading(cmp, true);

    return that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_SurgeryCancel,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(message) {
          console.log(params, message);
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: message
          });
          that.isLoading(cmp, false);
          that.refreshView();
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
          that.showToast({
            type: 'error',
            title: $A.get('$Label.c.Error'),
            message: that.buildHtmlServerError(err)
          });
          that.refreshView();
        })
      );
  }
});