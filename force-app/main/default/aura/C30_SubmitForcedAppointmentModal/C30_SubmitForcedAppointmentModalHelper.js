/**@type {import("C30_SubmitForcedAppointmentModal").Helper} */
({
  init: function(cmp) {
    this.config(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},

  initData: function(cmp, value) {
    return this.attribute(cmp, 'initData', value);
  },

  editData: function(cmp, value) {
    return this.attribute(cmp, 'editData', value);
  },

  timeGap: function(cmp, value) {
    return this.attribute(cmp, 'timeGap', value);
  },

  selectedOptions: function(cmp, value) {
    return this.attribute(cmp, 'selectedOptions', value);
  },

  errorMessage: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },

  steps: function(cmp, value) {
    return this.attribute(cmp, 'steps', value);
  },
  currentStep: function(cmp, value) {
    return this.attribute(cmp, 'currentStep', value);
  },
  currentStepIndex: function(cmp, value) {
    return this.attribute(cmp, 'currentStepIndex', value);
  },

  tableColumns: function(cmp, value) {
    return this.attribute(cmp, 'tableColumns', value);
  },
  tableData: function(cmp, value) {
    return this.attribute(cmp, 'tableData', value);
  },

  selectedSlot: function(cmp, value) {
    return this.attribute(cmp, 'selectedSlot', value);
  },

  slotsTableCmp: function(cmp) {
    return cmp.find('slotsTable');
  },

  step1Fields: function(cmp) {
    return this.convertCmpsToArray(cmp.find('step1Field'));
  },

  step3Fields: function(cmp) {
    return this.convertCmpsToArray(cmp.find('step3Field'));
  },

  isForDocExpert: function(cmp, value) {
    return this.attribute(cmp, 'isForDocExpert', value);
  },

  isForUrgent: function(cmp, value) {
    return this.attribute(cmp, 'isForUrgent', value);
  },

  recordId: function(cmp, value) {
    return this.attribute(cmp, 'recordId', value);
  },

  doctorId: function(cmp, value) {
    return this.attribute(cmp, 'doctorId', value);
  },
  
  findAutocompleteEditField: function(fields, fieldName) {
    var that = this;
    return fields.find(function(item) {
      var name = that.attribute(item, 'name');
      return name === fieldName;
    });
  },

  calendarAutocompleteCmp: function(cmp) {
    var fields = this.step1Fields(cmp);
    return this.findAutocompleteEditField(fields, 'calendar');
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

  config: function(cmp) {
    var editData = this.editData(cmp);
    var tableColumns = this.buildTableColumns(cmp);       
    var isForUrgent = this.isForUrgent(cmp);

    this.tableColumns(cmp, tableColumns);

    this.configSteps(cmp);
    
    if(isForUrgent) {
      return this.fetchStaticData(cmp);
    }
    var initData = this.initData(cmp);

    if (!initData) {
      return;
    }
    var selectedOptions = initData.selectedOptions;
    var staticData = initData.staticData;
    var domain = selectedOptions.domain;
    var insurerFactor = selectedOptions.insurerFactor;
    var procedure = selectedOptions.procedure;
    if (domain) {
      editData.domain = domain.value;
    }
    if (insurerFactor) {
      editData.insurerFactor = selectedOptions.insurerFactor.value;
    }
    if (procedure) {
      editData.procedure = selectedOptions.procedure.value;
    }

    editData.startDate = initData.startDate;
    this.editData(cmp, editData);
    this.selectedOptions(cmp, selectedOptions);
    this.staticData(cmp, staticData);

    console.log(this.unProxyData(initData));
  },

  configSteps: function(cmp) {
    var steps = [
      { id: 'search', label: 'Appointment' },
      { id: 'select', label: 'Reason' },
      { id: 'edit', label: 'edit' }
    ];
    this.steps(cmp, steps);
    var currentStepIndex = 0;
    this.currentStepIndex(cmp, currentStepIndex);
    this.currentStep(cmp, steps[currentStepIndex]);
  },

   buildTableColumns: function(cmp) {
    /**@type {import('C30_SubmitForcedAppointmentModal').TableColumn[]} */
    var isForUrgent = this.isForUrgent(cmp);
    var tableColumns = [
      {
        fieldName: 'date',
        label: $A.get('$Label.c.Date'),
        type: 'date',
        fixedWidth: 120,
        typeAttributes: {
          year: 'numeric',
          month: '2-digit',
          day: '2-digit'
        },
        cellAttributes: { 
          class: { 
            fieldName: 'dateColorCSSClass'
          }
        }
      },
      {
        fieldName: 'startTime',
        label: $A.get('$Label.c.Start_time'),
        type: 'text',
        fixedWidth: 120,
        typeAttributes: {},
        cellAttributes: { 
          class: { 
            fieldName: 'startTimeColorCSSClass'
          }
        }
      },
      {
        fieldName: 'endTime',
        label: $A.get('$Label.c.End_time'),
        type: 'text',
        fixedWidth: 120,
        typeAttributes: {},
        cellAttributes: { 
          class: { 
            fieldName: 'endTimeColorCSSClass'
          }
        }

      },
      {
        fieldName: 'type',
        label: $A.get('$Label.c.Forced_slot_type'),
        fixedWidth: 100,
        type: 'text',
        cellAttributes: { 
          class: { 
            fieldName: 'typeColorCSSClass'
          }
        }
      },
      {
        fieldName: 'description',
        label: $A.get('$Label.c.Forced_slot_description'),
        type: 'text',
        fixedWidth: 150,
        cellAttributes: { 
          class: { 
            fieldName: 'descriptionColorCSSClass'
          }
        }
      },          
      {
        fieldName: 'calendarCode',
        label: $A.get('$Label.c.Forced_slot_calender_code'),
        fixedWidth: 120,
        type: 'text',
      },
      {
        fieldName: 'calenderName',
        label: $A.get('$Label.c.Forced_slot_calender_name'),
        fixedWidth: 150,
        type: 'text',
      },
      {
        fieldName: 'name',
        label: $A.get('$Label.c.Forced_slot_name'),
        type: 'text',
        fixedWidth: 100,
        visibility: false,
        cellAttributes: { 
          class: { 
            fieldName: 'nameColorCSSClass'
          }
        }
      },
      {
        fieldName: 'patientId',
        label: $A.get('$Label.c.Forced_slot_patient_id'),
        fixedWidth: 100,
        type: 'text',
        visibility: false,
        cellAttributes: { 
          class: { 
            fieldName: 'patientIdColorCSSClass'
          }
        }
      }
    ];
    return tableColumns;
  },

  buildTableData: function(cmp, slots) {
    /**@type {import('C30_SubmitForcedAppointmentModal').TableRow[]} */
    var tableData = slots.map(function(slot, index) {
      /**@type {import('C30_SubmitForcedAppointmentModal').TableRow} */
      var row = Object.assign({}, slot, { index: index });
      return row;
    });
    return tableData;
  },

  submit: function(cmp) {
    var that = this;
    var isForUrgent = that.isForUrgent(cmp);

    that.errorMessage(cmp, '');
    that.isLoading(cmp, true);
    if(isForUrgent){
      return that.updateAppointment(cmp);
    }
    that
      .createAppointmentRequest(cmp)
      .then(
        $A.getCallback(function(res) {
          that.isLoading(cmp, false);
          that.emitCreated(cmp);
          that.close(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isLoading(cmp, false);
          that.errorMessage(cmp, that.buildHtmlServerError(err));
        })
      );
  },

  createAppointmentRequest: function(cmp) {
    var that = this;
    var editData = that.editData(cmp);
    var staticData = that.staticData(cmp);
    var recordId = that.recordId(cmp);
    var selectedSlot = that.unProxyData(that.selectedSlot(cmp));    
    var slot = this.buildSlot(cmp, selectedSlot, editData, staticData);
    var jsonedSlots = JSON.stringify([slot]);
    var patientId = staticData.accountPaitientId;
    var idType = staticData.accountPaitientIdType;
    var insurenceCode = editData.insurerFactor;    

    function createAppointment() {
      var params = {
        actionName: 'createAppointmentArray',
        jsonedSlots: jsonedSlots,
        procedureCodes: JSON.stringify([]),
        patientId: patientId,
        idType: idType,
        clinicId: '',
        urgentReason: '',
        insurenceCode: insurenceCode,
        recordId: recordId,
        protocols: JSON.stringify([''])
      };
      return that.scheduleAppointmentService(cmp).appointmentApiRequest(params);
    }

    function setAppointment(appointmentIds) {
      var params = {
        actionName: 'setAppointmentArray',
        jsonedSlots: jsonedSlots,
        patientId: patientId,
        idType: idType,
        insurenceCode: insurenceCode,
        recordIds: JSON.stringify(appointmentIds),
        sendForApproval: false,
        forcedCode: editData.overbook
      };
      return that.scheduleAppointmentService(cmp).appointmentApiRequest(params);
    }

    that.errorMessage(cmp, '');
    that.isLoading(cmp, true);
    return Promise.resolve()
      .then(createAppointment)
      .then(setAppointment)
      .then(
        $A.getCallback(function(res) {
          that.isLoading(cmp, false);
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: $A.get('$Label.c.Appointment_created')
          });
          that.refreshView();
          that.close(cmp);
          return true;
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
          that.isLoading(cmp, false);
          that.errorMessage(cmp, that.buildHtmlServerError(err));
        })
      );
  },
  updateAppointmentRequest: function(cmp, isSendForApproval) {
    var that = this;
    var editData = that.editData(cmp);
    var staticData = that.staticData(cmp);
    var recordId = that.recordId(cmp);
    var selectedSlot = that.unProxyData(that.selectedSlot(cmp));    
    var slot = that.buildSlot(cmp, selectedSlot, editData, staticData);
    var jsonedSlots = JSON.stringify([slot]);    
    var insurenceCode = editData.insurerFactor;
    var preparedAppointments = staticData.existingAppointmentList;
    var appointmentIds = preparedAppointments.map(function(item) {
      return item.Id;
    });
    
    function rescheduleAppointment() {     
      var params = {
        actionName: 'rescheduleAppointmentArray',
        jsonedSlots: jsonedSlots,
        patientId: staticData.accountPaitientId,
        idType: staticData.accountPaitientIdType,
        recordId: recordId,
        clinicId: '',        
        insurenceCode: insurenceCode,
        sendForApproval: isSendForApproval,
        appointmentIds: JSON.stringify(appointmentIds)
      };
      return that.scheduleAppointmentService(cmp).appointmentApiRequest(params);
    }

    that.errorMessage(cmp, '');
    that.isLoading(cmp, true);
    return Promise.resolve()
      .then(rescheduleAppointment)      
      .then(
        $A.getCallback(function(res) {
          that.isLoading(cmp, false);
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

  buildDateFromDateTime: function(cmp, date, time) {
    return new Date(date + 'T' + time + 'Z');
  },

  buildSlot: function(cmp, forcedSlot, editData, staticData) {
    var that = this;
    var isForUrgent = this.isForUrgent(cmp);
    var timeGap = that.timeGap(cmp);
    var targetDate = forcedSlot.date;
    var slotStartTime = that.buildDateFromDateTime(
      cmp,
      targetDate,
      forcedSlot.startTime
    );
    var slotEndTime = that.buildDateFromDateTime(cmp, targetDate, forcedSlot.endTime);
    var slotDuration = slotEndTime.getTime() - slotStartTime.getTime();

    var startDateTime = that.buildDateFromDateTime(cmp, targetDate, editData.time);
    var endDateTime = new Date(
      that.buildDateFromDateTime(cmp, targetDate, editData.time).getTime() +
        slotDuration
    );

    var durationInMinutes = slotDuration / 1000 / 60; //ms to minutes
    var startTime = new Date(startDateTime.getTime() - timeGap);
    var isForDocExpert = that.isForDocExpert(cmp);
    return {
      Duration: isForUrgent? staticData.duration : durationInMinutes,
      ModalityCode: isForUrgent? forcedSlot.calendarCode : editData.calendar,
      SlotId: 0,
      StartTime: startTime,
      UnitCode: undefined,
      dayKey: undefined,
      dayOfWeek: undefined,
      procedureCode: editData.procedure,
      region: undefined,
      siteCode: isForDocExpert? editData.clinic : isForUrgent? forcedSlot.siteCode : editData.calendar,
      targetDate: targetDate,
      uniqKey: undefined
    };
  },

  cancel: function(cmp) {
    this.close(cmp);
  },

  validateForm: function(cmp) {
    var isValid = true;
    return isValid;
  },

  emitCreated: function(cmp) {
    this.emitEvent(cmp, 'oncreated');
  },
  nextStep: function(cmp) {
    var steps = this.steps(cmp);
    var currentStepIndex = this.currentStepIndex(cmp);
    var currentStep = this.currentStep(cmp);
    var isStepValid = this.validateStep(cmp, currentStep.id);
    if (!isStepValid) {
      return;
    }
    if (currentStepIndex >= steps.length - 1) {
      this.submit(cmp);
    } else {
      currentStepIndex += 1;
      this.currentStepIndex(cmp, currentStepIndex);
      this.currentStep(cmp, steps[currentStepIndex]);
      var prevStepIndex = currentStepIndex - 1;
      this.changeStepHandler(cmp, currentStepIndex, prevStepIndex);
    }
  },
  prevStep: function(cmp) {
    this.errorMessage(cmp, '');
    var steps = this.steps(cmp);
    var currentStepIndex = this.currentStepIndex(cmp);
    if (currentStepIndex === 0) {
      return;
    }
    currentStepIndex -= 1;
    this.currentStepIndex(cmp, currentStepIndex);
    this.currentStep(cmp, steps[currentStepIndex]);
    var prevStepIndex = currentStepIndex + 1;
    this.changeStepHandler(cmp, currentStepIndex, prevStepIndex);
  },
  moveToStep: function(cmp, stepIndex) {
    var steps = this.steps(cmp);
    if (stepIndex >= 0 && stepIndex < steps.length) {
      var targetStep = steps[stepIndex];
      var prevStepIndex = this.currentStepIndex(cmp);
      this.currentStepIndex(cmp, stepIndex);
      this.currentStep(cmp, targetStep);
      this.changeStepHandler(cmp, stepIndex, prevStepIndex);
    }
  },
  validateStep: function(cmp, stepId) {
    switch (stepId) {
      case 'search': {
        return this.validateSearchStep(cmp);
      }
      case 'select': {
        return this.validateSelectStep(cmp);
      }
      case 'edit': {
        return this.validateEditStep(cmp);
      }
      default: {
        return false;
      }
    }
  },

  validateSearchStep: function(cmp) {
    var isValid = true;
    var fieldCmps = this.step1Fields(cmp);
    fieldCmps.forEach(function(fieldCmp) {
      var isFieldValid = fieldCmp.checkValidity();
      fieldCmp.showHelpMessageIfInvalid();
      isValid = isValid && isFieldValid;
    });
    return isValid;
  },
  validateSelectStep: function(cmp) {
    var isValid = true;
    var selectedSlot = this.selectedSlot(cmp);
    if (!selectedSlot) {
      this.errorMessage(cmp, $A.get('$Label.c.Please_select_a_slot'));
      isValid = false;
    }
    return isValid;
  },
  validateEditStep: function(cmp) {
    var isValid = true;
    var stepFieldCmps = this.step3Fields(cmp);
    stepFieldCmps.forEach(function(fieldCmp) {
      var isFieldValid = fieldCmp.checkValidity();
      fieldCmp.showHelpMessageIfInvalid();
      isValid = isValid && isFieldValid;
    });
    return isValid;
  },
  changeStepHandler: function(cmp, currentStepIndex, prevStepIndex) {
    var that = this;
    that.errorMessage(cmp, '');
    if (currentStepIndex < prevStepIndex) {
      return;
    }
    var currentStep = that.currentStep(cmp);
    // console.log('next', that.unProxyData(currentStep));

    switch (currentStep.id) {
      case 'search': {
        return that.prepareSearchStep(cmp);
      }
      case 'select': {
        return that.prepareSelectStep(cmp);
      }
      case 'edit': {
        return that.prepareEditStep(cmp);
      }
    }
  },

  searchDomains: function(cmp, term) {
    var that = this;

    return that
      .scheduleAppointmentService(cmp)
      .searchDomains({
        keyWord: term,
        screenMode: ''
      })
      .catch(function(err) {
        return [];
      });
  },

  searchSites: function(cmp, term) {
    var that = this;
    var editData = that.editData(cmp);
    var isForUrgent = this.isForUrgent(cmp);
    if (isForUrgent) {
      return that
      .scheduleAppointmentService(cmp)
      .searchSequenceSites({
        keyWord: term,
        procedureCodes: JSON.stringify([editData.procedure])
      })
      .catch(function(err) {
        return [];
      });
    }
    return that
      .scheduleAppointmentService(cmp)
      .searchForcedSites({
        keyWord: term,
        procedureCode: editData.procedure
      })
      .then(function(options) {
        return options;
      })
      .catch(function(err) {
        return [];
      });
  },

  searchCalendars: function(cmp, term) {
    var that = this;
    var editData = that.editData(cmp);
    var scheduleAppointmentService = that.scheduleAppointmentService(cmp);
    var params = {
      actionName: 'calendarSearchForced',
      siteCode: editData.site,
      procedureCode: editData.procedure,
      keyWord: term
    };
    return that
      .scheduleAppointmentService(cmp)
      .appointmentApiRequest(params)
      .then(function(options) {
        return options.map(function(item) {
          return scheduleAppointmentService.buildCalendarOption(item);
        });
        // return [{ label: '174', value: '174' }];
      })
      .catch(function(err) {
        return [];
      });
  },

  searchProcedures: function(cmp, term) {
    var that = this;
    var editData = that.editData(cmp);
    return that
      .scheduleAppointmentService(cmp)
      .searchProcedures({
        keyWord: term
      })
      .then(function(options) {
        return options;
      })
      .catch(function(err) {
        return [];
      });
  },

  searchSlots: function(cmp) {
    var that = this;
    var editData = this.editData(cmp);
    var doctorId = this.doctorId(cmp);
    var isForDocExpert = that.isForDocExpert(cmp);
    var isForUrgent = that.isForUrgent(cmp);

    var params = {
      actionName: 'searchForcedSlots',
      startDate: editData.startDate,
      procedureCode: editData.procedure,
      siteCode: isForDocExpert? editData.clinic : editData.site,
      calendarCode: editData.calendar,
      restrictionsOnly : isForUrgent ? true : false,
      doctorId: doctorId,

      /* startDate: '2019-10-15' || editData.startDate,
      procedureCode: editData.procedure,
      siteCode: '1' || editData.site,
      calendarCode: '174' || editData.calendar */
    };
    that.errorMessage(cmp, '');
    that.isLoading(cmp, true);
    that
      .scheduleAppointmentService(cmp)
      .appointmentApiRequest(params)
      .then(
        $A.getCallback(function(response) {
          /* response = JSON.parse(
            '{"slots":[{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT עש צווארי (CT) [721251]","startTime":"08:55","endTime":"09:05","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT עש צווארי (CT) [721251]","startTime":"10:00","endTime":"10:10","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT מח CT [70450]","startTime":"12:20","endTime":"12:30","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT מח CT [70450]","startTime":"12:30","endTime":"12:40","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT מח CT [70450]","startTime":"13:50","endTime":"14:00","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT עש מותני (CT) [72131]","startTime":"14:40","endTime":"14:50","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT חזה CT [71250]","startTime":"15:20","endTime":"15:30","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT עש מותני (CT) [72131]","startTime":"16:10","endTime":"16:20","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT חזה CT [71250]","startTime":"16:20","endTime":"16:30","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT פרק קרסול - CT [737002]","startTime":"16:40","endTime":"16:50","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT מח CT [70450]","startTime":"16:50","endTime":"17:00","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT עש צווארי (CT) [721251]","startTime":"17:10","endTime":"17:20","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT סינוסים - CT [70480]","startTime":"17:20","endTime":"17:30","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT בטן-CT [74150]","startTime":"17:30","endTime":"17:40","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT עש מותני (CT) [72131]","startTime":"17:40","endTime":"17:50","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT סינוסים - CT [70480]","startTime":"17:50","endTime":"18:00","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT בטן-CT [74150]","startTime":"18:00","endTime":"18:10","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT עש מותני (CT) [72131]","startTime":"18:10","endTime":"18:20","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT בטן-CT [74150]","startTime":"18:30","endTime":"18:40","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT עש מותני (CT) [72131]","startTime":"18:40","endTime":"18:50","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT חזה CT [71250]","startTime":"18:50","endTime":"19:00","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT בטן-CT [74150]","startTime":"19:00","endTime":"19:10","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT עש צווארי (CT) [721251]","startTime":"19:10","endTime":"19:20","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT מח CT [70450]","startTime":"19:20","endTime":"19:30","type":"פגישה"},{"calendarCode":"104","date":"2020-01-20","description":"באר שבע CT עש מותני (CT) [72131]","startTime":"19:30","endTime":"19:40","type":"פגישה"}],"timeGapInMiliSeconds":7200000}'
          ); */
          that.isLoading(cmp, false);
          var tableData = that.buildTableData(cmp, response.slots);
          that.tableData(cmp, tableData);
          var timeGap = response.timeGapInMiliSeconds;
          that.timeGap(cmp, timeGap);
          console.log(
            that.unProxyData({
              slots: response.slots,
              tableData: tableData,
              timeGapInSeconds: response.timeGapInMiliSeconds
            })
          );
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isLoading(cmp, false);
          that.errorMessage(cmp, that.buildHtmlServerError(err));
        })
      );
  },

  prepareSearchStep: function(cmp) {
    var that = this;
    that.selectedSlot(cmp, null);
  },
  prepareSelectStep: function(cmp) {
    var that = this;
    that.tableData(cmp, []);
    that.selectedSlot(cmp, null);
    that.searchSlots(cmp);
  },
  prepareEditStep: function(cmp) {
    var that = this;
  },
  rowSelectedHandler: function(cmp) {
    var slotsTable = this.slotsTableCmp(cmp);
    var editData = this.editData(cmp);
    /**@type {import('C30_SubmitForcedAppointmentModal').TableRow[]} */
    var selectedRows = slotsTable.getSelectedRows();
    var selectedRow = selectedRows[0];
    this.selectedSlot(cmp, selectedRow);
    editData.time = '';
    this.editData(cmp, editData);
  },
  siteChangedHandler: function(cmp) {
    this.resetCalendar(cmp);
  },
  procedureChangedHandler: function(cmp) {
    // this.resetCalendar(cmp);
  },
  resetCalendar: function(cmp) {
    var calendarAutocompleteCmp = this.calendarAutocompleteCmp(cmp);
    if (!calendarAutocompleteCmp) {
      return;
    }
    calendarAutocompleteCmp.reset();
    calendarAutocompleteCmp.triggerSearch();
  },
  fetchStaticData: function(cmp) {
    var that = this;     
    var recordId = that.recordId(cmp);
      
    var params = {
      actionName: 'getUrgentAppointmentFormData',
      recordId: recordId     
    };
    that.isLoading(cmp, true);
    return that
      .scheduleAppointmentService(cmp)
      .appointmentApiRequest(params)
      .then(
        $A.getCallback(function(
          /**@type {import('AppointmentsBase').StaticDataRes} */ staticDataRes
        ) {
          that.configData(cmp, staticDataRes);           
          that.isLoading(cmp, false);          
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
  
  configData: function(cmp, staticDataRes) {
    var that = this;               
    var editData = that.editData(cmp);
    var selectedOptions = that.selectedOptions(cmp);       
    var staticData = that.transformStaticDataRes(cmp, staticDataRes);

    var insurerFactorOptionsMap = staticData.insurerFactorOptionsMap;
    var insurerFactorOption =
      insurerFactorOptionsMap[staticData.accountInsurerFactor] ||
      staticData.insurerFactorOptions[0];

    selectedOptions.calendar = staticData.defaultCalendarOption;
    selectedOptions.procedure = staticData.defaultProcedureOption;
    selectedOptions.domain = staticData.defaultDomainOption;
    selectedOptions.urgentReason = staticData.defaultUrgentReasonOption;
    selectedOptions.site = staticData.defaultSiteOption;
    selectedOptions.insurerFactor = insurerFactorOption;

    var domain = selectedOptions.domain;
    var insurerFactor = selectedOptions.insurerFactor;
    var procedure = selectedOptions.procedure;
    var site = selectedOptions.site;
    var calendar = selectedOptions.calendar;
    var urgentReason = selectedOptions.urgentReason;
    if (domain) {
      editData.domain = domain.value;
    }
    if (insurerFactor) {
      editData.insurerFactor = insurerFactor.value;
    }
    if (procedure) {
      editData.procedure = procedure.value;
    }
    if (site) {
      editData.site = site.value;
    }
    if (calendar) {
      editData.calendar = calendar.value;
    }
    if (urgentReason) {
      editData.overbook = urgentReason.value;
    }    
    editData.startDate = staticData.formattedCurrentDate;
    this.editData(cmp, editData);
    this.selectedOptions(cmp, selectedOptions);
    this.staticData(cmp, staticData);
  },

  transformStaticDataRes: function(cmp, data) {
    var that = this;          
    var scheduleAppointmentService = that.scheduleAppointmentService(cmp);      
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

    var defaultDomainOption = scheduleAppointmentService.buildDomainOption(
      data.defaultDomain      
    );

    /**@type {import('ScheduleAppointmentService').UrgentReasonOption} */
    var defaultUrgentResonOption = scheduleAppointmentService.buildUrgentReasonOption(
      data.defaultUrgentReason
    );
    
    var existingAppointments = data.existingAppointmentList[0];
    var defaultProcedureOption = scheduleAppointmentService.buildProcedureOption(
      existingAppointments.Medical_Procedure__r      
    );    
    
    /**@type {import("AppointmentsBase").StaticData} */
    var staticData = {
      caseId: data.caseId,
      duration: data.duration,
      accountInsurerFactor: data.accountInsurerFactor,
      insurerFactorOptions: data.accountInsurerFactorValues,
      insurerFactorOptionsMap: insurerFactorOptionsMap,     
      urgentReasonOptions: urgentReasonOptions,
      urgentReasonOptionsMap: urgetReasonOptionsMap,      
      accountName: data.accountName,
      isAshdodEmloyee: data.isAshdodEmloyee,            
      accountPaitientId: data.accountPaitientId,
      accountPaitientIdType: data.accountPaitientIdType,
      accountPaitientEmail: data.accountPaitientEmail,      
      formattedCurrentDate: formattedCurrentDate,
      currentDate: currentDate,
      sitesMap: data.sitesMap || {},    
      defaultCalendarOption: defaultCalendarOption,
      defaultProcedureOption: defaultProcedureOption,      
      defaultSiteOption: defaultSiteOption,      
      defaultDomainOption: defaultDomainOption,
      defaultUrgentReasonOption: defaultUrgentResonOption,
      existingAppointmentList: data.existingAppointmentList           
    };
    return staticData;
  }
});