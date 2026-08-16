/**@type {import("BaseModal").Controller} */
({
  onInit: function(cmp, event, helper) {
    helper.init(cmp);
  },
  onClose: function(cmp, event, helper) {
    helper.emitClose(cmp);
  },
  onOpenChange: function(cmp, event, helper) {
    // var isOpen = event.getParam('value');
    // helper.onOpenChange(cmp, isOpen);
  },
  onDestroy: function(cmp, event, helper) {
    // helper.onOpenChange(cmp, false);
  },
  onBackClick: function(cmp, event, helper) {
    //TODO polyfill closest for IE
    /*  var target = event.target;
    if (!target.closest('.modal-dialog')) {
      helper.backdropClick(cmp);
    } */
  }
});