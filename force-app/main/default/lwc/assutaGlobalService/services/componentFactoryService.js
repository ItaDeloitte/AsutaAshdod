//@ts-check

/**
 * @typedef {Object} CmpDefinition
 * @property {string} name
 * @property {string} className
 */

/**
 * @typedef {ComponentFactoryService} Service
 */

class ComponentFactoryService {
  statuses = {
    SUCCESS: 'SUCCESS'
  };

  /**
   *
   * @param {*} auraContext
   * @param {string} componentName
   * @param {*} attributes
   */
  createComponent(auraContext, componentName, attributes = {}) {
    return new Promise((resolve, reject) => {
      /**
       *
       * @param {*} component
       * @param {string} status
       * @param {string} errorMessage
       */
      const cb = (component, status, errorMessage) => {
        if (status === this.statuses.SUCCESS) {
          resolve(component);
        } else {
          reject({
            status,
            errorMessage
          });
        }
      };
      auraContext.createComponent(componentName, attributes, cb);
    });
  }

  createComponents() {}

  /**
   *
   * @param {string} componentName
   * @param {string} [namespace]
   * @returns {CmpDefinition}
   */
  buildComponentDefinition(componentName, namespace = 'c') {
    return {
      name: `${namespace}:${componentName}`,
      className: `${namespace}${componentName}`
    };
  }
}

export const componentFactoryService = new ComponentFactoryService();