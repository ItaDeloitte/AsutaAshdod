/**@type {import("UpdateAccountApi").Helper} */
({
  init: function(cmp) {
    this.autoUpdate(cmp);
  },
  CONSTANTS: {},

  controllers: {
    demography: 'LC_Demography'
  },

  destroy: function(cmp) {},
  render: function(cmp) {},

  isAutoUpdate: function(cmp, value) {
    return this.attribute(cmp, 'isAutoUpdate', value);
  },

  accountId: function(cmp, value) {
    return this.attribute(cmp, 'accountId', value);
  },
  update: function(cmp, accountId) {
    var params = {
      actionName: 'updateAccount',
      accountId: accountId
    };

    return this.executeApex(cmp, {
      controllerName: this.controllers.demography,
      params: params
    }).then(this.BASE_RES_PIPES.statusPipe);
  },
  autoUpdate: function(cmp) {
    var self = this;
    var isAutoUpdate = this.isAutoUpdate(cmp);
    if (!isAutoUpdate) {
      return;
    }
    var accountId = this.recordId(cmp);
    // self.isLoading(cmp, true);
    this.update(cmp, accountId)
      .then(
        $A.getCallback(function() {
          self.isLoading(cmp, false);
          self.refreshView();
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          self.isLoading(cmp, false);
        })
      );
  }
});