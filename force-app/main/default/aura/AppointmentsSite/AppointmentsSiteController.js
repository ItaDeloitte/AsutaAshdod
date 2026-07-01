/**@type {import("AppointmentsSite").Controller} */
({
  onInit: function(cmp, event, helper) {
    helper.init(cmp);
  },
  onDestroy: function(cmp, event, helper) {
    helper.destroy(cmp);
  },
  onRender: function(cmp, event, helper) {
    helper.render(cmp);
  },
  onGroupSelect: function(cmp, event, helper) {
    helper.sliderCmp(cmp).updateHeight();
  },
  onTransferToDepartment: function(cmp, event, helper) {
    helper.emitTransfer(cmp);
  },
  onShowNote: function(cmp, event, helper) {
    helper.toggleNoteHandler(cmp);
  },
  onHideNote: function(cmp, event, helper) {
    helper.hideNoteHandler(cmp);
  },
  onModalitySelect: function(cmp, event, helper) {
    var params = event.getParams();
    var modality = params.value;
    helper.modalityCodeClickHandler(cmp, modality);
  },
  onRowChanged: function(cmp, event, helper) {
    var params = event.getParams();
    helper.configDays(cmp);
  }
});