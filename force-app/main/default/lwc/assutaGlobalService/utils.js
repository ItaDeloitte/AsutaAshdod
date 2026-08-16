//@ts-check

import { ClassSet } from './classUtils/ClassSet';
// @ts-ignore
import currentFormFactor from '@salesforce/client/formFactor';

const formFactorNames = {
  Large: 'Large',
  Medium: 'Medium',
  Small: 'Small'
};

class Utils {
  ClassSet = ClassSet;
  /**
   *
   * @param {*} cmp
   * @param {string} attrName
   * @param {*} value
   */
  attribute(cmp, attrName, value) {
    var prefix = 'v.';
    var valueName =
      attrName.indexOf(prefix) === 0 ? attrName : `${prefix}${attrName}`;
    if (value === undefined) {
      return cmp.get(valueName);
    }
    cmp.set(valueName, value);
    return undefined;
  }
  /**
   *
   * @param {*} data
   * @returns {string}
   */
  unproxyData(data) {
    if (data === undefined) {
      return data;
    }
    return JSON.parse(JSON.stringify(data));
  }
  /**
   *
   * @param {Function} func
   * @param {number} wait
   * @param {boolean} immediate
   * @returns {Function}
   */
  debounce(func, wait, immediate) {
    var timeout;

    return function executedFunction() {
      var context = this;
      var args = arguments;

      var later = function () {
        timeout = null;
        if (!immediate) func.apply(context, args);
      };

      var callNow = immediate && !timeout;

      clearTimeout(timeout);

      // eslint-disable-next-line @lwc/lwc/no-async-operation
      timeout = setTimeout(later, wait);

      if (callNow) func.apply(context, args);
    };
  }
  /**
   *
   * @param {Date} date
   * @returns {String}
   */
  formatDateForDateInput(date) {
    if (!(date instanceof Date)) {
      return '';
    }
    return `${date.getFullYear()}-${date.getMonth() + 1}-${date.getDate()}`;
  }
  /**
   *
   * @param {any[]} data
   * @param {string} key
   * @returns {Object}
   */
  buildMapFromArray(data, key) {
    if (!Array.isArray(data)) {
      return {};
    }
    return data.reduce((acc, item) => {
      acc[item[key]] = item;
      return acc;
    }, {});
  }
  /**
   *
   * @param {Array<string|number>} values
   * @returns {any[]}
   */
  buildOptionsFromValues(values = []) {
    return values.map((val) => {
      return { label: val, value: val };
    });
  }
  /**
   *
   * @param {string} url
   * @param {string} [fileName]
   */
  downloadFileFromUrl(url, fileName) {
    const linkEl = document.createElement('a');
    linkEl.href = url;
    linkEl.download = fileName;
    linkEl.style.display = 'none';
    linkEl.target = '_blank';
    document.body.appendChild(linkEl);
    linkEl.click();
    document.body.removeChild(linkEl);
  }
  /**
   *
   * @param {*} [params]
   * @param {*} [options]
   * @returns {Promise}
   */
  fakeRequest(params, options) {
    return new Promise((resolve) => {
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(() => {
        console.log(params);
        resolve();
      }, 1000);
    });
  }
  /**
   *
   * @param {string} template
   * @param {any[]} data
   * @returns {string}
   */
  formatTemplateText(template = '', data = []) {
    const formattedText = data.reduce((acc, dataText, index) => {
      const regexp = new RegExp(`\\{${index}\\}`, 'g');
      return acc.replace(regexp, dataText);
    }, template);
    return formattedText;
  }
  /**
   *
   * @param {string} template
   * @param {Object} data
   * @returns {string}
   */
  formatTemplateTextWithNamedParams(template = '', data = {}) {
    const formattedText = Object.keys(data).reduce((acc, key) => {
      const regexp = new RegExp(`\\{${key}\\}`, 'g');
      return acc.replace(regexp, data[key]);
    }, template);
    return formattedText;
  }
  /**
   *
   * @param {string} term
   * @returns {string}
   */
  normalizeSearchTerm(term) {
    return term.trim().replace(/\*/g, '').toLowerCase();
  }
  /**
   *
   * @param {number} [interval]
   * @returns {Promise}
   */
  timeout(interval) {
    return new Promise((resolve) => {
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      setTimeout(resolve, interval);
    });
  }
  /**
   * @return {Promise}
   */
  animationFrame() {
    return new Promise((resolve) => {
      // eslint-disable-next-line @lwc/lwc/no-async-operation
      window.requestAnimationFrame(resolve);
    });
  }

  /**
   *
   * @param {string} fieldName
   * @param {string} separator
   * @returns {string[]}
   */
  buildFieldNamePath(fieldName = '', separator = '.') {
    return fieldName.split(separator);
  }
  /**
   *
   * @param {Object} obj
   * @param {string|string[]} path
   * @returns {any}
   */
  getPropByFieldPath(obj = {}, path = []) {
    if (typeof path === 'string') {
      path = this.buildFieldNamePath(path);
    }
    let fieldValue;
    try {
      fieldValue = path.reduce((val, pathItem) => {
        return val[pathItem];
      }, obj);
    } catch (err) {
      console.log(err);
    }
    return fieldValue;
  }
  /**
   *
   * @param {Function} fn
   * @param {number} [retryTimeout]
   * @param {number} [maxRetries]
   * @returns {Promise}
   */
  promiseRetry(fn, retryTimeout = 100, maxRetries = 10) {
    let tryCounter = 0;

    const fnWrapper = () => {
      return Promise.resolve()
        .then(() => fn(tryCounter))
        .catch((err) => {
          err = err || new Error('retryFn failed');
          if (tryCounter < maxRetries) {
            console.log('retryFn failed. trying again', err);
            tryCounter += 1;
            return this.timeout(retryTimeout).then(() => fnWrapper());
          }
          throw err;
        });
    };
    return fnWrapper();
  }
  /**
   *
   * @param {Promise[]} promisesArray
   * @returns {Promise}
   */
  buildSequencePromises(promisesArray) {
    return promisesArray.reduce((acc, promise) => {
      return acc.then(() => promise);
    }, Promise.resolve());
  }

  getFormFactorNames() {
    return formFactorNames;
  }

  getCurrentFormFactor() {
    return currentFormFactor;
  }

  isMobile() {
    return currentFormFactor !== formFactorNames.Large;
  }

  /**
   *
   * @param {*} val
   */
  parseJsonString(val) {
    return typeof val === 'string' ? JSON.parse(val) : val;
  }
}

export const utils = new Utils();