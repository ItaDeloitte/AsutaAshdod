/**@type {import("UpdateAccount").Helper} */
({
  init: function(cmp) {
    this.update(cmp);
  },

  CONSTANTS: {},

  controllers: {
    demography: 'LC_Demography'
  },

  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },

  updateAccountApiCmp: function(cmp) {
    return cmp.find('updateAccountApi');
  },

  destroy: function(cmp) {},

  update: function(cmp) {
    var self = this;
    var accountId = this.recordId(cmp);
    var updateAccountApiCmp = this.updateAccountApiCmp(cmp);
    self.serverError(cmp, '');
    self.isLoading(cmp, true);
    return updateAccountApiCmp
      .update(accountId)
      .then(
        $A.getCallback(function(res) {
          self.isLoading(cmp, false);
          self.showToast({
            title: $A.get('$Label.c.Success'),
            type: 'success',
            message: 'Account Updated'
          });
          self.close(cmp);
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
  cancel: function(cmp) {
    this.close(cmp);
  },
  close: function(cmp) {
    this.closeQuickAction();
  },
  showServerError: function(cmp, err) {
    var errMessage = this.buildHtmlServerError(err);
    this.serverError(cmp, errMessage);
  },
  actionClicked: function(cmp, action) {
    switch (action) {
      case 'retry': {
        return this.update(cmp);
      }
      case 'cancel': {
        return this.cancel(cmp);
      }
    }
  }
});