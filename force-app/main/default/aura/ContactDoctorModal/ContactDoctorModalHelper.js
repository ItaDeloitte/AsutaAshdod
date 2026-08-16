/**@type {import("ContactDoctorModal").Helper} */
({
  init: function(cmp) {
    this.fetchStaticData(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},

  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },
  staticData: function(cmp, value) {
    return this.attribute(cmp, 'staticData', value);
  },
  editData: function(cmp, value) {
    return this.attribute(cmp, 'editData', value);
  },
  doctorData: function(cmp, value) {
    return this.attribute(cmp, 'doctorData', value);
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

  stepFieldCmps: function(cmp, stepId) {
    return this.convertCmpsToArray(cmp.find('step' + stepId + 'Field'));
  },
  doctorAutocompleteCmp: function(cmp) {
    var that = this;
    var stepFieldsCmps = that.stepFieldCmps(cmp, '1');
    return stepFieldsCmps.find(function(fieldCmp) {
      return that.attribute(fieldCmp, 'name') === 'doctor';
    });
  },
  overlayLibCmp: function(cmp) {
    return cmp.find('overlayLib');
  },

  close: function(cmp) {
    var overlayLibCmp = this.overlayLibCmp(cmp);
    overlayLibCmp.notifyClose();
  },

  cancel: function(cmp) {
    this.close(cmp);
  },

  fetchStaticData: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var params = {
      actionName: 'getContactDoctorData',
      recordId: recordId
    };
    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    that
      .lcCase360Request(cmp, params)
      .then(
        $A.getCallback(function(
          /**@type {import('ContactDoctorModal').StaticDataRes}*/ data
        ) {
          that.isLoading(cmp, false);
          that.config(cmp, data);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isLoading(cmp, false);
          that.serverError(cmp, that.buildHtmlServerError(err));
        })
      );
  },

  config: function(cmp, data) {
    this.configSteps(cmp);
    var defaultDoctorOption = this.buildDoctorOption(data.defaultDoctor);
    data.quickTexts = data.quickTexts || [];
    var quickTextsMap = data.quickTexts.reduce(function(acc, item) {
      acc[item.Id] = item;
      return acc;
    }, {});
    /**@type {import('ContactDoctorModal').StaticData} */
    var staticData = {
      contactMethods: [
        {
          label: $A.get('$Label.c.Call'),
          value: 'call'
        },
        {
          label: $A.get('$Label.c.SMS'),
          value: 'sms'
        },
        {
          label: $A.get('$Label.c.Email'),
          value: 'email'
        }
      ],
      defaultDoctorOption: defaultDoctorOption,
      quickTexts: data.quickTexts,
      quickTextsMap: quickTextsMap,
      doctors: data.doctors
    };
    this.staticData(cmp, staticData);
    var doctorAutocompleteCmp = this.doctorAutocompleteCmp(cmp);
    if (defaultDoctorOption && doctorAutocompleteCmp) {
      doctorAutocompleteCmp.setOption(staticData.defaultDoctorOption);
      this.fetchDoctorData(cmp);
    }
    console.log(staticData);
  },

  configSteps: function(cmp) {
    var steps = this.buildSteps(cmp);
    this.steps(cmp, steps);
    var currentStepIndex = 0;
    this.currentStepIndex(cmp, currentStepIndex);
    this.currentStep(cmp, steps[currentStepIndex]);
  },
  buildSteps: function(cmp) {
    /**@type {import('ContactDoctorModal').Step[]} */
    var steps = [
      { id: '1', label: $A.get('$Label.c.Select_Doctor') },
      { id: '2', label: $A.get('$Label.c.Contact_Method') },
      { id: '3', label: $A.get('$Label.c.Details') }
    ];
    return steps;
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
    }
  },
  prevStep: function(cmp) {
    this.serverError(cmp, '');
    var steps = this.steps(cmp);
    var currentStepIndex = this.currentStepIndex(cmp);
    if (currentStepIndex === 0) {
      return;
    }
    currentStepIndex -= 1;
    this.currentStepIndex(cmp, currentStepIndex);
    this.currentStep(cmp, steps[currentStepIndex]);
  },
  moveToStep: function(cmp, stepIndex) {
    var steps = this.steps(cmp);
    if (stepIndex >= 0 && stepIndex < steps.length) {
      var targetStep = steps[stepIndex];
      this.currentStepIndex(cmp, stepIndex);
      this.currentStep(cmp, targetStep);
    }
  },
  validateStep: function(cmp, stepId) {
    var validateMethodName = 'validateStep' + stepId;
    if (typeof this[validateMethodName] !== 'function') {
      return false;
    }
    return this[validateMethodName](cmp, stepId);
  },
  validateStepInputs: function(cmp, stepId) {
    var that = this;
    var isValid = true;
    var stepFieldCmps = this.stepFieldCmps(cmp, stepId);
    stepFieldCmps.forEach(function(fieldCmp) {
      var value;
      var isCustomValid = true;
      var customMessage = '';
      var name = that.attribute(fieldCmp, 'name');
      switch (name) {
        case 'email': {
          value = that.attribute(fieldCmp, 'value');
          isCustomValid = that.validateEmail(value);
          customMessage = isCustomValid
            ? ''
            : $A.get('$Label.c.Email_is_not_valid');
          break;
        }
        case 'phone': {
          value = that.attribute(fieldCmp, 'value');
          isCustomValid = that.validatePhone(value);
          customMessage = isCustomValid
            ? ''
            : $A.get('$Label.c.Phone_is_not_valid');
          break;
        }
      }
      if (typeof fieldCmp.setCustomValidity === 'function') {
        fieldCmp.setCustomValidity(customMessage);
      }

      fieldCmp.showHelpMessageIfInvalid();
      var validity = that.attribute(fieldCmp, 'validity');
      if (validity) {
        isValid = isValid && validity.valid;
      }
    });
    return isValid;
  },

  validateStep1: function(cmp, stepId) {
    var isValid = true;
    isValid = this.validateStepInputs(cmp, stepId);
    return isValid;
  },
  validateStep2: function(cmp, stepId) {
    var isValid = true;
    isValid = this.validateStepInputs(cmp, stepId);
    return isValid;
  },
  validateStep3: function(cmp, stepId) {
    var isValid = true;
    isValid = this.validateStepInputs(cmp, stepId);
    return isValid;
  },

  validateEmail: function(email) {
    // eslint-disable-next-line no-useless-escape
    var re = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
    return re.test(String(email).toLowerCase());
  },

  validatePhone: function(phone) {
    var re = /^\+?\d{7,}$/;
    return re.test(String(phone));
  },

  submit: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var editData = that.editData(cmp);
    var contactMethod = editData.contactMethod;
    var params = {
      actionName: 'contactDoctor',
      recordId: recordId,
      doctorId: editData.doctorId,
      text: '',
      phone: '',
      email: '',
      saveInfo: false
    };
    switch (contactMethod) {
      case 'sms': {
        params.phone = editData.phone;
        params.text = editData.smsText;
        params.saveInfo = editData.savePhone;
        break;
      }
      case 'email': {
        params.email = editData.email;
        params.text = editData.emailText;
        params.saveInfo = editData.saveEmail;
        break;
      }
      default: {
        that.close(cmp);
        return;
      }
    }

    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    that
      .lcCase360Request(cmp, params)
      .then(
        $A.getCallback(function(message) {
          that.isLoading(cmp, false);
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: message
          });
          that.close(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isLoading(cmp, false);
          that.serverError(cmp, that.buildHtmlServerError(err));
        })
      );
  },

  lcCase360Request: function(cmp, params) {
    var that = this;
    console.log(params);
    return that
      .executeApex(cmp, {
        controllerName: 'LC_Case360Controller',
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(function(res) {
        console.log(params, res);
        return res;
      })
      .catch(function(err) {
        console.log(err);
        throw err;
      });
  },
  doctorSelectHandler: function(cmp) {
    var editData = this.editData(cmp);
    this.doctorData(cmp, null);
    this.resetEditData(cmp);
    if (!editData.doctorId) {
      return;
    }
    this.fetchDoctorData(cmp);
  },
  fetchDoctorData: function(cmp) {
    var that = this;
    var editData = that.editData(cmp);
    var params = {
      actionName: 'getDoctorInfo',
      doctorId: editData.doctorId
    };
    that.doctorData(cmp, null);
    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    that
      .lcCase360Request(cmp, params)
      .then(
        $A.getCallback(function(data) {
          that.isLoading(cmp, false);
          var doctorData = that.buildDoctorData(data);
          that.doctorData(cmp, doctorData);
          editData.email = doctorData.defaultEmail || '';
          editData.phone = doctorData.defaultPhoneNumber || '';
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.serverError(cmp, that.buildHtmlServerError(err));
          that.isLoading(cmp, false);
        })
      );
  },
  buildDoctorData: function(data) {
    /**@type {import('ContactDoctorModal').DoctorData} */
    var doctorData = {
      clinics: data.clinics.map(function(clinic) {
        return clinic.Clinic__r;
      }),
      contacts: data.contacts,
      defaultEmail: data.defaultEmail,
      defaultPhoneNumber: data.defaultPhoneNumber,
      doctor: data.doctor,
      emails: data.emails,
      phoneNumbers: data.phoneNumbers
    };
    return doctorData;
  },
  searchEmails: function(cmp, term) {
    var doctorData = this.doctorData(cmp);
    var emails = doctorData.emails || [];
    var results = emails
      .filter(function(item) {
        return item.toLowerCase().indexOf(term) == 0;
      })
      .map(function(item) {
        return { label: item, value: item };
      });
    return Promise.resolve(results);
  },
  searchPhones: function(cmp, term) {
    var doctorData = this.doctorData(cmp);
    var phones = doctorData.phoneNumbers || [];
    var results = phones
      .filter(function(item) {
        return item.toLowerCase().indexOf(term) == 0;
      })
      .map(function(item) {
        return { label: item, value: item };
      });
    return Promise.resolve(results);
  },

  searchDoctors: function(cmp, term) {
    var that = this;
    var params = {
      actionName: 'doctorSearch',
      keyWord: term
    };
    return that
      .lcCase360Request(cmp, params)
      .then(function(data) {
        var doctorOptions = data.map(function(item) {
          return that.buildDoctorOption(item);
        });
        return doctorOptions;
      })
      .catch(function(err) {
        return [];
      });
  },

  resetEditData: function(cmp) {
    var editData = this.editData(cmp);
    editData = Object.assign({}, editData, {
      email: '',
      emailText: '',
      phone: '',
      smsText: '',
      savePhone: false,
      saveEmail: false
    });
    this.editData(cmp, editData);
  },
  autocompleteChangedHandler: function(cmp, autocompleteCmp) {
    var name = this.attribute(autocompleteCmp, 'name');
    autocompleteCmp.setCustomValidity('');
    autocompleteCmp.showHelpMessageIfInvalid();
    if (name === 'doctor') {
      var editData = this.editData(cmp);
      this.doctorData(cmp, null);
      this.resetEditData(cmp);
      if (!editData.doctorId) {
        return;
      }
      this.fetchDoctorData(cmp);
    }
  },
  buildDoctorOption: function(data) {
    if (!data) {
      return null;
    }
    /**@type {import('ContactDoctorModal').DoctorOption} */
    var option = Object.assign({}, data, { value: data.Id, label: data.Name });
    return option;
  },
  selectQuickTextHandler: function(cmp, textId) {
    if (!textId) {
      return;
    }
    var staticData = this.staticData(cmp);
    var quickTextObj = staticData.quickTextsMap[textId];
    if (!quickTextObj) {
      return;
    }
    var editData = this.editData(cmp);
    switch (editData.contactMethod) {
      case 'sms': {
        editData.smsText = quickTextObj.Message;
        break;
      }
      case 'email': {
        editData.emailText = quickTextObj.Message;
        break;
      }
    }
    this.editData(cmp, editData);
  }
});