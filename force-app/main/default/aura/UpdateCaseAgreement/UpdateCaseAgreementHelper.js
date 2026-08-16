({
  init: function(cmp) {
    this.getAgreement(cmp);
  },
  CONSTANTS: {},
  controllers: {
    caseAgreement: 'LC_CaseAgreement'
  },
  destroy: function(cmp) {},
  render: function(cmp) {},
  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },
  searchError: function(cmp, value) {
    return this.attribute(cmp, 'searchError', value);
  },
  selectedAgreementId: function(cmp, value) {
    return this.attribute(cmp, 'selectedAgreementId', value);
  },
  formFieldCmp: function(cmp) {
    return cmp.find('formField');
  },
  searchAgreements: function(cmp, term) {
    var that = this;
    var recordId = this.recordId(cmp);
    var params = {
      recordId: recordId,
      actionName: 'obtainAgreements',
      agreementName: term
    };

    return that
      .executeApex(cmp, {
        controllerName: this.controllers.caseAgreement,
        params: params
      })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          that.resetSearchError(cmp);
          var agreements = res.map(function(item) {
            return Object.assign(item, { label: item.Name, value: item.Id });
          });
          return agreements;
        })
      )
      .catch(
        $A.getCallback(function(err) {
          if (typeof err.responseObj === 'string') {
            that.searchError(cmp, err.responseObj);
          }
          console.log(err);
          return [];
        })
      );
  },

  resetSearchError: function(cmp) {
    var searchError = this.searchError(cmp);
    if (searchError) {
      this.searchError(cmp, '');
    }
  },
  submit: function(cmp) {
    var self = this;
    var isValid = this.validate(cmp);
    if (!isValid) {
      return;
    }
    var recordId = this.recordId(cmp);
    var agreementId = this.selectedAgreementId(cmp);
    var params = {
      recordId: recordId,
      agreementId: agreementId,
      actionName: 'setAgreement'
    };
    self.serverError(cmp, '');
    self.isLoading(cmp, true);
    this.executeApex(cmp, {
      controllerName: this.controllers.caseAgreement,
      params: params
    })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          self.isLoading(cmp, false);
          self.showToast({
            title: 'Success',
            message: 'Agreement updated',
            type: 'success'
          });
          self.refreshView();
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          self.isLoading(cmp, false);
          var errMessage = self.buildHtmlServerError(err);
          self.serverError(cmp, errMessage);
        })
      );
  },
  getAgreement: function(cmp) {
    var self = this;
    var isValid = this.validate(cmp);
    if (!isValid) {
      return;
    }
    var recordId = this.recordId(cmp);

    var params = {
      recordId: recordId,
      actionName: 'getAgreement'
    };
    self.serverError(cmp, '');
    self.isLoading(cmp, true);
    this.executeApex(cmp, {
      controllerName: this.controllers.caseAgreement,
      params: params
    })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          self.isLoading(cmp, false);
          if (res.Id != null) {
            var option = {
              label: res.Name,
              value: res.Id
            };
            self.formFieldCmp(cmp).setOption(option);
          }
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          self.isLoading(cmp, false);
          var errMessage = self.buildHtmlServerError(err);
          self.serverError(cmp, errMessage);
        })
      );
  },
  validate: function(cmp) {
    var isValid = true;
    var formFieldCmp = this.formFieldCmp(cmp);
    if (formFieldCmp) {
      formFieldCmp.showHelpMessageIfInvalid();
      var validity = this.attribute(formFieldCmp, 'validity');
      isValid = validity.valid;
    }
    return isValid;
  }
});