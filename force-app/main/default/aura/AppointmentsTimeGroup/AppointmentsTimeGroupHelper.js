/**@type {import("AppointmentsTimeGroup").Helper} */
({
  init: function(cmp) {},
  destroy: function(cmp) {},
  render: function(cmp) {},

  day: function(cmp, value) {
    return this.attribute(cmp, 'day', value);
  },

  slotsMap: function(cmp, value) {
    return this.attribute(cmp, 'slotsMap', value);
  },

  slotsRows: function(cmp, value) {
    return this.attribute(cmp, 'slotRows', value);
  },
  selectedRow: function(cmp, value) {
    return this.attribute(cmp, 'selectedRow', value);
  },

  timeSlots: function(cmp, value) {
    return this.attribute(cmp, 'timeSlots', value);
  },

  lockedData: function(cmp, value) {
    return this.attribute(cmp, 'lockedData', value);
  },

  config: function(cmp) {}
});