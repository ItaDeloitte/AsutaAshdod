/**@type {import("CaseAppointmentButtons").Helper} */
({
  init: function(cmp) {},
  CONSTANTS: {},
  controllers: {
    caseAppointmentButtons: 'LC_CaseAppointmentButtons',
    buttonsController: 'LC_ButtonsController',
    LC_Case360Controller: 'LC_Case360Controller'
  },
  destroy: function(cmp) {},
  render: function(cmp) {
    var isRendered = this.isRendered(cmp);
    if (isRendered) {
      return;
    }
    this.isRendered(cmp, true);
    this.fetchConfig(cmp);
  },

  overlayLibCmp: function(cmp) {
    return cmp.find('overlayLib');
  },
  buttonsVisibility: function(cmp, value) {
    return this.attribute(cmp, 'buttonsVisibility', value);
  },

  isPaymentButtonEnabled: function (cmp, value) {
    return this.attribute(cmp, 'isPaymentButtonEnabled', value);
  },

  fetchConfig: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var params = {
      recordId: recordId,
      actionName: 'checkObject'
    };
    that.isLoading(cmp, true);
    return that
      .executeApex(cmp, {
        controllerName: this.controllers.caseAppointmentButtons,
        params: params
      })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(
          /**@type {import('CaseAppointmentButtons').ButtonsVisibility} */ data
        ) {
          console.log(params, data);
          that.isLoading(cmp, false);
          that.buttonsVisibility(cmp, data);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
        })
      );
  },
  convertAppointment: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var params = {
      actionName: 'convert',
      recordId: recordId
    };
    that
      .executeApex(cmp, {
        controllerName: this.controllers.LC_Case360Controller,
        params: params
      })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: $A.get('$Label.c.Appointment_converted')
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
            message: err
          });
        })
      );
  },

  showCase360CloseModal: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var cmpName = 'Case360CloseModal';
    var cmpDefinition = that.buildCmpDefinition(cmpName);
    that.isLoading(cmp, true);
    $A.createComponent(
      cmpDefinition.name,
      {
        recordId: recordId
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
            .then(
              $A.getCallback(function() {
                that.isLoading(cmp, false);
              })
            );
        } else {
          console.log(status);
          that.isLoading(cmp, false);
        }
      }
    );
  },
  showContactDoctorModal: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var cmpName = 'ContactDoctorModal';
    var cmpDefinition = that.buildCmpDefinition(cmpName);
    that.isLoading(cmp, true);
    $A.createComponent(
      cmpDefinition.name,
      {
        recordId: recordId
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
            .then(
              $A.getCallback(function() {
                that.isLoading(cmp, false);
              })
            );
        } else {
          console.log(status);
          that.isLoading(cmp, false);
        }
      }
    );
  },
  sendOtp: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var params = {
      actionName: 'sendOTP',
      recordId: recordId
    };
    that
      .executeApex(cmp, {
        controllerName: this.controllers.buttonsController,
        params: params
      })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(data) {
          console.log(params, data);
          that.isLoading(cmp, false);
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: $A.get('$Label.c.OTP_Sent')
          });
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
        })
      );
  },
  showDisabilityModal: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var services = that.globalServices(cmp);
    var componentFactoryService = services.componentFactoryService;
    var modalService = services.modalService;
    var modalName = 'AppointmentDisabilitiesModal';
    var modalParams = modalService.buildAuraModalParams(modalName);
    modalParams.modalData = {
      caseId: recordId,
      appointmentIds: [],
      search: true
    };

    var cmpDefinition = componentFactoryService.buildComponentDefinition(
      modalName
    );
    that.isLoading(cmp, true);
    componentFactoryService
      .createComponent($A, cmpDefinition.name, {
        modalParams: modalParams
      })
      .then(
        $A.getCallback(function(component) {
          return overlayLibCmp.showCustomModal({
            body: component,
            cssClass: cmpDefinition.className + ' modal',
            showCloseButton: true,
            closeCallback: function() {}
          });
        })
      )
      .then(
        $A.getCallback(function() {
          that.isLoading(cmp, false);
          return modalParams.promises.close;
        })
      )
      .then(
        $A.getCallback(function(data) {
          console.log(that.unProxyData({ data: data }));
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
        })
      );
  },
  showIVFModal: function(cmp) {
    cmp.find('modal').openModal();
  },
  uploadFilesToClinic: function(cmp) {
    var that = this;
    var recorId = that.recordId(cmp);
    var params = {
      actionName: 'uploadFilesToClinic',
      caseId: recorId
    };
    that
      .executeApex(cmp, {
        controllerName: this.controllers.buttonsController,
        params: params
      })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(data) {
          console.log(params, data);
          that.isLoading(cmp, false);
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: $A.get('$Label.c.FilesUploadedToClinic')
          });
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
        })
      );
  },
  showForcedAppointmentScreen: function(cmp) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var recordId = that.recordId(cmp);
    var isForDocExpert = false;
    var isForUrgent = true;
    var globalServiceCmp = that.globalServiceCmp(cmp);
    var all = globalServiceCmp.getAll();
    var services = all.services;
    var componentFactoryService = services.componentFactoryService;

    var cmpDefinition = componentFactoryService.buildComponentDefinition(
      'C30_SubmitForcedAppointmentModal'
    );
    that.isLoading(cmp, true);
    componentFactoryService
      .createComponent($A, cmpDefinition.name, {
        recordId: recordId,
        isForDocExpert: isForDocExpert,
        isForUrgent: isForUrgent          
      })
      .then(
        $A.getCallback(function(component) {
          overlayLibCmp
            .showCustomModal({
              body: component,
              cssClass: cmpDefinition.className + ' modal',
              showCloseButton: true,
              closeCallback: function() {}
            })
            .then(
              $A.getCallback(function(modalRef) {
                that.isLoading(cmp, true);
                // that.close(cmp);
              })
            );
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
        })
      );
    },
    createAndShowModal: function (cmp, modalName) {
       var that = this;
       var globalServiceCmp = cmp.find('globalServiceNew');
       var all = globalServiceCmp.getAll();
       var services = all.services;
       var modalService = services.modalService;

       var recordId = that.recordId(cmp);
       var modalParams = modalService.buildAuraModalParams(modalName, {useAuraModalDynamicLwc: true});
       modalParams.modalData = {
          recordId: recordId,
       };
       return modalService.showModal(that, modalParams);
    },
    showLinkToCaseActionModal: function(cmp) {
       return this.createAndShowModal(cmp, 'LinkToCaseAction');
    },
    showSendQuestionnaireLinkModal: function(cmp) {
        return this.createAndShowModal(cmp, 'SendQuestionnaireLinkModal');
    }
});