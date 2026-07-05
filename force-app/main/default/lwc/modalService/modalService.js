//@ts-check
import { auraLwcBridgeService } from 'c/auraLwcBridgeService';

/**@module ModalService */

/**
 *
 * @typedef {Object} ModalParamsPromises
 * @property {Promise} [create]
 * @property {Promise} [close]
 */
/** @typedef {Object} ModalParams
 * @property {string} modalName
 * @property {string} cssClass
 * @property {boolean} [showCloseButton]
 * @property {boolean} [useAuraModalDynamicLwc]
 * @property {*} modalData
 * @property {Object.<string,Function>} callbacks
 * @property {Object.<string,Function>} resolvers
 * @property {ModalParamsPromises} promises
 */
/**
 * @typedef {Object} ModalParamsConfig
 * @property {string} [cssClass]
 * @property {*} [modalData]
 * @property {boolean} [showCloseButton]
 * @property {boolean} [useAuraModalDynamicLwc]
 */
/**
 * @callback ShowModalFn
 * @param {ModalParams} params
 */
/**
 * @typedef {Object} AuraModalService
 * @property {string} id
 * @property {ShowModalFn} showModal
 */

const NAMESPACE = '[MODAL SERVICE]';

const modalSizeClassNames = {
  small: 'slds-modal_small',
  medium: 'slds-modal_medium',
  large: 'slds-modal_large'
};

/**
 * ModalService
 */
class ModalService {
  /**
   * @type {AuraModalService[]}
   */
  auraModalServices = [];

  get modalSizeClassNames() {
    return modalSizeClassNames;
  }

  /**
   *
   * @param {string} modalName
   * @param {ModalParamsConfig} [config]
   * @returns {ModalParams}
   */
  buildAuraModalParams(modalName, config) {
    const promisesAndResolvers = ['create', 'close'].reduce(
      (acc, name) => {
        const promise = new Promise((resolve) => {
          acc.resolvers[name] = resolve;
        });
        acc.promises[name] = promise;

        return acc;
      },
      { resolvers: {}, promises: {} }
    );

    /**@type {ModalParams} */
    const params = Object.assign(
      {
        modalName: modalName,
        cssClass: 'slds-modal_small',
        useAuraModalDynamicLwc: true,
        modalData: {},
        callbacks: {},
        resolvers: {},
        promises: {}
      },
      config,
      promisesAndResolvers
    );
    return params;
  }

  /**
   *
   * @param {*} lwcElement
   * @param {ModalParams} modalParams
   */
  showModal(lwcElement, modalParams) {
    auraLwcBridgeService.showModal(modalParams);
    return modalParams.promises.close;
  }

  /**
   *
   * @param {*} lwcElement
   * @param {*} [result]
   */
  emitCloseModal(lwcElement, result) {
    lwcElement.dispatchEvent(
      new CustomEvent('close', {
        bubbles: true,
        cancelable: true,
        composed: true,
        detail: result
      })
    );
  }
}

export const modalService = new ModalService();