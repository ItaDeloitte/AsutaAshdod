import { LightningElement, api, track } from 'lwc';

export class Modal extends LightningElement {
  @api modalParams = {};

  @track modalData = {
    builderAttributes: {}
  };

  connectedCallback() {
    const { modalData } = this.modalParams;
    this.modalData = Object.assign(this.modalData, modalData);
  }

  disconnectedCallback() {}

  cancelClickHandler() {
    this.emitClose();
  }

  emitClose(result) {
    this.dispatchEvent(
      new CustomEvent('close', {
        bubbles: true,
        cancelable: true,
        detail: result
      })
    );
  }
}