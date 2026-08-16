/**@type {import("ConfirmModal").Controller} */
({
  onInit: function(cmp, event, helper) {},
  onCloseModal: function(cmp, event, helper) {
    event.stopPropagation();
    helper.emitClose(cmp, null);
  },
  onConfirm: function(cmp, event, helper) {
    helper.emitClose(cmp, true);
  },
  onCancel: function(cmp, event, helper) {
    helper.emitClose(cmp, false);
  }
});