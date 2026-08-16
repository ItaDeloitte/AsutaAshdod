/**@type {import("PatientDetailsModal").Helper} */
({
  init: function(cmp) {
    this.configLabels(cmp);
    this.configSteps(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {
    var isRendered = this.isRendered(cmp);
    if (isRendered) {
      return;
    }
    this.isRendered(cmp, true);
    this.checkModalData(cmp);
  },
  controllers: {
    LC_PatientDetails: 'LC_PatientDetailsController'
  },
  CONSTANTS: {},

  modalParams: function(cmp, value) {
    return this.attribute(cmp, 'modalParams', value);
  },
  showSensitivitiesInfo: function(cmp, value) {
    return this.attribute(cmp, 'showSensitivitiesInfo', value);
  },
  schParameterRows: function(cmp, value) {
    return this.attribute(cmp, 'schParameterRows', value);
  },
  patientId: function(cmp, value) {
    return this.attribute(cmp, 'patientId', value);
  },
  idType: function(cmp, value) {
    return this.attribute(cmp, 'idType', value);
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
  step1FieldCmps: function(cmp) {
    return this.convertCmpsToArray(cmp.find('step1Field'));
  },
  editData: function(cmp, value) {
    return this.attribute(cmp, 'editData', value);
  },
  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },
  selectedOptions: function(cmp, value) {
    return this.attribute(cmp, 'selectedOptions', value);
  },
  messageInfo: function(cmp, value) {
    return this.attribute(cmp, 'messageInfo', value);
  },
  actionInfo: function(cmp, value) {
    return this.attribute(cmp, 'actionInfo', value);
  },
  configLabels: function(cmp) {
    var customLabels = this.getCustomLabels();
    this.labels(cmp, customLabels);
  },
  getCustomLabels: function() {
    return {
      Cancel: $A.get('$Label.c.Cancel'),
      Back: $A.get('$Label.c.Back'),
      Next: $A.get('$Label.c.Next'),
      Submit: $A.get('$Label.c.Submit'),
      Asthma: $A.get('$Label.c.Asthma'),
      MetalsInBody: $A.get('$Label.c.MetalsInBody'),
      IodineSensitivity: $A.get('$Label.c.IodineSensitivity'),
      Diabetic: $A.get('$Label.c.Diabetic'),
      Dust: $A.get('$Label.c.Dust'),
      BloodDilution: $A.get('$Label.c.BloodDilution'),
      Weight: $A.get('$Label.c.Weight'),
      Gender: $A.get('$Label.c.Gender'),
      CompleteThisField: $A.get('$Label.c.Complete_this_field')
    };
  },
  configSteps: function(cmp) {
    /**@type {import('PatientDetailsModal').Step[]} */
    var steps = [
      { id: 'sensitivities', label: 'Sensitivities' },
      { id: 'message', label: 'Message' }
    ];
    this.steps(cmp, steps);
    var currentStepIndex = 0;
    this.currentStepIndex(cmp, currentStepIndex);
    this.currentStep(cmp, steps[currentStepIndex]);
  },
  validateStep: function(cmp, stepId) {
    if(stepId == 'sensitivities'){
        return this.validateSensitivitiesStep(cmp);
      }
      return true;
  },
  validateSensitivitiesStep: function(cmp) {
    var that = this;
    var isValid = true;
    var stepFields = that.step1FieldCmps(cmp);
    stepFields.forEach(function(fieldCmp) {
      fieldCmp.showHelpMessageIfInvalid();
      var validity = that.attribute(fieldCmp, 'validity');
      if (validity) {
        isValid = isValid && validity.valid;
      }
    });
    return isValid;
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
      this.getMessage(cmp);
      currentStepIndex += 1;
      this.currentStepIndex(cmp, currentStepIndex);
      this.currentStep(cmp, steps[currentStepIndex]);
      
    }
  },
  prevStep: function(cmp) {
    this.serverError(cmp, '');
    var steps = this.steps(cmp);
    var stepIndex = this.currentStepIndex(cmp);
    if (stepIndex === 0) {
      return;
    }
    stepIndex -= 1;
    this.currentStepIndex(cmp, stepIndex);
    this.currentStep(cmp, steps[stepIndex]);
  },
  moveToStep: function(cmp, stepIndex) {
    var steps = this.steps(cmp);
    if (stepIndex >= 0 && stepIndex < steps.length) {
      var targetStep = steps[stepIndex];
      this.currentStepIndex(cmp, stepIndex);
      this.currentStep(cmp, targetStep);
    }
  },
  checkModalData: function(cmp) {
    var that = this;
    var modalParams = that.modalParams(cmp);
    var modalData = modalParams.modalData;
    var patientId = modalData.patientId || '';
    var idType = modalData.idType || '';
    var showSensitivitiesInfo = modalData.showSensitivitiesInfo;
    var schParameterRows = modalData.schParameters;
    that.patientId(cmp, patientId);
    that.idType(cmp, idType);
    that.showSensitivitiesInfo(cmp, showSensitivitiesInfo);
    that.schParameterRows(cmp, schParameterRows);
    that.fetchStaticData(cmp);
  },

  fetchStaticData: function(cmp) {
    var that = this;
    var patientId = that.patientId(cmp);
    var idType = that.idType(cmp);
    var params = {
      actionName: 'getPatientDetails',
      patientId: patientId,
      idType: idType
    };
    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    return that
      .executeApex(cmp, {
      controllerName: that.controllers.LC_PatientDetails,
      params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
      $A.getCallback(function(
          /**@type {import('AppointmentsBase').StaticDataRes} */ staticDataRes
      ) {
          that.isLoading(cmp, false);
          that.config(cmp, staticDataRes);
          //that.moveToStep(cmp, 1);
      })
      )
      .catch(
      $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
          that.serverError(cmp, that.buildHtmlServerError(err));
      })
    );
  },

  config: function(cmp, staticDataRes) {
    var that = this;
    var staticData = that.transformStaticDataRes(staticDataRes);
    var editData = that.editData(cmp);
    var selectedOptions = that.selectedOptions(cmp);
      
      /**@type {import('PatientDetailsModal').editData} */ editData
    editData = {
      asthma: staticData.defaultAsthma,
      metalsInBody: staticData.defaultMetalsInBody,
      iodineSensitivity: staticData.defaultIodineSensitivity,
      diabetic: staticData.defaultDiabetic,
      dust: staticData.defaultDust,
      bloodDilution: staticData.defaultBloodDilution,
      weight: staticData.defaultWeight,
      gender: staticData.defaultGender,
    };

    selectedOptions = {
      asthma: staticData.asthmaOptionsMap,
      metalsInBody: staticData.metalsInBodyOptionsMap,
      iodineSensitivity: staticData.iodineSensitivityOptionsMap,
      diabetic: staticData.diabeticOptionsMap,
      dust: staticData.dustOptionsMap,
      bloodDilution: staticData.bloodDilutionOptionsMap,
      weight: staticData.weightOptionsMap,
      gender: staticData.genderOptionsMap,
    };

    that.selectedOptions(cmp, selectedOptions);
    that.editData(cmp, editData);
    that.staticData(cmp, staticData);
  },

  transformStaticDataRes: function(data) {
    /**@type {import("AppointmentsBase").StaticData} */
    var staticData = {
        asthmaOptionsMap: data.asthmaOptions,
        metalsInBodyOptionsMap: data.metalsInBodyOptions,
        iodineSensitivityOptionsMap: data.iodineSensitivityOptions,
        diabeticOptionsMap: data.diabeticOptions,
        dustOptionsMap: data.dustOptions,
        bloodDilutionOptionsMap: data.bloodDilutionOptions,
        weightOptionsMap: data.weightOptions,
        genderOptionsMap: data.genderOptions,
        defaultProtocolOption: data.defaultProtocol,
        defaultAsthma: data.defaultAsthma,
        defaultMetalsInBody: data.defaultMetalsInBody,
        defaultIodineSensitivity: data.defaultIodineSensitivity,
        defaultDiabetic: data.defaultDiabetic,
        defaultDust: data.defaultDust,
        defaultBloodDilution: data.defaultBloodDilution,
        defaultWeight: data.defaultWeight,
        defaultGender: data.defaultGender,
        accountName: data.accountName
    }
    return staticData;
  },

  cancelHandler: function(cmp) {
    this.emitCloseModal(cmp);
  },

  emitCloseModal: function(cmp, result) {
    var modalParams = this.modalParams(cmp);
    modalParams.resolvers.close(result);
    this.close(cmp);
  },

  submit: function(cmp) {
    var that = this;
    var editData = that.editData(cmp);
    var patientId = that.patientId(cmp);
    var idType = that.idType(cmp);
    var actionInfo = that.actionInfo(cmp);

    var params = {
      actionName: 'setPatientDetails',
      patientId: patientId,
      idType: idType,
      sensitivitiesData: editData
    };
    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_PatientDetails,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          console.log(params, res);
          that.isLoading(cmp, false);
          that.refreshView();
          that.emitCloseModal(cmp, actionInfo);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
          that.serverError(cmp, that.buildHtmlServerError(err));
        })
      );
  },

  getMessage: function(cmp) {
    var that = this;
    var sensitivitiesData = that.editData(cmp);
    var schParameterRows = that.schParameterRows(cmp);
    var previewText = '';
    var actionInfo = {};
    
    schParameterRows.forEach(i => {
      if((i.Metals_In_Body__c == undefined || ((i.Metals_In_Body__c.split(';')).some(arry => sensitivitiesData.metalsInBody.includes(arry)))) &&
         (i.Weight__c == undefined || (i.Weight__c.split(';')).includes(sensitivitiesData.weight)) &&
         (i.Dust__c == undefined || (i.Dust__c.split(';')).includes(sensitivitiesData.dust)) &&
         (i.Diabetes__c == undefined || (i.Diabetes__c.split(';')).includes(sensitivitiesData.diabetic)) &&
         (i.Blood_Thinning_Pills__c == undefined || (i.Blood_Thinning_Pills__c.split(';')).includes(sensitivitiesData.bloodDilution)) &&
         (i.Gender__c == undefined || i.Gender__c == sensitivitiesData.gender) &&
         (i.Asthma__c == undefined || (i.Asthma__c.split(';')).includes(sensitivitiesData.asthma)) &&
         (i.Iodine_Sensitivity__c == undefined || (i.Iodine_Sensitivity__c.split(';')).includes(sensitivitiesData.iodineSensitivity))){
          previewText = i.Preview_Text__c != undefined ? i.Preview_Text__c : "";
          var actType = i.Action_Type__c != undefined ? i.Action_Type__c : "";
          actionInfo.actionType = actType == 'מניעת זימון' ? 'preventAppointment' :
          actType == 'הודעת אזהרה' ? 'message':
          actType == 'מניעת זימון ושינוי בעלים' ? 'changeOwner':
          actType == 'מתאריך' ? 'changeFromDate':
          actType == 'חיפוש לפי יומן' ? 'scheduleByCalendar': '';

          switch (actionInfo.actionType) {   
            case 'message': {
              actionInfo.fromHour = i.FromHour__c != undefined ? i.FromHour__c : "";
              actionInfo.toHour = i.ToHour__c != undefined ? i.ToHour__c : "";
              break;
            }                                                 
            case 'changeOwner': {
              actionInfo.ownerForTransfer = i.Owner_For_Transfer__c != undefined ? i.Owner_For_Transfer__c : "";
              break;
            }
            case 'changeFromDate': {
              actionInfo.days = i.From_Date__c != undefined ? i.From_Date__c : "";
              actionInfo.fromHour = i.FromHour__c != undefined ? i.FromHour__c : "";
              actionInfo.toHour = i.ToHour__c != undefined ? i.ToHour__c : "";
              break;
            }
            case 'scheduleByCalendar': {
              actionInfo.calendar = i.Calendar__r.ServiceId__c != undefined ? i.Calendar__r.ServiceId__c : "";
              actionInfo.fromHour = i.FromHour__c != undefined ? i.FromHour__c : "";
              actionInfo.toHour = i.ToHour__c != undefined ? i.ToHour__c : "";
            }
          }
        }
    });
    that.messageInfo(cmp, previewText);
    that.actionInfo(cmp, actionInfo);

    if(previewText == ''){
      return this.submit(cmp);
    }
  }
})