/**@type {import("UpdateCaseContact").Helper} */
({
  init: function(cmp) {
    this.getContact(cmp);
  },
  CONSTANTS: {},
  controllers: {
    caseContact: 'LC_CaseContact'
  },
  destroy: function(cmp) {},
  render: function(cmp) {},
  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },
  selectedContactId: function(cmp, value) {
    return this.attribute(cmp, 'selectedContactId', value);
  },
  formFieldCmp: function(cmp) {
    return cmp.find('formField');
  },
  searchContacts: function(cmp, term) {
    var self = this;
    var caseId = this.recordId(cmp);
    var params = {
      caseId: caseId,
      actionName: 'obtainContacts',
      contactName: term
    };
    return self
      .executeApex(cmp, {
        controllerName: this.controllers.caseContact,
        params: params
      })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          var contacts = res.map(function(item) {
            return Object.assign(item, { label: item.Name, value: item.Id });
          });
          return contacts;
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          return [];
        })
      );
  },
  submit: function(cmp) {
    var self = this;
    var isValid = this.validate(cmp);
    if (!isValid) {
      return;
    }
    var caseId = this.recordId(cmp);
    var contactId = this.selectedContactId(cmp);
    var params = {
      caseId: caseId,
      contactId: contactId,
      actionName: 'setContact'
    };
    self.serverError(cmp, '');
    self.isLoading(cmp, true);
    this.executeApex(cmp, {
      controllerName: this.controllers.caseContact,
      params: params
    })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          self.isLoading(cmp, false);
          self.showToast({
            title: 'Success',
            message: 'Contact updated',
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
  getContact: function(cmp) {
    var self = this;
    var isValid = this.validate(cmp);
    if (!isValid) {
      return;
    }
    var caseId = this.recordId(cmp);

    var params = {
      caseId: caseId,
      actionName: 'getContact'
    };
    self.serverError(cmp, '');
    self.isLoading(cmp, true);
    this.executeApex(cmp, {
      controllerName: this.controllers.caseContact,
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