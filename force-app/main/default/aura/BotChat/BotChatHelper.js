({
  init: function(cmp) {
    this.config(cmp);
  },
  destroy: function(cmp) {},
  controllers: {
    ChatBot: "Bot_ChatbotController"
  },
  CONSTANTS: {
    fieldNames: {
      firstName: "First Name",
      lastName: "Last Name",
      phone: "Phone"
    },
    chatFieldId: "chatField"
  },
  /*  */
  preparedFieldCmps: function(cmp, value) {
    return this.attribute(cmp, "fieldCmps", value);
  },
  /*  */
  prechatApiCmp: function(cmp) {
    return cmp.find("prechatAPI");
  },
  findFieldCmps: function(cmp) {
    return this.convertCmpsToArray(cmp.find(this.CONSTANTS.chatFieldId));
  },
  findField: function(cmp, fieldName) {
    var that = this;
    var fieldCmps = this.findFieldCmps(cmp);
    return fieldCmps.find(function(field) {
      var name = that.attribute(field, "name");
      return name === fieldName;
    });
  },
  fetchPatientSearch: function(cmp, fields, cb) {
    var that = this;
    var firstName, lastName, phone;
    fields.forEach(function(field) {
      if (field.name === "FirstName") {
        firstName = field.value;
      }
      if (field.name === "LastName") {
        lastName = field.value;
      }
      if (field.name === "Phone") {
        phone = field.value;
      }
    });
    var params = {
      actionName: "patientSearch",
      firstName: firstName,
      lastName: lastName,
      phone: phone
    };
    console.log(params);
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.ChatBot,
        params: params
      })
      .then(
        $A.getCallback(function(response) {
          console.log(params, response);
          fields.forEach(function(field) {
            if (field.name === "Account_ID_TMP__c") {
              field.value = response.responseObj;
            }
          });
          cb();
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
    var chatApiCmp = that.prechatApiCmp(cmp);
    /**@type {Aura.PrechatField} */
    var chatFields = chatApiCmp.getPrechatFields();
    console.log("before", chatFields);
    chatFields.forEach(function(field) {
      if (that.nameToLabelMap) {
        field.label = that.nameToLabelMap[field.name];
      }
    });
    console.log("after", chatFields);

    var preparedComponents = that.prepareFieldComponents(cmp, chatFields);
    $A.createComponents(preparedComponents, function(
      components,
      status,
      errorMessage
    ) {
      if (status === "SUCCESS") {
        that.preparedFieldCmps(cmp, components);
      } else {
        console.log(errorMessage);
      }
    });
  },
  // nameToLabelMap: {
  //   FirstName: "שם פרטי",
  //   LastName: "שם משפחה",
  //   Phone: "Phone"
  // },
  startChat: function(cmp) {
    var that = this;
    var fieldCmps = this.findFieldCmps(cmp);
    var fields = this.createFieldsArray(cmp, fieldCmps);
    var chatApi = this.prechatApiCmp(cmp);
    var isFormValid = this.validate(cmp, fields, fieldCmps);
    console.log({
      fields: this.unProxyData(fields),
      fieldCmps: fieldCmps
    });
    if (!isFormValid) {
      console.warn("Prechat fields did not pass validation!");
      return;
    }

    var cb = function() {
      chatApi.startChat(fields);
    };
    that.fetchPatientSearch(cmp, fields, cb);
  },
  validate: function(cmp, fields, fieldCmps) {
    var that = this;
    var isValid = true;

    var chatValidation = this.prechatApiCmp(cmp).validateFields(fields);
    console.log({
      chatValidation: that.unProxyData(chatValidation)
    });

    isValid = fieldCmps.reduce(function(acc, fieldCmp) {
      if (typeof fieldCmp.showHelpMessageIfInvalid === "function") {
        fieldCmp.showHelpMessageIfInvalid();
      }
      var validity = that.attribute(fieldCmp, "validity");
      var isFieldValid = validity ? validity.valid : true;
      return acc && isFieldValid;
    }, isValid);

    return chatValidation.valid && isValid;
  },
  createFieldsArray: function(cmp, fieldCmps) {
    var that = this;
    /**@type {Aura.PrechatField[]} */
    var fields = [];
    if (fieldCmps.length > 0) {
      fields = fieldCmps.map(function(cmp) {
        var label = that.attribute(cmp, "label");
        var name = that.attribute(cmp, "name");
        var value = that.attribute(cmp, "value");
        return {
          label: label,
          value: value,
          name: name
        };
      });
    }
    return fields;
  },

  prepareFieldComponents: function(cmp, chatFields) {
    var fieldComponentNames = {
      inputSplitName: "lightning:input",
      inputPhone: "lightning:input",
      inputText: "lightning:input"
    };
    var fieldNames = this.CONSTANTS.fieldNames;
    var chatFieldId = this.CONSTANTS.chatFieldId;
    /**@type {Aura.CreateComponentDef[]} */
    var preparedCmpDefs = chatFields.map(function(field) {
      var fieldType = field.type;
      var componentName = fieldComponentNames[fieldType];
      var classNames = [field.className, fieldType];
      var fieldName = field.name;

      /**@type {Aura.ComponentAttrs} */
      var attributes = {
        "aura:id": chatFieldId,
        autocomplete: "off",
        required: field.required,
        label: field.label,
        disabled: field.readOnly,
        maxlength: field.maxLength,
        name: fieldName,
        type: "text",
        class: "",
        value: field.value
      };
      attributes.class = classNames.join(" ");
      if (fieldName === "Account_ID_TMP__c") {
        attributes.class += " hide";
      }

      return [componentName, attributes];
    });
    console.log("Prepared", preparedCmpDefs);
    return preparedCmpDefs;
  }
});