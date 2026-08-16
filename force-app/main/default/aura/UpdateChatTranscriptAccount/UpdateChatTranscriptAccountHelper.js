/**@type {import("UpdateChatTranscriptAccount").Helper} */
({
    init: function(cmp) {
      this.getAccount(cmp);
    },
    CONSTANTS: {},
    controllers: {
      chatTranscriptAccount: 'LC_ChatTranscriptAccount'
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
      var chatId = this.recordId(cmp);
      var params = {
        chatId: chatId,
        accountName: term,
        actionName: 'obtainAccounts'
      };
      return self
        .executeApex(cmp, {
          controllerName: this.controllers.chatTranscriptAccount,
          params: params
        })
        .then(this.BASE_RES_PIPES.statusPipe)
        .then(
          $A.getCallback(function(res) {
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
      var chatId = this.recordId(cmp);
      var accountId = this.selectedAccountId(cmp);
      var params = {
        chatId: chatId,
        accountId: accountId,
        actionName: 'setAccount'
      };
      self.serverError(cmp, '');
      self.isLoading(cmp, true);
      this.executeApex(cmp, {
        controllerName: this.controllers.chatTranscriptAccount,
        params: params
      })
        .then(this.BASE_RES_PIPES.statusPipe)
        .then(
          $A.getCallback(function(res) {
            self.isLoading(cmp, false);
            self.showToast({
              title: $A.get('$Label.c.Success'),
              message: $A.get('$Label.c.Account_updated'),
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
      var chatId = this.recordId(cmp);
  
      var params = {
        chatId: chatId,
        actionName: 'getAccount'
      };
      self.serverError(cmp, '');
      self.isLoading(cmp, true);
      this.executeApex(cmp, {
        controllerName: this.controllers.chatTranscriptAccount,
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