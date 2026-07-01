/**@type {import("AppointmentsTimeSlot").Controller} */
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
  onSelect: function(cmp, event, helper) {
    helper.emitSlotSelect(cmp);
  },
  onChangeSlotsMap: function(cmp, event, helper) {
    helper.updateSlot(cmp);
  },
  onChangeLockedData: function(cmp, event, helper) {
    helper.updateIsLocked(cmp);
  }
});