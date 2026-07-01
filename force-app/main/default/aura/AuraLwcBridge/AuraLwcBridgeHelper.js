/**@type {import("AuraLwcBridge").Helper} */
({
  init: function (cmp) {},
  render: function (cmp) {
    var isRendered = this.isRendered(cmp);
    if (isRendered) {
      return;
    }
    this.isRendered(cmp, true);
    this.registerAuraBridgeService(cmp);
  },
  destroy: function (cmp) {
    this.unregisterAuraBridgeService(cmp);
  },

  overlayLibCmp: function (cmp) {
    return cmp.find('overlayLib');
  },
  workspaceApiCmp: function (cmp) {
    return cmp.find('workspaceApi');
  },

  auraBridgeServiceRegistration: function (cmp, value) {
    return this.property(cmp, '_auraBridgeServiceRegistration', value);
  },

  registerAuraBridgeService: function (cmp, isDetached) {
    var that = this;
    if (that.auraBridgeServiceRegistration(cmp)) {
      return;
    }

    var globalServiceCmp = that.globalServiceCmp(cmp);
    var all = globalServiceCmp.getAll();
    var services = all.services;
    var auraLwcBridgeService = services.auraLwcBridgeService;

    var bridgeConfig = {
      id: cmp.getGlobalId(),
      cmp: cmp,
      isDetached: isDetached,
      showModal: $A.getCallback(that.showModal.bind(that, cmp)),
      showToast: $A.getCallback(that.showToast.bind(that)),
      refreshView: $A.getCallback(that.refreshView.bind(that)),
      isOnFocusedTab: that.isOnFocusedTab.bind(that, cmp),
      globalServiceCmp: that.globalServiceCmp(cmp)
    };

    var registration = auraLwcBridgeService.addAuraBridge(bridgeConfig);
    that.auraBridgeServiceRegistration(cmp, registration);
  },

  isOnFocusedTab: function (cmp) {
    var workspaceApiCmp = this.workspaceApiCmp(cmp);

    // eslint-disable-next-line compat/compat
    return Promise.all([
      workspaceApiCmp.getEnclosingTabId(),
      workspaceApiCmp.getFocusedTabInfo()
    ])
      .then(function (result) {
        var enclosingTabId = result[0];
        if (!enclosingTabId) {
          return true;
        }
        var focusedTabId = result[1].tabId;

        if (!focusedTabId) {
          return !enclosingTabId;
        }

        return focusedTabId === enclosingTabId;
      })
      .catch(function () {
        return false;
      });
  },

  unregisterAuraBridgeService: function (cmp) {
    var auraBridgeServiceRegistration = this.auraBridgeServiceRegistration(cmp);
    if (auraBridgeServiceRegistration) {
      auraBridgeServiceRegistration.unregister();
    }
  },

  showModal: function (cmp, params) {
    var that = this;
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var globalServiceCmp = that.globalServiceCmp(cmp);
    var all = globalServiceCmp.getAll();
    var services = all.services;
    var componentFactoryService = services.componentFactoryService;

    var cssClass = params.cssClass || '';
    var resolvers = params.resolvers;
    var showCloseButton = true;
    if (params.showCloseButton === false) {
      showCloseButton = false;
    }
    var cmpDefinition = componentFactoryService.buildComponentDefinition(
      params.useAuraModalDynamicLwc ? 'AuraModalDynamicLwc' : params.modalName
    );
    // eslint-disable-next-line compat/compat
    var cmpParams = Object.assign(
      {
        modalParams: params
      },
      params.modalData
    );
    componentFactoryService
      .createComponent($A, cmpDefinition.name, cmpParams)
      .then(
        $A.getCallback(function (modalCmp) {
          overlayLibCmp
            .showCustomModal({
              body: modalCmp,
              cssClass: cmpDefinition.className + ' modal ' + cssClass,
              closeCallback: $A.getCallback(function () {
                resolvers.close();
              }),
              showCloseButton: showCloseButton
            })
            .then(
              $A.getCallback(function (modalRef) {
                if (!params.useAuraModalDynamicLwc) {
                  resolvers.create();
                }
              })
            );
        })
      )
      .catch(
        $A.getCallback(function (err) {
          console.log(err);
        })
      );
  }
});