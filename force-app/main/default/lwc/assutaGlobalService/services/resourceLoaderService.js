//@ts-check
// @ts-ignore
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { utils } from '../utils';

/**
 * @callback LoadPromiseFn
 * @returns {Promise}
 *
 */

class ResourceLoaderService {
  /**
   * @type {Object.<string,boolean>}
   */
  loadedResources = {};
  /**
   * @type {Object.<string,Promise>}
   */
  progressPromises = {};

  /**
   *
   * @param {*} lwcElement
   * @param {string[]} fileUrls
   * @param {boolean} [inSequence]
   * @returns {Promise}
   */
  loadScripts(lwcElement, fileUrls, inSequence = false) {
    const promises = fileUrls.map((url) =>
      this.loadResource(() => loadScript(lwcElement, url), url)
    );
    if (inSequence) {
      return utils.buildSequencePromises(promises);
    }
    return Promise.all(promises);
  }

  /**
   *
   * @param {*} lwcElement
   * @param {string[]} fileUrls
   * @param {boolean} [inSequence]
   * @returns {Promise}
   */
  loadStyles(lwcElement, fileUrls, inSequence = false) {
    const promises = fileUrls.map((url) =>
      this.loadResource(() => loadStyle(lwcElement, url), url)
    );
    if (inSequence) {
      return utils.buildSequencePromises(promises);
    }
    return Promise.all(promises);
  }
  /**
   * @private
   * @param {LoadPromiseFn} loadPromiseFn
   * @param {string} fileUrl
   * @returns {Promise}
   */
  loadResource(loadPromiseFn, fileUrl) {
    if (this.loadedResources[fileUrl]) {
      return Promise.resolve();
    }
    if (this.progressPromises[fileUrl]) {
      return this.progressPromises[fileUrl];
    }
    this.progressPromises[fileUrl] = loadPromiseFn()
      .then(() => {
        this.loadedResources[fileUrl] = true;
        delete this.progressPromises[fileUrl];
      })
      .catch(() => {
        delete this.progressPromises[fileUrl];
        throw new Error(`Load Resource Error for "${fileUrl}"`);
      });

    return this.progressPromises[fileUrl];
  }
}

export const resourceLoaderService = new ResourceLoaderService();