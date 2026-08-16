//@ts-check
class InternalApiEventService {
  /**
   *
   * @param {string} category
   * @param {string} methodName
   * @param {*} [methodArgs]
   * @returns
   */
  invoke(category, methodName, methodArgs) {
    return new Promise((resolve, reject) => {
      const apiEvent = new CustomEvent('internalapievent', {
        bubbles: true,
        composed: true,
        cancelable: false,
        detail: {
          category,
          methodName,
          methodArgs,
          callback: (err, response) => {
            if (err) {
              return reject(err);
            }
            return resolve(response);
          }
        }
      });

      window.dispatchEvent(apiEvent);
    });
  }
}

export const internalApiEventService = new InternalApiEventService();