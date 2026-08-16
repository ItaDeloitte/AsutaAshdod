/**
 * Created by daniilvinnik on 28.09.2022.
 */

({
     CONSTANTS: {},
     controllers: {
          caseAppointmentButtons: 'LC_CaseAppointmentButtons',
          buttonsController: 'LC_ButtonsController',
          LC_Case360Controller: 'LC_Case360Controller',
          actionButtonController: 'LC_ActionButtonController'
     },
     init: function (cmp) {
          this.fetchConfig(cmp);
     },
     fetchConfig: function (cmp) {
          var that = this;
          var recordId = that.recordId(cmp);
          var params = {
               recordId: recordId,
               actionName: 'obtainButtons'
          };
          that.isLoading(cmp, true);
          that.executeApex(cmp, {
               controllerName: this.controllers.actionButtonController,
               params: params
          }).then(this.BASE_RES_PIPES.statusPipe).then(
                $A.getCallback(function (data) {
                     console.log('+++ DV params, data >>> ', params, JSON.parse(JSON.stringify(data)))
                     cmp.set('v.obtainData', data.buttons)
                     cmp.set('v.sObjectType', data.sObjectType)
                     that.isLoading(cmp, false);
                })
          ).catch(
                $A.getCallback(function (err) {
                     console.log(err);
                     that.isLoading(cmp, false);
                })
          );
     },
     overlayLibCmp: function(cmp) {
          return cmp.find('overlayLib');
     },
     isPaymentButtonEnabled: function (cmp, value) {
          return this.attribute(cmp, 'isPaymentButtonEnabled', value);
     },
     showLinkToCaseActionModal: function(cmp) {
          return this.createAndShowModal(cmp, 'LinkToCaseAction')
     },
     showSendQuestionnaireLinkModal: function(cmp) {
          return this.createAndShowModal(cmp, 'SendQuestionnaireLinkModal');
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
          componentFactoryService.createComponent($A, cmpDefinition.name, {
                     recordId: recordId,
                     isForDocExpert: isForDocExpert,
                     isForUrgent: isForUrgent
                })
                .then($A.getCallback(function(component) {
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

          var cmpDefinition = componentFactoryService.buildComponentDefinition(modalName);
          that.isLoading(cmp, true);
          componentFactoryService.createComponent($A, cmpDefinition.name, {modalParams: modalParams}).then(
                      $A.getCallback(function(component) {
                           return overlayLibCmp.showCustomModal({
                                body: component,
                                cssClass: cmpDefinition.className + ' modal',
                                showCloseButton: true,
                                closeCallback: function() {}
                           });
                      })
                ).then(
                      $A.getCallback(function() {
                           that.isLoading(cmp, false);
                           return modalParams.promises.close;
                      })
                ).then(
                      $A.getCallback(function(data) {
                           console.log(that.unProxyData({ data: data }));
                      })
                ).catch(
                      $A.getCallback(function(err) {
                           console.log(err);
                      })
                );
     },
     uploadFilesToClinic: function(cmp) {
          var that = this;
          var recorId = that.recordId(cmp);
          var params = {
               actionName: 'uploadFilesToClinic',
               caseId: recorId
          };
          this.callApex(cmp, this.controllers.buttonsController, params, $A.get('$Label.c.Appointment_converted'))
     },
     convertAppointment: function(cmp) {
          var that = this;
          var recordId = that.recordId(cmp);
          var params = {
               actionName: 'convert',
               recordId: recordId
          };
          this.callApex(cmp, this.controllers.LC_Case360Controller, params, $A.get('$Label.c.Appointment_converted'), true)
     },
     sendOtp: function(cmp) {
          var that = this;
          var recordId = that.recordId(cmp);
          var params = {
               actionName: 'sendOTP',
               recordId: recordId
          };
          this.callApex(cmp, this.controllers.buttonsController, params, $A.get('$Label.c.OTP_Sent'))
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
     callApex: function (cmp,controllerName, params, toastMessage, refreshView) {
          var that = this;
          that.executeApex(cmp, {controllerName: controllerName, params: params})
                .then(this.BASE_RES_PIPES.statusPipe)
                .then($A.getCallback(function(res) {
                           that.showToast({
                                type: 'success',
                                title: $A.get('$Label.c.Success'),
                                message: toastMessage
                           });
                           if (refreshView) {
                                that.refreshView();
                           }
                      })
                ).catch(
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
     showIVFModal: function(cmp) {
          cmp.find('modal').openModal();
     },
});