/**@type {import("AppointmentsDashboard").Helper} */
({
  init: function(cmp) {
    this.attachGlobalEvents(cmp);
    // this.checkAvailable(cmp);
    this.fetchStaticData(cmp);
  },
  CONSTANTS: {},
  LOG_LEVEL: 0,

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

  closeF: function(cmp) {
    var that = this;
    that.close(cmp);
  },

  mode: function(cmp, value) {
    return this.attribute(cmp, 'mode', value);
  },
  screenMode: function(cmp, value) {
    return this.attribute(cmp, 'screenMode', value);
  },
  clinic: function(cmp, value) {
    return this.attribute(cmp, 'clinic', value);
  },
  doctorId: function(cmp, value) {
    return this.attribute(cmp, 'doctorId', value);
  },
  appointmentData: function(cmp, value) {
    return this.attribute(cmp, 'appointmentData', value);
  },
  isUrgentVisible: function(cmp, value) {
    return this.attribute(cmp, 'isUrgentVisible', value);
  },
  editData: function(cmp, value) {
    return this.attribute(cmp, 'editData', value);
  },
  editDataDisableConfig: function(cmp, value) {
    return this.attribute(cmp, 'editDataDisableConfig', value);
  },
  isSlotsNotFoundMessageVisible: function(cmp, value) {
    return this.attribute(cmp, 'isSlotsNotFoundMessageVisible', value);
  },
  editFieldCmps: function(cmp) {
    return this.convertCmpsToArray(cmp.find('editField'));
  },
  appointmentFieldCmps: function(cmp, value) {
    return this.convertCmpsToArray(cmp.find('appointmentField'));
  },
  sequenceProcedureFields: function(cmp, value) {
    return this.attribute(cmp, 'sequenceProcedureFields', value);
  },
  findAutocompleteEditField: function(cmp, fieldName) {
    var that = this;
    var editFieldCmps = that.editFieldCmps(cmp);
    return editFieldCmps.find(function(item) {
      var name = that.attribute(item, 'name');
      return name === fieldName;
    });
  },
  /*  */
  slotsData: function(cmp, value) {
    return this.attribute(cmp, 'slotsData', value);
  },
  slotsMap: function(cmp) {
    var slotsData = this.slotsData(cmp);
    return slotsData ? slotsData.slotsMap : {};
  },
  lockedData: function(cmp, value) {
    return this.attribute(cmp, 'lockedData', value);
  },
  selectedDayData: function(cmp, value) {
    return this.attribute(cmp, 'selectedDayData', value);
  },
  isClinicChanged: function(cmp, value) {
    return this.attribute(cmp, 'isClinicChanged', value);
  },
  /*  */
  isSequence: function(cmp, value) {
    return this.attribute(cmp, 'isSequence', value);
  },
  isTechnician: function(cmp, value) {
    return this.attribute(cmp, 'isTechnician', value);
  },

  isSequenceSiteInitSearch: function(cmp, value) {
    return this.property(cmp, '_isSequenceSiteInitSearch', value);
  },
  hasTechnicianProcedure: function(cmp, value) {
    return this.attribute(cmp, 'hasTechnicianProcedure', value);
  },
  canAddSequence: function(cmp, value) {
    return this.attribute(cmp, 'canAddSequence', value);
  },
  procedureAutocompleteCmp: function(cmp) {
    return this.findAutocompleteEditField(cmp, 'procedure');
  },
  procedureToCalendarCmp: function(cmp) {
    return this.findCalendarToProcedure(cmp, 'procedure');
  },
  domainAutocompleteCmp: function(cmp) {
    return this.findAutocompleteEditField(cmp, 'domain');
  },
  technicianAutocompleteCmp: function(cmp) {
    return this.findAutocompleteEditField(cmp, 'technician');
  },
  clinicAutocompleteCmp: function(cmp) {
    return this.findAutocompleteEditField(cmp, 'clinic');
  },
  sequenceSiteAutocompleteCmp: function(cmp) {
    return this.findAutocompleteEditField(cmp, 'sequenceSite');
  },
  calendarAutocompleteCmp: function(cmp) {
    return this.findAutocompleteEditField(cmp, 'calendar');
  },
  fileAutocompleteCmp: function(cmp) {
    return this.findAutocompleteEditField(cmp, 'file');
  },
  appointments: function(cmp, value) {
    //TODO:remove?
    return this.attribute(cmp, 'appointments', value);
  },
  lockTimerId: function(cmp, value) {
    return this.property(cmp, '_lockTimerId', value);
  },
  lockTimeCounter: function(cmp, value) {
    return this.attribute(cmp, 'lockTimeCounter', value);
  },

  slotRows: function(cmp, value) {
    return this.attribute(cmp, 'slotRows', value);
  },
  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },

  selectedFilters: function(cmp, value) {
    return this.attribute(cmp, 'selectedFilters', value);
  },
  selectedOptions: function(cmp, value) {
    return this.attribute(cmp, 'selectedOptions', value);
  },
  selectedAppointment: function(cmp, value) {
    //TODO:change
    return this.attribute(cmp, 'selectedAppointment', value);
  },
  isTimeGroupVisible: function(cmp, value) {
    return this.attribute(cmp, 'isTimeGroupVisible', value);
  },
  appointmentScrollerWrapperCmp: function(cmp) {
    return cmp.find('appointmentScrollerWrapper');
  },
  sideScrollerWrapperCmp: function(cmp) {
    return cmp.find('sideScrollerWrapper');
  },
  windowResizeListener: function(cmp, value) {
    return this.property(cmp, '_windowResizeListener', value);
  },
  confirmDaysResolver: function(cmp, value) {
    return this.property(cmp, '_confirmDaysResolver', value);
  },
  preparedAppointments: function(cmp, value) {
    return this.attribute(cmp, 'preparedAppointments', value);
  },
  isForDocExpert: function(cmp, value) {
    return this.attribute(cmp, 'isForDocExpert', value);
  },
  isFileRequired: function(cmp, value) {
    return this.attribute(cmp, 'isFileRequired', value);
  },
  isAvailableTimeSlots: function(cmp, value) {
    return this.attribute(cmp, 'isAvailableTimeSlots', value);
  },
  availableTimeSlotsString: function(cmp, value) {
    return this.attribute(cmp, 'availableTimeSlotsString', value);
  },

  retrieveReferralsFromAccountTimeoutId: function(cmp, value) {
    return this.property(cmp, '_retrieveReferralsFromAccountTimeoutId', value);
  },

  retrieveReferralsFromAccountRequestMap: function(cmp, value) {
    return (
      this.property(cmp, '_retrieveReferralsFromAccountRequestMap', value) || {}
    );
  },

  destroy: function(cmp) {
    var cmpId = cmp.getGlobalId();
    this.stopLockTimer(cmp);
    this.clearGlobalEvents(cmp);

    var services = this.globalServices(cmp);
    /**
     * @type {import('../../lwc/assutaGlobalService/services/appointmentService').Service}
     */
    var appointmentService = services.appointmentService;

    appointmentService.checkAccessionNumberAfterCmpDestroy(cmpId);
  },
  render: function(cmp) {},

  lockSlotsRequest: function(cmp, slotsForLock, prevLockedIdsForRefresh) {
    var that = this;
    var recordId = that.recordId(cmp);
    var params = {
      actionName: 'lockSlotArray',
      recordId: recordId,
      jsonedSlots: JSON.stringify(slotsForLock),
      slotLockIds: JSON.stringify(prevLockedIdsForRefresh),
      doctorId: that.doctorId(cmp)
    };
    that.serverError(cmp, '');
    that.updateTimeGroupPosition(cmp);
    that.isLoading(cmp, true);
    return that
      .scheduleAppointmentService(cmp)
      .appointmentApiRequest(params)
      .then(
        $A.getCallback(function(res) {
          that.isLoading(cmp, false);
          return res;
        })
      );
  },
  unlockAndRefreshSlotsRequest: function(cmp, data) {
    var that = this;
    var mode = that.mode(cmp);
    var editData = that.editData(cmp);

    var params = {
      actionName: 'unlockAndRefreshSlotArray',
      jsonedSlotsForUnlock: JSON.stringify(data.slotsForUnlock),
      slotLockIdsForUnlock: JSON.stringify(data.lockIdsForUnlock),
      jsonedSlotsForRefresh: JSON.stringify(data.slotsForRefresh),
      slotLockIdsForRefresh: JSON.stringify(data.lockIdsForRefresh),
      doctorId: that.doctorId(cmp)
    };
    that.serverError(cmp, '');
    that.updateTimeGroupPosition(cmp);
    that.isLoading(cmp, true);
    return that
      .scheduleAppointmentService(cmp)
      .appointmentApiRequest(params)
      .then(
        $A.getCallback(function(res) {
          that.isLoading(cmp, false);
          return res;
        })
      );
  },
  submit: function(cmp) {
    var mode = this.mode(cmp);
    var isValid = this.validateAppointmentFields(cmp);
    if (!isValid) {
      return;
    }
    switch (mode) {
      case 'create': {
        return this.createAppointment(cmp);
      }
      case 'update': {
        return this.updateAppointment(cmp);
      }
    }
  },
  createAppointment: function(cmp) {
    var that = this;
    var lockedData = that.lockedData(cmp);
    var lockedSlots = lockedData.lockedSlots;
    var firstSlot = lockedSlots[0].slot;

    var isForDocExpert = that.isForDocExpert(cmp);
    Promise.resolve()
      .then(
        $A.getCallback(function() {
          if (!isForDocExpert) {
            return that.createAppointmentRequest(cmp, false);
          }
          return that.checkWorkingDays(cmp, firstSlot).then(
            $A.getCallback(function(message) {
              if (message) {
                return that.showDaysConfirmation(cmp, message).then(
                  $A.getCallback(function(isConfirmed) {
                    return isConfirmed
                      ? that.createAppointmentRequest(cmp, true)
                      : null;
                  })
                );
              }
              return that.createAppointmentRequest(cmp, false);
            })
          );
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.requestErrorHandler(cmp, err);
        })
      );
  },
  createAppointmentRequest: function(cmp, isSendForApproval) {
    var that = this;
    var cmpId = cmp.getGlobalId();
    var services = that.globalServices(cmp);
    /**
     * @type {import('../../lwc/assutaGlobalService/services/appointmentDisabilitiesService').Service}
     */
    var appointmentDisabilitiesService =
      services.appointmentDisabilitiesService;
    var appointmentService = services.appointmentService;
    var editData = that.editData(cmp);
    var selectedOptions = that.selectedOptions(cmp);
    var appointmentData = that.appointmentData(cmp);
    var staticData = that.staticData(cmp);
    var recordId = that.recordId(cmp);
    var slots = that.getSlotsFromLockedData(cmp);
    var clinic = that.clinic(cmp);
    var fileIds = that.getFileIds(cmp);
    var protocolIds = that.getSelectedProtocolIds(cmp);
    var isTechnician = that.isTechnician(cmp);
    var isForDocExpert = that.isForDocExpert(cmp);
    var appointmentIds = [];
    var hasDisabilities = false;
    var disabilitiesData;

    var procedureCodes = that.getAllSelectedProcedureCodes(cmp);

    var technicianProcedure = selectedOptions.technicianProcedure;
    var technician = null;
    var technicianProcedureCode = '';
    var technicianProcedureLeading = false;

    if (!isForDocExpert) {
      if (isTechnician) {
        technician = selectedOptions.technician;
        if (technicianProcedure) {
          technicianProcedureCode = editData.technicianProcedure;
          technicianProcedureLeading = technicianProcedure.isLeading;
        }
      }
    }

    function createAppointment() {
      var assists = [];
      var assistsMap = {};
      if (disabilitiesData) {
        disabilitiesData.disabilities.forEach(function(assistGroup) {
          assistGroup.assists.forEach(function(item) {
            if (item.isSelected && !assistsMap[item.value]) {
              assistsMap[item.value] = item.value;
            }
          });
        });
        assists = Object.keys(assistsMap);
      }

      var params = {
        actionName: 'createAppointmentArray',
        jsonedSlots: JSON.stringify(slots),
        patientId: staticData.accountPaitientId,
        idType: staticData.accountPaitientIdType,
        clinicId: clinic ? clinic.Id : '',
        protocol: editData.protocol,
        protocols: JSON.stringify(protocolIds),
        insurenceCode: editData.insurerFactor,
        urgentReason: appointmentData.urgentReason,
        recordId: recordId,
        assists: JSON.stringify(assists),

        procedureCodes: JSON.stringify(procedureCodes),

        technician: technician ? JSON.stringify(technician) : '',
        technicianProcedureCode: technicianProcedureCode,
        technicianProcedureLeading: technicianProcedureLeading,
        doctorId: that.doctorId(cmp)
      };

      // console.log(that.unProxyData(params));

      return appointmentService
        .createAppointmentArray(cmpId, params)
        .then(function(ids) {
          appointmentIds = ids;
          that.executeApex(cmp, {
            controllerName: 'LC_AppointmentScreenController',
            params: {
              actionName: 'getSequenceOfAppointments',
              appointmentId: appointmentIds[0],
              operationType: 'create'
            }
          }).then(res => {
            const appointmentLabel  = $A.get('$Label.c.Appointment')
            const medicalProcedureLabel = $A.get('$Label.c.DocMedicalProcedure')
            const dateTimeOfAppointmentLabel = $A.get('$Label.c.DateTimeOfAppointment')
            const clinicSiteNameLabel = $A.get('$Label.c.ClinicSiteName')
            const siteAddressLabel = $A.get('$Label.c.SiteAddress')
            const ExactDomainLocationLabel = $A.get('$Label.c.ExactDomainLocation')

            let guidanceArr = []

            // if(res.responseObj.length > 1) {
              guidanceArr = res.responseObj.map((appointment, i) => {
                const { 
                  Guidance_Scenario__r, 
                  Medical_Procedure__r, 
                  Appointment_Date_Time__c, 
                  Exact_Location_In_Domain__c,
                  Site__r
                } = appointment;
                const innerArr = [];

                for(const guidanceKey in Guidance_Scenario__r) {
                  const guidanceElement = Guidance_Scenario__r[guidanceKey];
                  if(typeof guidanceElement === 'object' && guidanceElement.Required_To_Read__c) {
                    innerArr.push(guidanceElement.Guideline_Desc__c);
                  }
                }
                
                return {
                  label: `${appointmentLabel} ${i+1}`,
                  values: [...innerArr],
                  isEmpty: innerArr.length === 0,
                  appointmentInfo: [
                    { label: medicalProcedureLabel, value: Medical_Procedure__r.Name, isDate: false },
                    { label: dateTimeOfAppointmentLabel, value: Appointment_Date_Time__c, isDate: true },
                    { label: clinicSiteNameLabel, value: Site__r.Name, isDate: false },
                    { label: siteAddressLabel, value: Site__r.Address__c, isDate: false },
                    { label: ExactDomainLocationLabel, value: Exact_Location_In_Domain__c, isDate: false },
                  ]
                }
              })
            // }
            // guidanceArr.forEach((g, i) => {g.showDivider = i < guidanceArr.length - 1})
            cmp.set('v.hasGuidances', !!guidanceArr.length)
            cmp.set('v.isInstitutes', res.responseObj[0].RecordType.DeveloperName === 'Institutes')
            cmp.set('v.guidanceList', guidanceArr);
          })
        });
    }

    /**@type {import('AppointmentsDashboard').SetAppointmentReq} */
    function setAppointment() {
      var params = {
        actionName: 'setAppointmentArray',
        jsonedSlots: JSON.stringify(slots),
        patientId: staticData.accountPaitientId,
        idType: staticData.accountPaitientIdType,
        insurenceCode: editData.insurerFactor,
        recordIds: JSON.stringify(appointmentIds),
        sendForApproval: isSendForApproval,
        fileIds: JSON.stringify(fileIds)
      };
      return that.scheduleAppointmentService(cmp).appointmentApiRequest(params);
    }

    function checkAccessionNumber() {
      return appointmentService.checkAccessionNumber(cmpId, appointmentIds);
    }

    function checkAccessionNumberWhenPrevError(err) {
      return checkAccessionNumber()
        .then(function() {
          throw err;
        })
        .catch(function() {
          throw err;
        });
    }

    function checkDisabilities() {
      return appointmentDisabilitiesService
        .getDisabilities(recordId, appointmentIds)
        .then(function(options) {
          hasDisabilities = options.length > 0;
        });
    }

    function showDisabilitiesModal() {
      return that
        .showAppointmentDisabilitiesModal(cmp, recordId, appointmentIds)
        .then(function(data) {
          disabilitiesData = data;
        });
    }

    function setDisabilities() {
      return appointmentDisabilitiesService.setDisabilities(
        recordId,
        appointmentIds,
        disabilitiesData.disabilities
      );
    }

    function success() {
      that.isLoading(cmp, false);
      that.showToast({
        type: 'success',
        title: $A.get('$Label.c.Success'),
        message: $A.get('$Label.c.Appointment_created')
      });
      that.refreshView();

      var staticData = cmp.get('v.staticData');
      
      var isAshdodEmployee = staticData.isAshdodEmloyee;
      var isInstitutes = cmp.get('v.isInstitutes')

      if(!isAshdodEmployee && isInstitutes) { 
        cmp.set('v.isSummaryScreen', true);
      } else {
        that.close(cmp); 
      }
      
      return true;
    }

    function createWithoutDisabilities() {
      return createAppointment()
        .then(setAppointment)
        .then(checkAccessionNumber, checkAccessionNumberWhenPrevError)
        .then($A.getCallback(success));
    }

    function createWithDisabilities() {
      return showDisabilitiesModal().then(
        $A.getCallback(function() {
          if (disabilitiesData) {
            that.isLoading(cmp, true);
            return createAppointment()
              .then(setAppointment)
              .then(setDisabilities)
              .then(checkAccessionNumber, checkAccessionNumberWhenPrevError)
              .then($A.getCallback(success));
          }
          return null;
        })
      );
    }

    that.serverError(cmp, '');
    that.updateTimeGroupPosition(cmp);
    that.isLoading(cmp, true);
    return Promise.resolve()
      .then(checkDisabilities)
      .then(
        $A.getCallback(function() {
          if (hasDisabilities) {
            return createWithDisabilities();
          }
          return createWithoutDisabilities();
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log('ERRRRRR');
          that.requestErrorHandler(cmp, err);
        })
      );
  },

  updateAppointment: function(cmp) {
    var that = this;
    return Promise.resolve()
      .then(
        $A.getCallback(function() {
          return that.updateAppointmentRequest(cmp, false);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.requestErrorHandler(cmp, err);
        })
      );
  },
  updateAppointmentRequest: function(cmp, isSendForApproval) {
    var that = this;
    var services = that.globalServices(cmp);
    /**
     * @type {import('../../lwc/assutaGlobalService/services/appointmentDisabilitiesService').Service}
     */
    var appointmentDisabilitiesService =
      services.appointmentDisabilitiesService;
    var editData = that.editData(cmp);
    var recordId = that.recordId(cmp);
    var clinic = that.clinic(cmp);
    var staticData = that.staticData(cmp);
    var slots = that.getSlotsFromLockedData(cmp);
    var preparedAppointments = that.preparedAppointments(cmp);
    var appointmentIds = preparedAppointments.map(function(item) {
      return item.Id;
    });

    var hasDisabilities = false;
    var disabilitiesData;

    function checkDisabilities() {
      return appointmentDisabilitiesService
        .getDisabilities(recordId, appointmentIds)
        .then(function(options) {
          hasDisabilities = options.length > 0;
        });
    }

    function showDisabilitiesModal() {
      return that
        .showAppointmentDisabilitiesModal(cmp, recordId, appointmentIds)
        .then(function(data) {
          disabilitiesData = data;
        });
    }

    function setDisabilities() {
      return appointmentDisabilitiesService.setDisabilities(
        recordId,
        appointmentIds,
        disabilitiesData.disabilities
      );
    }

    function rescheduleAppointment() {
      var assists = [];
      var assistsMap = {};
      if (disabilitiesData) {
        disabilitiesData.disabilities.forEach(function(assistGroup) {
          assistGroup.assists.forEach(function(item) {
            if (item.isSelected && !assistsMap[item.value]) {
              assistsMap[item.value] = item.value;
            }
          });
        });
        assists = Object.keys(assistsMap);
      }
      var params = {
        actionName: 'rescheduleAppointmentArray',
        jsonedSlots: JSON.stringify(slots),
        patientId: staticData.accountPaitientId,
        idType: staticData.accountPaitientIdType,
        recordId: recordId,
        clinicId: clinic ? clinic.Id : '',
        assists: JSON.stringify(assists),
        insurenceCode: editData.insurerFactor,
        sendForApproval: isSendForApproval,
        appointmentIds: JSON.stringify(appointmentIds)
      };

      return that.scheduleAppointmentService(cmp).appointmentApiRequest(params);
    }

    that.serverError(cmp, '');
    that.updateTimeGroupPosition(cmp);
    that.isLoading(cmp, true);

    return Promise.resolve()
      .then(checkDisabilities)
      .then(
        $A.getCallback(function() {
          if (!hasDisabilities) {
            return rescheduleAppointment();
          }
          return showDisabilitiesModal().then(
            $A.getCallback(function() {
              if (disabilitiesData) {
                that.isLoading(cmp, true);
                return rescheduleAppointment().then(setDisabilities);
              }
              return null;
            })
          );
        })
      )
      .then(
        $A.getCallback(function(result) {
          that.isLoading(cmp, false);
          if (result === null) {
            return;
          }
          that.stopLockTimer(cmp);
          that.resetSlots(cmp);
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: $A.get('$Label.c.Appointment_updated')
          });

          that.refreshView();
          that.close(cmp);
          return true;
        })
      );
  },
  config: function(cmp, staticDataRes) {
    var that = this;
    var doctorId = that.doctorId(cmp);
    var clinic = that.clinic(cmp);
    var screenMode = that.screenMode(cmp);
    var scheduleAppointmentService = that.scheduleAppointmentService(cmp);
    var isForDocExpert = screenMode === 'doctorHeader';
    var staticData = that.transformStaticDataRes(cmp, staticDataRes);
    var isAshdodEmloyee = staticData.isAshdodEmloyee;
    var mode = that.mode(cmp);
    var selectedAppointment = that.selectedAppointment(cmp);
    var editData = that.editData(cmp);
    var selectedOptions = that.selectedOptions(cmp);
    var sequenceProcedureFields = that.sequenceProcedureFields(cmp);
    var isSequence = false;

    editData.startDate = staticData.formattedCurrentDate;
    editData.endDate = '';
    editData.urgentReason = staticData.defaultUrgentReasonOption
      ? staticData.defaultUrgentReasonOption.value
      : '';
    
    if (doctorId === '' || !doctorId) {
      that.doctorId(cmp, staticDataRes.doctorId)
    }

    var insurerFactorOptionsMap = staticData.insurerFactorOptionsMap;
    var insurerFactorOption =
      insurerFactorOptionsMap[staticData.accountInsurerFactor] ||
      staticData.insurerFactorOptions[0];

    var defaultProcedureOption = staticData.defaultProcedureOption;

    var protocolOption = staticData.defaultProtocolOption;
    var calendarQflowOption = staticData.defaultCalendarOption;
    if (!isForDocExpert) {
      editData.insurerFactor = insurerFactorOption.value;
      selectedOptions.insurerFactor = insurerFactorOption;
      if (protocolOption) {
        editData.protocol = protocolOption.value;
        selectedOptions.protocol = protocolOption;
      }
    }

    selectedOptions.clinic = staticData.defaultClinicOption;
    selectedOptions.calendar = staticData.defaultCalendarOption;
    selectedOptions.procedure = defaultProcedureOption;
    selectedOptions.domain = staticData.defaultDomainOption;
    selectedOptions.urgentReason = staticData.defaultUrgentReasonOption;

    if (mode === 'create') {
      if (isForDocExpert) {
        /*  */
      }
    } else if (mode === 'update') {
      var existingAppointments = staticData.existingAppointmentList;
      if (existingAppointments.length === 0) {
        existingAppointments.push(selectedAppointment); //TODO:check
        // return;
      }
      isSequence = existingAppointments.length > 1;
      var firstAppointment = existingAppointments[0];
      var sequenceAppointments = existingAppointments.slice(1);
      sequenceProcedureFields = sequenceAppointments.map(function(item) {
        /**@type {import('AppointmentsDashboard').SequenceProcedureField} */
        var seqField = {
          option: scheduleAppointmentService.buildProcedureOption(
            item.Medical_Procedure__r
          ),
          value: item.Medical_Procedure__r.Procedure_Code__c,
          fileId: '',
          fileOption: null,
          protocolId: '',
          protocolOption: null
        };
        return seqField;
      });

      var procedureOption = scheduleAppointmentService.buildProcedureOption(
        firstAppointment.Medical_Procedure__r,
        staticData.protocolOptionsMap
      );
      selectedOptions.procedure = procedureOption;
      selectedOptions.sequenceSite = scheduleAppointmentService.buildSiteOption(
        firstAppointment.Site__r
      );

      if (isAshdodEmloyee) {
        editData.qflowCalendarOptions = staticData.qflowCalendarOptions;
        if (staticData.defaultCalendarOption) {
          editData.qflowCalendar = staticData.defaultCalendarOption.value;
          editData.qflowCalendarLabel = staticData.defaultCalendarOption.label;
        }
      }
    }

    if (isSequence) {
      selectedOptions.sequenceSite = staticData.defaultSiteOption;
    }
    that.isSequenceSiteInitSearch(cmp, true);
    that.isForDocExpert(cmp, isForDocExpert);
    that.isSequence(cmp, isSequence);
    that.sequenceProcedureFields(cmp, sequenceProcedureFields);
    that.editData(cmp, editData);
    that.selectedOptions(cmp, selectedOptions);
    that.staticData(cmp, staticData);
    that.updateEditDataDisableConfig(cmp);
    that.updatePreparedAppointments(cmp);
    that.scrollSidebarAppointmentsToBottom(cmp);
    if (selectedOptions.procedure) {
      that.emitKmsSearchEvent(cmp, selectedOptions.procedure.Name);
    }

    var dd = {
      mode: mode,
      screenMode: screenMode,
      isForDocExpert: isForDocExpert,
      isSequence: isSequence,
      staticDataRes: staticDataRes,
      editData: editData,
      staticData: staticData,
      selectedAppointment: selectedAppointment,
      selectedOptions: selectedOptions,
      doctorId: doctorId,
      clinic: clinic
    };
    
    if (this.screenMode(cmp) === 'doctorHeader') {
      const siteCode = staticData.defaultCalendarOption?.BranchName__r?.Site_Code__c
      editData.clinic = siteCode || selectedOptions.clinic
      editData.clinicValue = siteCode || selectedOptions.clinic?.value
    }
    console.log(that.unProxyData(dd));
  },
  filtersChangedHandler: function(cmp, filter) {
    var that = this;
    that.unlockAllSlots(cmp).then(
      $A.getCallback(function(isSuccess) {
        if (!isSuccess) {
          return;
        }
        that.buildSlotRows(cmp, true);
        that.updatePreparedAppointments(cmp);
      })
    );
  },
  checkAvailable: function(cmp) {
    var that = this;
    var caseId = that.recordId(cmp);
    var params = {
      actionName: 'isAppointmentAvailable',
      recordId: caseId
    };
    return that
      .executeApex(cmp, {
        controllerName: this.controllers.LC_Appointment,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe);
  },
  fetchStaticData: function(cmp) {
    var that = this;
    var clinic = that.clinic(cmp);
    var doctorId = that.doctorId(cmp);
    var recordId = that.recordId(cmp);
    if (recordId === '' || !recordId) {
      recordId = new URLSearchParams(location.search).get('c__id');
      this.attribute(cmp, 'recordId', recordId)
    }
    var procedureId = new URLSearchParams(location.search).get('c__procedureId');
    var payerFactorId = new URLSearchParams(location.search).get('c__payerFactorId');
    var selectedAppointment = that.selectedAppointment(cmp);
    var params = {
      actionName: 'getFormData',
      recordId: selectedAppointment ? selectedAppointment.Id : recordId,
      doctorId: doctorId,
      procedureId: procedureId,
      payerFactorId: payerFactorId,
      clinicId: clinic ? clinic.Clinic__c : ''
    };
    that.isLoading(cmp, true);
    return that
      .scheduleAppointmentService(cmp)
      .appointmentApiRequest(params)
      .then(
        $A.getCallback(function(
          /**@type {import('AppointmentsBase').StaticDataRes} */ staticDataRes
        ) {
          that.config(cmp, staticDataRes);
          that.isLoading(cmp, false);
          return true;
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.showToast({
            type: 'error',
            title: $A.get('$Label.c.Error'),
            message: that.buildHtmlServerError(err)
          });
          that.close(cmp);
          that.isLoading(cmp, false);
          return false;
        })
      );
  },
  checkProcedure: function(cmp, procedureCodes) {
    var that = this;
    var services = that.globalServices(cmp);
    var appointmentService = services.appointmentService;

    return appointmentService
      .checkProcedure(procedureCodes)
      .then(function(res) {
        return res;
      });
  },
  searchProcedures: function(cmp, term, parsedFieldName) {
    var that = this;
    var staticData = that.staticData(cmp);
    var editData = that.editData(cmp);
    var recordId = that.recordId(cmp);
    var screenMode = that.screenMode(cmp);
    var isForDocExpert = that.isForDocExpert(cmp);
    /**@type {string[]} */
    var procedureCodes = [];
    /**@type {string[]} */
    var sequenceProcedureCodes = [];
    if (parsedFieldName) {
      procedureCodes.push(editData.procedure);
      sequenceProcedureCodes = that
        .getSequenceProcedureCodes(cmp)
        .slice(0, parsedFieldName.index);
      procedureCodes = procedureCodes.concat(sequenceProcedureCodes);
    }

    var params = {
      procedureCodes: JSON.stringify(procedureCodes),
      domainId: editData.domain,
      siteCode: editData.clinic,
      calendarCode: editData.calendar,
      screenMode: screenMode,
      keyWord: term,
      recordId: recordId
    };

    return Promise.resolve()
      .then(function() {
        if (isForDocExpert) {
          return that
            .scheduleAppointmentService(cmp)
            .searchProceduresByCalendar(params, staticData.protocolOptionsMap);
        }
        return that
          .scheduleAppointmentService(cmp)
          .searchProcedures(params, staticData.protocolOptionsMap);
      })
      .catch(function(err) {
        return [];
      });
  },

  searchDomains: function(cmp, term) {
    var that = this;
    var screenMode = that.screenMode(cmp);
    var staticData = that.staticData(cmp);
    return that
      .scheduleAppointmentService(cmp)
      .searchDomains(
        {
          keyWord: term,
          screenMode: screenMode
        },
        staticData.warningDomains
      )
      .then(function(options) {
        return options;
      })
      .catch(function(err) {
        return [];
      });
  },

  searchClinics: function(cmp, term) {
    var that = this;
    var recordId = that.recordId(cmp);
    var doctorId = that.doctorId(cmp);
    return that
      .scheduleAppointmentService(cmp)
      .searchClinics({
        caseId: recordId,
        keyWord: term,
        doctorId: doctorId
      })
      .catch(function(err) {
        return [];
      });
  },

  searchSequenceSites: function(cmp, term) {
    var that = this;
    var procedureCodes = that.getAllSelectedProcedureCodes(cmp);
    return that
      .scheduleAppointmentService(cmp)
      .searchSequenceSites({
        keyWord: term,
        procedureCodes: JSON.stringify(procedureCodes)
      })
      .then(
        $A.getCallback(function(options) {
          var isSequenceSiteInitSearch = that.isSequenceSiteInitSearch(cmp);
          var sequenceSiteAutocompleteCmp = that.sequenceSiteAutocompleteCmp(
            cmp
          );
          if (isSequenceSiteInitSearch && options[0] && !term) {
            sequenceSiteAutocompleteCmp.setOption(options[0]);
          }

          that.isSequenceSiteInitSearch(cmp, false);

          return options;
        })
      )
      .catch(function(err) {
        return [];
      });
  },

  searchCalendars: function(cmp, term) {
    var that = this;
    var recordId = that.recordId(cmp);
    var editData = that.editData(cmp);
    var doctorId = that.doctorId(cmp);
    var isClinicChanged = that.isClinicChanged(cmp);

    return that
      .scheduleAppointmentService(cmp)
      .searchCalendars({
        caseId: recordId,
        siteCode: editData.clinic,
        keyWord: term,
        doctorId: doctorId
      })
      .then(
        $A.getCallback(function(options) {
          if (isClinicChanged) {
            var calendarAutocompleteCmp = that.calendarAutocompleteCmp(cmp);
            that.isClinicChanged(cmp, false);
            if (options.length === 1) {
              calendarAutocompleteCmp.setOption(options[0]);
              that.getProcedureForCalendar(cmp);
            }
          }
          return options;
        })
      )
      .catch(function(err) {
        return [];
      });
  },

  searchFiles: function(cmp, term) {
    var that = this;
    var editData = that.editData(cmp);
    var caseId = that.recordId(cmp);

    return that
      .scheduleAppointmentService(cmp)
      .searchFiles({
        recordId: caseId,
        domainId: editData.domain,
        keyWord: term
      })
      .catch(function(err) {
        return [];
      });
  },
  searchCalendarByProcdedure: function(cmp, term) {
    var that = this;
    var editData = that.editData(cmp);
    var params = {
      actionName: 'calendarSearchAshdod',
      siteCode: '33',
      procedureCode: editData.procedure
    };
    that.isLoading(cmp,true);
    return that
      .executeApex(cmp, {
        controllerName: this.controllers.LC_Appointment,
        params: params
      })
      .then(function(res) {
        that.isLoading(cmp,false);
        var options = [];
        let option = {};
        option.label = null;
        option.value = null;
        editData.qflowCalendar = null;
        options.push(option);

        res.responseObj.map(function(item) {
          var option = {};
          option.label = item.Name;
          option.value = item.ServiceId__c;
          options.push(option);
          console.log('option :' + option);
        });

        editData.qflowCalendarOptions = options;
        that.editData(cmp, editData);
        return options;
      })
  },

  searchSlots: function(cmp) {
    var that = this;
    var isFormValid = that.validateEditForm(cmp);
    if (!isFormValid) {
      return;
    }

    // console.log(
    //   this.unProxyData({
    //     editData: that.editData(cmp),
    //     options: that.selectedOptions(cmp)
    //   })
    // );
    that.resetFilters(cmp);
    var procedureCodes = that.getAllSelectedProcedureCodes(cmp);
    if (procedureCodes.length > 1) {
      that.handleSearchSlots(cmp);
    } else {
      that.checkExistingAppointment(cmp).then(
        $A.getCallback(function (res) {
          if (res) {
            that.close(cmp)
            window.dispatchEvent(new CustomEvent('closeAppointmentModal'))
            // that.showUpdateModal(cmp)
            return
          }
          that.handleSearchSlots(cmp);
        })
      ).catch(
        $A.getCallback(function (err) {
          that.isLoading(cmp, false);
          console.log(err);
        })
      );
    }
  },

  showUpdateModal: function (cmp) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var recordId = that.recordId(cmp);
    var cmpName = 'AppointmentsUpdate';
    var cmpDefinition = that.buildCmpDefinition(cmpName);
    that.isLoading(cmp, true);
    $A.createComponent(
      cmpDefinition.name,
      {
        recordId: recordId
      },
      function (dashboardCmp, status) {
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
      }
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

  handleSearchSlots: function (cmp) {
    var that = this;
    var isForDocExpert = this.isForDocExpert(cmp);
    Promise.resolve()
      .then(function() {
        if (isForDocExpert) {
          return that.searchDoctorSlots(cmp);
        }
        return that.searchSlotsArray(cmp);
      })
      .then(
        $A.getCallback(function(
          /**@type {import('AppointmentsBase').SlotsDataRes} */ data
        ) {
          that.isLoading(cmp, false);
          that.configSlotsData(cmp, data);
          that.updateEditDataDisableConfig(cmp);
          return true;
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.requestErrorHandler(cmp, err);
          return false;
        })
      );
  },

  checkExistingAppointment: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var editData = that.editData(cmp);
    var params = {
      actionName: 'hasFutureAppointments',
      caseId: recordId,
      procedureCode: editData.procedure
    };
    return that
      .executeApex(cmp, {
        controllerName: 'LC_AppointmentScreenController',
        params: params
      })
      .then(function(res) {
        if (res.responseObj && cmp.get('v.selectedAppointment') === null) {
            var globalServiceCmp = cmp.find('globalServiceNew');
            var all = globalServiceCmp.getAll();
            var services = all.services;
            var modalService = services.modalService;

            var modalParams = modalService.buildAuraModalParams(
              'confirmModalNew',
              {
                modalData: {
                  title: $A.get('$Label.c.CheckAccountFutureAppointmentButton_ConfirmationTitle'),
                  text: $A.get('$Label.c.CheckAccountFutureAppointment_ConfirmationMessage'),
                  acceptLabel: $A.get('$Label.c.CheckAccountFutureAppointmentButton_ConfirmationYes'),
                  declineLabel: $A.get('$Label.c.CheckAccountFutureAppointmentButton_ConfirmationNo')
                },
                cssClass: 'doc-expert-dashboard-modal',
                useAuraModalDynamicLwc: true
              }
            );
            return modalService.showModal(this, modalParams);
          }
        return false
      })
  },

  searchDoctorSlots: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var editData = that.editData(cmp);
    var staticData = that.staticData(cmp);
    var params = {
      recordId: recordId,
      actionName: 'getSlotsByClinic',
      domainId: editData.domain,
      patientId: staticData.accountPaitientId,
      idType: staticData.accountPaitientIdType,
      insurenceCode: editData.insurerFactor,
      procedureCode: editData.procedure,
      startDate: editData.startDate,
      endDate: editData.endDate,
      siteCode: that.screenMode(cmp) === 'doctorHeader' ? editData.clinicValue : editData.clinic,
      calendarCode: editData.calendar,
      doctorId: that.doctorId(cmp)
    };

    that.serverError(cmp, '');
    that.updateTimeGroupPosition(cmp);
    that.isLoading(cmp, true);
    return that.scheduleAppointmentService(cmp).appointmentApiRequest(params);
  },
  searchSlotsArray: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var editData = that.editData(cmp);
    var selectedOptions = that.selectedOptions(cmp);
    var staticData = that.staticData(cmp);
    var isTechnician = that.isTechnician(cmp);
    var procedureCodes = that.getAllSelectedProcedureCodes(cmp);
    var protocolIds = that.getSelectedProtocolIds(cmp);
    var technicianProcedure = selectedOptions.technicianProcedure;
    var technician = null;
    var technicianProcedureCode = '';
    var technicianProcedureLeading = false;
    var isAshdodEmloyee = staticData.isAshdodEmloyee;
    var accountPaitientEmail = staticData.accountPaitientEmail;
    var isValidSchedulerParams = procedureCodes.length < 2;
    var hasSchParameterRows = false;
    var showSensitivities = false;
    var actionInfo = null;
    var ownerForTransfer = '';
    var spCalendar = '';
    var previewText = '';
    var actionType = '';
    var days = '';
    var showSensitivitiesInfo;
    var schParameters;
    var startDate;
    var fromHour;
    var toHour;
    var result;

    if (isTechnician) {
      technician = selectedOptions.technician;
      if (technicianProcedure) {
        technicianProcedureCode = editData.technicianProcedure;
        technicianProcedureLeading = technicianProcedure.isLeading;
      }
    }

    that.serverError(cmp, '');
    that.updateTimeGroupPosition(cmp);
    that.isLoading(cmp, true);
    return Promise.resolve().then(function() {
      if(!isAshdodEmloyee && accountPaitientEmail == undefined){
        return isRelatedDocExists();
      }
      return getSlotsWithSchParameters();
    });

    function isRelatedDocExists() {
      var params = {
        actionName: 'isRelatedDocExists',
        procedureCodes: JSON.stringify(procedureCodes),
        siteCode: editData.sequenceSite
      };
      return that
        .scheduleAppointmentService(cmp)
        .appointmentApiRequest(params)
        .then(function(isExist) {
          if (isExist) {
            return patientEmailModal().then(
              $A.getCallback(function() {
                if(result){
                  return getSlotsWithSchParameters();
                }
                return false;
              })
            );
          }
          return getSlotsWithSchParameters();
        });
    }

    function patientEmailModal() {
      return that
        .showPatientEmailModal(
          cmp,
          staticData.accountPaitientId,
          staticData.accountPaitientIdType
        )
        .then(function(data) {
          result = data;
        });
    }

    function getSlotsWithSchParameters() {
      if (isValidSchedulerParams) {
        return checkSchedulerParameters().then(function() {
          if (hasSchParameterRows) {
            if (showSensitivities) {
              return showSensitivitiesModal().then(
                $A.getCallback(function() {
                  if (actionInfo) {
                    that.isLoading(cmp, true);
                    fillFieldsByAction(actionInfo);
                  } else if (actionInfo == undefined) {
                    return false;
                  }
                  if (actionType != undefined) {
                    return checkAction();
                  }
                  return getSlots();
                })
              );
            }
            return checkAction();
          }
          that.isLoading(cmp, true);
          return getSlots();
        });
      }
      return getSlots();
    }

    function checkSchedulerParameters() {
      var params = {
        actionName: 'checkSchedulerParameters',
        patientId: staticData.accountPaitientId,
        idType: staticData.accountPaitientIdType,
        insurenceCode: editData.insurerFactor,
        procedureCode: editData.procedure,
        calendar: editData.qflowCalendar,
        siteCode: editData.sequenceSite,
        protocol: editData.protocol,
        domainId: editData.domain
      };
      return that
        .scheduleAppointmentService(cmp)
        .appointmentApiRequest(params)
        .then(function(data) {
          hasSchParameterRows = data.haveRecord;
          if (hasSchParameterRows) {
            showSensitivities = data.showSensitivities;
            if (hasSchParameterRows && !showSensitivities) {
                fillFieldsByAction(data.actionTypeInfo);
            } else {
              showSensitivitiesInfo = data.showSensitivitiesInfo;
              schParameters = data.schParameters;
            }
          }
        });
    }

    function fillFieldsByAction(actionInfo) {
      previewText = actionInfo.previewText;
      actionType = actionInfo.actionType;
      switch (actionType) {
        case 'message': {
          fromHour = actionInfo.fromHour;
          toHour = actionInfo.toHour;
          break;
        }
        case 'changeOwner': {
          ownerForTransfer = actionInfo.ownerForTransfer;
          break;
        }
        case 'changeFromDate': {
          days = actionInfo.days;
          fromHour = actionInfo.fromHour;
          toHour = actionInfo.toHour;
          break;
        }
        case 'scheduleByCalendar': {
          spCalendar = actionInfo.calendar;
          fromHour = actionInfo.fromHour;
          toHour = actionInfo.toHour;
          break;
        }
      }
    }

    function showSensitivitiesModal() {
      return that
        .showPatientDetailsModal(
          cmp,
          staticData.accountPaitientId,
          staticData.accountPaitientIdType,
          showSensitivitiesInfo,
          schParameters
        )
        .then(function(data) {
          actionInfo = data;
        });
    }

    function checkAction() {
      switch (actionType) {
        case 'preventAppointment': {
          that.isLoading(cmp, true);
          if (previewText != '') {
            return error(previewText, true);
          }
        }
        case 'message': {
          if (previewText != '') {
            error(previewText, false);
          }
          that.isLoading(cmp, true);
          return getSlots();
        }
        case 'changeOwner': {
          if (previewText != '') {
            error(previewText, false);
          }
          that.isLoading(cmp, true);
          that.transferToDepartment(cmp, null, ownerForTransfer);
          return true;
        }
        case 'changeFromDate': {
          if (previewText != '') {
            error(previewText, false);
          }
          startDate = editData.startDate;
          var newFromDate = addDays(startDate, parseInt(days));
          startDate = newFromDate;
          that.isLoading(cmp, true);
          return getSlots();
        }
        case 'scheduleByCalendar': {
          if (previewText != '') {
            error(previewText, false);
          }
          that.isLoading(cmp, true);
          return getSlots();
        }
      }
    }

    function addDays(date, days) {
      var newDate = new Date(date);
      newDate.setDate(newDate.getDate() + days);
      var formattedNewDate = $A.localizationService.formatDate(
        newDate,
        'yyyy-MM-dd'
      );
      return formattedNewDate;
    }

    function error(err, close) {
      that.isLoading(cmp, false);
      that.showToast({
        type: 'error',
        title: $A.get('$Label.c.Error'),
        message: that.buildHtmlServerError(err),
        mode: 'sticky'
      });
      that.refreshView();
      if (close) {
        that.close(cmp);
      }
      return true;
    }

    function getSlots() {
      var params = {
        recordId: recordId,
        actionName: 'getSlotsArray',
        domainId: editData.domain,
        patientId: staticData.accountPaitientId,
        idType: staticData.accountPaitientIdType,
        insurenceCode: editData.insurerFactor,
        procedureCodes: JSON.stringify(procedureCodes),
        protocol: editData.protocol,
        protocols: JSON.stringify(protocolIds),
        startDate: startDate != undefined ? startDate : editData.startDate,
        endDate: editData.endDate,
        fromHour: fromHour,
        toHour: toHour,
        calendar: spCalendar!= undefined && spCalendar!= '' ? spCalendar : editData.qflowCalendar,
        //calendar: editData.qflowCalendar,
        siteCode: editData.sequenceSite,
        technician: technician ? JSON.stringify(technician) : '',
        technicianProcedureCode: technicianProcedureCode,
        technicianProcedureLeading: technicianProcedureLeading
      };
      return that.scheduleAppointmentService(cmp).appointmentApiRequest(params);
    }
  },
  transformStaticDataRes: function(cmp, data) {
    var that = this;
    var mode = this.mode(cmp);
    var recordId = this.recordId(cmp);
    var scheduleAppointmentService = this.scheduleAppointmentService(cmp);
    var $Locale = this.$Locale();
    /**@type {import('AppointmentsBase').WeekDay[]} */
    var allWeekDays = data.days;
    var nameOfWeekdays = $Locale.nameOfWeekdays;
    /**@type {import('AppointmentsBase').WeekdayOption[]} */
    var weekDaysOptions = allWeekDays.map(function(item, index) {
      var shortName = nameOfWeekdays[index].shortName;
      var label = shortName[0].toUpperCase() + shortName.slice(1).toLowerCase();
      return {
        value: item,
        label: label
      };
    });
    /**@type {import('AppointmentsBase').WeekDayOptionsMap} */
    var weekDayOptionsMap = weekDaysOptions.reduce(function(
      accMap,
      item,
      index
    ) {
      accMap[index] = item;
      return accMap;
    },
    {});
    /**@type {import('AppointmentsBase').TimePeriodOption[]} */
    var timePeriodsOptions = [
      {
        label: $A.get('$Label.c.Morning'),
        value: '1'
      },
      {
        label: $A.get('$Label.c.Noon'),
        value: '2'
      },
      {
        label: $A.get('$Label.c.Evening'),
        value: '3'
      },
      {
        label: $A.get('$Label.c.Night'),
        value: '4'
      }
    ];
    var currentDate = new Date();
    var formattedCurrentDate = $A.localizationService.formatDate(
      currentDate,
      'yyyy-MM-dd'
    );
    /**@type {import('AppointmentsBase').InsurerFactorOptionsMap} */
    var insurerFactorOptionsMap = data.accountInsurerFactorValues.reduce(
      function(acc, item) {
        acc[item.value] = item;
        return acc;
      },
      {}
    );
    /**@type {import('AppointmentsBase').Option[]} */
    var protocolOptions = data.protocolValues || [];

    /**@type {import('AppointmentsBase').OptionsMap} */
    var protocolOptionsMap = protocolOptions.reduce(function(acc, item) {
      acc[item.value] = item;
      return acc;
    }, {});

    /**@type {import('AppointmentsBase').Option[]} */
    var urgentReasonOptions = data.urgentReasonValues;

    var urgetReasonOptionsMap = urgentReasonOptions.reduce(function(acc, item) {
      acc[item.value] = item;
      return acc;
    }, {});

    var defaultCalendarOption = scheduleAppointmentService.buildCalendarOption(
      data.defaultCalendar
    );
    var defaultSiteOption = scheduleAppointmentService.buildSiteOption(
      data.defaultSite
    );
    var defaultClinicOption = scheduleAppointmentService.buildClinicOption(
      data.defaultClinic
    );
    var defaultProcedureOption = scheduleAppointmentService.buildProcedureOption(
      data.defaultMedicalProcedure
    );

    var defaultDomainOption = scheduleAppointmentService.buildDomainOption(
      data.defaultDomain,
      data.warningDomains
    );

    var qflowCalendarOptions = data.calendarValues || [];

    /**@type {import('ScheduleAppointmentService').UrgentReasonOption} */
    var defaultUrgentResonOption = scheduleAppointmentService.buildUrgentReasonOption(
      data.defaultUrgentReason
    );

    var existingAppointmentList =
      mode === 'create' ? [] : data.existingAppointmentList || [];
    /**@type {import('AppointmentsBase').SidebarAppointment[]} */
    var historyAppointments = [];
    if (mode === 'create') {
      historyAppointments = data.existingAppointmentList.map(function(item) {
        return that.buildHistoryAppointment(cmp, item);
      });
    }

    var forcedGapInSeconds = data.localeOffsetInSeconds;
    /**@type {import("AppointmentsBase").StaticData} */
    var staticData = {
      caseId: data.caseId || recordId,
      showKMS: data.showKMS,
      accountInsurerFactor: data.accountInsurerFactor,
      insurerFactorOptions: data.accountInsurerFactorValues,
      insurerFactorOptionsMap: insurerFactorOptionsMap,
      protocolOptions: protocolOptions,
      protocolOptionsMap: protocolOptionsMap,
      urgentReasonOptions: urgentReasonOptions,
      urgentReasonOptionsMap: urgetReasonOptionsMap,
      qflowCalendarOptions: qflowCalendarOptions,

      existingAppointmentList: existingAppointmentList,
      historyAppointments: historyAppointments,
      accountName: data.accountName,
      isAshdodEmloyee: data.isAshdodEmloyee,
      payerFactorIconPath: data.payerFactorIconPath,
      payerFactorName: data.payerFactorName,
      accountPaitientId: data.accountPaitientId,
      accountPaitientIdType: data.accountPaitientIdType,
      accountPaitientEmail: data.accountPaitientEmail,
      domainOptions: data.domainValues,
      regionOptions: data.regionValues,
      weekDaysOptions: weekDaysOptions,
      weekDayOptionsMap: weekDayOptionsMap,
      timePeriodsOptions: timePeriodsOptions,
      allRegionValues: data.regionValues.map(function(item) {
        return item.value;
      }),
      allTimePeriodsValues: timePeriodsOptions.map(function(item) {
        return item.value;
      }),
      allWeekDaysValues: allWeekDays,
      formattedCurrentDate: formattedCurrentDate,
      currentDate: currentDate,
      sitesMap: data.sitesMap || {},
      lockTimeout: data.timeOut * 60, //seconds
      defaultCalendarOption: defaultCalendarOption,
      defaultProcedureOption: defaultProcedureOption,
      defaultProtocolOption: data.defaultProtocol,
      defaultSiteOption: defaultSiteOption,
      defaultClinicOption: defaultClinicOption,
      defaultDomainOption: defaultDomainOption,
      defaultUrgentReasonOption: defaultUrgentResonOption,
      forcedGapInSeconds: forcedGapInSeconds,
      warningDomains: data.warningDomains,
      alertMessage: data.alertMessage,
      alertProcedureCodes: data.alertProcedureCodes,
    };
    return staticData;
  },
  domainChangedHandler: function(cmp, option) {
    var that = this;
    var procedureAutocompleteCmp = that.procedureAutocompleteCmp(cmp);
    var staticData = this.staticData(cmp);
    var editData = that.editData(cmp);

    if (staticData.isAshdodEmloyee) {
      editData.qflowCalendar = '';
      editData.qflowCalendarLabel = '';
      this.editData(cmp, editData);
    }

    if (procedureAutocompleteCmp) {
      procedureAutocompleteCmp.reset();
      procedureAutocompleteCmp.triggerSearch();
    }

    setTimeout(
      $A.getCallback(function() {
        var fileAutocompleteCmp = that.fileAutocompleteCmp(cmp);
        if (fileAutocompleteCmp) {
          fileAutocompleteCmp.reset();
          fileAutocompleteCmp.triggerSearch();
        }
        var editData = that.editData(cmp);
        var selectedOptions = that.selectedOptions(cmp);
        editData.file = '';
        selectedOptions.file = null;
        that.editData(cmp, editData);
        that.selectedOptions(cmp, selectedOptions);

        that.checkFileMandatory(cmp);
        that.retrieveReferralsFromAccount(cmp);
      })
    );
  },
  insurerFactorChangedHandler: function(cmp) {
    var staticData = this.staticData(cmp);
    if (!staticData) {
      return;
    }
    var editData = this.editData(cmp);
    var insurerFactorOptionsMap = staticData.insurerFactorOptionsMap;
    var insurerFactorValue = editData.insurerFactor;
    var insurerFactorOption =
      insurerFactorOptionsMap[insurerFactorValue] || null;

    var selectedOptions = this.selectedOptions(cmp);
    selectedOptions.insurerFactor = insurerFactorOption;
    this.selectedOptions(cmp, selectedOptions);
    this.checkFileMandatory(cmp);
  },

  protocolChangedHandler: function(cmp) {
    var staticData = this.staticData(cmp);
    if (!staticData) {
      return;
    }
    var selectedOptions = this.selectedOptions(cmp);
    var editData = this.editData(cmp);

    var protocolId = editData.protocol;
    if (!protocolId) {
      selectedOptions.protocol = null;
    } else {
      var procedure = selectedOptions.procedure;
      var protocols = procedure.protocols;
      var protocolOption = protocols.find(function(item) {
        return item.value === protocolId;
      });
      selectedOptions.protocol = protocolOption;
    }
    this.selectedOptions(cmp, selectedOptions);
  },
  // calendarQflowChangedHandler: function(cmp) {
  //   var staticData = this.staticData(cmp);
  //   if (!staticData) {
  //     return;
  //   }
  //   var selectedOptions = this.selectedOptions(cmp);
  //   var editData = this.editData(cmp);

  //   var protocolId = editData.protocol;
  //   if (!protocolId) {
  //     selectedOptions.calendar = null;
  //   } else {
  //     var procedure = selectedOptions.procedure;
  //     var protocols = procedure.protocols;
  //     var protocolOption = protocols.find(function(item) {
  //       return item.value === protocolId;
  //     });
  //     selectedOptions.caledar = protocolOption;
  //   }
  //   this.selectedOptions(cmp, selectedOptions);
  // },

  urgentChangedHandler: function(cmp) {
    var appointmentData = this.appointmentData(cmp);
    if (!appointmentData.isUrgent) {
      appointmentData.urgentReason = '';
      this.appointmentData(cmp, appointmentData);
    }
  },
  procedureChangedHandler: function(cmp, procedure) {
    var that = this;
    var staticData = that.staticData(cmp);
    var scheduleAppointmentService = that.scheduleAppointmentService(cmp);
    var isForDocExpert = that.isForDocExpert(cmp);
    var editData = that.editData(cmp);
    var selectedOptions = that.selectedOptions(cmp);
    var domainAutocompleteCmp = that.domainAutocompleteCmp(cmp);
    var fileAutocompleteCmp = that.fileAutocompleteCmp(cmp);

    if (staticData.isAshdodEmloyee) {
      editData.qflowCalendar = '';
      editData.qflowCalendarLabel = '';
    }

    editData.protocol = '';
    selectedOptions.protocol = null;
    if (procedure && procedure.Procedure_Code__c) {
      that.searchCalendarByProcdedure(cmp);
      editData.qflowCalendar = procedure.Procedure_Code__c;
    }
    this.editData(cmp, editData);
    this.selectedOptions(cmp, selectedOptions);

    /**@type {import('AppointmentsBase').DomainOption} */
    var domainOption = null;
    if (procedure && procedure.Domain__c) {
      domainOption = scheduleAppointmentService.buildDomainOption(
        procedure.Domain__r,
        staticData.warningDomains
      );
    }
    if (domainAutocompleteCmp && domainOption) {
      domainAutocompleteCmp.setOption(domainOption);
    }

    that.sequenceProcedureFields(cmp, []);
    that.retrieveReferralsFromAccount(cmp);
    if (!procedure) {
      that.isTechnician(cmp, false);
      that.isSequence(cmp, false);
      that.canAddSequence(cmp, false);
      that.updatePreparedAppointments(cmp);
      that.isUrgentVisible(cmp,false);
      resetUrgentReason();
      that.resetTechnician(cmp);

      that.resetSequenceSite(cmp);

      return;
    }
    this.checkFileMandatory(cmp);
    this.emitKmsSearchEvent(cmp, procedure.Name);

    if (isForDocExpert) {
      that.updatePreparedAppointments(cmp);
      return;
    }

    that.resetTechnician(cmp);

    that
      .checkProcedure(cmp, [procedure.Procedure_Code__c])
      .then(
        $A.getCallback(function(res) {
          var hasSequence = res.isSequence;
          var isTechnician = res.isTechnician;
          that.isTechnician(cmp, isTechnician);
          that.canAddSequence(cmp, hasSequence);
          that.resetSequenceSite(cmp);
          if (isTechnician) {
            var technicianOption = null;
            var data = {
              id: 'null',
              label: $A.get('$Label.c.Without_a_technician'),
              withProcedures: false
            };
            technicianOption = scheduleAppointmentService.buildTechnicianOption(
              data
            );
            var technicianAutocompleteCmp = that.technicianAutocompleteCmp(cmp);
            if (technicianAutocompleteCmp && technicianOption) {
              technicianAutocompleteCmp.setOption(technicianOption);
            }
          }
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
        })
      );
    that.updatePreparedAppointments(cmp);

    function resetUrgentReason() {
      var appointmentData = that.appointmentData(cmp);
      appointmentData.isUrgent = false;
      appointmentData.urgentReason = '';
      that.appointmentData(cmp, appointmentData);
    }
  },

  resetSequenceSite: function(cmp) {
    var that = this;
    var sequenceSiteAutocompleteCmp = that.sequenceSiteAutocompleteCmp(cmp);
    var editData = that.editData(cmp);
    var selectedOptions = that.selectedOptions(cmp);
    that.isSequenceSiteInitSearch(cmp, true);
    if (sequenceSiteAutocompleteCmp) {
      sequenceSiteAutocompleteCmp.reset();
      sequenceSiteAutocompleteCmp.triggerSearch();
    } else {
      selectedOptions.sequenceSite = null;
      editData.sequenceSite = '';
      that.selectedOptions(cmp, selectedOptions);
      that.editData(cmp, editData);
    }
  },
  sequenceProcedureChangedHandler: function(cmp, procedure, parsedFieldName) {
    var that = this;
    var sequenceProcedureFields = this.sequenceProcedureFields(cmp);
    //remove fields after current field, because current field changed
    sequenceProcedureFields = sequenceProcedureFields.slice(
      0,
      parsedFieldName.index + 1
    );
    that.resetSequenceSite(cmp);
    this.sequenceProcedureFields(cmp, sequenceProcedureFields);
    if (!procedure) {
      that.updatePreparedAppointments(cmp);
      return;
    }
    var editData = that.editData(cmp);
    /**@type {string[]} */
    var procedureCodes = [editData.procedure];
    /**@type {string[]} */
    var sequenceProcedureCodes = [];
    var fieldIndex = parsedFieldName.index;
    sequenceProcedureCodes = that
      .getSequenceProcedureCodes(cmp)
      .slice(0, parsedFieldName.index + 1);
    procedureCodes = procedureCodes.concat(sequenceProcedureCodes);
    that
      .checkProcedure(cmp, procedureCodes)
      .then(
        $A.getCallback(function(res) {
          var hasSequence = res.isSequence;
          var isTechnician = res.isTechnician;
          if (!hasSequence) {
            return;
          }
          var targetSequenceField = sequenceProcedureFields[fieldIndex];
          if (targetSequenceField && targetSequenceField.option) {
            targetSequenceField.option.hasSequence = hasSequence;
            that.sequenceProcedureFields(cmp, sequenceProcedureFields);
          }
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
    that.updatePreparedAppointments(cmp);
  },

  sequenceProtocolChangedHandler: function(cmp, parsedFieldName) {
    var that = this;
    var fieldIndex = parsedFieldName.index;
    var sequenceProcedureFields = that.sequenceProcedureFields(cmp);
    var targetProcedureField = sequenceProcedureFields[fieldIndex];
    var staticData = that.staticData(cmp);
    var protocolOption =
      staticData.protocolOptionsMap[targetProcedureField.protocolId];
    targetProcedureField.protocolOption = protocolOption;

    that.sequenceProcedureFields(cmp, sequenceProcedureFields);
  },

  clinicChangedHandler: function(cmp, clinic) {
    var editData = this.editData(cmp);
    var procedureAutocompleteCmp = this.procedureAutocompleteCmp(cmp);
    var calendarAutocompleteCmp = this.calendarAutocompleteCmp(cmp);
    if (calendarAutocompleteCmp) {
      if (editData.clinic) {
        this.isClinicChanged(cmp, true);
      }
      calendarAutocompleteCmp.reset();
      calendarAutocompleteCmp.triggerSearch();
    }

    if (procedureAutocompleteCmp) {
      procedureAutocompleteCmp.reset();
      procedureAutocompleteCmp.triggerSearch();
    }
  },
  calendarChangedHandler: function(cmp, calendar) {
    var procedureAutocompleteCmp = this.procedureAutocompleteCmp(cmp);
    if (procedureAutocompleteCmp) {
      procedureAutocompleteCmp.reset();
      procedureAutocompleteCmp.triggerSearch();
    }

    if (this.screenMode(cmp) === 'doctorHeader') {
      var editData = this.editData(cmp);
      editData.siteCode =
        calendar && calendar.BranchName__r
          ? calendar.BranchName__r.Site_Code__c
          : '';
      editData.clinic = editData.siteCode
      editData.clinicValue = editData.siteCode
      this.editData(cmp, editData);
    }

    if (!calendar) {
      return;
    }
    this.getProcedureForCalendar(cmp);
  },
  validateEditForm: function(cmp) {
    var isValid = true;
    var editFieldCmps = this.editFieldCmps(cmp);
    editFieldCmps.forEach(function(fieldCmp) {
      var isFieldValid = fieldCmp.checkValidity();
      fieldCmp.showHelpMessageIfInvalid();
      isValid = isValid && isFieldValid;
    });
    return isValid;
  },

  validateAppointmentFields: function(cmp) {
    var isValid = true;
    var fieldsCmps = this.appointmentFieldCmps(cmp);
    fieldsCmps.forEach(function(fieldCmp) {
      var isFieldValid = fieldCmp.checkValidity();
      fieldCmp.showHelpMessageIfInvalid();
      isValid = isValid && isFieldValid;
    });
    return isValid;
  },

  startLockTimer: function(cmp) {
    var that = this;
    var staticData = that.staticData(cmp);
    var lockTimeout = staticData.lockTimeout;
    var duration = $A.localizationService.duration(lockTimeout, 'seconds');
    updateLockTimer();
    startTimeout();
    /**
     *
     */
    function updateLockTimer() {
      duration = $A.localizationService.duration(
        duration.asSeconds() - 1,
        'seconds'
      );
      var lockTimeCounter = {
        formattedTime: formatTime(duration)
      };
      that.lockTimeCounter(cmp, lockTimeCounter);
    }
    /**
     *
     */
    function startTimeout() {
      var delay = 1000;
      var lockTimerId = window.setTimeout(
        $A.getCallback(function() {
          if (duration.asSeconds() > 0) {
            updateLockTimer();
            startTimeout();
            return;
          } else {
            that.lockedData(cmp, {
              lockedSlots: [],
              slotsByRow: []
            });

            that.resetSelectedDayData(cmp);
            that.lockTimeCounter(cmp, null);
            that.buildSlotRows(cmp, true);
            that.updatePreparedAppointments(cmp);
            that.updateEditDataDisableConfig(cmp);
            that.updateTimeGroupPosition(cmp);
            that.updatePreparedAppointments(cmp);
            that.updateUrgentField(cmp);
            return;
          }
        }),
        delay
      );
      that.lockTimerId(cmp, lockTimerId);
    }
    function formatTime(/**@type {Aura.Duration} */ duration) {
      var minutes = $A.localizationService.getMinutesInDuration(duration);
      var seconds = $A.localizationService.getSecondsInDuration(duration);
      var minutesStr = ('0' + minutes.toString()).slice(-2);
      var secondsStr = ('0' + seconds.toString()).slice(-2);
      return minutesStr + ':' + secondsStr;
    }
  },
  stopLockTimer: function(cmp) {
    this.lockTimeCounter(cmp, null);
    var lockTimerId = this.lockTimerId(cmp);
    if (lockTimerId) {
      window.clearTimeout(lockTimerId);
    }
  },
  filterSlots: function(cmp, slots) {
    var staticData = this.staticData(cmp);
    var selectedFilters = this.selectedFilters(cmp);
    var allRegionValues = staticData.allRegionValues;
    var areas = selectedFilters.geoAreas;
    var allPeriodsValues = staticData.allTimePeriodsValues;
    var timePeriods = selectedFilters.timePeriods;
    var allWeekDaysValues = staticData.allWeekDaysValues;
    var weekDays = selectedFilters.weekDays;

    var filteredSlots = slots
      .filter(filterByRegions)
      .filter(filterByDays)
      .filter(filterByTime);

    return filteredSlots;

    /**@type {import('AppointmentsDashboard').FilterSlotFn} */
    function filterByRegions(slot) {
      if (areas.length === 0 || areas.length >= allRegionValues.length) {
        return true;
      }
      return areas.some(function(val) {
        return slot.region === val;
      });
    }

    /**@type {import('AppointmentsDashboard').FilterSlotFn} */
    function filterByDays(slot) {
      if (
        weekDays.length === 0 ||
        weekDays.length >= allWeekDaysValues.length
      ) {
        return true;
      }
      return weekDays.some(function(val) {
        return slot.dayOfWeek === val;
      });
    }

    /**@type {import('AppointmentsDashboard').FilterSlotFn} */
    function filterByTime(slot) {
      if (
        timePeriods.length === 0 ||
        timePeriods.length >= allPeriodsValues.length
      ) {
        return true;
      }
      var time = $A.localizationService.parseDateTime(slot.StartTime);
      var hours = time.getHours();
      return timePeriods.some(function(value) {
        switch (value) {
          case '1': {
            return hours >= 6 && hours < 12;
          }
          case '2': {
            return hours >= 12 && hours < 18;
          }
          case '3': {
            return hours >= 18 && hours < 22;
          }
          case '4': {
            return hours >= 22 || hours < 6;
          }
          default: {
            return false;
          }
        }
      });
    }
  },
  editDataChangedHandler: function(cmp, params) {
    // this.slotRows(cmp, []);
    // this.stopLockTimer(cmp);
    // this.resetSelectedDayData(cmp);
    // this.isTimeGroupVisible(cmp, false);
    // this.validateEditForm(cmp);
  },
  resetLock: function(cmp) {
    this.stopLockTimer(cmp);
  },

  scrollAppointmentTo: function(cmp, destination, xcoord, ycoord) {
    var appointmentScrollWrapper = this.appointmentScrollerWrapperCmp(cmp);
    if (appointmentScrollWrapper) {
      appointmentScrollWrapper.scrollTo(destination, xcoord, ycoord);
    }
  },
  restoreUpdatedAppointment: function(cmp) {
    // var selectedAppointment = this.selectedAppointment(cmp);
  },
  attachGlobalEvents: function(cmp) {
    var that = this;
    var windowResizeListener = $A.getCallback(function() {
      var isTimeGroupVisible = that.isTimeGroupVisible(cmp);
      if (isTimeGroupVisible) {
        that.isTimeGroupVisible(cmp, false);
      }
    });
    window.addEventListener('resize', windowResizeListener);
    that.windowResizeListener(cmp, windowResizeListener);
  },
  clearGlobalEvents: function(cmp) {
    var windowResizeListener = this.windowResizeListener(cmp);
    if (windowResizeListener) {
      window.removeEventListener('resize', windowResizeListener);
    }
  },
  selectDayHandler: function(cmp, data) {
    var prevSelectedData = this.selectedDayData(cmp);
    var day = data.day;
    var prevDay = prevSelectedData.day;
    var prevRowIndex = prevSelectedData.rowIndex;
    if (!prevDay) {
      this.selectedDayData(cmp, data);
      this.isTimeGroupVisible(cmp, true);
    } else if (
      prevRowIndex !== data.rowIndex ||
      prevDay.uniqKey !== day.uniqKey
    ) {
      this.resetSelectedDayData(cmp);
      this.selectedDayData(cmp, data);
      this.isTimeGroupVisible(cmp, true);
    } else {
      this.resetSelectedDayData(cmp);
    }
    this.updateTimeGroupPosition(cmp);
  },
  updateTimeGroupPosition: function(cmp) {
    var that = this;
    var selectors = {
      positionEl: '.position-element',
      containerEl: '.appointment-inner'
    };
    setTimeout(function() {
      if (!cmp.isValid()) {
        return;
      }
      var selectedDayData = that.selectedDayData(cmp);
      var dashboardEl = cmp.getElement();
      /**@type {HTMLElement} */
      var positionEl = dashboardEl.querySelector(selectors.positionEl);
      if (!selectedDayData.day) {
        positionEl.style.transform = '';
        positionEl.style.width = '0';
        return;
      }
      var dayEl = selectedDayData.dayEl;

      var innerWrapperEl = dashboardEl.querySelector(selectors.containerEl);

      var innerWrapperRect = innerWrapperEl.getBoundingClientRect();
      var dayRect = dayEl.getBoundingClientRect();

      var $Locale = that.$Locale();
      var dir = $Locale.dir;
      var translateX;
      if (dir === 'ltr') {
        translateX = Math.round(dayRect.left - innerWrapperRect.left);
      } else {
        translateX = -Math.round(innerWrapperRect.right - dayRect.right);
      }

      var translateY = Math.round(
        dayRect.top - innerWrapperRect.top + dayEl.offsetHeight
      );

      positionEl.style.width = dayEl.offsetWidth + 'px';
      positionEl.style.transform =
        'translate(' + translateX + 'px,' + translateY + 'px)';
    });
  },
  updateEditDataDisableConfig: function(cmp) {
    var mode = this.mode(cmp);
    var slotsData = this.slotsData(cmp);
    var isForDocExpert = this.isForDocExpert(cmp);
    var staticData = this.staticData(cmp);

    var isAshdodEmloyee = staticData.isAshdodEmloyee;

    var editData = this.editData(cmp);
    /**@type {import('AppointmentsBase').EditDataDisableConfig} */
    var config = {
      domain: {
        isDisabled: false,
        isEditable: false
      },
      insurerFactor: {
        isDisabled: false,
        isEditable: false
      },
      procedure: {
        isDisabled: false,
        isEditable: false
      },
      diary: {
        isDisabled: false,
        isEditable: false
      },
      startDate: {
        isDisabled: false,
        isEditable: false
      },
      endDate: {
        isDisabled: false,
        isEditable: false
      },
      clinic: {
        isDisabled: false,
        isEditable: false
      },
      calendar: {
        isDisabled: false,
        isEditable: false
      },
      file: {
        isDisabled: false,
        isEditable: false
      },
      sequenceSite: {
        isDisabled: false,
        isEditable: false
      },
      urgentReason: {
        isDisabled: false,
        isEditable: false
      }
    };
    if (mode === 'create') {
      if (slotsData) {
        setFieldConfig('domain', true, true);
        setFieldConfig('insurerFactor', true, true);
        setFieldConfig('procedure', true, true);
        setFieldConfig('diary', true, true);
        setFieldConfig('startDate', true, true);
        setFieldConfig('endDate', true, true);
        setFieldConfig('calendar', true, true);
        setFieldConfig('clinic', true, true);
        setFieldConfig('file', true, true);
        setFieldConfig('sequenceSite', true, true);
        setFieldConfig('urgentReason', true, true);
      } else {
        /*  */
      }
    } else if (mode === 'update') {
      if (slotsData) {
        setFieldConfig('domain', true, false);
        setFieldConfig('insurerFactor', true, true);
        setFieldConfig('procedure', true, false);
        setFieldConfig('diary', true, true);
        setFieldConfig('startDate', true, true);
        setFieldConfig('endDate', true, true);
        setFieldConfig('sequenceSite', true, false);
        setFieldConfig('urgentReason', true, false);
        setFieldConfig('file', true, false);
      } else {
        setFieldConfig('domain', true, false);
        setFieldConfig('insurerFactor', false, true);
        setFieldConfig('procedure', true, false);
        setFieldConfig('diary', true, true);
        setFieldConfig('startDate', false, true);
        setFieldConfig('endDate', false, true);
        setFieldConfig('sequenceSite', false, true);
        setFieldConfig('urgentReason', false, false);
        setFieldConfig('file', true, false);

        if (isAshdodEmloyee) {
          setFieldConfig('diary', false, true);
        }
      }
      if (isForDocExpert) {
        setFieldConfig('procedure', true, false);
        setFieldConfig('calendar', true, false);
        setFieldConfig('clinic', true, false);
        setFieldConfig('sequenceSite', true, false);
        // setFieldConfig(config.startDate, false, false);
      }
    }
    /**@type {import('AppointmentsDashboard').SetFieldConfig} */
    function setFieldConfig(field, isDisabled, isEditable) {
      config[field].isDisabled = isDisabled;
      config[field].isEditable = isEditable;
    }
    this.editDataDisableConfig(cmp, config);
  },
  fieldEditHandler: function(cmp, fieldName) {
    this.isAvailableTimeSlots(cmp, false)
    var that = this;
    that.unlockAllSlots(cmp).then(
      $A.getCallback(function(isSuccess) {
        if (!isSuccess) {
          return;
        }
        that.isSlotsNotFoundMessageVisible(cmp, false);
        that.resetSlots(cmp);
        that.updatePreparedAppointments(cmp);
      })
    );
  },
  resetSlots: function(cmp) {
    this.slotRows(cmp, []);
    this.slotsData(cmp, null);
    this.updateEditDataDisableConfig(cmp);
    this.updateTimeGroupPosition(cmp);
    this.resetSelectedDayData(cmp);
  },
  checkWorkingDays: function(cmp, slot) {
    var that = this;
    var params = {
      actionName: 'checkWorkingDays',
      scheduleDate: slot.StartTime
    };
    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    return that
      .scheduleAppointmentService(cmp)
      .appointmentApiRequest(params)
      .then(
        $A.getCallback(function(message) {
          that.isLoading(cmp, false);
          return message;
        })
      );
  },
  showDaysConfirmation: function(cmp, message) {
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
        message: message,
        showCancel: true,
        onconfirmation: cmp.getReference('c.onDayConfirmation')
      },
      function(bodyCmp, status) {
        if (status === 'SUCCESS') {
          overlayLibCmp
            .showCustomModal({
              body: bodyCmp,
              cssClass: cmpDefinition.className + ' confirmation-modal',
              showCloseButton: true,
              closeCallback: function() {}
            })
            .then(function(modalRef) {});
        } else {
          console.log(status);
        }
      }
    );
    that.confirmDaysResolver(cmp, confirmResolver);
    return confirmPromise;
  },
  dayConfirmationHandler: function(cmp, isConfirmed) {
    var confirmDaysResolver = this.confirmDaysResolver(cmp);
    if (confirmDaysResolver) {
      confirmDaysResolver(isConfirmed);
    }
  },
  showFileForm: function(cmp) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var cmpDefinition = that.buildCmpDefinition('AppointmentsFileForm');
    var caseId = this.recordId(cmp);
    var editData = this.editData(cmp);
    $A.createComponent(
      cmpDefinition.name,
      {
        caseId: caseId,
        procedureCode: editData.procedure,
        oncreate: cmp.getReference('c.onCreateFile')
      },
      function(bodyCmp, status) {
        if (status === 'SUCCESS') {
          overlayLibCmp
            .showCustomModal({
              body: bodyCmp,
              cssClass: cmpDefinition.className + ' file-form',
              showCloseButton: true,
              closeCallback: function() {}
            })
            .then(function(modalRef) {});
        } else {
          console.log(status);
        }
      }
    );
  },
  fileCreatedHandler: function(cmp, fileData) {
    var fileAutocompleteCmp = this.fileAutocompleteCmp(cmp);
    fileAutocompleteCmp.triggerSearch();
  },
  addSequenceProcedure: function(cmp) {
    var staticData = this.staticData(cmp);
    var sequenceProcedureFields = this.sequenceProcedureFields(cmp);
    /**@type {import('AppointmentsDashboard').SequenceProcedureField} */
    var sequenceField = {
      value: '',
      option: null,
      fileId: '',
      fileOption: null,
      protocolId: '',
      protocolOption: null
    };
    sequenceProcedureFields.push(sequenceField);
    this.sequenceProcedureFields(cmp, sequenceProcedureFields);
    this.isSequence(cmp, true);
    this.isTechnician(cmp, false);
    this.resetTechnician(cmp);
  },
  parseFieldName: function(cmp, fieldName) {
    var parsedName = fieldName.split('_');
    /**@type {import('AppointmentsDashboard').ParsedFieldName} */
    var result = {
      name: parsedName[0],
      index: parseInt(parsedName[1], 10) || 0
    };
    return result;
  },
  getSequenceProcedureCodes: function(cmp) {
    var sequenceProcedureFields = this.sequenceProcedureFields(cmp);
    var codes = sequenceProcedureFields.map(function(field) {
      return field.value;
    });
    return codes;
  },
  getFileIds: function(cmp) {
    var editData = this.editData(cmp);
    var sequenceProcedureFields = this.sequenceProcedureFields(cmp);
    var sequenceFileIds = sequenceProcedureFields.map(function(field) {
      return field.fileId;
    });
    return [editData.file].concat(sequenceFileIds);
  },

  getSelectedProtocolIds: function(cmp) {
    var editData = this.editData(cmp);
    var sequenceProcedureFields = this.sequenceProcedureFields(cmp);
    var sequenceProtocolIds = sequenceProcedureFields.map(function(field) {
      return field.protocolId;
    });
    return [editData.protocol].concat(sequenceProtocolIds);
  },

  getAllSelectedProcedureCodes: function(cmp) {
    var editData = this.editData(cmp);
    /**@type {string[]} */
    var codes = [editData.procedure];
    var sequenceProcedureCodes = this.getSequenceProcedureCodes(cmp);
    codes = codes.concat(sequenceProcedureCodes).filter(function(code) {
      return !!code;
    });
    return codes;
  },
  resetFilters: function(cmp) {
    /**@type {import('AppointmentsBase').SelectedFilters} */
    var filters = {
      geoAreas: [],
      timePeriods: [],
      weekDays: []
    };
    this.selectedFilters(cmp, filters);
  },
  buildSlotRows: function(cmp, usePrev) {
    var that = this;
    var slotsData = this.slotsData(cmp);
    if (!slotsData) {
      return;
    }
    // var oldSlotRowsMap = {};

    // if (usePrev) {
    //   oldSlotRowsMap = (that.slotRows(cmp) || []).reduce(function(acc, row) {
    //     acc[row.code] = row;
    //     return acc;
    //   }, {});
    // }

    // console.log(
    //   that.unProxyData({
    //     old: oldSlotRowsMap
    //   })
    // );

    var selectedFilters = that.selectedFilters(cmp);
    var regions = selectedFilters.geoAreas;
    // console.log(that.unProxyData(selectedFilters));
    var scheduleAppointmentService = that.scheduleAppointmentService(cmp);
    var slotsMap = this.slotsMap(cmp);
    var lockedData = this.lockedData(cmp);
    var lockedSlots = lockedData.lockedSlots;
    var isSequence = this.isSequence(cmp);
    var slots = slotsData.slots;
    if (!Array.isArray(slots)) {
      return;
    }
    var procedureMapByCode = slotsData.procedureMapByCode;
    var siteMapByCode = slotsData.siteMapByCode;
    var calendarMapByDate = slotsData.calendarMapByDate;
    var calendarMapByCode = slotsData.calendarMapByCode;
    var sequenceMapByCode = slotsData.sequenceMapByCode;
    var showSiteMap = slotsData.showSiteMap;
    var showEmptySiteMap = slotsData.showEmptySiteMap;
    var filteredSlots = this.filterSlots(cmp, slots);
    /**@type {import('AppointmentsBase').SlotsRowMap} */
    var slotsRowMap = filteredSlots.reduce(function(acc, slot) {
      /**@type {import('AppointmentsBase').SlotsDay} */
      var daySlot;

      var rowKey = isSequence ? slot.procedureCode : slot.siteCode;
      var rowData = isSequence
        ? procedureMapByCode[rowKey]
        : siteMapByCode[rowKey];
      var code = isSequence
        ? procedureMapByCode[rowKey].Procedure_Code__c
        : siteMapByCode[rowKey].Site_Code__c;
      var rowLabel = rowData.label;
      var rowNote = rowData.note;
      var row = acc[rowKey] || that.buildRow(cmp, rowLabel, rowNote, code);
      var days = row.days;

      if (
        days.length === 0 ||
        days[days.length - 1].targetDate !== slot.targetDate
      ) {
        var calendarDate = calendarMapByDate[slot.targetDate];
        daySlot = {
          dayOfWeek: slot.dayOfWeek,
          isHoliday: calendarDate.Holiday__c,
          isSelected: false,
          isWeekend: calendarDate.Weekend__c,
          jewishDate: calendarDate.Jewish_date__c,
          holidayLabel: calendarDate.Holiday_Description__c,
          targetDate: slot.targetDate,
          uniqKey: slot.dayKey,
          procedureCode: slot.procedureCode,
          siteCode: slot.siteCode,
          slots: []
        };
        days.push(daySlot);
      }

      daySlot = days[days.length - 1];
      daySlot.slots.push(slot.uniqKey);
      acc[rowKey] = row;
      return acc;
    }, {});

    /**@type {import('AppointmentsBase').SlotsRow[]} */
    var slotRows = [];

    if (isSequence) {
      // sequence procedure rows
      slotRows = slotsData.procedures.reduce(function(acc, procedureCode) {
        var slotRow = slotsRowMap[procedureCode];
        if (slotRow) {
          acc.push(slotRow);
        }
        return acc;
      }, []);
    } else {
      //site rows

      slotRows = Object.keys(slotsRowMap).map(function(code) {
        return slotsRowMap[code];
      });
      Object.keys(showSiteMap).forEach(function(key) {
        var row;
        var code;
        var rowData;
        if (!slotsRowMap[key]) {
          rowData = siteMapByCode[key];
          if (rowData) {
            code = rowData.Site_Code__c;
            if (
              regions.length === 0 ||
              regions.indexOf(rowData.Region__c) >= 0
            ) {
              row = that.buildRow(cmp, rowData.label, rowData.note, code);
              row.transferToDepartment = true;
              row.code = key;
              slotRows.push(row);
            }
          }
        }
      });
      Object.keys(showEmptySiteMap).forEach(function(key) {
        var row;
        var code;
        var rowData;
        if (!slotsRowMap[key]) {
          rowData = siteMapByCode[key];
          if (rowData) {
            code = rowData.Site_Code__c;
            if (
              regions.length === 0 ||
              regions.indexOf(rowData.Region__c) >= 0
            ) {
              row = that.buildRow(cmp, rowData.label, rowData.note, code);
              row.transferToDepartment = false;
              row.code = key;
              slotRows.push(row);
            }
          }
        }
      });
    }

    if (lockedSlots.length > 0) {
      slotRows = slotRows.map(function(row) {
        return Object.assign({}, row);
      });
      slotRows.forEach(function(row, index) {
        var dependSlotWithLock = lockedSlots.slice(0, index);
        if (dependSlotWithLock.length === 0) {
          return;
        }
        var lockedTimes = dependSlotWithLock.map(function(_slotWithLock) {
          var slot = _slotWithLock.slot;
          var sequenceData = sequenceMapByCode[slot.procedureCode];
          var offset = sequenceData.offset || 0;
          var maxOffset = sequenceData.maxOffset || 0; //TODO
          var sameDay = sequenceData.sameDay;
          var sameCalendar = sequenceData.sameCalendar;

          var slotTime = $A.localizationService.parseDateTime(slot.StartTime);
          var nextStartTime =
            new Date(slotTime).getTime() +
            minutesToMs(slot.Duration) +
            minutesToMs(offset);

          var nextEndTime = null;
          if (sameDay) {
            nextEndTime = nextStartTime;
            if (maxOffset > 0) {
              nextEndTime = nextStartTime + minutesToMs(maxOffset);
            } else {
              nextEndTime = nextStartTime + hoursToMs(23);
            }
          }
          return {
            sameCalendar: sameCalendar,
            slot: slot,
            sameDay: sameDay,
            slotTime: slotTime,
            nextStartTime: nextStartTime,
            nextEndTime: nextEndTime,
            nextStartTimeDate: new Date(nextStartTime),
            nextEndTimeDate: new Date(nextEndTime)
          };
        });
        var lockedTime = lockedTimes[index - 1];

        row.days = row.days
          .map(function(day) {
            return Object.assign({}, day);
          })
          .filter(function(day) {
            day.slots = day.slots.filter(function(slotKey) {
              var slot = slotsMap[slotKey];

              // slot.ModalityCode
              var slotTime = $A.localizationService
                .parseDateTime(slot.StartTime)
                .getTime();

              if (!lockedTime) {
                return true;
              }
              if (
                lockedTime.sameCalendar &&
                slot.ModalityCode !== lockedTime.slot.ModalityCode
              ) {
                return false;
              }

              if (!lockedTime.nextEndTime) {
                return slotTime >= lockedTime.nextStartTime;
              } else {
                return (
                  slotTime >= lockedTime.nextStartTime &&
                  slotTime <= lockedTime.nextEndTime
                );
              }
            });
            return day.slots.length > 0;
          });
      });

      //
    }
    slotRows.forEach(function(row) {
      var rowModalityCodesMap = row.days.reduce(function(acc, day) {
        day.slots.forEach(function(slotKey) {
          var slot = slotsMap[slotKey];
          if (!slot) {
            return;
          }
          var modalityCode = slot.ModalityCode;
          if (acc[modalityCode] || !calendarMapByCode[modalityCode]) {
            return;
          }

          acc[modalityCode] = {
            modalityCode: modalityCode,
            label: calendarMapByCode[modalityCode]
          };
        });
        return acc;
      }, {});
      row.modalityCodes = Object.keys(rowModalityCodesMap).map(function(key) {
        return rowModalityCodesMap[key];
      });
    });
    console.log(this.unProxyData(slotRows));
    var staticData = this.staticData(cmp);
    if (staticData.isAshdodEmloyee && slotRows[0]) {
      this.formatAvailableTimeSlots(cmp, slotRows[0])
    }
    this.slotRows(cmp, slotRows);

    function minutesToMs(val) {
      return val * 60000;
    }

    function hoursToMs(val) {
      return val * 60 * 60000;
    }
  },
  filterAvailableDate: function (cmp, data) {
    var slotsCounter = 0
    console.log('+++ DV data >>> ', JSON.parse(JSON.stringify(data)))
    var days = []
    JSON.parse(JSON.stringify(data)).days.forEach(item => {
      if (slotsCounter < 9) {
        item.slots = item.slots.slice(0, 9 - slotsCounter < 3 ? 9 - slotsCounter : 3 )
        slotsCounter += item.slots.length
        days.push(item)
      }
    })
    return days
  },
  formatAvailableTimeSlots: function (cmp, data) {
    const schedule = this.filterAvailableDate(cmp, data)
    console.log('+++ DV schedule >>> ', schedule)
    if (schedule) {
      const firstThreeDays = schedule
      const dayNameToHebrew = {
        Sun: $A.get('$Label.c.AppointmentDashboard_Sun'),
        Mon: $A.get('$Label.c.AppointmentDashboard_Mon'),
        Tue: $A.get('$Label.c.AppointmentDashboard_Tue'),
        Wed: $A.get('$Label.c.AppointmentDashboard_Wed'),
        Thu: $A.get('$Label.c.AppointmentDashboard_Thu'),
        Fri: $A.get('$Label.c.AppointmentDashboard_Fri'),
        Sat: $A.get('$Label.c.AppointmentDashboard_Sat')
      }
      const formattedDates = firstThreeDays.map((day) => {
        const dayOfWeek = dayNameToHebrew[new Date(day.targetDate).toLocaleString('en-us', {weekday: 'short'})]
        const numberedDate = new Date(day.targetDate);
        const firstThreeSlots = day.slots.slice(0, 3).map((slot) => {
          const slotWithoutCodes = slot.replace(`${day.procedureCode}_${day.siteCode}_`, '');
          const parsedDateTime = slotWithoutCodes.replace('_', 'T')
          const formattedTime = new Date(parsedDateTime).toLocaleTimeString('en-GB', {hour: 'numeric', minute: '2-digit', hour12: false});
          return formattedTime;
        });
        const formattedString = `${dayOfWeek} ${numberedDate.getDate()}.${numberedDate.getMonth() + 1}.${numberedDate.getFullYear().toString().substring(2)}, ${$A.get('$Label.c.AppointmentDashboard_FollowingTime')} ${firstThreeSlots.join(', ')}`;
        return formattedString;
      });
      console.log('+++ DV formattedDates >>> ', formattedDates)
      this.isAvailableTimeSlots(cmp, cmp.get("v.lockTimeCounter") === null)
      this.availableTimeSlotsString(cmp, formattedDates.join('<br>'))
    }
  },
  copyAvailableTimeSlot: function (cmp) {
      var textArea = document.createElement("textarea");
      textArea.value = $A.get('$Label.c.AppointmentDashboard_ListOfAvailabelSlots') + '\n' + this.availableTimeSlotsString(cmp).replace(/<br>/g, '\n') + '\n' + '\n' + $A.get('$Label.c.AppointmentDashboard_GeneralSentence')+ '\n' + $A.get('$Label.c.AppointmentDashboard_GeneralSentence1');
      textArea.style.position = "fixed";
      textArea.style.left = "-999999px";
      textArea.style.top = "-999999px";
      document.body.appendChild(textArea);
      textArea.focus();
      textArea.select();
      new Promise((res, rej) => {
        document.execCommand("copy") ? res() : rej();
        textArea.remove();
        this.showToast({
          type: 'success',
          title: $A.get('$Label.c.Success'),
          message: $A.get('$Label.c.AppointmentDashboard_CopySuccess')
        });
      });
  },
  configSlotsData: function(cmp, data) {
    /**@type {import('AppointmentsBase').SlotsData} */
    var slotsData;
    this.isSlotsNotFoundMessageVisible(cmp, false);
    this.slotRows(cmp, []);
    this.slotsData(cmp, null);
    var staticData = this.staticData(cmp);
    var insurerFactorOptionsMap = staticData.insurerFactorOptionsMap;
    var scheduleAppointmentService = this.scheduleAppointmentService(cmp);

    if (data.slotList) {
      /**@type {import('AppointmentsBase').TimeSlot[]} */
      var slots = data.slotList.map(function(slot) {
        return Object.assign({}, slot, {
          dayKey:
            slot.procedureCode + '_' + slot.siteCode + '_' + slot.targetDate
        });
      });

      /**@type {import('AppointmentsBase').SitesMap} */
      var siteMapByCode = this.normalizeOptionsMap(
        data.siteMapByCode,
        scheduleAppointmentService.buildSiteOption
      );

      /**@type {import('AppointmentsBase').ProceduresMap} */
      var procedureMapByCode = this.normalizeOptionsMap(
        data.procedureMapByCode,
        scheduleAppointmentService.buildProcedureOption
      );
      /**@type {import('AppointmentsBase').SequencesMap} */
      var sequenceMapByCode = data.sequenceMapByCode || {};

      /**@type {import('AppointmentsBase').CalendarDatesMap} */
      var calendarMapByDate = data.calendarMapByDate || {};

      /**@type {import('AppointmentsBase').SlotsData} */
      slotsData = {
        slots: slots,
        slotsMap: this.buildSlotsMap(cmp, slots),
        isForcedAvailable: data.isForcedAvailable,
        calendarMapByDate: calendarMapByDate,
        calendarMapByCode: data.calendarMapByCode,
        procedureMapByCode: procedureMapByCode,
        sequenceMapByCode: sequenceMapByCode,
        isCalendarFilterEnabled: data.isCalendarFilterEnabled,
        siteMapByCode: siteMapByCode,
        showSiteMap: data.showSiteMap,
        showEmptySiteMap: data.showEmptySiteMap,
        procedures: data.procedures,
        pricesInfo: data.pricesInfo,
        infoMessage: data.infoMessage
      };
      this.isSlotsNotFoundMessageVisible(cmp, data.slotList.length === 0);
      console.log(this.unProxyData(slotsData));
      this.slotsData(cmp, slotsData);
      this.buildSlotRows(cmp);
    } else if (data.pricesInfo) {
      /**@type {import('AppointmentsBase').SlotsData} */
      slotsData = {
        infoMessage: data.infoMessage,
        pricesInfo: data.pricesInfo.map(function(item) {
          var client = insurerFactorOptionsMap[item.ClientNo];
          var label = client ? client.label : item.ClientNo;
          return Object.assign({}, item, { label: label });
        })
      };
      this.slotsData(cmp, slotsData);
    }
  },
  buildSlotsMap: function(cmp, slots) {
    /**@type {import('AppointmentsBase').TimeSlotsMap} */
    var slotsMap = slots.reduce(function(acc, slot) {
      acc[slot.uniqKey] = Object.assign({}, slot);
      return acc;
    }, {});
    return slotsMap;
  },
  selectSlotHandler: function(cmp, slotKey, rowIndex) {
    var slotsMap = this.slotsMap(cmp);
    var lockedData = this.lockedData(cmp);
    var isSequence = this.isSequence(cmp);
    var lockedSlots = lockedData.lockedSlots;
    var slot = slotsMap[slotKey];
    if (!slot) {
      return;
    }
    var slotLockIndex = isSequence ? rowIndex : 0;

    if (isSequence && slotLockIndex > 0 && !lockedSlots[slotLockIndex - 1]) {
      this.showToast({
        type: 'warning',
        title: $A.get('$Label.c.Warning'),
        message: $A.get('$Label.c.Select_slot_for_previous_appointment')
      });
      return;
    }
    var currentSlotWithLock = lockedSlots[slotLockIndex];
    if (
      currentSlotWithLock &&
      currentSlotWithLock.lock &&
      currentSlotWithLock.slot.uniqKey === slot.uniqKey
    ) {
      var staticData = this.staticData(cmp);
      if (staticData.isAshdodEmloyee) {
        this.isAvailableTimeSlots(cmp, true);
      }
      return this.unlockSlotHandler(cmp, slot, slotLockIndex, rowIndex);
    }
    this.isAvailableTimeSlots(cmp, false);
    return this.lockSlotHandler(cmp, slot, slotLockIndex, rowIndex);
  },
  lockSlotHandler: function(cmp, slot, slotLockIndex, rowIndex) {
    var that = this;
    var isSequence = that.isSequence(cmp);
    var lockedData = that.lockedData(cmp);
    var lockedSlots = lockedData.lockedSlots.slice();
    var slotsByRow = lockedData.slotsByRow.slice();
    var currentSlotWithLock = lockedSlots[slotLockIndex];
    if (isSequence) {
      //
    } else {
      //
    }

    var dataForUnlock = that.getDataForUnlock(cmp, slot, slotLockIndex);

    Promise.resolve()
      .then(
        $A.getCallback(function() {
          if (dataForUnlock.slotsForUnlock.length === 0) {
            return true;
          }
          return that.unlockAndRefreshSlotsRequest(cmp, dataForUnlock);
        })
      )
      .then(
        $A.getCallback(function(res) {
          /**@type {string[]} */
          var prevLockedIdsForRefresh = lockedSlots
            .slice(0, slotLockIndex)
            .map(function(item) {
              return item.lock.SlotLockId;
            });
          /**@type {import('AppointmentsBase').SlotWithLock} */
          var lockedSlot = {
            lock: null,
            slot: slot
          };
          lockedSlots[slotLockIndex] = {
            lock: null,
            slot: slot
          };
          slotsByRow[rowIndex] = lockedSlot;
          /**@type {import('AppointmentsBase').TimeSlot[]} */
          var slotsForLock = lockedSlots
            .slice(0, slotLockIndex + 1)
            .map(function(item) {
              return item.slot;
            });

          return that.lockSlotsRequest(
            cmp,
            slotsForLock,
            prevLockedIdsForRefresh
          );
        })
      )
      .then(
        $A.getCallback(function(
          /**@type {import('AppointmentsDashboard').LockRes} */ lockRes
        ) {
          /**@type {import('AppointmentsBase').SlotWithLock} */
          var lockedSlot = {
            lock: lockRes,
            slot: slot
          };

          lockedSlots = lockedSlots.slice(0, slotLockIndex + 1);
          lockedSlots[slotLockIndex] = lockedSlot;
          if (isSequence) {
            slotsByRow = slotsByRow.slice(0, rowIndex + 1);
            slotsByRow[rowIndex] = lockedSlot;
          } else {
            slotsByRow = [];
            slotsByRow[rowIndex] = lockedSlot;
          }

          lockedData.lockedSlots = lockedSlots;
          lockedData.slotsByRow = slotsByRow;
          console.log(that.unProxyData(lockedData));
          that.lockedData(cmp, lockedData);
          that.stopLockTimer(cmp);
          that.startLockTimer(cmp);
          that.updateEditDataDisableConfig(cmp);
          that.updateTimeGroupPosition(cmp);
          that.updatePreparedAppointments(cmp);
          that.filterSlotRows(cmp);
          that.resetSelectedDayData(cmp);
          that.updateUrgentField(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.requestErrorHandler(cmp, err);
        })
      );
  },
  unlockSlotHandler: function(cmp, slot, slotLockIndex, rowIndex) {
    var that = this;
    var isSequence = that.isSequence(cmp);
    var lockedData = that.lockedData(cmp);
    var lockedSlots = lockedData.lockedSlots.slice();
    var slotsByRow = lockedData.slotsByRow.slice();
    var dataForUnlock = that.getDataForUnlock(cmp, slot, slotLockIndex);
    that
      .unlockAndRefreshSlotsRequest(cmp, dataForUnlock)
      .then(
        $A.getCallback(function(res) {
          lockedSlots = lockedSlots.slice(0, slotLockIndex);
          slotsByRow = isSequence ? slotsByRow.slice(0, rowIndex) : [];
          lockedData.lockedSlots = lockedSlots;
          lockedData.slotsByRow = slotsByRow;
          that.lockedData(cmp, lockedData);
          console.log(that.unProxyData(lockedData));
          that.stopLockTimer(cmp);
          if (lockedSlots.length > 0) {
            that.startLockTimer(cmp);
          }
          that.updateEditDataDisableConfig(cmp);
          that.updateTimeGroupPosition(cmp);
          that.updatePreparedAppointments(cmp);
          that.filterSlotRows(cmp);
          that.resetSelectedDayData(cmp);
          that.updateUrgentField(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.requestErrorHandler(cmp, err);
        })
      );
  },

  refreshSlotsHandler: function(cmp) {
    var that = this;
    var dataForRefresh = that.getDataForRefresh(cmp);
    that
      .unlockAndRefreshSlotsRequest(cmp, dataForRefresh)
      .then(
        $A.getCallback(function(res) {
          console.log(res);
          that.stopLockTimer(cmp);
          that.startLockTimer(cmp);
          that.updateEditDataDisableConfig(cmp);
          that.updateTimeGroupPosition(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.requestErrorHandler(cmp, err);
        })
      );
  },

  unlockSlotButton: function(cmp) {
    var that = this;
    that.unlockAllSlots(cmp).then(
      $A.getCallback(function(isSuccess) {
        if (!isSuccess) {
          return;
        }
        that.updatePreparedAppointments(cmp);
      })
    );
  },

  getSlotLockIndex: function(cmp, slot) {
    var slotsData = this.slotsData(cmp);
    var procedures = slotsData.procedures;

    var slotLockIndex = procedures.findIndex(function(code) {
      return code === slot.procedureCode;
    });
    return slotLockIndex;
  },
  getDataForUnlock: function(cmp, slot, slotLockIndex) {
    var lockedData = this.lockedData(cmp);
    var lockedSlots = lockedData.lockedSlots;

    /**@type {import('AppointmentsBase').SlotWithLock[]} */
    var slicedSlotsWithLockForUnlock = lockedSlots.slice(slotLockIndex);

    /**@type {import('AppointmentsBase').TimeSlot[]} */
    var slotsForUnlock = slicedSlotsWithLockForUnlock.map(function(item) {
      return item.slot;
    });

    /**@type {string[]} */
    var lockIdsForUnlock = slicedSlotsWithLockForUnlock.map(function(item) {
      return item.lock.SlotLockId;
    });

    /**@type {import('AppointmentsBase').SlotWithLock[]} */
    var slicedSlotsWithLockForRefresh = lockedSlots.slice(0, slotLockIndex);

    /**@type {import('AppointmentsBase').TimeSlot[]} */
    var slotsForRefresh = slicedSlotsWithLockForRefresh.map(function(item) {
      return item.slot;
    });

    /**@type {string[]} */
    var lockIdsForRefresh = slicedSlotsWithLockForRefresh.map(function(item) {
      return item.lock.SlotLockId;
    });

    /**@type {import('AppointmentsDashboard').DataForUnlockAndRefresh} */
    var data = {
      lockIdsForUnlock: lockIdsForUnlock,
      slotsWithLockForUnlock: slicedSlotsWithLockForUnlock,
      slotsForUnlock: slotsForUnlock,
      lockIdsForRefresh: lockIdsForRefresh,
      slotsWithLockForRefresh: slicedSlotsWithLockForRefresh,
      slotsForRefresh: slotsForRefresh
    };
    return data;
  },
  getDataForRefresh: function(cmp) {
    var lockedData = this.lockedData(cmp);
    var lockedSlots = lockedData.lockedSlots;

    /**@type {import('AppointmentsBase').TimeSlot[]} */
    var slotsForRefresh = lockedSlots.map(function(item) {
      return item.slot;
    });

    /**@type {string[]} */
    var lockIdsForRefresh = lockedSlots.map(function(item) {
      return item.lock.SlotLockId;
    });

    /**@type {import('AppointmentsDashboard').DataForUnlockAndRefresh} */
    var data = {
      lockIdsForUnlock: [],
      slotsWithLockForUnlock: [],
      slotsForUnlock: [],
      lockIdsForRefresh: lockIdsForRefresh,
      slotsWithLockForRefresh: lockedSlots,
      slotsForRefresh: slotsForRefresh
    };
    return data;
  },
  requestErrorHandler: function(cmp, err) {
    console.log(err);
    this.isLoading(cmp, false);
    this.serverError(cmp, this.buildHtmlServerError(err));
    this.scrollAppointmentTo(cmp, 'top');
    this.updateTimeGroupPosition(cmp);
  },
  unlockAllSlots: function(cmp) {
    var that = this;
    var slotsMap = that.slotsMap(cmp);
    var lockedData = that.lockedData(cmp);
    var lockedSlots = lockedData.lockedSlots;
    return Promise.resolve()
      .then(
        $A.getCallback(function() {
          if (lockedSlots.length === 0) {
            return Promise.resolve(true);
          }
          var slot = lockedSlots[0].slot;
          var dataForUnlock = that.getDataForUnlock(cmp, slot, 0);
          return that.unlockAndRefreshSlotsRequest(cmp, dataForUnlock);
        })
      )
      .then(
        $A.getCallback(function(res) {
          lockedData = {
            lockedSlots: [],
            slotsByRow: []
          };

          that.stopLockTimer(cmp);
          that.updateTimeGroupPosition(cmp);
          that.resetSelectedDayData(cmp);
          that.lockedData(cmp, lockedData);
          that.updateUrgentField(cmp);
          return true;
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.requestErrorHandler(cmp, err);
          return false;
        })
      );
  },
  getSlotByKey: function(cmp, key) {
    var slotsMap = this.slotsMap(cmp);
    return slotsMap[key];
  },
  getSlotsFromLockedData: function(cmp) {
    var lockedData = this.lockedData(cmp);
    var lockedSlots = lockedData.lockedSlots;

    /**@type {import('AppointmentsBase').TimeSlot[]} */
    var slots = lockedSlots.map(function(item) {
      return item.slot;
    });
    return slots;
  },
  updatePreparedAppointments: function(cmp) {
    var that = this;
    var mode = that.mode(cmp);
    var staticData = that.staticData(cmp);
    var existingAppointmentList = staticData.existingAppointmentList;
    var slotsData = that.slotsData(cmp);
    var lockedData = that.lockedData(cmp);
    var lockedSlots = lockedData.lockedSlots;
    var selectedProcedureCodes = that.getAllSelectedProcedureCodes(cmp);
    var selectedOptions = that.selectedOptions(cmp);
    var mainProcedureOption = selectedOptions.procedure;
    var sequenceProceduresOptions = that
      .sequenceProcedureFields(cmp)
      .map(function(item) {
        return item.option;
      });
    var allProcedureOptions = [mainProcedureOption]
      .concat(sequenceProceduresOptions)
      .filter(function(item) {
        return !!item;
      });

    var preparedAppointments = selectedProcedureCodes.map(function(_, index) {
      var siteName = '';
      var procedure = allProcedureOptions[index];
      var procedureName = procedure.label;
      var slot = lockedSlots[index] && lockedSlots[index].slot;
      var updatedAppointment = existingAppointmentList[index];
      var appointmentId = updatedAppointment ? updatedAppointment.Id : '';
      var dateTime = '';
      var calendarName = '';
      if (slot) {
        var siteMapByCode = slotsData.siteMapByCode;
        var calendarMapByCode = slotsData.calendarMapByCode;
        calendarName = calendarMapByCode[slot.ModalityCode] || '';
        dateTime = slot.StartTime;
        siteName = siteMapByCode[slot.siteCode].label;
      }

      return that.buildPreparedAppointment(cmp, {
        Id: appointmentId,
        dateTime: dateTime,
        procedureName: procedureName,
        calendarName: calendarName,
        siteName: siteName
      });
    });
    that.preparedAppointments(cmp, preparedAppointments);
    that.scrollSidebarAppointmentsToBottom(cmp);
  },
  buildPreparedAppointment: function(cmp, data) {
    /**@type {import('AppointmentsBase').SidebarAppointment} */
    var defaultFields = {
      dateTime: '',
      procedureName: '',
      calendarName: '',
      siteName: '',
      Id: ''
    };
    /**@type {import('AppointmentsBase').SidebarAppointment} */
    var appointment = Object.assign(defaultFields, data);
    return appointment;
  },
  buildHistoryAppointment: function(cmp, data) {
    var procedureName = '';
    var procedureRef = data.Medical_Procedure__r;
    if (procedureRef) {
      procedureName =
        procedureRef.Marketing_Procedure_Name__c || procedureRef.Name;
    }

    var calendarName = data.Calendar__r ? data.Calendar__r.Name : '';

    /**@type {import('AppointmentsBase').SidebarAppointment} */
    var defaultFields = {
      dateTime: data.Appointment_Date_Time__c,
      procedureName: procedureName,
      siteName: data.Site__r ? data.Site__r.Name : '',
      calendarName: calendarName,
      Id: data.Id
    };
    /**@type {import('AppointmentsBase').SidebarAppointment} */
    var appointment = Object.assign(defaultFields, data);
    return appointment;
  },
  filterSlotRows: function(cmp) {
    var isSequence = this.isSequence(cmp);
    if (!isSequence) {
      return;
    }
    this.buildSlotRows(cmp, true);
  },
  resetSelectedDayData: function(cmp) {
    /**@type {import('AppointmentsBase').SelectDayEventData} */
    var dayData = {
      day: null,
      dayEl: null,
      rowIndex: null
    };
    this.selectedDayData(cmp, dayData);
    this.isTimeGroupVisible(cmp, false);
  },
  buildLockedDaysMapFromLockedSlots: function(cmp, lockedKeys) {
    var slotsMap = this.slotsMap(cmp);
    /**@type {import('AppointmentsBase').LockedDaysMap} */
    var lockedDaysMap = lockedKeys.reduce(function(acc, key) {
      var slot = slotsMap[key];
      if (!slot) {
        return acc;
      }
      var dayKey = slot.dayKey;
      acc[dayKey] = dayKey;
      return acc;
    }, {});
    return lockedDaysMap;
  },
  checkFileMandatory: function(cmp) {
    var that = this;
    var mode = that.mode(cmp);
    if (mode !== 'create') {
      return;
    }
    var recordId = that.recordId(cmp);
    var editData = that.editData(cmp);
    var domainId = editData.domain;
    if (!domainId) {
      that.isFileRequired(cmp, false);
      return;
    }
    var params = {
      actionName: 'isFileMandatory',
      recordId: recordId,
      insurerFactor: editData.insurerFactor,
      domainId: editData.domain
    };
    return that
      .scheduleAppointmentService(cmp)
      .appointmentApiRequest(params)
      .then(
        $A.getCallback(function(/**@type {boolean} */ isMandatory) {
          that.isFileRequired(cmp, isMandatory);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
        })
      );
  },
  getProcedureForCalendar: function(cmp) {
    var that = this;
    var scheduleAppointmentService = that.scheduleAppointmentService(cmp);
    var editData = that.editData(cmp);
    if (!editData.calendar) {
      return;
    }
    var procedureAutocompleteCmp = that.procedureAutocompleteCmp(cmp);
    var params = {
      actionName: 'getProcedureForCalendar',
      calendarCode: editData.calendar
    };
    return scheduleAppointmentService
      .appointmentApiRequest(params)
      .then(
        $A.getCallback(function(
          /**@type {import('ScheduleAppointmentService').ProcedureOptionRes} */ procedure
        ) {
          if (!procedure || !procedureAutocompleteCmp) {
            return;
          }
          var procedureOption = scheduleAppointmentService.buildProcedureOption(
            procedure
          );
          procedureAutocompleteCmp.setOption(procedureOption);
          that.updatePreparedAppointments(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
        })
      );
  },
  buildRow: function(cmp, label, note, code) {
    /**@type {import('AppointmentsBase').SlotsRow} */
    var row = {
      label: label,
      note: note,
      smallNote: note.length > 20 ? note.slice(0, 20) : note,
      days: [],
      code: code,
      modalityCodes: [],
      transferToDepartment: false
    };
    return row;
  },
  normalizeOptionsMap: function(mapObj, optionBuilderFn) {
    mapObj = mapObj || {};
    for (var key in mapObj) {
      // eslint-disable-next-line no-prototype-builtins
      if (mapObj.hasOwnProperty(key)) {
        mapObj[key] = optionBuilderFn(mapObj[key]);
      }
    }
    return mapObj;
  },
  retrieveReferralsFromAccount: function(cmp) {
    var that = this;
    var isForDocExpert = that.isForDocExpert(cmp);

    if (isForDocExpert) {
      return;
    }
    var editData = that.editData(cmp);

    var domainCode = editData.domain;
    var procedureCode = editData.procedure;

    if (!domainCode || !procedureCode) {
      return;
    }

    var recordId = that.recordId(cmp);
    var requestMap = that.retrieveReferralsFromAccountRequestMap(cmp);
    var requestResult = requestMap[domainCode];

    if (requestResult) {
      return;
    }

    var params = {
      actionName: 'retrieveReferralsFromAccount',
      recordId: recordId,
      domainCode: domainCode,
      procedureCode: procedureCode
    };


    requestResult = that
      .scheduleAppointmentService(cmp)
      .appointmentApiRequest(params)
      .then(function() {
        requestMap[domainCode] = true;
      })
      .catch(function() {
        delete requestMap[domainCode];
      })
      .then(function() {
        that.retrieveReferralsFromAccountRequestMap(cmp, requestMap);
      });

    requestMap[domainCode] = requestResult;
    that.retrieveReferralsFromAccountRequestMap(cmp, requestMap);
  },
  showForcedAppointmentScreen: function(cmp) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var recordId = that.recordId(cmp);
    var doctorId = that.doctorId(cmp);
    var isForDocExpert = that.isForDocExpert(cmp);
    var selectedOptions = that.selectedOptions(cmp);
    var staticData = that.staticData(cmp);
    var editData = that.editData(cmp);
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
        doctorId: doctorId,
        isForDocExpert: isForDocExpert,
        initData: {
          staticData: that.unProxyData(staticData),
          startDate: editData.startDate,
          selectedOptions: that.unProxyData(selectedOptions)
        }
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
                that.isLoading(cmp, false);
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
  emitShowForcedAppointment: function(cmp, data) {
    this.emitEvent(cmp, 'showForcedAppointment', { value: data });
  },
  scrollSidebarAppointmentsToBottom: function(cmp) {
    var that = this;
    setTimeout(function() {
      var sideScrollerWrapperCmp = that.sideScrollerWrapperCmp(cmp);
      if (sideScrollerWrapperCmp) {
        sideScrollerWrapperCmp.scrollTo('bottom');
      }
    });
  },
  transferToDepartment: function(cmp, slotRow, queueId) {
    var that = this;
    var scheduleAppointmentService = that.scheduleAppointmentService(cmp);
    var caseId = that.recordId(cmp);
    var editData = that.editData(cmp);
    that.isLoading(cmp, true);
    that.serverError(cmp, '');
    that.updateTimeGroupPosition(cmp);

    var params = {
      actionName: 'transferToDepartment',
      caseId: caseId,
      domainId: editData.domain,
      insurenceCode: editData.insurerFactor,
      siteCode: slotRow != null ? slotRow.code : null,
      procedureCode: editData.procedure,
      queueId: queueId
    };
    scheduleAppointmentService
      .appointmentApiRequest(params)
      .then(
        $A.getCallback(function(message) {
          that.isLoading(cmp, false);
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: message
          });
          that.refreshView();
          that.close(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.requestErrorHandler(cmp, err);
        })
      );
  },

  updateUrgentField: function(cmp) {
    var that = this;
    var isForDocExpert = that.isForDocExpert(cmp);
    if (isForDocExpert) {
      return;
    }
    var mode = that.mode(cmp);
    var isVisible = false;
    if (mode !== 'create') {
      return;
    }
    var appointmentData = that.appointmentData(cmp);
    var selectedOptions = that.selectedOptions(cmp);
    var slotsFromLockedKeys = that.getSlotsFromLockedData(cmp);
    var procedure = selectedOptions.procedure;
    var firstLockedSlot = slotsFromLockedKeys[0];
    var isAfter2Weeks = false;

    if (firstLockedSlot) {
      var startDate = $A.localizationService.parseDateTime(
        firstLockedSlot.StartTime
      );
      var targetDate = new Date();
      var daysTargetPeriod = 14; //2 weeks (14days)
      targetDate.setDate(targetDate.getDate() + daysTargetPeriod);
      isAfter2Weeks = $A.localizationService.isAfter(startDate, targetDate);
    }

    var params = {
      actionName: 'isSaveSlot',
      procedureId: procedure ? procedure.Id : '',
      calendarCode: firstLockedSlot ? (firstLockedSlot.ModalityCode + '') : ''
    }

    that
        .scheduleAppointmentService(cmp)
        .appointmentApiRequest(params)
        .then((isSave) => {
          console.log('isSave', isSave);
          //if (isAfter2Weeks && isSave) {
          if (isSave) {
            isVisible = true;
          } else {
            appointmentData.urgentReason = '';
            appointmentData.isUrgent = false;
            isVisible = false;
          }
          this.isUrgentVisible(cmp, isVisible);
          this.appointmentData(cmp, appointmentData);
        });
  },
  emitKmsSearchEvent: function(cmp, searchString) {
    var eventName = 'e.kmslh:KMS_MainSearchEvent';
    var appEvent = $A.get(eventName);
    if (!appEvent) {
      return;
    }
    appEvent.setParams({ searchstring: searchString });
    appEvent.fire();
  },
  selectModalityHandler: function(cmp, data) {
    var that = this;
    var rowIndex = data.rowIndex;
    var modality = data.modality;
    var slotRows = that.slotRows(cmp);
    var row = slotRows[rowIndex];
    if (!row) {
      return;
    }

    row.selectedModality = row.selectedModality === modality ? '' : modality;
    this.slotRows(cmp, slotRows);
    this.resetSelectedDayData(cmp);
  },
  showAppointmentDisabilitiesModal: function(cmp, caseId, appointmentIds) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var services = that.globalServices(cmp);
    var componentFactoryService = services.componentFactoryService;
    var modalService = services.modalService;
    var modalName = 'AppointmentDisabilitiesModal';
    var modalParams = modalService.buildAuraModalParams(modalName);
    modalParams.modalData = {
      caseId: caseId || '',
      appointmentIds: appointmentIds || []
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
        $A.getCallback(function(component) {
          return overlayLibCmp.showCustomModal({
            body: component,
            cssClass: cmpDefinition.className + ' modal',
            showCloseButton: true,
            closeCallback: function() {
              modalParams.resolvers.close();
            }
          });
        })
      )
      .then(
        $A.getCallback(function() {
          that.isLoading(cmp, false);
          return modalParams.promises.close;
        })
      );
  },
  searchTechnician: function(cmp, term) {
    var that = this;
    var services = that.globalServices(cmp);
    var appointmentService = services.appointmentService;
    var editData = this.editData(cmp);
    return appointmentService
      .searchTechnician(editData.procedure, term)
      .then(function(options) {
        return options;
      })
      .catch(function(err) {
        return [];
      });
  },
  resetTechnician: function(cmp) {
    var editData = this.editData(cmp);
    var selectedOptions = this.selectedOptions(cmp);
    this.hasTechnicianProcedure(cmp, false);
    this.resetTechnicialProcedure(cmp);
    editData.technician = '';
    selectedOptions.technician = null;
    this.editData(cmp, editData);
    this.selectedOptions(cmp, selectedOptions);
  },
  searchTechnicianProcedure: function(cmp, term) {
    var that = this;
    var editData = that.editData(cmp);
    var selectedOptions = that.selectedOptions(cmp);
    var procedureCode = editData.procedure;
    var technician = selectedOptions.technician;

    var services = that.globalServices(cmp);
    var appointmentService = services.appointmentService;
    return appointmentService
      .searchTechnicianProcedure(procedureCode, technician, term)
      .then(function(data) {
        var options = data.map(function(item) {
          return that
            .scheduleAppointmentService(cmp)
            .buildProcedureOption(item);
        });
        return options;
      })
      .catch(function() {
        return [];
      });
  },

  technicianChangedHandler: function(cmp, option) {
    if (!option) {
      this.resetTechnicialProcedure(cmp);
      this.hasTechnicianProcedure(cmp, false);
      return;
    }
    var hasTechnicianProcedure = option.withProcedures;
    this.hasTechnicianProcedure(cmp, hasTechnicianProcedure);
  },
  resetTechnicialProcedure: function(cmp) {
    var that = this;
    var editData = this.editData(cmp);
    var selectedOptions = this.selectedOptions(cmp);
    this.hasTechnicianProcedure(cmp, false);
    editData.technicianProcedure = '';
    selectedOptions.technicianProcedure = null;
    this.editData(cmp, editData);
    this.selectedOptions(cmp, selectedOptions);

    setTimeout(function() {
      var editData = that.editData(cmp);
      var selectedOptions = that.selectedOptions(cmp);
      console.log(
        that.unProxyData({
          editData: editData,
          selectedOptions: selectedOptions
        })
      );
    });
  },
  calendarQflowChangedHandler: function(cmp, calendar, caldenarList) {
    var that = this;
    var editData = this.editData(cmp);

    if (calendar === '') {
      editData.qflowCalendarLabel = null;
      editData.qflowCalendar = null;
    } else {
      for (var i = 0; i < caldenarList.length; i++) {
        if (caldenarList[i].value === calendar) {
          editData.qflowCalendarLabel = caldenarList[i].label;
        }
      }
    }
    this.editData(cmp, editData);
  },

  showPatientDetailsModal: function(
    cmp,
    patientId,
    idType,
    showSensitivitiesInfo,
    schParameters
  ) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var services = that.globalServices(cmp);
    var componentFactoryService = services.componentFactoryService;
    var modalService = services.modalService;
    var modalName = 'PatientDetailsModal';
    var modalParams = modalService.buildAuraModalParams(modalName);
    modalParams.modalData = {
      patientId: patientId,
      idType: idType,
      showSensitivitiesInfo: showSensitivitiesInfo,
      schParameters: schParameters
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
        $A.getCallback(function(component) {
          return overlayLibCmp.showCustomModal({
            body: component,
            cssClass: cmpDefinition.className + ' modal',
            showCloseButton: true,
            closeCallback: function() {
              modalParams.resolvers.close();
            }
          });
        })
      )
      .then(
        $A.getCallback(function() {
          that.isLoading(cmp, false);
          return modalParams.promises.close;
        })
      );
  },
  showPatientEmailModal: function(cmp, patientId, idType) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var services = that.globalServices(cmp);
    var componentFactoryService = services.componentFactoryService;
    var modalService = services.modalService;
    var modalName = 'PatientEmailModal';
    var modalParams = modalService.buildAuraModalParams(modalName);
    modalParams.modalData = {
      patientId: patientId,
      idType: idType,
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
        $A.getCallback(function(component) {
          return overlayLibCmp.showCustomModal({
            body: component,
            cssClass: cmpDefinition.className + ' modal',
            showCloseButton: true,
            closeCallback: function() {
              modalParams.resolvers.close();
            }
          });
        })
      )
      .then(
        $A.getCallback(function() {
          that.isLoading(cmp, false);
          return modalParams.promises.close;
        })
      );
  }
});