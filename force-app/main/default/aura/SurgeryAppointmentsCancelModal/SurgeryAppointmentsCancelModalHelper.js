/**@type {import("SurgeryAppointmentsCancelModal").Helper} */
({
  init: function(cmp) {
    this.config(cmp);
    this.fetchAppointments(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},

  controllers: {
    LC_SurgeryCancel: 'LC_SurgeryCancel'
  },
  caseId: function(cmp, value) {
    return this.attribute(cmp, 'caseId', value);
  },
  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },
  tableColumns: function(cmp, value) {
    return this.attribute(cmp, 'tableColumns', value);
  },
  tableData: function(cmp, value) {
    return this.attribute(cmp, 'tableData', value);
  },
  overlayLibCmp: function(cmp) {
    return cmp.find('overlayLib');
  },
  actionModalInnerCmp: function(cmp) {
    return cmp.find('modalInner');
  },

  config: function(cmp, data) {
    var tableColumns = this.buildTableColumns(cmp);
    this.tableColumns(cmp, tableColumns);
  },
  fetchAppointments: function(cmp) {
    var that = this;
    var caseId = that.caseId(cmp);
    var params = {
      actionName: 'getAppointments',
      recordId: caseId
    };
    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_SurgeryCancel,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(
          /**@type {import('SurgeryAppointmentsCancelModal').TableRowRes[]} */ data
        ) {
          console.log(params, data);
          that.isLoading(cmp, false);
          var tableData = that.buildTableData(cmp, data);
          that.tableData(cmp, tableData);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isLoading(cmp, false);
          that.requestErrorHandler(cmp, err);
        })
      );
  },
  buildTableColumns: function(cmp) {
    /**@type {import('SurgeryAppointmentsCancelModal').TableColumn[]} */
    var columns = [
      {
        label: $A.get('$Label.c.Appointment_Name'),
        fieldName: 'Name',
        type: 'text'
      },
      {
        label: $A.get('$Label.c.Appointment_Date'),
        fieldName: 'Appointment_Date_Time__c',
        type: 'date'
      },
      {
        label: $A.get('$Label.c.Site_Name'),
        fieldName: 'siteName',
        type: 'text'
      },
      {
        label: $A.get('$Label.c.Doctor_Name'),
        fieldName: 'doctorName',
        type: 'text'
      },
      {
        label: $A.get('$Label.c.Action'),
        type: 'button',
        typeAttributes: { label: $A.get('$Label.c.Cancel'), name: 'cancel' }
      }
    ];
    return columns;
  },
  buildTableData: function(cmp, data) {
    /**@type {import('SurgeryAppointmentsCancelModal').TableRow[]} */
    var tableRows = data.map(function(item) {
      var siteName = item.Site__r ? item.Site__r.Name : '';
      var doctorName = item.Doctor_Account__r
        ? item.Doctor_Account__r.Name
        : '';
      return Object.assign({}, item, {
        siteName: siteName,
        doctorName: doctorName
      });
    });
    return tableRows;
  },
  close: function(cmp) {
    var overlayLibCmp = this.overlayLibCmp(cmp);
    overlayLibCmp.notifyClose();
  },
  cancelAppointment: function(cmp, row) {
    var that = this;
    var params = {
      actionName: 'cancelAppointment',
      recordId: row.Id
    };
    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    console.log(params);
    return that
      .executeApex(cmp, {
        controllerName: that.controllers.LC_SurgeryCancel,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(message) {
          console.log(params, message);
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: message
          });
          that.isLoading(cmp, false);
          that.fetchAppointments(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isLoading(cmp, false);
          that.requestErrorHandler(cmp, err);
        })
      );
  },
  requestErrorHandler: function(cmp, err) {
    console.log(err);
    this.serverError(cmp, this.buildHtmlServerError(err));
    var modalInnerCmp = this.actionModalInnerCmp(cmp);
    modalInnerCmp.scrollBody();
  }
});