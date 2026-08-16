/**@type {import("AuraModalDynamicLwc").Helper} */
({
  init: function (cmp) {},
  destroy: function (cmp) {},
  render: function (cmp) {
    var isRendered = this.isRendered(cmp);
    if (isRendered) {
      return;
    }
    this.isRendered(cmp, true);
    this.buildModal(cmp);
  },
  modalParams: function (cmp, value) {
    return this.attribute(cmp, 'modalParams', value);
  },
  lwcModal: function (cmp, value) {
    return this.attribute(cmp, 'lwcModal', value);
  },
  overlayLibCmp: function (cmp) {
    return cmp.find('overlayLib');
  },
  buildModal: function (cmp) {
    var that = this;
    var globalServiceCmp = that.globalServiceCmp(cmp);
    var all = globalServiceCmp.getAll();
    var services = all.services;
    var componentFactoryService = services.componentFactoryService;
    var modalParams = that.modalParams(cmp);
    var cmpDefinition = componentFactoryService.buildComponentDefinition(
      modalParams.modalName
    );
    componentFactoryService
      .createComponent($A, cmpDefinition.name, { modalParams: modalParams })
      .then(
        $A.getCallback(function (modalCmp) {
          that.lwcModal(cmp, modalCmp);
          modalParams.resolvers.create();
        })
      )
      .catch(
        $A.getCallback(function (err) {
          console.log(err);
          that.close(cmp);
        })
      );
  },
  close: function (cmp, value) {
    var overlayLibCmp = this.overlayLibCmp(cmp);
    var modalParams = this.modalParams(cmp);
    modalParams.resolvers.close(value);
    overlayLibCmp.notifyClose();
  }
});