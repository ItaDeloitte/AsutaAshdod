({
    init: function(cmp) {
      this.getQueue(cmp);
    },
    CONSTANTS: {},
    controllers: {
      junctionsQueue: 'LC_JunctionsQueue'
    },
    destroy: function(cmp) {},
    render: function(cmp) {},
    serverError: function(cmp, value) {
      return this.attribute(cmp, 'serverError', value);
    },
    selectedQueueId: function(cmp, value) {
      return this.attribute(cmp, 'selectedQueueId', value);
    },
    formFieldCmp: function(cmp) {
      return cmp.find('formField');
    },
    searchQueues: function(cmp, term) {
      var self = this;
      var recordId = this.recordId(cmp);
      var params = {
        recordId: recordId,
        actionName: 'obtainQueues',
        keyWord: term
      };
      return self
        .executeApex(cmp, {
          controllerName: this.controllers.junctionsQueue,
          params: params
        })
        .then(this.BASE_RES_PIPES.statusPipe)
        .then(
          $A.getCallback(function(res) {
            var queues = res.map(function(item) {
              return Object.assign(item, { label: item.Name, value: item.Id });
            });
            return queues;
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
      var recordId = this.recordId(cmp);
      var queueId = this.selectedQueueId(cmp);
      var params = {
        recordId: recordId,
        queueId: queueId,
        actionName: 'setQueue'
      };
      self.serverError(cmp, '');
      self.isLoading(cmp, true);
      this.executeApex(cmp, {
        controllerName: this.controllers.junctionsQueue,
        params: params
      })
        .then(this.BASE_RES_PIPES.statusPipe)
        .then(
          $A.getCallback(function(res) {
            self.isLoading(cmp, false);
            self.showToast({
              title: 'Success',
              message: 'Queue updated',
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
    getQueue: function(cmp) {
      var self = this;
      var isValid = this.validate(cmp);
      if (!isValid) {
        return;
      }
      var recordId = this.recordId(cmp);
  
      var params = {
        recordId: recordId,
        actionName: 'getQueue'
      };
      self.serverError(cmp, '');
      self.isLoading(cmp, true);
      this.executeApex(cmp, {
        controllerName: this.controllers.junctionsQueue,
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