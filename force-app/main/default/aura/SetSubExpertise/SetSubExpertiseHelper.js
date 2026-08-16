/**@type {import("SetSubExpertise").Helper} */
({
  init: function(cmp) {},

  destroy: function(cmp) {},
  render: function(cmp) {},

  CONSTANTS: {},

  controllers: {
    buttonsController: 'LC_ButtonsController'
  },
  subExpertiseId: function(cmp, value) {
    return this.attribute(cmp, 'subExpertiseId', value);
  },
  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },
  formFieldCmps: function(cmp) {
    var formFieldCmps = cmp.find('formField');
    if (Array.isArray(formFieldCmps)) {
      return formFieldCmps;
    }
    if (formFieldCmps) {
      return [formFieldCmps];
    }
    return null;
  },

  searchExpertiseOptions: function(cmp, term) {
    var self = this;
    var accountId = this.recordId(cmp);
    var params = {
      accountId: accountId,
      actionName: 'retriveSubExpertises',
      expertiseName: term
    };
    self.serverError(cmp, '');
    return self
      .executeApex(cmp, {
        controllerName: this.controllers.buttonsController,
        params: params
      })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(data) {
          var options = self.buildExpertiseOptions(data);
          return options;
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          self.serverError(cmp, self.buildHtmlServerError(err));
          return [];
        })
      );
  },
  setLookup: function(cmp) {
    var self = this;
    var isFormValid = this.validateForm(cmp);
    if (!isFormValid) {
      return;
    }
    var accountId = this.recordId(cmp);
    var subExpertiseId = this.subExpertiseId(cmp);
    var params = {
      accountId: accountId,
      subExpertiseId: subExpertiseId,
      actionName: 'setSubExpertise'
    };
    self.serverError(cmp, '');
    self.isLoading(cmp, true);
    return self
      .executeApex(cmp, {
        controllerName: this.controllers.buttonsController,
        params: params
      })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          self.isLoading(cmp, false);
          self.showToast({
            title: $A.get('$Label.c.Success'),
            type: 'success',
            message: 'Sub-Expertise was assigned to the Account'
          });
          self.refreshView();
          self.close(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          self.isLoading(cmp, false);
          self.serverError(cmp, self.buildHtmlServerError(err));
        })
      );
  },
  cancel: function(cmp) {
    this.close(cmp);
  },
  close: function(cmp) {
    this.closeQuickAction();
  },
  validateForm: function(cmp) {
    var self = this;
    var isValid = true;
    var formFieldCmps = this.formFieldCmps(cmp);
    formFieldCmps.forEach(function(formFieldCmp) {
      formFieldCmp.showHelpMessageIfInvalid();
      var validity = self.attribute(formFieldCmp, 'validity');
      if (validity) {
        isValid = isValid && validity.valid;
      }
    });
    return isValid;
  },
  buildExpertiseOptions: function(data) {
    var options = data.map(function(item) {
      return Object.assign(item, { label: item.Name, value: item.Id });
    });
    return options;
  }
});