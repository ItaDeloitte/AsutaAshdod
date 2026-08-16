//@ts-check
import { LightningElement, api } from 'lwc';
import { svgIcons } from './svgIcons';
import { images } from './images';
import { appConfig } from 'c/appConfig';
import * as pubsub from './pubsub';
import * as services from './services';
import { LightningElementWithNavigation } from 'c/abstractComponents';

const config = appConfig;

const lwcGlobalService = {
  svgIcons,
  images,
  config,
  appConfig,
  services,
  pubsub
};

// eslint-disable-next-line dot-notation
// window['lwcGlobalService'] = lwcGlobalService;

export default class GlobalService extends LightningElementWithNavigation {
  connectedCallback() {
    this.elementRef.dispatchEvent(new CustomEvent('ready'));
  }
  disconnectedCallback() {}

  @api getServices() {
    return services;
  }

  @api getAll() {
    return lwcGlobalService;
  }

  /**
   *
   * @param {string} eventName
   * @param {Function} callback
   */
  @api
  registerListener(eventName, callback) {
    pubsub.registerListener(eventName, callback, this);
  }

  /**
   *
   * @param {string} eventName
   * @param {Function} callback
   */
  @api
  unregisterListener(eventName, callback) {
    pubsub.unregisterListener(eventName, callback, this);
  }

  @api
  unregisterAllListeners() {
    pubsub.unregisterAllListeners(this);
  }

  /**
   *
   * @param {string} eventName
   * @param {*} data
   */
  @api
  fireEvent(eventName, data) {
    pubsub.fireEvent(this.pageRef, eventName, data);
  }

  @api getLwcContext() {
    return () => this.elementRef;
  }
  /**
   *
   * @param {Function} cb
   */
  @api callWithLwcContext(cb) {
    if (typeof cb === 'function') {
      return cb(this);
    }
    throw new Error('cb must be a function');
  }
}

export { svgIcons, images, appConfig, config, services, pubsub };