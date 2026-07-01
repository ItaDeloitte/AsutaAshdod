/**@type {import("AppointmentsSite").Helper} */
({
  init: function(cmp) {
    this.config(cmp);
  },
  destroy: function(cmp) {
    console.log('site row destroyed');
  },
  render: function(cmp) {},

  CONSTANTS: {},
  isNoteVisible: function(cmp, value) {
    return this.attribute(cmp, 'isNoteVisible', value);
  },
  colors: function(cmp, value) {
    return this.attribute(cmp, 'colors', value);
  },
  rowColor: function(cmp, value) {
    return this.attribute(cmp, 'rowColor', value);
  },
  rowIndex: function(cmp, value) {
    return this.attribute(cmp, 'rowIndex', value);
  },
  selectedDay: function(cmp, value) {
    return this.attribute(cmp, 'selectedDay', value);
  },
  sliderCmp: function(cmp) {
    return cmp.find('slider');
  },

  scheduleAppointmentServiceCmp: function(cmp) {
    return cmp.find('scheduleAppointmentService');
  },

  scheduleAppointmentService: function(cmp) {
    if (!cmp._scheduleAppointmentService) {
      var service = this.scheduleAppointmentServiceCmp(cmp).getService();
      cmp._scheduleAppointmentService = service;
    }
    return cmp._scheduleAppointmentService;
  },

  row: function(cmp, value) {
    return this.attribute(cmp, 'row', value);
  },
  days: function(cmp, value) {
    return this.attribute(cmp, 'days', value);
  },
  slotsData: function(cmp, value) {
    return this.attribute(cmp, 'slotsData', value);
  },
  lockedData: function(cmp, value) {
    return this.attribute(cmp, 'lockedData', value);
  },

  config: function(cmp) {
    var colors = this.colors(cmp);
    var rowIndex = this.rowIndex(cmp);
    var siteColor = colors[rowIndex % colors.length];
    if (siteColor) {
      this.rowColor(cmp, siteColor);
    }
    this.configDays(cmp);
  },
  emitTransfer: function(cmp) {
    var row = this.row(cmp);
    this.emitEvent(cmp, 'onTransfer', { value: row });
  },
  toggleNoteHandler: function(cmp) {
    var isNoteVisible = this.isNoteVisible(cmp);
    this.isNoteVisible(cmp, !isNoteVisible);
  },
  hideNoteHandler: function(cmp) {
    this.isNoteVisible(cmp, false);
  },
  modalityCodeClickHandler: function(cmp, modality) {
    var rowIndex = this.rowIndex(cmp);
    this.emitEvent(cmp, 'onSelectModality', {
      value: {
        modality: modality,
        rowIndex: rowIndex
      }
    });
  },
  configDays: function(cmp) {
    var that = this;
    var slotsData = that.slotsData(cmp);
    var row = that.row(cmp);
    if (!row) {
      return;
    }
    var days = row.days
      .map(function(day) {
        var slots = day.slots;
        if (row.selectedModality) {
          slots = slots.filter(function(slotId) {
            var slot = slotsData.slotsMap[slotId];
            return slot.ModalityCode === row.selectedModality;
          });
        }
        return Object.assign({}, day, { slots: slots });
      })
      .filter(function(day) {
        return day.slots.length > 0;
      });
    that.days(cmp, days);
  }
});