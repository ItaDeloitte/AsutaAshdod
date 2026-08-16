//@ts-check
import { LightningElement, api } from 'lwc';
import { modalService } from 'c/modalService';
import { labels } from './labels';

export default class DocExpertDashboardButton extends LightningElement {
  @api recordId = '';
  @api label = 'Doc Expert Dashboard';

  connectedCallback() {}

  disconnectedCallback() {}

  get labels() {
    return labels;
  }

  buttonClickHandler() {
    this.showDocExpertDashboardModal();
  }

  showDocExpertDashboardModal() {
    const modalParams = modalService.buildAuraModalParams(
      'docExpertDashboardModal',
      {
        modalData: {
          recordId: this.recordId
        },
        cssClass: 'doc-expert-dashboard-modal',
        useAuraModalDynamicLwc: true
      }
    );
    modalService.showModal(this, modalParams).catch(() => {
      console.log('error');
    });
  }
}