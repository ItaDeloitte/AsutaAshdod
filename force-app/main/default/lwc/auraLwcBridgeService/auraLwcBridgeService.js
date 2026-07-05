//@ts-check
import { EventEmitter, utils } from 'c/utils';
import { workspaceService } from 'c/workspaceService';
import { componentFactoryService } from 'c/componentFactoryService';

/**
 * @callback isConsoleNavigation
 * @returns {Promise<boolean>}
 *
 *
 * @typedef {Object} BridgeConfig
 * @property {string} id
 * @property {any} cmp
 * @property {any} globalServiceCmp
 * @property {boolean} isDetached
 * @property {isConsoleNavigation} isConsoleNavigation
 * @property {Function} isOnFocusedTab
 * @property {Function} showModal
 * @property {Function} showToast
 */

/**
 * AuraLwcBridgeService
 */
class AuraLwcBridgeService {
  eventEmitter = new EventEmitter();
  events = {};
  /**
   * @type {BridgeConfig[]}
   */
  auraBridges = [];
  /**
   * @type {Promise<BridgeConfig>}
   */
  _createDetachedAuraLwcBridgePromise;
  /**
   * @type {any}
   */
  _detachedBridgeCmp;

  /**
   * @type {BridgeConfig}
   */
  _detachedAuraLwcBridgeConfig;

  constructor() {
    utils.timeout().then(() => {
      this.createDetachedAuraLwcBridge();
    });
  }

  /**
   *
   * @param {*} bridgeConfig
   * @returns {any}
   */
  addAuraBridge(bridgeConfig) {
    if (!bridgeConfig.isDetached) {
      this.auraBridges.push(bridgeConfig);
    } else {
      this._detachedAuraLwcBridgeConfig = bridgeConfig;
    }

    return {
      unregister: () => this.removeAuraBridge(bridgeConfig.id)
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
    return Promise.resolve()
      .then(() => {
        const bridge = this.auraBridges[0];
        if (!bridge) {
          return null;
        }

        return workspaceService.isConsoleNavigation().then((isConsole) => {
          if (!isConsole) {
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
      })
      .then((bridge) => {
        if (bridge) {
          return bridge;
        }
        if (this._detachedAuraLwcBridgeConfig) {
          return Promise.resolve(this._detachedAuraLwcBridgeConfig);
        }
        return this.createDetachedAuraLwcBridge();
      });
  }

  getAuraContext() {
    return eval('(function(){return $A})()');
  }

  /**
   *
   * @returns {Promise<BridgeConfig>}
   */
  createDetachedAuraLwcBridge() {
    const auraContext = this.getAuraContext();

    if (this._createDetachedAuraLwcBridgePromise) {
      return this._createDetachedAuraLwcBridgePromise;
    }

    this._createDetachedAuraLwcBridgePromise = componentFactoryService
      .createComponent(auraContext, 'c:AuraLwcBridge')
      .then((bridgeCmp) => {
        bridgeCmp.superRender();
        this._detachedBridgeCmp = bridgeCmp;
        bridgeCmp.detachedInit();
        return this._detachedAuraLwcBridgeConfig;
      });
    return this._createDetachedAuraLwcBridgePromise;
  }

  getDetachedBridge() {
    if (this._createDetachedAuraLwcBridgePromise) {
      return this._createDetachedAuraLwcBridgePromise;
    }
    return this.createDetachedAuraLwcBridge();
  }
}

export const auraLwcBridgeService = new AuraLwcBridgeService();