/**@type {import("SearchAccount").Helper} */
({
  init: function(cmp) {},
  destroy: function(cmp) {},
  controllers: {
    demography: 'LC_Demography'
  },
  CONSTANTS: {
    fieldNames: {
      idType: 'idType',
      idNumber: 'idNumber'
    },
    minSearchLength: 2
  },

  getLabels: function() {
    return {
      Person_Id_is_incorrect: $A.get('$Label.c.Person_Id_is_incorrect')
    };
  },

  utilityBarCmp: function(cmp) {
    return cmp.find('utilitybar');
  },

  data: function(cmp, value) {
    return this.attribute(cmp, 'data', value);
  },
  selectedAccountOption: function(cmp, value) {
    return this.attribute(cmp, 'selectedAccountOption', value);
  },
  queryLimit: function(cmp, value) {
    return this.attribute(cmp, 'queryLimit', value);
  },
  formFieldCmps: function(cmp) {
    return this.convertCmpsToArray(cmp.find('formField'));
  },
  idNumberFieldCmp: function(cmp) {
    var that = this;
    var formFieldCmps = that.formFieldCmps(cmp);
    return formFieldCmps.find(function(item) {
      var name = that.attribute(item, 'name');
      return name === 'idNumber';
    });
  },
  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },

  submit: function(cmp) {
    var that = this;
    var data = that.data(cmp);
    var selectedAccountOption = that.selectedAccountOption(cmp);
    var isFormValid = that.validateForm(cmp);
    that.serverError(cmp, '');
    if (!isFormValid) {
      return;
    }
    var createAccEvent = $A.get(
      that.BASE_CONSTANTS.forceEventTypes.createRecord
    );
    var personIdType = selectedAccountOption
      ? selectedAccountOption.ID_Type__c
      : '';
    var params = {
      actionName: 'retriveAccount',
      personIdType: personIdType,
      personId: data.idNumber
    };
    that.isLoading(cmp, true);
    that
      .executeApex(cmp, {
        controllerName: that.controllers.demography,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(function(res) {
        if (res.isAccountExist) {
          return res;
        }
        res.accountData = JSON.parse(res.accountData);
        return res;
      })
      .then(
        $A.getCallback(function(accountRes) {
          that.isLoading(cmp, false);
          var accountData = accountRes.accountData;
          if (
            !accountRes.isAccountExist &&
            typeof accountRes.accountData === 'object'
          ) {
            that.hideUtilityBar(cmp);
            that.emitAccountCreationForm(
              createAccEvent,
              accountRes.accountData
            );
          }
          if (typeof accountData === 'string') {
            that.navigateToAccount(cmp, accountData);
          }
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isLoading(cmp, false);
          that.showServerError(cmp, err);
        })
      );
  },

  searchAccounts: function(cmp, term) {
    var that = this;
    var queryLimit = that.queryLimit(cmp);
    if (term.length < that.CONSTANTS.minSearchLength) {
      return Promise.resolve([]);
    }
    var params = {
      actionName: 'autocompleteAccount',
      queryLimit: queryLimit,
      personIdentifier: term
    };
    that.serverError(cmp, '');
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.demography,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(function(accountsRes) {
        var accounts = that.transformAccountsRes(accountsRes);
        return accounts;
      })
      .catch(
        $A.getCallback(function(err) {
          that.showServerError(cmp, err);
          return [];
        })
      );
  },

  transformAccountsRes: function(res) {
    var that = this;
    return res.map(function(item) {
      return Object.assign({}, item, {
        label: item.ID_Number__c,
        labelHtml: that.buildOptionTemplate(item),
        value: item.ID_Number__c
      });
    });
  },

  buildOptionTemplate: function(option) {
    return (
      '<div class="account-option">' +
      this.buildOptionLabel($A.get('{!$Label.c.ID_Number}'), option.ID_Number__c) +
      this.buildOptionLabel($A.get('{!$Label.c.ID_Type}'), option.ID_Type__c) +
      this.buildOptionLabel($A.get('{!$Label.c.Name}'), option.Name) +
      this.buildOptionLabel($A.get('{!$Label.c.Phone}'), option.Phone) +
      '</div>'
    );
  },

  buildOptionLabel: function(labelName, value) {
    value = value || '';
    return (
      '<div class="slds-grid">' +
      '<span class="account-option__label">' +
      labelName +
      ':&nbsp;</span> ' +
      value +
      '</div>'
    );
  },

  validateForm: function(cmp) {
    var isValid = true;
    var fieldCmps = this.formFieldCmps(cmp);
    fieldCmps.forEach(function(fieldCmp) {
      var isFieldValid = fieldCmp.checkValidity();
      fieldCmp.showHelpMessageIfInvalid();
      isValid = isValid && isFieldValid;
    });
    return isValid;
  },

  emitAccountCreationForm: function(event, accountData) {
    delete accountData.attributes;
    var params = {
      entityApiName: 'Account',
      recordTypeId: accountData.RecordTypeId,
      defaultFieldValues: accountData
    };
    this.closeQuickAction();

    event.setParams(params);

    event.fire();
  },
  showServerError: function(cmp, err) {
    console.log(err);
    var errMessage = this.buildHtmlServerError(err);
    this.serverError(cmp, errMessage);
  },
  cancel: function(cmp) {
    this.refreshView();
    var pageType = this.BASE_CONSTANTS.navigationTypes.objectPage;
    var pageReference = {
      type: pageType,
      attributes: {
        objectApiName: 'Account',
        actionName: 'list'
      },
      state: {
        filterName: 'MyAccounts'
      }
    };
    this.navigate(cmp, pageReference);
  },
  checkAccountOption: function(cmp) {
    var selectedAccountOption = this.selectedAccountOption(cmp);
    var data = this.data(cmp);
    if (
      selectedAccountOption &&
      selectedAccountOption.ID_Number__c === data.idNumber
    ) {
      return;
    } else {
      this.selectedAccountOption(cmp, null);
    }
  },
  changeAutocompleteHandler: function(cmp, params) {
    var option = params.option;
    this.selectedAccountOption(cmp, option);
    this.serverError(cmp, '');
    if (option) {
      this.navigateToAccount(cmp, option.Id);
    }
  },
  hideUtilityBar: function(cmp) {
    var utilityBarCmp = this.utilityBarCmp(cmp);
    utilityBarCmp.minimizeUtility().catch(function(err) {
      console.log(err);
    });
  },
  reset: function(cmp) {
    var idNumberFieldCmp = this.idNumberFieldCmp(cmp);
    if (idNumberFieldCmp) {
      idNumberFieldCmp.reset();
    }
  },
  navigateToAccount: function(cmp, accountId) {
    this.navigateToSobject(accountId);
    this.hideUtilityBar(cmp);
    this.reset(cmp);
  }
});