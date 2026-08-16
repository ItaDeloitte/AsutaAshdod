//@ts-check
import { LightningElement, api, wire } from 'lwc';
import { svgIcons } from './svgIcons';
import { images } from './images';
import { config } from './config';
import { utils } from './utils';
import { domUtils } from './domUtils';
import * as pubsub from './pubsub';
import * as services from './services';
import { classUtils } from './classUtils';
import { abstractComponents } from './abstractComponents';

const { LightningElementWithNavigation } = abstractComponents;

const lwcGlobalService = {
  svgIcons,
  images,
  config,
  utils,
  domUtils,
  services,
  pubsub,
  classUtils
};
window['lwcGlobalService'] = lwcGlobalService;

export default class AssutaGlobalService extends LightningElementWithNavigation {
  connectedCallback() {
    this.elementRef.dispatchEvent(new CustomEvent('ready'));
  }
  disconnectedCallback() {}

  @api getServices() {
    return services;
  }

  @api getAll() {
    return {
      svgIcons,
      images,
      config,
      utils,
      domUtils,
      services,
      pubsub,
      classUtils
    };
  }

  @api
  registerListener(eventName, callback) {
    pubsub.registerListener(eventName, callback, this);
  }

  @api
  unregisterListener(eventName, callback) {
    pubsub.unregisterListener(eventName, callback, this);
  }

  @api
  unregisterAllListeners() {
    pubsub.unregisterAllListeners(this);
  }

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
  }
}

export {
  svgIcons,
  images,
  config,
  utils,
  domUtils,
  services,
  pubsub,
  classUtils
};