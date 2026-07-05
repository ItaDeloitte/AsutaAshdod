//@ts-check
// @ts-ignore
import { NavigationMixin } from 'lightning/navigation';
// @ts-ignore
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

/**
 * @typedef {Object} PageReference
 * @property {string} type
 * @property {Object.<string,*>} [attributes]
 * @property {Object.<string,*>} [state]
 *
 */

const pageRefTypes = {
  webPage: 'standard__webPage',
  recordRelationshipPage: 'standard__recordRelationshipPage',
  recordPage: 'standard__recordPage',
  objectPage: 'standard__objectPage',
  navItemPage: 'standard__navItemPage',
  namedPage: 'standard__namedPage',
  knowledgeArticlePage: 'standard__knowledgeArticlePage',
  commNamedPage: 'comm__namedPage',
  commLoginPage: 'comm__loginPage',
  component: 'standard__component',
  app: 'standard__app'
};

const pageActionNames = {
  view: 'view',
  new: 'new',
  edit: 'edit',
  list: 'list',
  home: 'home'
};

class NavigationService {
  get pageRefTypes() {
    return pageRefTypes;
  }
  get pageActionNames() {
    return pageActionNames;
  }
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
   * @param {boolean} [replace]
   */
  navigateTo(lwcWithNavigationMixin, params, replace) {
    lwcWithNavigationMixin[NavigationMixin.Navigate](params, replace);
  }

  /**
   *
   * @param {*} lwcWithNavigationMixin
   */
  navigateToLogin(lwcWithNavigationMixin) {
    lwcWithNavigationMixin[NavigationMixin.Navigate]({
      type: pageRefTypes.commLoginPage,
      attributes: {
        actionName: 'login'
      }
    });
  }

  /**
   *
   * @param {*} lwcWithNavigationMixin
   */
  navigateToLogout(lwcWithNavigationMixin) {
    lwcWithNavigationMixin[NavigationMixin.Navigate]({
      type: pageRefTypes.commLoginPage,
      attributes: {
        actionName: 'logout'
      }
    });
  }

  /**
   *
   * @param {string} recordId
   * @returns {PageReference}
   */
  buildRecordViewParams(recordId) {
    return {
      type: pageRefTypes.recordPage,
      attributes: {
        recordId: recordId,
        actionName: pageActionNames.view
      }
    };
  }

  /**
   *
   * @param {*} fieldValues
   * @returns {string}
   */
  encodeFieldValues(fieldValues) {
    return encodeDefaultFieldValues(fieldValues);
  }

  /**
   *
   * @param {*} stateRef
   * @param {*} [element]
   * @returns
   */
  getLinkInfo(stateRef, element = document.body) {
    return new Promise((resolve, reject) => {
      const getLinkInfoEvent = new CustomEvent(
        'lightningroutingservicegetlinkinfo',
        {
          detail: {
            stateRef,
            callback: (err, linkInfo) => {
              if (err) {
                reject(err);
              } else {
                resolve(linkInfo);
              }
            }
          },

          bubbles: true,
          composed: true,
          cancelable: true
        }
      );

      element.dispatchEvent(getLinkInfoEvent);
    });
  }
}

export const navigationService = new NavigationService();