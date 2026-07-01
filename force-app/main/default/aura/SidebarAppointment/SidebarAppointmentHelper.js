/**@type {import("SidebarAppointment").Helper} */
({
  init: function(cmp) {
    this.config(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},
  appointment: function(cmp, value) {
    return this.attribute(cmp, 'appointment', value);
  },
  formattedDateTime: function(cmp, value) {
    return this.attribute(cmp, 'formattedDateTime', value);
  },
  emitSelected: function(cmp) {
    var appointment = this.appointment(cmp);
    this.emitEvent(cmp, 'selected', { value: appointment });
  },
  emitSet: function(cmp) {
    var appointment = this.appointment(cmp);
    this.emitEvent(cmp, 'onset', { value: appointment });
  },
  config: function(cmp) {}
});