/**@type {import("DocExpertShowButton").Helper} */
({
  init: function (cmp) {},
  destroy: function (cmp) {
    this.isAutoShowed(false);
  },
  render: function (cmp) {},
  CONSTANTS: {
    cmpNames: {
      docExpertDashboard: 'DocExpertDashboard',
      appointmentsDashboard: 'AppointmentsDashboard',
      docExpertClinicsModal: 'DocExpertClinicsModal',
      appointmentsCancel: 'AppointmentsCancel',
      appointmentsUpdate: 'AppointmentsUpdate'
    }
  },
  DYNAMIC_DATA: {
    isAutoShowed: false
  },

  isAutoShowed: function (value) {
    if (typeof value === 'undefined') {
      return this.DYNAMIC_DATA.isAutoShowed;
    }
    this.DYNAMIC_DATA.isAutoShowed = value;
  },

  isAvailable: function (cmp, value) {
    return this.attribute(cmp, 'isAvailable', value);
  },

  mode: function (cmp, value) {
    return this.attribute(cmp, 'mode', value);
  },
  sobjectType: function (cmp, value) {
    return this.attribute(cmp, 'sobjectType', value);
  },
  modalRef: function (cmp, value) {
    return this.property(cmp, '_modalRef', value);
  },
  overlayLibCmp: function (cmp) {
    return cmp.find('overlayLib');
  },
  checkAvailable: function (cmp, caseId) {
    var globalServiceCmp = cmp.find('globalServiceNew');
    var all = globalServiceCmp.getAll();
    var services = all.services;
    var docExpertService = services.docExpertService;

    return docExpertService.isAvailable(caseId);
  },

  showModalByMode: function (cmp) {
    var mode = this.mode(cmp);
    switch (mode) {
      case 'create': {
        return this.showDoctorsModal(cmp);
      }
      case 'update': {
        return this.showUpdateModal(cmp);
      }
      case 'cancel': {
        return this.showCancelModal(cmp);
      }
      default: {
        /*  */
      }
    }
  },

  showDoctorsModal: function (cmp) {
    var that = this;
    that.isLoading(cmp, true);

    that
      .checkFillAccount(cmp)
      .then(
        $A.getCallback(function (isSubmitted) {
          if (!isSubmitted) {
            return null;
          }
          return that.getCaseRecordId(cmp).then(
            $A.getCallback(function (caseId) {
              return that.checkAvailable(cmp, caseId).then(
                $A.getCallback(function () {
                  return that.showDocExpertDashboardModal(cmp, caseId);
                })
              );
            })
          );
        })
      )
      .then(
        $A.getCallback(function () {
          that.isLoading(cmp, false);
        })
      )
      .catch(
        $A.getCallback(function (err) {
          that.isLoading(cmp, false);
          console.log(err);
          that.showToast({
            type: 'error',
            title: $A.get('$Label.c.Error'),
            message: that.buildServerErrorsArray(err).join(', ')
          });
        })
      );
  },

  showDocExpertDashboardModal: function (cmp, caseId) {
    var globalServiceCmp = cmp.find('globalServiceNew');
    var all = globalServiceCmp.getAll();
    var services = all.services;
    var modalService = services.modalService;

    var modalParams = modalService.buildAuraModalParams(
      'docExpertDashboardModal',
      {
        modalData: {
          recordId: caseId
        },
        cssClass: 'doc-expert-dashboard-modal',
        useAuraModalDynamicLwc: true
      }
    );
    return modalService.showModal(this, modalParams);
  },

  showCancelModal: function (cmp) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var recordId = that.recordId(cmp);
    var cmpName = that.CONSTANTS.cmpNames.appointmentsCancel;
    var cmpDefinition = that.buildCmpDefinition(cmpName);
    that.isLoading(cmp, true);
    $A.createComponent(
      cmpDefinition.name,
      {
        recordId: recordId
      },
      function (preparedCmp, status) {
        if (status === 'SUCCESS') {
          overlayLibCmp
            .showCustomModal({
              body: preparedCmp,
              cssClass: cmpDefinition.className + ' cancel-modal',
              showCloseButton: true,
              closeCallback: function () {
                that.isAutoShowed(false);
              }
            })
            .then(
              $A.getCallback(function (modalRef) {
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
  showUpdateModal: function (cmp) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var recordId = that.recordId(cmp);
    var cmpName = that.CONSTANTS.cmpNames.appointmentsUpdate;
    var cmpDefinition = that.buildCmpDefinition(cmpName);
    that.isLoading(cmp, true);
    $A.createComponent(
      cmpDefinition.name,
      {
        recordId: recordId,
        onShowUpdateDashboard: cmp.getReference('c.onShowUpdateDashboard')
      },
      function (preparedCmp, status) {
        if (status === 'SUCCESS') {
          overlayLibCmp
            .showCustomModal({
              body: preparedCmp,
              cssClass: cmpDefinition.className + ' update-modal',
              showCloseButton: true,
              closeCallback: function () {
                that.isAutoShowed(false);
              }
            })
            .then(
              $A.getCallback(function (modalRef) {
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

  showAppointmentsUpdate: function (cmp, appointment) {
    var that = this;
    if (!appointment.Accession_Number__c) {
      return this.showEditRecordForm(cmp, appointment);
    }
    /**@type {import('AppointmentsBase').AppointmentScreenMode} */
    var screenMode = 'doctorHeader';
    var overlayLibCmp = this.overlayLibCmp(cmp);
    var recordId = this.recordId(cmp);
    var mode = this.mode(cmp);
    var cmpName = that.CONSTANTS.cmpNames.appointmentsDashboard;
    var cmpDefinition = that.buildCmpDefinition(cmpName);

    that.isLoading(cmp, true);
    $A.createComponent(
      cmpDefinition.name,
      {
        recordId: recordId,
        mode: mode,
        clinic: null,
        screenMode: screenMode,
        selectedAppointment: appointment
      },
      function (dashboardCmp, status) {
        if (status === 'SUCCESS') {
          overlayLibCmp
            .showCustomModal({
              body: dashboardCmp,
              cssClass: cmpDefinition.className + ' dashboard-modal',
              showCloseButton: true,
              closeCallback: function () {}
            })
            .then(
              $A.getCallback(function (modalRef) {
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

  showEditRecordForm: function (cmp, appointment) {
    //check if 'Case'
    // console.log('========', this.unProxyData(appointment));
    //377 -- 5008E00000HKxDZQA1
    //408 -- 5008E00000HhseEQAR
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

    /* Valid parameters are 'recordId', 'layoutType', 'layoutOverride', 'fullScreen', 'recordTypeId', 'errors', 'changeRecordType', 'navigationLocation', 'navigationLocationId', 'nooverride', 'newFieldValues' */
  },
  /**
   *
   * @returns {Promise<string>}
   */
  getCaseRecordId: function (cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var sobjectType = that.sobjectType(cmp);
    var services = that.globalServices(cmp);
    var presaleService = services.presaleService;
    if (sobjectType !== 'Opportunity') {
      return Promise.resolve(recordId);
    }
    return presaleService.createCase(recordId);
  },

  checkFillAccount: function (cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var sobjectType = that.sobjectType(cmp);
    var services = that.globalServices(cmp);
    var fillAccountService = services.fillAccountService;
    if (sobjectType !== 'Opportunity') {
      return Promise.resolve(true);
    }

    return fillAccountService.isAccountFull(recordId).then(
      $A.getCallback(function (isFull) {
        if (isFull) {
          return true;
        }
        return that.showFillAccountModal(cmp, recordId);
      })
    );
  },

  showFillAccountModal: function (cmp, recordId) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var services = that.globalServices(cmp);
    var componentFactoryService = services.componentFactoryService;
    var modalService = services.modalService;
    var modalName = 'FillAccountModal';
    var modalParams = modalService.buildAuraModalParams(modalName);
    modalParams.modalData = {
      recordId: recordId
    };

    var cmpDefinition =
      componentFactoryService.buildComponentDefinition(modalName);
    that.isLoading(cmp, true);
    return componentFactoryService
      .createComponent($A, cmpDefinition.name, {
        modalParams: modalParams
      })
      .then(
        $A.getCallback(function (component) {
          return overlayLibCmp.showCustomModal({
            body: component,
            cssClass: cmpDefinition.className + ' modal',
            showCloseButton: true,
            closeCallback: function () {
              modalParams.resolvers.close();
            }
          });
        })
      )
      .then(
        $A.getCallback(function () {
          that.isLoading(cmp, false);
          return modalParams.promises.close;
        })
      );
  }
});