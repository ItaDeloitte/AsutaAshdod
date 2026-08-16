//@ts-check
import { classUtils } from '../classUtils';
import { auraLwcBridgeService } from './auraLwcBridgeService';

/**
 *
 * @typedef {Object} ModalParamsPromises
 * @property {Promise} [create]
 * @property {Promise} [close]
 *
 * @typedef {Object} ModalParams
 * @property {string} modalName
 * @property {string} cssClass
 * @property {boolean} [showCloseButton]
 * @property {boolean} [useAuraModalDynamicLwc]
 * @property {*} modalData
 * @property {Object.<string,Function>} callbacks
 * @property {Object.<string,Function>} resolvers
 * @property {ModalParamsPromises} promises
 *
 *
 * @typedef {Object} ModalParamsConfig
 * @property {string} [cssClass]
 * @property {*} [modalData]
 * @property {boolean} [useAuraModalDynamicLwc]
 * @property {boolean} [showCloseButton]
 *
 *
 * @callback ShowModalFn
 * @param {ModalParams} params
 *
 *
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

class ModalService {
  eventEmitter = new classUtils.EventEmitter();
  events = {
    showModal: `${NAMESPACE} showModal`
  };
  /**
   * @type {AuraModalService[]}
   */
  auraModalServices = [];

  get modalSizeClassNames() {
    return modalSizeClassNames;
  }

  getEvents() {
    return this.events;
  }

  /**
   *
   * @param {AuraModalService} service
   * @returns {any}
   */
  addAuraModalService(service) {
    this.auraModalServices.push(service);
    return {
      unregister: () => this.removeAuraModalService(service.id)
    };
  }

  /**
   *
   * @param {string} serviceId
   */
  removeAuraModalService(serviceId) {
    this.auraModalServices = this.auraModalServices.filter(
      (item) => item.id !== serviceId
    );
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
        useAuraModalDynamicLwc: true,
        cssClass: 'slds-modal_small',
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
        detail: result
      })
    );
  }
}

export const modalService = new ModalService();