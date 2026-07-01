/**@type {import("AppoitmentsShowButton").Helper} */
({
  init: function (cmp) {
    var that = this
    var mode = this.mode(cmp);
    if (mode==='update') {
      window.addEventListener('closeAppointmentModal', function (event) {
        that.showUpdateModal(cmp)
      })
    }
  },
  destroy: function (cmp) {
    this.modalRef(cmp, null);
    this.isAutoShowed(false);
  },
  render: function (cmp) {
    var isRendered = this.isRendered(cmp);
    if(isRendered) {
      return;
    }
  },

  CONSTANTS: {
    cmpNames: {
      appointmentDashboard: 'AppointmentsDashboard',
      appointmentsCancel: 'AppointmentsCancel',
      appointmentsUpdate: 'AppointmentsUpdate'
    }
  },

  DYNAMIC_DATA: {
    isAutoShowed: false
  },

  isAutoShowed: function (value) {
    if(typeof value === 'undefined') {
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
  screenMode: function (cmp, value) {
    return this.attribute(cmp, 'screenMode', value);
  },
  modalRef: function (cmp, value) {
    return this.property(cmp, '_modalRef', value);
  },

  overlayLibCmp: function (cmp) {
    return cmp.find('overlayLib');
  },

  checkAppointmentAvailable: function (cmp, recordId) {
    var that = this;
    var services = that.globalServices(cmp);
    var appointmentService = services.appointmentService;
    return appointmentService.isAppointmentAvailable(recordId);
  },

  showModalByMode: function (cmp) {
    var mode = this.mode(cmp);
    switch(mode) {
      case 'create': {
        return this.showCreateModal(cmp);
      }
      case 'update': {
        return this.showUpdateModal(cmp);
      }
      case 'cancel': {
        return this.showCancelModal(cmp);
      }
    }
  },
  showCreateModal: function (cmp) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var mode = that.mode(cmp);
    var screenMode = that.screenMode(cmp);
    var cmpName = that.CONSTANTS.cmpNames.appointmentDashboard;
    var cmpDefinition = that.buildCmpDefinition(cmpName);

    function showDashboard(caseId) {
      $A.createComponent(
        cmpDefinition.name,
        {
          recordId: caseId,
          mode: mode,
          screenMode: screenMode
        },
        function (dashboardCmp, status) {
          if(status === 'SUCCESS') {
            overlayLibCmp
              .showCustomModal({
                body: dashboardCmp,
                cssClass: cmpDefinition.className + ' dashboard-modal',
                showCloseButton: true,
                closeCallback: function () {
                  // that.isAutoShowed(false);
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
    }

    that.isLoading(cmp, true);


    that.checkFillAccount(cmp)
      .then($A.getCallback(function (isSubmitted) {
        if(!isSubmitted) {
          return null;
        }
        return that
          .getCaseRecordId(cmp)
          .then(
            $A.getCallback(function (caseId) {
              return that.checkAppointmentAvailable(cmp, caseId).then(
                $A.getCallback(function (result) {
                  if(result.showPreferredChannel) {
                    return that.showPreferredChannelModal(cmp, caseId).then(
                      $A.getCallback(function (result) {
                        if(!result) {
                          return null;
                        }
                        return showDashboard(caseId);
                      })
                    );
                  } else {
                    return showDashboard(caseId);
                  }
                })
              );
            })
          );

      }))
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
  showUpdateModal: function (cmp) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var recordId = that.recordId(cmp);
    var cmpName = that.CONSTANTS.cmpNames.appointmentsUpdate;
    var cmpDefinition = that.buildCmpDefinition(cmpName);
    that.isLoading(cmp, true);
    that
      .checkAppointmentAvailable(cmp, recordId)
      .then(
        $A.getCallback(function () {
          $A.createComponent(
            cmpDefinition.name,
            {
              recordId: recordId,
              onShowUpdateDashboard: cmp.getReference('c.onShowUpdateDashboard')
            },
            function (dashboardCmp, status) {
              if(status === 'SUCCESS') {
                if (!overlayLibCmp) {
                  return;
                }
                overlayLibCmp
                  .showCustomModal({
                    body: dashboardCmp,
                    cssClass: cmpDefinition.className + ' update-modal',
                    showCloseButton: true,
                    closeCallback: function () {
                      // that.isAutoShowed(false);
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
  showCancelModal: function (cmp) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var recordId = that.recordId(cmp);
    var cmpName = that.CONSTANTS.cmpNames.appointmentsCancel;
    var cmpDefintion = that.buildCmpDefinition(cmpName);
    that.isLoading(cmp, true);
    $A.createComponent(
      cmpDefintion.name,
      {
        recordId: recordId
      },
      function (dashboardCmp, status) {
        if(status === 'SUCCESS') {
          overlayLibCmp
            .showCustomModal({
              body: dashboardCmp,
              cssClass: cmpDefintion.className + ' cancel-modal',
              showCloseButton: true,
              closeCallback: function () {
                // that.isAutoShowed(false);
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
  showUpdateDashboard: function (cmp, appointment) {
    var that = this;
    if(!appointment.Accession_Number__c) {
      return that.showEditRecordForm(cmp, appointment);
    }
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var recordId = that.recordId(cmp);
    var mode = that.mode(cmp);
    var screenMode = that.screenMode(cmp);
    var cmpName = that.CONSTANTS.cmpNames.appointmentDashboard;
    var cmpDefinition = that.buildCmpDefinition(cmpName);
    that.isLoading(cmp, true);
    $A.createComponent(
      cmpDefinition.name,
      {
        recordId: recordId,
        screenMode: screenMode,
        mode: mode,
        selectedAppointment: appointment
      },
      function (dashboardCmp, status) {
        if(status === 'SUCCESS') {
          overlayLibCmp
            .showCustomModal({
              body: dashboardCmp,
              cssClass: cmpDefinition.className + ' dashboard-modal',
              showCloseButton: true,
              closeCallback: function () {
                // that.isAutoShowed(false);
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
  showEditRecordForm: function (cmp, appointment) {
    var sobjectType = this.sobjectType(cmp);
    var recordId = this.recordId(cmp);
    var newFieldValues = {};
    if(sobjectType === 'Case') {
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
  },

  showPreferredChannelModal: function (cmp, recordId) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var services = that.globalServices(cmp);
    var componentFactoryService = services.componentFactoryService;
    var modalService = services.modalService;
    var modalName = 'AccountPreferredChannelModal';
    var modalParams = modalService.buildAuraModalParams(modalName);
    modalParams.modalData = {
      recordId: recordId
    };

    var cmpDefinition = componentFactoryService.buildComponentDefinition(
      modalName
    );
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
    if(sobjectType !== 'Opportunity') {
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
    if(sobjectType !== 'Opportunity') {
      return Promise.resolve(true);
    }

    return fillAccountService.isAccountFull(recordId)
      .then($A.getCallback(function (isFull) {
        if(isFull) {
          return true;
        }
        return that.showFillAccountModal(cmp, recordId);
      }));
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

    var cmpDefinition = componentFactoryService.buildComponentDefinition(
      modalName
    );
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