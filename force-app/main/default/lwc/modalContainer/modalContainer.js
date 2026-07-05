import { LightningElement, api } from 'lwc';

export default class ModalContainer extends LightningElement {
  @api isLoading = false;
  hasFooterContent = false;

  get modalContainerClassName() {
    return `slds-is-relative modal-container ${
      this.hasFooterContent ? '' : 'hide-footer'
    }`;
  }

  /**@param {any} event */
  slotChangeHandler(event) {
    /**@type {HTMLSlotElement} */
    const target = event.target;
    this.hasFooterContent = target.assignedElements().length > 0;
  }
}