/**@type {import("OmniUtilityItem").Helper} */
({
  init: function(cmp) {
    this.fetchInitData(cmp);
  },
  destroy: function(cmp) {
    this.clearStyles(cmp);
  },
  render: function(cmp) {},

  staticData: function(cmp, value) {
    return this.property(cmp, '_staticData', value);
  },
  omniUtilityId: function(cmp, value) {
    return this.property(cmp, '_omniUtilityId', value);
  },
  stylesId: function(cmp, value) {
    return this.property(cmp, '_stylesId', value);
  },

  omniToolkitAPI: function(cmp) {
    return cmp.find('omniToolkit');
  },
  utilityBarCmp: function(cmp) {
    return cmp.find('utilityBarAPI');
  },

  fetchInitData: function(cmp) {
    var that = this;
    var params = {
      actionName: 'getInitData'
    };
    that
      .omniChannelRequest(cmp, params)
      .then(function(data) {
        that.config(cmp, data);
      })
      .catch(function(err) {
        that.showToast({
          type: 'error',
          title: $A.get('$Label.c.Error'),
          message: that.buildHtmlServerError(err)
        });
      });
  },

  config: function(cmp, data) {
    this.staticData(cmp, data);
    this.appendStyles(cmp);
  },

  omniChannelRequest: function(cmp, params) {
    var that = this;
    var requestParams = {
      controllerName: 'LC_OmniChanelController',
      params: params
    };
    return that
      .executeApex(cmp, requestParams)
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(function(res) {
        return res;
      })
      .catch(function(err) {
        console.log(requestParams, err);
        throw err;
      });
  },

  appendStyles: function(cmp) {
    var staticData = this.staticData(cmp);
    var stylesId =
      'omniStyles_' +
      Math.random()
        .toString(16)
        .slice(2);

    this.stylesId(cmp, stylesId);
    var depricatedStatusList = staticData.depricatedStatusList || [];
    var listClassName = '.runtime_service_omnichannelStatus .dropdown__list';
    var itemClassName = '.slds-dropdown__item';

    var depricatedItemsSelectors = depricatedStatusList.map(function(status) {
      return (
        listClassName +
        ' ' +
        itemClassName +
        '[title="' +
        status.masterLabel +
        '"]'
      );
    });

    var deprecatedItemsSelectorsText = depricatedItemsSelectors.join(',\n');

    var depricatedItemsStyles =
      deprecatedItemsSelectorsText + ' {\n' + 'display:none;' + '\n}\n';

    var styleEl = document.createElement('style');
    styleEl.id = stylesId;
    styleEl.innerHTML = depricatedItemsStyles;
    document.body.appendChild(styleEl);
  },

  clearStyles: function(cmp) {
    var stylesId = this.stylesId(cmp);
    var styleEl = document.body.querySelector(stylesId);
    if (!styleEl) {
      return;
    }
    document.body.removeChild(styleEl);
  },
  workAcceptedHandler: function(cmp, workData) {
    var that = this;
    var workItemId = workData.workItemId;
    if (workItemId.indexOf('500') !== 0) {
      return;
    }

    var params = {
      actionName: 'assignOwner',
      itemId: workItemId
    };

    that
      .omniChannelRequest(cmp, params)
      .then(
        $A.getCallback(function(newAssign) {
          if (!newAssign) {
            return;
          }
          that.refreshView();
        })
      )
      .catch($A.getCallback(function(err) {}));
  }
});