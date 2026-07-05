import { LightningElement, api, track } from 'lwc';

export default class ErrorsAlert extends LightningElement {
  @api error = '';
  @api errors = [];
  @api closeable = false;

  get hasErrors() {
    if (this.error) {
      return true;
    }
    return Array.isArray(this.errors) && this.errors.length > 0;
  }

  closeHandler() {
    this.dispatchEvent(new CustomEvent('close'));
  }
}