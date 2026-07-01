/**@type {import("AppointmentsTimeGroup").Controller} */
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
  onSetAppointment: function(cmp, event, helper) {},
  onChangeLockedSlot: function(cmp, event, helper) {},
  onChangeGroup: function(cmp, event, helper) {},
  onChangeSlotRows: function(cmp, event, helper) {}
});