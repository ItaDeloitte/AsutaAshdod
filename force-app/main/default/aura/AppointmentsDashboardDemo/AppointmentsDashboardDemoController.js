/**@type {import("AppointmentsDashboardDemo").Controller} */
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
  onSubmit: function(cmp, event, helper) {
    event.preventDefault();
    helper.submit(cmp);
  },
  onLockSlot: function(cmp, event, helper) {
    var btnCmp = event.getSource();
    var slot = btnCmp.get('v.name');
    helper.lockSlot(cmp, slot);
  },
  onUnlockSlot: function(cmp, event, helper) {
    var btnCmp = event.getSource();
    var slot = btnCmp.get('v.name');
    helper.unlockSlot(cmp, slot);
  },
  onRefreshSlot: function(cmp, event, helper) {
    var btnCmp = event.getSource();
    var slot = btnCmp.get('v.name');
    helper.refreshLockSlot(cmp, slot);
  },
  onSetAppointment: function(cmp, event, helper) {
    var btnCmp = event.getSource();
    var slot = btnCmp.get('v.name');
    helper.setAppointment(cmp, slot);
  }
});