/**@type {import("Case360CloseModal").Helper} */
({
  init: function(cmp) {
    this.fetchStaticData(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},

  staticData: function(cmp, value) {
    return this.attribute(cmp, 'staticData', value);
  },
  editData: function(cmp, value) {
    return this.attribute(cmp, 'editData', value);
  },
  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },
  overlayLibCmp: function(cmp) {
    return cmp.find('overlayLib');
  },
  close: function(cmp) {
    var overlayLibCmp = this.overlayLibCmp(cmp);
    overlayLibCmp.notifyClose();
  },

  cancel: function(cmp) {
    this.close(cmp);
  },

  fetchStaticData: function(cmp) {
    var that = this;
    var params = {
      actionName: 'getCloseData'
    };
    that.isLoading(cmp, true);
    that.serverError(cmp, '');
    that
      .lcCase360Request(cmp, params)
      .then(
        $A.getCallback(function(data) {
          that.config(cmp, data);
          that.isLoading(cmp, false);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isLoading(cmp, false);
          that.serverError(cmp, that.buildHtmlServerError(err));
        })
      );
  },

  config: function(cmp, data) {
    var editData = this.editData(cmp);
    var reasonOptions = data.closeReasons || [];
    var firstReasonOption = reasonOptions[0];
    editData.closeReason = firstReasonOption ? firstReasonOption.value : '';
    this.editData(cmp);
    this.staticData(cmp, data);
  },

  submit: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var editData = that.editData(cmp);
    var params = {
      actionName: 'closeRecommendation',
      recordId: recordId,
      closeReason: editData.closeReason
    };
    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    that
      .lcCase360Request(cmp, params)
      .then(
        $A.getCallback(function(message) {
          that.isLoading(cmp, false);
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: message
          });
          that.refreshView();
          that.close(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isLoading(cmp, false);
          that.serverError(cmp, that.buildHtmlServerError(err));
        })
      );
  },
  lcCase360Request: function(cmp, params) {
    var that = this;
    console.log(params);
    return that
      .executeApex(cmp, {
        controllerName: 'LC_Case360Controller',
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(function(res) {
        console.log(params, res);
        return res;
      })
      .catch(function(err) {
        console.log(err);
        throw err;
      });
  }
});