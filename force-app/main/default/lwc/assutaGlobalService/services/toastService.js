//@ts-check
// @ts-ignore
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { labels } from '../labels';

/**
 * @typedef {Object} ToastParams
 * @property {string} [title]
 * @property {Variants} [variant]
 * @property {Modes} [mode]
 * @property {string} message
 * @property {any[]} [messageData]
 *
 */

/**
 * @enum {string}
 */
export const Variants = {
  error: 'error',
  success: 'success',
  warning: 'warning',
  info: 'info'
};
/**
 * @enum {string}
 */
export const Modes = {
  dismissable: 'dismissable',
  pester: 'pester',
  sticky: 'sticky'
};

class ToastService {
  labels = labels;
  variants = Variants;
  modes = Modes;

  /**
   *
   * @param {*} lwcEl
   * @param {ToastParams} config
   */
  error(lwcEl, config) {
    this.show(
      lwcEl,
      Object.assign({ title: labels.Error }, config, {
        variant: Variants.error
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
        variant: Variants.success
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
      Object.assign({ title: labels.Success }, config, {
        variant: Variants.warning
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
      Object.assign({ title: labels.Info }, config, { variant: Variants.info })
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
        mode: Modes.dismissable
      },
      config
    );
    lwcEl.dispatchEvent(new ShowToastEvent(options));
  }
}

export const toastService = new ToastService();