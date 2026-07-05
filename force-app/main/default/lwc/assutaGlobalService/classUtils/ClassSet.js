//@ts-check

/**
 * @typedef {Object.<string,boolean>} ClassConfig
 * @typedef {string|ClassConfig} RawClassConfig
 */

export class ClassSet {
  /**
   * @type {ClassConfig}
   */
  classes = {};
  /**
   *
   * @param {RawClassConfig} classConfig
   */
  constructor(classConfig) {
    if (typeof classConfig === 'string') {
      const key = classConfig;
      classConfig = {};
      classConfig[key] = true;
    }
    Object.assign(this.classes, classConfig);
  }
  /**
   *
   * @param {RawClassConfig} classConfig
   *
   */
  add(classConfig) {
    if (typeof classConfig === 'string') {
      this.classes[classConfig] = true;
    } else {
      Object.assign(this.classes, classConfig);
    }

    return this;
  }

  invert() {
    Object.keys(this.classes).forEach((key) => {
      this.classes[key] = !this.classes[key];
    });
    return this;
  }
  /**
   * @returns {string}
   */
  toString() {
    return Object.keys(this.classes)
      .filter((key) => this.classes[key])
      .join(' ');
  }
}