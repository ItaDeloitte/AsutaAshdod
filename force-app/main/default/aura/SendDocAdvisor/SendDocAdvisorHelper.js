/**@type {import("SendDocAdvisor").Helper} */
({
  CONSTANTS: {},

  controllers: {
    buttonsController: 'LC_ButtonsController'
  },

  init: function(cmp) {},

  destroy: function(cmp) {},
  render: function(cmp) {},

  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },

  update: function(cmp) {
    var self = this;
    var caseId = this.recordId(cmp);
    var params = {
      caseId: caseId,
      actionName: 'sendDocAdvisor'
    };
    self.isLoading(cmp, true);
    self.serverError(cmp, '');
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
            message: 'Send DocAdvisor Successed'
          });
          self.refreshView();
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          self.showServerError(cmp, err);
          self.isLoading(cmp, false);
        })
      );
  },
  showServerError: function(cmp, err) {
    var errMessage = this.buildHtmlServerError(err);
    this.serverError(cmp, errMessage);
  }
});