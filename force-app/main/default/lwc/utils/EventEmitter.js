//@ts-check

/**
 *
 * @typedef {Object} Subscription
 * @property {Function} unsubscribe
 */

export class EventEmitter {
  constructor() {
    this.registry = {};
  }
  /**
   *
   * @param {string} name
   * @param {Function} listener
   * @returns {Subscription}
   */
  on(name, listener) {
    this.registry[name] = this.registry[name] || [];
    this.registry[name].push(listener);
    return {
      unsubscribe: () => this.removeListener(name, listener)
    };
  }
  /**
   *
   * @param {string} name
   * @param {Function} listener
   */
  once(name, listener) {
    const doOnce = function () {
      listener.apply(null, arguments);
      this.removeListener(name, doOnce);
    }.bind(this);
    return this.on(name, doOnce);
  }
  /**
   *
   * @param {...any} name
   *
   */
  emit(name) {
    const args = Array.prototype.slice.call(arguments, 1);
    const listeners = this.registry[name];
    let count = 0;
    if (listeners) {
      listeners.forEach((listener) => {
        count += 1;
        listener.apply(null, args);
      });
    }
    return count > 0;
  }
  /**
   *
   * @param {string} name
   * @param {Function} listener
   */
  removeListener(name, listener) {
    const listeners = this.registry[name];
    if (listeners) {
      for (let i = 0, len = listeners.length; i < len; i += 1) {
        if (listeners[i] === listener) {
          listeners.splice(i, 1);
        }
      }
    }
  }
}