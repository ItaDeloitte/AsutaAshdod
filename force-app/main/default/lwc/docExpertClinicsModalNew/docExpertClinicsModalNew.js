import { LightningElement, api } from 'lwc';
import { docExpertClinicsService } from './docExpertClinicsService';
import { modalService } from 'c/modalService';
import { docExpertService, buildClinic } from 'c/docExpertService';
import { errorsService } from 'c/errorsService';
import { LightningElementWithNavigation } from 'c/abstractComponents';
import { navigationService } from 'c/navigationService';
import { tableColumns, rowActions } from './tableConfig';
import { labels } from './labels';

/**@typedef {DocExpertServiceTypes.Clinic} Clinic */

export default class DocExpertClinicsModalNew extends LightningElementWithNavigation {
  @api modalParams;
  recordId = '';
  doctorId = '';

  errors = [];
  /**@type {Clinic[]} */
  tableData = [];
  isLoading = false;

  connectedCallback() {
    const { modalData } = this.modalParams;
    this.recordId = modalData.recordId;
    this.doctorId = modalData.doctorId;
    this.fetchClinics();
  }

  disconnectedCallback() {}

  get labels() {
    return labels;
  }

  get tableColumns() {
    return tableColumns;
  }

  fetchClinics() {
    const { recordId, doctorId } = this;
    this.isLoading = true;

    docExpertService
      .getDoctorClinics({ recordId, doctorId })
      .then((res) => this.buildTableRows(res))
      .then((rows) => {
        this.isLoading = false;
        this.tableData = rows;
        if (this.tableData.length === 1) {
          this.schedule(this.tableData[0]);
        }
      })
      .catch((err) => {
        this.isLoading = false;
        this.errors = errorsService.buildServerErrorsArray(err);
      });
  }

  /**@param {any[]} rowsData */
  buildTableRows(rowsData) {
    return Promise.all(rowsData.map((item) => buildClinic(this, item)));
  }

  /**@param {Clinic} row */
  schedule(row) {
    const { recordId } = this;

    this.resetErrors();
    this.isLoading = true;

    docExpertClinicsService
      .chooseClinic({ recordId, id: row.id })
      .then((res) => {
        this.isLoading = false;
        switch (res.action) {
          case 'create': {
            return this.emitCreateAppointmentForm(res.appointment);
          }
          case 'schedule': {
            return this.showAppointmentsModal(row);
          }
          default: {
            return null;
          }
        }
      })
      .catch((err) => {
        this.isLoading = false;
        this.errors = errorsService.buildServerErrorsArray(err);
      });
  }
  /**@param {any} data */
  emitCreateAppointmentForm(data) {
    const { defaultFieldValues, objectApiName, recordTypeId } = data;
    const defaultValues =
      navigationService.encodeFieldValues(defaultFieldValues);

    const params = {
      type: navigationService.pageRefTypes.objectPage,
      attributes: {
        objectApiName,
        actionName: 'new'
      },
      state: {
        recordTypeId,
        navigationLocation: 'LOOKUP',
        defaultFieldValues: defaultValues
      }
    };
    navigationService.navigateTo(this, params);
    this.emitClose();
  }

  /**@param {Clinic} row */
  showAppointmentsModal(row) {
    const { recordId, doctorId } = this;
    this.isLoading = true;
    this.emitClose();

    const modalParams = modalService.buildAuraModalParams(
      'AppointmentsDashboard',
      {
        cssClass: 'dashboard-modal',
        modalData: {
          recordId: recordId,
          mode: 'create',
          screenMode: 'doctorHeader',
          doctorId: doctorId,
          clinic: {
            Id: row.id,
            Clinic__c: row.clinicId,
            Clinic__r: { Id: row.clinicId }
          }
        },
        showCloseButton: true,
        useAuraModalDynamicLwc: false
      }
    );
    modalService
      .showModal(this, modalParams)
      .then((res) => {
        this.isLoading = false;
      })
      .catch((err) => {
        this.isLoading = false;
        console.error(err);
      });
  }

  /**@param {any} event */
  rowActionHandler(event) {
    const { action, row } = event.detail;

    switch (action.name) {
      case rowActions.schedule: {
        return this.schedule(row);
      }
      default: {
        return null;
      }
    }
  }

  /**@param {any} [result] */
  emitClose(result) {
    modalService.emitCloseModal(this, result);
  }

  closeErrorsHandler() {
    this.resetErrors();
  }

  resetErrors() {
    this.errors = [];
  }
}