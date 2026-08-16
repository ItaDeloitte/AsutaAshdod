/**@type {import("UpdateLeadAccount").Helper} */
({
    init: function(cmp) {
      this.getAccount(cmp);
    },
    CONSTANTS: {},
    controllers: {
      leadAccount: 'LC_LeadAccount'
    },
    destroy: function(cmp) {},
    render: function(cmp) {},
    serverError: function(cmp, value) {
      return this.attribute(cmp, 'serverError', value);
    },
    selectedAccountId: function(cmp, value) {
      return this.attribute(cmp, 'selectedAccountId', value);
    },
    formFieldCmp: function(cmp) {
      return cmp.find('formField');
    },
    searchAccounts: function(cmp, term) {
      var self = this;
      var leadId = this.recordId(cmp);
      var params = {
        leadId: leadId,
        accountName: term,
        actionName: 'obtainAccounts'
      };
      self.serverError(cmp, '');
      return self
        .executeApex(cmp, {
          controllerName: this.controllers.leadAccount,
          params: params
        })
        .then(this.BASE_RES_PIPES.statusPipe)
        .then(
          $A.getCallback(function(res) {
            if(res.length > 1){
              var aleMessage = self.buildHtmlServerError('שים לב, יש  מספר מטופלים עם פרטים אלו,  אנא בחר מטופל');
              self.serverError(cmp, aleMessage);   
            }
            var accounts = res.map(function(item) {
              return Object.assign(item, { label: item.Name, value: item.Id });
            });
            return accounts;
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
      var leadId = this.recordId(cmp);
      var accountId = this.selectedAccountId(cmp);
      var params = {
        leadId: leadId,
        accountId: accountId,
        actionName: 'setAccount'
      };
      self.serverError(cmp, '');
      self.isLoading(cmp, true);
      this.executeApex(cmp, {
        controllerName: this.controllers.leadAccount,
        params: params
      })
        .then(this.BASE_RES_PIPES.statusPipe)
        .then(
          $A.getCallback(function(res) {
            self.isLoading(cmp, false);
            self.showToast({
              title: $A.get('$Label.c.Success'),
              message: $A.get('$Label.c.Lead_updated'),
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
    getAccount: function(cmp) {
      var self = this;
      var isValid = this.validate(cmp);
      if (!isValid) {
        return;
      }
      var leadId = this.recordId(cmp);
  
      var params = {
        leadId: leadId,
        actionName: 'getAccount'
      };
      self.serverError(cmp, '');
      self.isLoading(cmp, true);
      this.executeApex(cmp, {
        controllerName: this.controllers.leadAccount,
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
              self.refreshView();
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