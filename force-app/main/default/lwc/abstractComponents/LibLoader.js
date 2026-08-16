//@ts-check
import { resourceLoaderService } from 'c/resourceLoaderService';
import { utils } from 'c/utils';

/**
 * LibLoader
 */
export class LibLoader {
  scripts = [];
  styles = [];
  libKey = '';

  /**
   * @type {Promise}
   */
  loadPromise = null;
  isResourcesLoaded = false;

  /**
   *
   * @param {*} lwc
   */
  getLib(lwc) {
    if (this.isResourcesLoaded) {
      return Promise.resolve();
    }
    if (this.loadPromise) {
      return this.loadPromise;
    }
    this.loadPromise = this.loadLib(lwc);
    return this.loadPromise;
  }

  /**
   * @private
   * @param {*} lwc
   */
  loadLib(lwc) {
    return utils
      .promiseRetry(() => {
        return Promise.all([
          resourceLoaderService.loadScripts(lwc, this.scripts, true),
          resourceLoaderService.loadStyles(lwc, this.styles, true)
        ]);
      })
      .then(() => {
        this.isResourcesLoaded = true;
        return this.libKey;
      })
      .catch(() => {
        const errMessage = 'load failed';
        throw new Error(errMessage);
      });
  }
}