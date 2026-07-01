/**@type {import("C30_ScheduleForcedAppointmentDashboard").Helper} */
({
  init: function(cmp) {
    this.fetchStaticData(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},
  CONSTANTS: {},

  staticData: function(cmp, value) {
    return this.attribute(cmp, 'staticData', value);
  },
  editData: function(cmp, value) {
    return this.attribute(cmp, 'editData', value);
  },
  screenMode: function(cmp, value) {
    return this.attribute(cmp, 'screenMode', value);
  },

  slotsData: function(cmp, value) {
    return this.attribute(cmp, 'slotsData', value);
  },

  tableColumns: function(cmp, value) {
    return this.attribute(cmp, 'tableColumns', value);
  },
  tableData: function(cmp, value) {
    return this.attribute(cmp, 'tableData', value);
  },

  selectedRow: function(cmp, value) {
    return this.attribute(cmp, 'selectedRow', value);
  },

  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },

  editFieldCmps: function(cmp) {
    return this.convertCmpsToArray(cmp.find('editField'));
  },

  findAutocompleteEditField: function(cmp, fieldName) {
    var that = this;
    var editFieldCmps = that.editFieldCmps(cmp);
    return editFieldCmps.find(function(item) {
      var name = that.attribute(item, 'name');
      return name === fieldName;
    });
  },

  domainAutocompleteCmp: function(cmp) {
    return this.findAutocompleteEditField(cmp, 'domain');
  },

  siteAutocompleteCmp: function(cmp) {
    return this.findAutocompleteEditField(cmp, 'site');
  },

  calendarAutocompleteCmp: function(cmp) {
    return this.findAutocompleteEditField(cmp, 'calendar');
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

  slotsTableCmp: function(cmp) {
    return cmp.find('slotsTable');
  },

  fetchStaticData: function(cmp) {
    var that = this;
    var params = {};
    that.isLoading(cmp, true);
    this.executeApexFake(cmp, params)
      .then(
        $A.getCallback(function(res) {
          that.isLoading(cmp, false);

          that.config(cmp, {});
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isLoading(cmp, false);
          that.showToast({
            type: 'error',
            title: 'Error',
            message: that.buildHtmlServerError(err)
          });
          that.close(cmp);
        })
      );
  },
  config: function(cmp, data) {
    var staticData = this.buildStaticData(cmp, data);
    var editData = this.editData(cmp);
    editData.startDate = staticData.formattedCurrentDate;

    var tableColumns = this.buildTableColumns(cmp);

    var dd = {
      tableColumns: tableColumns,
      staticData: staticData,
      editData: editData
    };
    console.log(this.unProxyData(dd));
    this.tableColumns(cmp, tableColumns);
    this.editData(cmp, editData);
    this.staticData(cmp, staticData);
  },
  buildStaticData: function(cmp, data) {
    var $Locale = this.$Locale();
    var currentDate = new Date();
    var formattedCurrentDate = $A.localizationService.formatDate(
      currentDate,
      'yyyy-MM-dd'
    );
    /**@type {import('C30_ScheduleForcedAppointmentDashboard').StaticData} */
    var staticData = {
      currentDate: currentDate,
      formattedCurrentDate: formattedCurrentDate
    };
    return staticData;
  },
  searchDomains: function(cmp, term) {
    var that = this;
    var screenMode = that.screenMode(cmp);

    return that
      .scheduleAppointmentService(cmp)
      .searchDomains({
        keyWord: term,
        screenMode: screenMode
      })
      .catch(function(err) {
        return [];
      });
  },

  searchSites: function(cmp, term) {
    var that = this;
    return that
      .scheduleAppointmentService(cmp)
      .searchSequenceSites({
        keyWord: term
      })
      .catch(function(err) {
        return [];
      });
  },

  searchCalendars: function(cmp, term) {
    var that = this;
    var editData = that.editData(cmp);
    return that
      .scheduleAppointmentService(cmp)
      .searchCalendars({
        siteCode: editData.site,
        keyWord: term
      })
      .then(function(options) {
        //TODO:remove
        return [{ label: 'test', value: 'test' }];
      })
      .catch(function(err) {
        return [];
      });
  },

  searchSlots: function(cmp) {
    var that = this;
    var isFormValid = that.validateEditForm(cmp);
    if (!isFormValid) {
      return;
    }
    var editData = this.editData(cmp);
    var dd = {
      editData: editData
    };
    console.log(that.unProxyData(dd));
    var params = {};
    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    that
      .executeApexFake(cmp, params)
      .then(
        $A.getCallback(function(
          /**@type {import('C30_ScheduleForcedAppointmentDashboard').SlotsDataRes} */ data
        ) {
          that.isLoading(cmp, false);
          var slotsData = that.buildSlotsData(cmp, data);
          var tableData = that.buildTableData(cmp, slotsData.slots);
          that.slotsData(cmp, slotsData);
          that.tableData(cmp, tableData);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isLoading(cmp, false);
          that.serverError(cmp, that.buildHtmlServerError(err));
        })
      );
  },

  fieldEditHandler: function(cmp) {
    this.slotsData(cmp, null);
    this.selectedRow(cmp, null);
  },

  validateEditForm: function(cmp) {
    var isValid = true;
    var editFieldCmps = this.editFieldCmps(cmp);
    editFieldCmps.forEach(function(fieldCmp) {
      var isFieldValid = fieldCmp.checkValidity();
      fieldCmp.showHelpMessageIfInvalid();
      isValid = isValid && isFieldValid;
    });
    return isValid;
  },

  domainChangedHandler: function(cmp) {
    var editData = this.editData(cmp);
    console.log(this.unProxyData(editData));
  },
  siteChangedHandler: function(cmp) {
    var calendarAutocompleteCmp = this.calendarAutocompleteCmp(cmp);
    if (calendarAutocompleteCmp) {
      calendarAutocompleteCmp.reset();
      calendarAutocompleteCmp.triggerSearch();
    }

    var editData = this.editData(cmp);
    console.log(this.unProxyData(editData));
  },
  calendarChangedHandler: function(cmp) {
    var editData = this.editData(cmp);
    console.log(this.unProxyData(editData));
  },
  buildSlotsData: function(cmp, data) {
    /**@type {import('C30_ScheduleForcedAppointmentDashboard').SlotsData} */
    var slotsData = {
      slots: Array(50)
        .fill(null)
        .map(function(_, index) {
          var date = new Date();
          date.setDate(date.getDate() + index);
          var startTime = new Date(date);
          startTime.setHours(8 + index);
          var endTime = new Date(date);
          endTime.setHours(9 + index);
          var slotId = (index + 1).toString();
          /**@type {import('C30_ScheduleForcedAppointmentDashboard').Slot} */
          var slot = {
            Id: slotId,
            startDate: date.toISOString(),
            startTime: startTime.toISOString(),
            endTime: endTime.toISOString(),
            description: 'description ' + slotId,
            description2: 'description2 ' + slotId
          };
          return slot;
        })
    };
    return slotsData;
  },
  buildTableColumns: function(cmp) {
    /**@type {import('C30_ScheduleForcedAppointmentDashboard').TableColumn[]} */
    var tableColumns = [
      {
        fieldName: 'startDate',
        label: 'Start Date',
        type: 'date',
        fixedWidth: 150,
        typeAttributes: {
          year: 'numeric',
          month: '2-digit',
          day: '2-digit'
        }
      },
      {
        fieldName: 'startTime',
        label: 'Start Time',
        type: 'date',
        fixedWidth: 150,
        typeAttributes: {
          hour: '2-digit',
          minute: '2-digit'
        }
      },
      {
        fieldName: 'endTime',
        label: 'End Time',
        type: 'date',
        fixedWidth: 150,
        typeAttributes: {
          hour: '2-digit',
          minute: '2-digit'
        }
      },
      {
        fieldName: 'description',
        label: 'Description 1',
        type: 'text'
      },
      {
        fieldName: 'description2',
        label: 'Description 2',
        type: 'text'
      }
    ];
    return tableColumns;
  },
  buildTableData: function(cmp, data) {
    /**@type {import('C30_ScheduleForcedAppointmentDashboard').TableRow[]} */
    var tableData = data.map(function(slot, index) {
      /**@type {import('C30_ScheduleForcedAppointmentDashboard').TableRow} */
      var row = Object.assign({}, slot, { index: index });
      return row;
    });
    return tableData;
  },
  rowSelectedHandler: function(cmp) {
    var slotsTable = this.slotsTableCmp(cmp);
    /**@type {import('C30_ScheduleForcedAppointmentDashboard').TableRow[]} */
    var selectedRows = slotsTable.getSelectedRows();
    var selectedRow = selectedRows[0];
    this.selectedRow(cmp, selectedRow);
  },
  showSchedulePopupHandler: function(cmp) {
    var that = this;
    var selectedRow = that.selectedRow(cmp);
    if (!selectedRow) {
      return;
    }
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var cmpDefinition = that.buildCmpDefinition(
      'C30_SubmitForcedAppointmentModal'
    );
    that.isLoading(cmp, true);
    $A.createComponent(
      cmpDefinition.name,
      {
        oncreated: cmp.getReference('c.onAppointmentCreated')
      },
      function(bodyCmp, status) {
        if (status === 'SUCCESS') {
          overlayLibCmp
            .showCustomModal({
              body: bodyCmp,
              cssClass: cmpDefinition.className + ' modal',
              showCloseButton: false,
              closeCallback: function() {}
            })
            .then(function(modalRef) {
              that.isLoading(cmp, false);
            });
        } else {
          console.log(status);
          that.isLoading(cmp, false);
        }
      }
    );
  },
  appointmentCreatedHandler: function(cmp) {
    this.refreshView();
    this.close(cmp);
  }
});