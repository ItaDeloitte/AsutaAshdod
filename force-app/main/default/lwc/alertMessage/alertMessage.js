import { LightningElement, api } from 'lwc';

export default class AlertMessage extends LightningElement {
  @api theme = 'default'; //default,warning,error,offline,success
  @api texture = false;
  @api closeable = false;
  prefixClass = 'slds-theme';
  get className() {
    return `slds-notify slds-notify_alert slds-m-bottom_small ${this.themeClassName} ${this.textureClassName}`;
  }

  get themeClassName() {
    return `${this.prefixClass}_${this.theme}`;
  }

  get textureClassName() {
    return this.texture ? `${this.prefixClass}_alert_texture` : '';
  }

  get buttonIconVariant() {
    return this.theme === 'default' ? 'bare' : 'bare-inverse';
  }

  closeHandler() {
    this.dispatchEvent(new CustomEvent('closealert'));
  }
}