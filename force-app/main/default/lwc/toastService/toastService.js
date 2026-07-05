//@ts-check
// @ts-ignore
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { labels } from './labels';

/**
 * @typedef {Object} ToastParams
 * @property {string} [title]
 * @property {variants} [variant]
 * @property {modes} [mode]
 * @property {string} message
 * @property {any[]} [messageData]
 *
 */

/**
 * @enum {string}
 */
export const variants = {
  error: 'error',
  success: 'success',
  warning: 'warning',
  info: 'info'
};
/**
 * @enum {string}
 */
export const modes = {
  dismissable: 'dismissable',
  pester: 'pester',
  sticky: 'sticky'
};

class ToastService {
  get labels() {
    return labels;
  }
  get variants() {
    return variants;
  }
  get modes() {
    return modes;
  }

  /**
   *
   * @param {*} lwcEl
   * @param {ToastParams} config
   */
  error(lwcEl, config) {
    this.show(
      lwcEl,
      Object.assign({ title: labels.Error }, config, {
        variant: variants.error
      })
    );
  }
  /**
   *
   * @param {*} lwcEl
   * @param {ToastParams} config
   */
  success(lwcEl, config) {
    this.show(
      lwcEl,
      Object.assign({ title: labels.Success }, config, {
        variant: variants.success
      })
    );
  }
  /**
   *
   * @param {*} lwcEl
   * @param {ToastParams} config
   */
  warning(lwcEl, config) {
    this.show(
      lwcEl,
      Object.assign({ title: labels.Warning }, config, {
        variant: variants.warning
      })
    );
  }
  /**
   *
   * @param {*} lwcEl
   * @param {ToastParams} config
   */
  info(lwcEl, config) {
    this.show(
      lwcEl,
      Object.assign({ title: labels.Info }, config, { variant: variants.info })
    );
  }
  /**
   *
   * @param {*} lwcEl
   * @param {ToastParams} config
   */
  show(lwcEl, config) {
    const options = Object.assign(
      {
        message: 'message',
        mode: modes.dismissable
      },
      config
    );
    lwcEl.dispatchEvent(new ShowToastEvent(options));
  }
}

export const toastService = new ToastService();