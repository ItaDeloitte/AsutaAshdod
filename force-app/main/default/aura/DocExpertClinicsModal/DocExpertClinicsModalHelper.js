/**@type {import("DocExpertClinicsModal").Helper} */
({
  init: function(cmp) {
    this.fetchClinics(cmp);
  },
  destroy: function(cmp) {},
  render: function(cmp) {},

  clinics: function(cmp, value) {
    return this.attribute(cmp, 'clinics', value);
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
  doctorId: function(cmp, value) {
    return this.attribute(cmp, 'doctorId', value);
  },

  config: function(cmp, clinics) {
    this.clinics(cmp, clinics);
    var tableData = this.buildTableData(clinics);
    var tableColumns = this.buildTableColumns();
    this.tableColumns(cmp, tableColumns);
    this.tableData(cmp, tableData);
    if (tableData.length === 1) {
      this.schedule(cmp, tableData[0]);
    }
  },
  buildTableData: function(data) {
    /**@type {import('DocExpertClinicsModal').TableRow[]} */
    var tableData = data.map(function(item, index) {
      var clinicDetails = item.Clinic__r;
      /**@type {import('DocExpertClinicsModal').TableRow} */
      var row = {
        address: item.Address,
        calendarClinic: item.Schedule_System__c,
        clinicId: clinicDetails.Id,
        clinicPhone: item.Phone__c,
        doctorId: item.Doctors__c,
        id: item.Id,
        clinicUrl: '/' + clinicDetails.Id,
        name: clinicDetails.Name,
        workingHours: item.Working_Hours__c,
        payerFactorName: item.payerFactorName,
        siteName: clinicDetails.Site__r ? clinicDetails.Site__r.Name : '',
        siteUrl: clinicDetails.Site__c ? '/' + clinicDetails.Site__c : '',
        index: index
      };
      return row;
    });
    return tableData;
  },
  buildTableColumns: function() {
    /**@type {import('DocExpertClinicsModal').TableColumn[]} */
    var columns = [
      {
        label: $A.get('{!$Label.c.ClinicName}'),
        fieldName: 'clinicUrl',
        type: 'url',
        typeAttributes: {
          label: { fieldName: 'name' },
          tooltip: { fieldName: 'name' },
          target: '_blank'
        }
      },
      {
        label: $A.get('{!$Label.c.ClinicAddress}'),
        fieldName: 'address',
        type: 'text'
      },
      {
        label: $A.get('{!$Label.c.ClinicPhone}'),
        fieldName: 'clinicPhone',
        type: 'phone'
      },
      {
        label: $A.get('{!$Label.c.ClinicWorkingHours}'),
        fieldName: 'workingHours',
        type: 'text'
      },
      {
        label: $A.get('{!$Label.c.ClinicCalendar_Doc_expert}'),
        fieldName: 'calendarClinic',
        type: 'text'
      },
      {
        label: $A.get('{!$Label.c.DocInsuranceFactor}'),
        fieldName: 'payerFactorName',
        type: 'text'
      },
      {
        label: $A.get('{!$Label.c.ClinicSiteName}'),
        fieldName: 'siteUrl',
        type: 'url',
        typeAttributes: {
          label: { fieldName: 'siteName' },
          tooltip: { fieldName: 'siteName' },
          target: '_blank'
        }
      },
      {
        label: 'Action',
        type: 'button',
        typeAttributes: { label: $A.get('{!$Label.c.Next}'), name: 'schedule' } //
      }
    ];
    return columns;
  },
  fetchClinics: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var doctorId = that.doctorId(cmp);
    that.isLoading(cmp, true);
    that
      .fetchDoctorClinics(cmp, doctorId, recordId)
      .then(
        $A.getCallback(function(clinics) {
          that.isLoading(cmp, false);
          that.config(cmp, clinics);
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
  schedule: function(cmp, row) {
    var that = this;
    var caseId = that.recordId(cmp);
    var clinicId = row.clinicId;
    var doctorId = that.doctorId(cmp);
    var params = {
      actionName: 'chooseClinic',
      clinicId: clinicId,
      junctionId: row.id,
      doctorId: doctorId,
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
        controllerName: that.controllers.LC_DocExpertise,
        params: params
      })
      .then(that.BASE_RES_PIPES.statusPipe)
      .then(
        $A.getCallback(function(
          /**@type {import('DocExpertClinicsModal').ChooseClinicRes} */ res
        ) {
          console.log(params, res);
          that.isLoading(cmp, false);
          switch (res.action) {
            case 'create': {
              return that.emitCreateAppointmentForm(
                cmp,
                createRecordEvent,
                res.appointment
              );
            }
            case 'schedule': {
              return that.showAppointmentsModal(cmp, row);
            }
          }
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
    var clinics = this.clinics(cmp);
    var clinic = clinics[row.index];
    var doctorId = this.doctorId(cmp);
    /**@type {import('DocExpertBase').CloseModalEventParams} */
    var params = {
      modalName: 'clinics',
      data: {
        clinic: clinic,
        doctorId: doctorId
      }
    };
    this.emitEvent(cmp, 'onCloseModal', { value: params });
    this.close(cmp);
  },
  emitCreateAppointmentForm: function(cmp, event, data) {
    // var that = this;
    var params = {
      entityApiName: 'Appointment__c',
      recordTypeId: data.RecordTypeId,
      defaultFieldValues: data,
      navigationLocation: 'LOOKUP',
      panelOnDestroyCallback: function() {
        // console.log('create closed');
      }
    };
    event.setParams(params);
    event.fire();
    this.close(cmp);
  },
  showAppointmentsModal: function(cmp, row) {
    var that = this;
    var caseId = that.recordId(cmp);
    var clinics = this.clinics(cmp);
    var clinic = clinics[row.index];
    var doctorId = this.doctorId(cmp);
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var cmpDefinition = that.buildCmpDefinition('AppointmentsDashboard');
    that.isLoading(cmp, true);
    $A.createComponent(
      cmpDefinition.name,
      {
        recordId: caseId,
        mode: 'create',
        screenMode: 'doctorHeader',
        doctorId: doctorId,
        clinic: clinic
      },
      function(preparedCmp, status, message) {
        if (status === 'SUCCESS') {
          overlayLibCmp
            .showCustomModal({
              body: preparedCmp,
              cssClass: cmpDefinition.className + ' dashboard-modal',
              showCloseButton: true,
              closeCallback: function() {}
            })
            .then(function(modalRef) {
              that.isLoading(cmp, false);
              that.close(cmp);
            });
        } else {
          console.log(status, message);
          that.isLoading(cmp, false);
          that.close(cmp);
        }
      }
    );
  }
});