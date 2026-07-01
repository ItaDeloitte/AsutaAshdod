/**@type {import("AppointmentsConfirmation").Helper} */
({
  init: function(cmp) {},
  destroy: function(cmp) {},
  render: function(cmp) {},

  confirm: function(cmp) {
    this.emitAction(cmp, true);
    this.close(cmp);
  },
  cancel: function(cmp) {
    this.emitAction(cmp, false);
    this.close(cmp);
  },
  emitAction: function(cmp, value) {
    this.emitEvent(cmp, 'onconfirmation', { value: value });
  }
});