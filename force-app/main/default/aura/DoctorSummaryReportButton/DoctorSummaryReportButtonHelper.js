({
  init: function(cmp) {},
  CONSTANTS: {},
  controllers: {
    summaryReport: 'LC_DoctorSummaryReportController'
  },
  destroy: function(cmp) {},
  render: function(cmp) {
    var isRendered = this.isRendered(cmp);
    if (isRendered) {
      return;
    }
    this.isRendered(cmp, true);
    this.fetchConfig(cmp);
  },

  overlayLibCmp: function(cmp) {
    return cmp.find('overlayLib');
  },
  buttonAvailable: function(cmp, value) {
    return this.attribute(cmp, 'buttonAvailable', value);
  },
  fetchConfig: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var params = {
      actionName: 'reportButtonAvailable',
      doctorId: recordId
    };
    that.isLoading(cmp, true);
    return that
      .executeApex(cmp, {
        controllerName: this.controllers.summaryReport,
        params: params
      })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(data) {
          console.log(params, data);
          that.isLoading(cmp, false);
          that.buttonAvailable(cmp, data);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
        })
      );
  },
  sendReport: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var params = {
      actionName: 'sendReport',
      doctorId: recordId
    };
    that
      .executeApex(cmp, {
        controllerName: this.controllers.summaryReport,
        params: params
      })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(res) {
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: $A.get('$Label.c.Summary_Report_Sent')
          });
          that.refreshView();
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.showToast({
            type: 'error',
            title: $A.get('$Label.c.Error'),
            message: err.responseObj
          });
        })
      );
  }
})