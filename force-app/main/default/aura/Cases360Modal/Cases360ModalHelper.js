({
  init: function(cmp) {
    this.getCases(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},
  CONSTANTS: {},
  controllers: {
    caseAppointmentButtons: 'LC_CaseAppointmentButtons'
  },

  cases: function(cmp, value) {
    return this.attribute(cmp, 'cases', value);
  },
  tableColumns: function(cmp, value) {
    return this.attribute(cmp, 'tableColumns', value);
  },
  tableData: function(cmp, value) {
    return this.attribute(cmp, 'tableData', value);
  },
  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },

  config: function(cmp, cases) {
    this.cases(cmp, cases);
    var tableData = this.buildTableData(cases);
    var tableColumns = this.buildTableColumns();
    this.tableColumns(cmp, tableColumns);
    this.tableData(cmp, tableData);
    if (tableData.length === 1) {
      this.linkAppointment(cmp, tableData[0]);
    }
  },
  buildTableData: function(data) {
    var tableData = data.map(function(item, index) {
      var row = {
        id: item.Id,
        caseNumber: item.CaseNumber,
        accountName: item.Account.Name,
        ownerName: item.Owner.Name,
        appointmentName: item.memograph_exam__c == null ? '' : item.memograph_exam__r.Name,
        index: index
      };
      return row;
    });
    return tableData;
  },
  buildTableColumns: function() {
    var columns = [
      {
        label: $A.get('{!$Label.c.Case_Number}'),
        fieldName: 'caseNumber',
        type: 'text'
      },
      {
        label: $A.get('{!$Label.c.Account_Name}'),
        fieldName: 'accountName',
        type: 'text'
      },
      {
        label: $A.get('{!$Label.c.Owner_Name}'),
        fieldName: 'ownerName',
        type: 'text'
      },
      {
        label: $A.get('{!$Label.c.AppointmentName}'),
        fieldName: 'appointmentName',
        type: 'text'
      },
      {
        label: 'Action',
        type: 'button',
        typeAttributes: { label: $A.get('{!$Label.c.Next}'), name: 'schedule' } //
      }
    ];
    return columns;
  },
  getCases: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var params = {
      actionName: 'getCases',
      recordId: recordId
    };
    return that
      .executeApex(cmp, {
        controllerName: this.controllers.caseAppointmentButtons,
        params: params
      })
      .then(this.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(cases) {
          console.log('cases ' + cases);
          that.isLoading(cmp, false);
          that.config(cmp, cases);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
          that.serverError(cmp, that.buildHtmlServerError(err));
        })
      );
  },
  linkAppointment: function(cmp, row) {
    var that = this;
    var recordId = that.recordId(cmp);
    var caseId = row.id;
    var params = {
      actionName: 'linkAppointment',
      recordId: recordId,
      caseId: caseId
    };
    console.log(params);
    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    var createRecordEvent = $A.get(
      that.BASE_CONSTANTS.forceEventTypes.createRecord
    );
    that
      .executeApex(cmp, {
        controllerName: that.controllers.caseAppointmentButtons,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(
          res
        ) {
          console.log(params, res);
          that.isLoading(cmp, false);
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: $A.get('$Label.c.Appointment_linked')
          });
          that.refreshView();
          return that.emitCloseModal(cmp, row);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
          that.isLoading(cmp, false);
          that.serverError(cmp, that.buildHtmlServerError(err));
        })
      );
  },
  emitCloseModal: function(cmp, row) {
    var cases = this.cases(cmp);
    var cas = cases[row.index];
    var params = {
      modalName: 'cases',
      data: cas
    };
    this.isLoading(cmp, false);
    this.emitEvent(cmp, 'onCloseModal', { value: params });
    this.close(cmp);
  }
});