/**@type {import("LiveAgentChat").Helper} */
({
  init: function(cmp) {
    this.fetchFormData(cmp);
  },
  destroy: function(cmp) {},
  controllers: {
    LC_LiveAgent: 'LC_LiveAgentController'
  },
  CONSTANTS: {
    fieldNames: {
      subject: 'Case_subject__c',
      recordType: 'Case_Recordtype_TMP__c',
      subSubject: 'sub_case_subject__c'
    },
    chatFieldId: 'chatField'
  },
  /*  */
  preparedFieldCmps: function(cmp, value) {
    return this.attribute(cmp, 'fieldCmps', value);
  },
  formData: function(cmp, value) {
    return this.attribute(cmp, 'formData', value);
  },
  editData: function(cmp, value) {
    return this.attribute(cmp, 'editData', value);
  },
  currentStep: function(cmp, value) {
    return this.attribute(cmp, 'currentStep', value);
  },
  recordTypeFieldDef: function(cmp, value) {
    return this.attribute(cmp, 'recordTypeFieldDef', value);
  },
  /*  */
  prechatApiCmp: function(cmp) {
    return cmp.find('prechatAPI');
  },
  findFieldCmps: function(cmp) {
    return this.convertCmpsToArray(cmp.find(this.CONSTANTS.chatFieldId));
  },

  subjectFieldCmp: function(cmp) {
    return this.findField(cmp, this.CONSTANTS.fieldNames.subject);
  },
  subSubjectFieldCmp: function(cmp) {
    return this.findField(cmp, this.CONSTANTS.fieldNames.subSubject);
  },
  findField: function(cmp, fieldName) {
    var that = this;
    var fieldCmps = this.findFieldCmps(cmp);
    return fieldCmps.find(function(field) {
      var name = that.attribute(field, 'name');
      return name === fieldName;
    });
  },

  fetchFormData: function(cmp) {
    var that = this;
    var params = {
      actionName: 'getFormData'
    };
    console.log(params);
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_LiveAgent,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(
          /**@type {import('LiveAgentChat').FormData} */ formData
        ) {
          console.log(params, formData);
          that.formData(cmp, formData);
          that.config(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          return [];
        })
      );
  },
  config: function(cmp) {
    var that = this;
    var fieldNames = that.CONSTANTS.fieldNames;
    var formData = that.formData(cmp);
    var chatApiCmp = that.prechatApiCmp(cmp);
    /**@type {Aura.PrechatField} */
    var recordTypeFieldDef = null;
    var chatFields = chatApiCmp.getPrechatFields().filter(function(item) {
      if (item.name === fieldNames.recordType) {
        recordTypeFieldDef = item;
        return false;
      }
      return true;
    });
    console.log('before',chatFields);
    chatFields.forEach( field => field.label = that.nameToLabelMap[field.name] );

    console.log('after',chatFields);
    var editData = that.editData(cmp);
    editData.recordType = formData.recordTypesList[0].Id;
    that.editData(cmp, editData);
    that.recordTypeFieldDef(cmp, recordTypeFieldDef);
    console.log(chatFields);
    var preparedComponents = that.prepareFieldComponents(cmp, chatFields);
    $A.createComponents(preparedComponents, function(
      components,
      status,
      errorMessage
    ) {
      if (status === 'SUCCESS') {
        that.preparedFieldCmps(cmp, components);
        setTimeout(
          $A.getCallback(function() {
            that.recordTypeChangeHandler(cmp);
          })
        );
      } else {
        console.log(errorMessage);
      }
    });
  },
  nameToLabelMap: {
    'FirstName' : 'שם פרטי',
    'LastName' : 'שם משפחה',
    'Email': 'Email',
    'Phone': 'Phone',
    'Fax': 'Fax',
    'ID_Number__c':'ת.ז',
    'Case_subject__c':'נושא הפנייה',
    'sub_case_subject__c':'תת נושא הפנייה'
  },
  startChat: function(cmp) {
    var fieldCmps = this.findFieldCmps(cmp);
    var fields = this.createFieldsArray(cmp, fieldCmps);
    var chatApi = this.prechatApiCmp(cmp);
    var isFormValid = this.validate(cmp, fields, fieldCmps);
    console.log({
      fields: this.unProxyData(fields),
      fieldCmps: fieldCmps
    });
    if (!isFormValid) {
      console.warn('Prechat fields did not pass validation!');

      return;
    }
    chatApi.startChat(fields);
  },
  validate: function(cmp, fields, fieldCmps) {
    var that = this;
    var isValid = true;

    var chatValidation = this.prechatApiCmp(cmp).validateFields(fields);
    console.log({
      chatValidation: that.unProxyData(chatValidation)
    });
    isValid = fieldCmps.reduce(function(acc, fieldCmp) {
      if (typeof fieldCmp.showHelpMessageIfInvalid === 'function') {
        fieldCmp.showHelpMessageIfInvalid();
      }
      var validity = that.attribute(fieldCmp, 'validity');
      var isFieldValid = validity ? validity.valid : true;
      return acc && isFieldValid;
    }, isValid);
    return chatValidation.valid && isValid;
  },
  createFieldsArray: function(cmp, fieldCmps) {
    var that = this;
    var editData = that.editData(cmp);
    var recordTypeFieldDef = that.recordTypeFieldDef(cmp);
    /**@type {Aura.PrechatField[]} */
    var fields = [];
    if (fieldCmps.length > 0) {
      fields = fieldCmps.map(function(cmp) {
        var label = that.attribute(cmp, 'label');
        var name = that.attribute(cmp, 'name');
        var value = that.attribute(cmp, 'value');
        return {
          label: label,
          value: value,
          name: name
        };
      });
    }
    if (recordTypeFieldDef) {
      fields.push({
        label: recordTypeFieldDef.label,
        value: editData.recordType,
        name: recordTypeFieldDef.name
      });
    }
    return fields;
  },

  prepareFieldComponents: function(cmp, chatFields) {
    var fieldComponentNames = {
      input: 'lightning:input',
      select: 'lightning:select',
      customSelect: 'c:CustomLightningSelect',
      uiSelect: 'ui:inputSelect',
      combobox: 'lightning:combobox'
    };
    var fieldNames = this.CONSTANTS.fieldNames;
    var chatFieldId = this.CONSTANTS.chatFieldId;
    /**@type {Aura.CreateComponentDef[]} */
    var preparedCmpDefs = chatFields.map(function(field) {
      var componentName = fieldComponentNames.input;
      var classNames = [field.className, field.type];
      var fieldName = field.name;
      /**@type {Aura.ComponentAttrs} */
      var attributes = {
        'aura:id': chatFieldId,
        'autocomplete': 'off',
        'required': field.required,
        'label': field.label,
        'disabled': field.readOnly,
        'maxlength': field.maxLength,
        'name': fieldName,
        'type': 'text',
        'class': '',
        'value': field.value
      };
      if (fieldName === fieldNames.subject) {
        componentName = fieldComponentNames.customSelect;
        attributes.onchange = cmp.getReference('c.onFieldChange');
      } else if (fieldName === fieldNames.subSubject) {
        componentName = fieldComponentNames.customSelect;
      }
      attributes.class = classNames.join(' ');
      return [componentName, attributes];
    });
    return preparedCmpDefs;
  },
  fieldChangeHandler: function(cmp, fieldCmp) {
    var that = this;
    var fieldNames = that.CONSTANTS.fieldNames;
    var fieldName = that.attribute(fieldCmp, 'name');
    var fieldValue = that.attribute(fieldCmp, 'value');
    var formData = that.formData(cmp);
    console.log('fieldChangeHandler', {
      fieldName: fieldName,
      fieldValue: fieldValue
    });
    switch (fieldName) {
      case fieldNames.recordType: {
        return that.recordTypeChangeHandler(cmp);
      }
      case fieldNames.subject: {
        return handleSubject();
      }
    }

    function handleSubject() {
      var subSubjectFieldCmp = that.subSubjectFieldCmp(cmp);
      /**@type {import('LiveAgentChat').SubSubjectOption[]} */
      var subSubjectOptions = formData.subjectToSubSubjectMap[fieldValue] || [];
      var subSubjectValue = subSubjectOptions[0]
        ? subSubjectOptions[0].value
        : '';
      that.attribute(subSubjectFieldCmp, 'options', subSubjectOptions);
      that.attribute(subSubjectFieldCmp, 'value', subSubjectValue);
    }
  },
  recordTypeChangeHandler: function(cmp) {
    var that = this;
    var editData = that.editData(cmp);

    var formData = that.formData(cmp);
    var subjectFieldCmp = that.subjectFieldCmp(cmp);
    var subSubjectFieldCmp = that.subSubjectFieldCmp(cmp);

    /**@type {import('LiveAgentChat').SubjectOption[]} */
    var subjectOptions =
      formData.recordTypeToSubjectMap[editData.recordType] || [];
    var subjecValue = subjectOptions[0] ? subjectOptions[0].value : '';
    that.attribute(subjectFieldCmp, 'options', subjectOptions);
    that.attribute(subjectFieldCmp, 'value', subjecValue);

    /**@type {import('LiveAgentChat').SubSubjectOption[]} */
    var subSubjectOptions = formData.subjectToSubSubjectMap[subjecValue];
    var subSubjectValue = subSubjectOptions[0]
      ? subSubjectOptions[0].value
      : '';

    that.attribute(subSubjectFieldCmp, 'options', subSubjectOptions);
    that.attribute(subSubjectFieldCmp, 'value', subSubjectValue);
  },
  nextStep: function(cmp) {
    this.currentStep(cmp, 2);
  }
});