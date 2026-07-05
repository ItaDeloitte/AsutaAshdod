import { LightningElement, api } from 'lwc';
import { modalService } from 'c/modalService';
import { errorsService } from 'c/errorsService';
import { toastService } from 'c/toastService';
import { checkAppointmentService } from './checkAppointmentService';
import { labels } from './labels';

export default class CheckAccountFutureAppointmentButton extends LightningElement {
  @api recordId = '';
  isLoading = false;
  isModalOpened = false;

  connectedCallback() {}

  disconnectedCallback() {}

  get labels() {
    return labels;
  }

  get isButtonDisabled() {
    return this.isLoading || this.isModalOpened;
  }

  buttonClickHandler() {
    this.isLoading = true;
    checkAppointmentService
      .checkFutureAppointment(this.recordId)
      .then((isExists) => {
        // this.isLoading = false;
        this.isModalOpened = true;
        return this.appointmentResolver(isExists);
      })
      .then(() => {
        this.isLoading = false;
        this.isModalOpened = false;
      })
      .catch((err) => {
        this.isLoading = false;
        this.isModalOpened = false;
        const errMessage = errorsService.buildServerErrorsString(err);
        toastService.error(this, { message: errMessage });
      });
  }

  /**
   *
   * @param {boolean} isExists
   */
  async appointmentResolver(isExists) {
    const { recordId } = this;

    if (!isExists) {
      const caseId = await checkAppointmentService.createCase(
        recordId,
        'create'
      );

      return this.showDocExpertDashboardModal({ caseId });
    }

    const isConfirmed = await this.showConfirmModal();

    if (typeof isConfirmed !== 'boolean') {
      return null;
    }

    const action = isConfirmed ? 'update' : 'create';

    const caseId = await checkAppointmentService.createCase(recordId, action);

    if (isConfirmed) {
      return this.showSelectAppointmentForUpdateModal({ caseId });
    }
    return this.showDocExpertDashboardModal({ caseId });
  }

  showConfirmModal() {
    const modalParams = modalService.buildAuraModalParams('confirmModalNew', {
      modalData: {
        title: labels.ConfirmationTitle,
        text: labels.ConfirmationText,
        acceptLabel: labels.ConfirmationYes,
        declineLabel: labels.ConfirmationNo
      },
      cssClass: '',
      useAuraModalDynamicLwc: true
    });
    return modalService.showModal(this, modalParams);
  }

  /**
   *
   * @param {Record<any,any>} res
   */
  showSelectAppointmentForUpdateModal(res) {
    let selectedAppointment = null;

    const modalParams = modalService.buildAuraModalParams(
      'AppointmentsUpdate',
      {
        modalData: {
          recordId: res.caseId,
          closeCallback: (result) => {
            selectedAppointment = result.value;
          }
        },
        cssClass: 'cAppointmentsUpdate update-modal',
        useAuraModalDynamicLwc: false
      }
    );
    return modalService.showModal(this, modalParams).then(() => {
      if (selectedAppointment) {
        return this.showAppointmentsDashboard(res, selectedAppointment);
      }
      return null;
    });
  }

  /**
   *
   * @param {*} res
   * @param {*} appointment
   */
  showAppointmentsDashboard(res, appointment) {
    const modalParams = modalService.buildAuraModalParams(
      'AppointmentsDashboard',
      {
        modalData: {
          recordId: res.caseId,
          mode: 'update',
          clinic: null,
          screenMode: 'doctorHeader',
          selectedAppointment: appointment
        },
        cssClass: 'cAppointmentsDashboard dashboard-modal',
        useAuraModalDynamicLwc: false
      }
    );
    return modalService.showModal(this, modalParams);
  }

  /**
   *
   * @param {Record<any,any>} res
   */
  showDocExpertDashboardModal(res) {
    const modalParams = modalService.buildAuraModalParams(
      'docExpertDashboardModal',
      {
        modalData: {
          recordId: res.caseId
        },
        cssClass: 'doc-expert-dashboard-modal',
        useAuraModalDynamicLwc: true
      }
    );
    return modalService.showModal(this, modalParams);
  }
}