//@ts-check
import { LightningElement } from 'lwc';
import jssResource from '@salesforce/resourceUrl/jss';
import { resourceLoaderService } from './resourceLoaderService';
import { utils } from '../utils';

const lightningJssPath = `${jssResource}/dist/lightning-jss.min.js`;

class JssService {
  /**
   * @type {Promise}
   */
  loadPromise = null;
  isResourcesLoaded = false;

  /**
   *
   * @param {LightningElement} lwcElement
   */
  getJss(lwcElement) {
    if (this.isResourcesLoaded) {
      return Promise.resolve();
    }
    if (this.loadPromise) {
      return this.loadPromise;
    }
    this.loadPromise = this.loadLib(lwcElement);
    return this.loadPromise;
  }
  /**
   * @private
   * @param {LightningElement} lwcElement
   */
  loadLib(lwcElement) {
    return utils
      .promiseRetry(() => {
        return Promise.all([
          resourceLoaderService.loadScripts(lwcElement, [lightningJssPath])
        ]);
      })
      .then(() => {
        console.log('jss loaded');
        this.isResourcesLoaded = true;
      })
      .catch(() => {
        const errMessage = 'jss load fail';
        console.log(errMessage);
        throw new Error(errMessage);
      });
  }
}

export const jssService = new JssService();