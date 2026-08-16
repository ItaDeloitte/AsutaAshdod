//@ts-check
import { LightningElement, api, track } from 'lwc';
import { labels } from './labels';

export default class PicklistSelect extends LightningElement {
  // static delegatesFocus = true;
  variant = '';
  @api placeholder = '';
  @api label = '';
  @api name = '';
  @api options = [];
  _value = '';
  _required = false;
  _connected = false;
  _inputElement;
  _initialValueSet = false;
  _disabled = false;
  _inputElementRefreshNeeded = true;
  _helpMessage = '';
  error = null;

  @api
  get value() {
    return this._value;
  }
  set value(val) {
    this._value = val;
    if (this.inputElement) {
      this.inputElement.value = this._value;
    }
  }

  @api
  get required() {
    return this._required;
    // this._updateProxyInputAttributes('required');
  }
  set required(val) {
    this._required = val;
  }

  @api
  get disabled() {
    return this._disabled;
  }

  set disabled(value) {
    this._disabled = value;
    // this._updateProxyInputAttributes('disabled');
  }

  @api
  checkValidity() {
    if (!this.required) {
      return true;
    }
    return !!this.value;
  }

  @api
  reportValidity() {
    const isValid = this.checkValidity();
    if (!isValid) {
      this.error = labels.ThisFieldIsRequired;
    } else {
      this.error = null;
    }
    return isValid;
  }

  @api
  focus() {
    if (this._connected) {
      this.inputElement.focus();
    }
  }

  @api
  blur() {
    if (this._connected) {
      this.inputElement.blur();
    }
  }
  @api
  showHelpMessageIfInvalid() {
    this.reportValidity();
  }

  @api
  clearErrors() {
    this.error = null;
  }

  get formElClassNames() {
    const classNames = ['slds-form-element'];
    if (this.error) {
      classNames.push('slds-has-error');
    }
    return classNames.join(' ');
  }

  connectedCallback() {
    this._connected = true;
  }

  disconnectedCallback() {
    this._connected = false;
    this._inputElement = null;
  }

  renderedCallback() {
    if (!this._initialValueSet && this.inputElement) {
      this.inputElement.value = this._value;
      this._initialValueSet = true;
    }
  }

  get isLabelHidden() {
    // return this.variant === VARIANT.LABEL_HIDDEN;
    return false;
  }

  get isLabelStacked() {
    // return this.variant === VARIANT.LABEL_STACKED;
    return false;
  }

  get inputElement() {
    if (!this._connected) {
      return null;
    }

    if (!this._inputElement || this._inputElementRefreshNeeded) {
      // @ts-ignore
      let inputElement = this.template.querySelector('select');

      this._inputElementRefreshNeeded = false;
      this._inputElement = inputElement;
    }

    return this._inputElement;
  }

  dispatchChangeEventWithDetail(detail) {
    this.dispatchEvent(
      new CustomEvent('change', {
        composed: true,
        bubbles: true,
        detail
      })
    );
  }

  handleFocus() {
    this.dispatchEvent(new CustomEvent('focus'));
  }

  handleBlur(event) {
    if (!event.relatedTarget || !this.template.contains(event.relatedTarget)) {
      this.dispatchEvent(new CustomEvent('blur'));
    }
  }

  handleChange(event) {
    event.stopPropagation();
    const value = event.target.value;

    if (this.value === value) {
      return;
    }

    this._value = value;
    this.clearErrors();
    this.reportValidity();
    this.dispatchChangeEvent();
  }

  dispatchChangeEvent() {
    const detail = {};

    detail.value = this.inputElement.value;

    this.dispatchChangeEventWithDetail(detail);
  }
}