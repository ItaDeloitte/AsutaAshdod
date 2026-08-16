({
  init: function(cmp) {
    this.refreshView(cmp);
  },
  CONSTANTS: {},
  controllers: {
    caseContact: 'LC_CaseRefreshView'
  },
  destroy: function(cmp) {},
  render: function(cmp) {},
  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },
  refreshView: function(cmp) {
    var self = this;
    var recordId = this.recordId(cmp);

    var params = {
      recordId: recordId,
      actionName: 'refreshView'
    };
    self.serverError(cmp, '');
    this.executeApex(cmp, {
      controllerName: this.controllers.caseContact,
      params: params
    })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          console.log('refresh view: ' + res);
          if (res) {
            setTimeout(
              $A.getCallback(function() {
                $A.get('e.force:refreshView').fire();
              }), 3000);
          }
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          var errMessage = self.buildHtmlServerError(err);
          self.serverError(cmp, errMessage);
        })
      );
  }
})