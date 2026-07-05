//@ts-check
// @ts-ignore
import { NavigationMixin } from 'lightning/navigation';

/**
 * @typedef {Object} PageReference
 * @property {string} type
 * @property {Object.<string,*>} [attributes]
 * @property {Object.<string,*>} [state]
 *
 */

class NavigationService {
  /**
   *
   * @param {*} lwcWithNavigationMixin
   * @param {PageReference} params
   * @returns {Promise<string>}
   */
  generateUrl(lwcWithNavigationMixin, params) {
    return lwcWithNavigationMixin[NavigationMixin.GenerateUrl](params);
  }
  /**
   *
   * @param {*} lwcWithNavigationMixin
   * @param {PageReference} params
   */
  navigateTo(lwcWithNavigationMixin, params) {
    lwcWithNavigationMixin[NavigationMixin.Navigate](params);
  }
}

export const navigationService = new NavigationService();