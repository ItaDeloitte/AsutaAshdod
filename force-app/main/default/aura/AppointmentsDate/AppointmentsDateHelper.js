/**@type {import("AppointmentsDate").Helper} */
({
  init: function(cmp) {
    this.config(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},

  day: function(cmp, value) {
    return this.attribute(cmp, 'day', value);
  },
  selectedDay: function(cmp, value) {
    return this.attribute(cmp, 'selectedDay', value);
  },
  formattedDate: function(cmp, value) {
    return this.attribute(cmp, 'formattedDate', value);
  },
  lockedData: function(cmp, value) {
    return this.attribute(cmp, 'lockedData', value);
  },
  isLocked: function(cmp, value) {
    return this.attribute(cmp, 'isLocked', value);
  },
  rowIndex: function(cmp, value) {
    return this.attribute(cmp, 'rowIndex', value);
  },

  selectDay: function(cmp) {
    var day = this.day(cmp);
    var rowIndex = this.rowIndex(cmp);
    var groupEl = cmp.getElement();

    /**@type {import('AppointmentsBase').SelectDayEventData} */
    var selectGroupData = {
      day: day,
      dayEl: groupEl,
      rowIndex: rowIndex
    };
    this.emitDaySelect(cmp, selectGroupData);
  },

  config: function(cmp) {
    var group = this.day(cmp);
    var $Locale = this.$Locale();
    var targetDate = $A.localizationService.parseDateTime(group.targetDate);
    var weekDayName = $Locale.nameOfWeekdays[targetDate.getDay()].shortName;
    var formattedWeekday =
      weekDayName[0].toUpperCase() + weekDayName.slice(1).toLowerCase();
    var formattedDate = formattedWeekday;
    this.formattedDate(cmp, formattedDate);

    this.updateIsSelected(cmp);
  },

  updateIsSelected: function(cmp) {
    var rowIndex = this.rowIndex(cmp);
    var dayGroup = this.day(cmp);
    var lockedData = this.lockedData(cmp);
    var lockedSlot = lockedData.slotsByRow[rowIndex];
    var isLocked = false;
    if (lockedSlot) {
      isLocked = lockedSlot.slot.dayKey === dayGroup.uniqKey;
    }

    this.isLocked(cmp, isLocked);
  },

  emitDaySelect: function(cmp, data) {
    this.emitEvent(cmp, 'onDaySelect', { value: data });
  }
});