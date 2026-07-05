import { LightningElement, track, api } from 'lwc';
import { labels } from './labels';
import { modalService } from 'c/modalService';

export default class ConfirmModalNew extends LightningElement {
  @api modalParams = {};
  @track modalData = {
    title: labels.Confirmation,
    text: 'Confirm?',
    acceptLabel: labels.Yes,
    declineLabel: labels.No
  };

  connectedCallback() {
    const { modalData } = this.modalParams;
    this.modalData = Object.assign(this.modalData, modalData);
  }

  disconnectedCallback() {}

  get labels() {
    return labels;
  }

  declineClickHandler() {
    this.emitClose(false);
  }
  acceptClickHandler() {
    this.emitClose(true);
  }
  emitClose(result) {
    modalService.emitCloseModal(this, result);
  }
}