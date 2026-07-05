//@ts-check
import { classUtils } from '../classUtils';

/**
 * @typedef {Object} BridgeConfig
 * @property {string} id
 * @property {boolean} isConsoleNavigation
 * @property {Function} isOnFocusedTab
 * @property {Function} showModal
 * @property {Function} showToast
 */

class AuraLwcBridgeService {
  eventEmitter = new classUtils.EventEmitter();
  events = {};
  /**
   * @type {BridgeConfig[]}
   */
  auraBridges = [];

  /**
   *
   * @param {*} service
   * @returns {any}
   */
  addAuraBridge(service) {
    this.auraBridges.push(service);
    return {
      unregister: () => this.removeAuraBridge(service.id)
    };
  }

  /**
   *
   * @param {string} serviceId
   */
  removeAuraBridge(serviceId) {
    this.auraBridges = this.auraBridges.filter((item) => item.id !== serviceId);
  }

  /**
   *
   * @param {*} params
   */
  showToast(params) {
    this.getFirstAuraBridge().then((bridge) => {
      if (!bridge) {
        return;
      }
      bridge.showToast(params);
    });
  }

  /**
   *
   * @param {*} params
   */
  showModal(params) {
    this.getFirstAuraBridge().then((bridge) => {
      if (!bridge) {
        return;
      }
      bridge.showModal(params);
    });
  }

  refreshView() {
    return this.getFirstAuraBridge().then((bridge) => {
      if (!bridge) {
        return;
      }
      bridge.refreshView();
    });
  }

  getFirstAuraBridge() {
    return Promise.resolve().then(() => {
      const bridge = this.auraBridges[0];
      if (!bridge) {
        return null;
      }

      if (!bridge.isConsoleNavigation) {
        return bridge;
      }

      const promises = this.auraBridges.map((bridge) => {
        return bridge.isOnFocusedTab().then((isOnFocusedTab) => {
          return isOnFocusedTab ? bridge : null;
        });
      });
      return Promise.all(promises).then((bridges) => {
        const bridgesOnFocusedTab = bridges.filter((item) => !!item);
        return bridgesOnFocusedTab[0];
      });
    });
  }
}

export const auraLwcBridgeService = new AuraLwcBridgeService();