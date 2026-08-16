/**@type {import("AppointmentsTimeSlot").Helper} */
({
  init: function(cmp) {
    this.config(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},

  slotKey: function(cmp, value) {
    return this.attribute(cmp, 'slotKey', value);
  },
  slotsMap: function(cmp, value) {
    return this.attribute(cmp, 'slotsMap', value);
  },
  lockedData: function(cmp, value) {
    return this.attribute(cmp, 'lockedData', value);
  },
  slot: function(cmp, value) {
    return this.attribute(cmp, 'slot', value);
  },
  isLocked: function(cmp, value) {
    return this.attribute(cmp, 'isLocked', value);
  },
  selectedRow: function(cmp, value) {
    return this.attribute(cmp, 'selectedRow', value);
  },

  config: function(cmp) {
    this.updateSlot(cmp);
    this.updateIsLocked(cmp);
  },

  updateSlot: function(cmp) {
    var slotKey = this.slotKey(cmp);
    var slotsMap = this.slotsMap(cmp);
    var slot = slotsMap[slotKey];
    this.slot(cmp, slot);
  },

  updateIsLocked: function(cmp) {
    var rowIndex = this.selectedRow(cmp);
    var slotKey = this.slotKey(cmp);
    var lockedData = this.lockedData(cmp);
    var slotWithLock = lockedData.slotsByRow[rowIndex];
    var isLocked =
      slotWithLock &&
      slotWithLock.slot &&
      slotWithLock.slot.uniqKey === slotKey;
    this.isLocked(cmp, isLocked);
  },

  emitSlotSelect: function(cmp) {
    var slotKey = this.slotKey(cmp);
    var selectedRow = this.selectedRow(cmp);
    this.emitEvent(cmp, 'onSlotSelect', {
      value: { slotKey: slotKey, rowIndex: selectedRow }
    });
  }
});