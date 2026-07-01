({
  init: function(cmp) {
    this.getFields(cmp);
  },
  CONSTANTS: {},
  controllers: {
    caseContact: 'LC_NextBestAction'
  },
  destroy: function(cmp) {},
  render: function(cmp) {},
  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },
  apiNames: function(cmp, value) {
    return this.attribute(cmp, 'apiNames', value);
  },
  resultList: function(cmp, value) {
    return this.attribute(cmp, 'resultList', value);
  },
  getFields: function(cmp) {
    var self = this;
    var recordId = this.recordId(cmp);
    var apiNames = this.apiNames(cmp);

    var params = {
      recordId: recordId,
      apiNames: apiNames,
      actionName: 'getFields'
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
          console.log('success ' + res);
          self.resultList(cmp, res);
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
  }
})