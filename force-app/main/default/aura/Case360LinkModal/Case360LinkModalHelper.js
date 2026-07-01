/**@type {import("Case360LinkModal").Helper} */
({
  init: function(cmp) {
    this.fetchCases(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},

  tableColumns: function(cmp, value) {
    return this.attribute(cmp, 'tableColumns', value);
  },
  tableData: function(cmp, value) {
    return this.attribute(cmp, 'tableData', value);
  },
  serverError: function(cmp, value) {
    return this.attribute(cmp, 'serverError', value);
  },

  overlayLibCmp: function(cmp) {
    return cmp.find('overlayLib');
  },

  close: function(cmp) {
    var overlayLibCmp = this.overlayLibCmp(cmp);
    overlayLibCmp.notifyClose();
  },

  cancel: function(cmp) {
    this.close(cmp);
  },

  config: function(cmp, cases) {
    var tableData = this.buildTableData(cases);
    var tableColumns = this.buildTableColumns();
    this.tableColumns(cmp, tableColumns);
    this.tableData(cmp, tableData);
  },
  buildTableData: function(data) {
    /**@type {import('Case360LinkModal').TableRow[]} */
    var tableData = data.map(function(item, index) {
      var appointmentName = item.memograph_exam__c
        ? item.memograph_exam__r.Name
        : '';
      var row = {
        id: item.Id,
        caseNumber: item.CaseNumber,
        accountName: item.Account.Name,
        ownerName: item.Owner.Name,
        appointmentName: appointmentName,
        index: index
      };
      return row;
    });
    return tableData;
  },
  buildTableColumns: function() {
    /**@type {import('Case360LinkModal').TableColumn[]} */
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
        typeAttributes: { label: $A.get('{!$Label.c.Next}'), name: 'link' }
      }
    ];
    return columns;
  },
  fetchCases: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var params = {
      actionName: 'getCases',
      recordId: recordId
    };
    that.serverError(cmp, '');
    that.isLoading(cmp, true);
    that
      .lcCase360Request(cmp, params)
      .then(
        $A.getCallback(function(data) {
          that.isLoading(cmp, false);
          that.config(cmp, data);
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
      actionName: 'linkRecommendation',
      recordId: recordId,
      caseId: caseId
    };
    that.serverError(cmp, '');
    that.isLoading(cmp, true);

    that
      .lcCase360Request(cmp, params)
      .then(
        $A.getCallback(function(message) {
          that.isLoading(cmp, false);
          that.showToast({
            type: 'success',
            title: $A.get('$Label.c.Success'),
            message: message
          });
          that.refreshView();
          that.close(cmp);
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
  lcCase360Request: function(cmp, params) {
    var that = this;
    console.log(params);
    return that
      .executeApex(cmp, {
        controllerName: 'LC_Case360Controller',
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(function(res) {
        console.log(params, res);
        return res;
      })
      .catch(function(err) {
        console.log(err);
        throw err;
      });
  }
});