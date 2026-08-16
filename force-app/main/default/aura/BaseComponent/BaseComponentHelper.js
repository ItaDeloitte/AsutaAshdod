/**@type {import("BaseComponent").Helper} */
({
  attribute: function (cmp, attrName, value) {
    var prefix = 'v.';
    var valueName =
      attrName.indexOf(prefix) === 0 ? attrName : prefix + attrName;
    if (value === undefined) {
      return cmp.get(valueName);
    }
    return cmp.set(valueName, value);
  },
  property: function (object, propName, value) {
    if (value === undefined) {
      return object[propName];
    }
    object[propName] = value;
  },
  BASE_CONSTANTS: {
    appEventName: 'e.c:GenericApplicationEvent',
    appEventTypes: {},
    forceEventTypes: {
      closeQuickAction: 'e.force:closeQuickAction',
      refreshView: 'e.force:refreshView',
      createRecord: 'e.force:createRecord',
      editRecord: 'e.force:editRecord',
      showToast: 'e.force:showToast',
      navigateToURL: 'e.force:navigateToURL',
      navigateToSObject: 'e.force:navigateToSObject'
    },
    navigationTypes: {
      recordPage: 'standard__recordPage',
      objectPage: 'standard__objectPage',
      component: 'standard__component',
      knowledgeArticlePage: 'standard__knowledgeArticlePage',
      namedPage: 'standard__namedPage',
      navItemPage: 'standard__navItemPage',
      recordRelationshipPage: 'standard__recordRelationshipPage',
      webPage: 'standard__webPage'
    }
  },
  BASE_RES_PIPES: {
    statusPipe: function (res) {
      if (!res) {
        return res;
      }
      if (typeof res === 'object' && res.isSuccess) {
        return res.responseObj;
      }
      throw res;
    }
  },
  onScriptReady: function (cmp, scriptName) {
    var scriptControl;
    cmp._loadedScripts = cmp._loadedScripts || {};
    if (cmp._loadedScripts[scriptName]) {
      scriptControl = cmp._loadedScripts[scriptName];
    } else {
      scriptControl = {
        scriptName: scriptName,
        promise: null,
        resolve: null
      };
      scriptControl.promise = new Promise(function (resolve) {
        scriptControl.resolve = resolve;
      });
      cmp._loadedScripts[scriptName] = scriptControl;
    }
    return scriptControl.promise;
  },
  resolveScriptLoad: function (cmp, scriptName) {
    var loadedScripts = cmp._loadedScripts || {};
    var scriptControl = loadedScripts[scriptName];
    if (!scriptControl) {
      return;
    }
    scriptControl.resolve(scriptName);
  },

  isRendered: function (cmp, value) {
    return this.property(cmp, '_isRendered', value);
  },

  recordId: function (cmp, value) {
    return this.attribute(cmp, 'recordId', value);
  },

  isLoading: function (cmp, value) {
    return this.attribute(cmp, 'isLoading', value);
  },
  labels: function (cmp, value) {
    return this.attribute(cmp, 'labels', value);
  },
  getCustomLabels: function () {
    return {};
  },
  builderAttributes: function (cmp, value) {
    return this.attribute(cmp, 'builderAttributes', value);
  },
  isInitScriptsReady: function (cmp, value) {
    return this.attribute(cmp, 'isInitScriptsReady', value);
  },
  currentUser: function () {
    return $A.get('$SObjectType.CurrentUser');
  },
  $Locale: function () {
    return $A.get('$Locale');
  },

  globalServiceCmp: function (cmp) {
    return cmp.find('globalService');
  },

  globalServiceAll: function (cmp) {
    var lwcGlobalService = window['lwcGlobalService'];
    if (lwcGlobalService) {
      return lwcGlobalService;
    }
    var globalServiceCmp = this.globalServiceCmp(cmp);
    return globalServiceCmp.getAll();
  },

  globalServices: function (cmp) {
    return this.globalServiceAll(cmp).services;
  },

  executeApex: function (cmp, params, options) {
    /**@type {import("BaseComponent").ExecuteOptions} */
    var defaultOptions = {
      isStorable: false,
      withResponseObj: true,
      apexAction: 'execute'
    };
    options = Object.assign({}, defaultOptions, options);
    var apexAction = options.apexAction;

    /* var lwcExecuteApex = window['lwcExecuteApex'];

    if (lwcExecuteApex && apexAction === 'execute') {
      return lwcExecuteApex(params.controllerName, params.params).then(
        $A.getCallback(function (res) {
          return res;
        })
      );
    } */
    
    return new Promise(
      $A.getCallback(function (resolve, reject) {
        /**@type {Aura.ComponentAction} */
        var action = cmp.get('c.' + apexAction);
        action.setParams(params);
        if (options.isStorable) {
          action.setStorable();
        }
        action.setCallback(this, function (callbackResult) {
          if (callbackResult.getState() === 'SUCCESS') {
            var responseBody = callbackResult.getReturnValue();
            return resolve(responseBody);
          }
          if (callbackResult.getState() === 'ERROR') {
            console.log('ERROR', callbackResult.getError());
            return reject(callbackResult.getError());
          }
        });
        $A.enqueueAction(action);
      })
    );
  },
  executeApexFake: function (cmp, params, options) {
    /**@type {import("BaseComponent").ExecuteOptionsFake} */
    var defaultOptions = {
      data: null,
      error: null,
      emitError: false,
      delay: 2000,
      isStorable: false,
      withResponseObj: true
    };
    options = options || {};
    var mergedOptions = Object.assign({}, defaultOptions, options);
    return new Promise(
      $A.getCallback(function (resolve, reject) {
        console.log({
          message: 'Execute Fake Apex with',
          params: params,
          options: options
        });
        setTimeout(function () {
          if (mergedOptions.emitError) {
            return reject(options.error);
          }
          resolve(options.data);
        }, mergedOptions.delay);
      })
    );
  },
  closeQuickAction: function () {
    $A.get(this.BASE_CONSTANTS.forceEventTypes.closeQuickAction).fire();
  },
  refreshView: function () {
    $A.get(this.BASE_CONSTANTS.forceEventTypes.refreshView).fire();
  },

  showToast: function (options) {
    var message = options.message;
    if (typeof message !== 'string') {
      if (typeof message === 'object' && message.message) {
        options.message = message.message;
      } else {
        options.message = JSON.stringify(message);
      }
    }
    var toastEvent = $A.get(this.BASE_CONSTANTS.forceEventTypes.showToast);
    toastEvent.setParams(options);
    toastEvent.fire();
  },

  navigateToURL: function (url, options) {
    if (!url) {
      return;
    }
    var defaultOptions = {};
    var params = Object.assign({ url: url }, defaultOptions, options);
    var urlEvent = $A.get(this.BASE_CONSTANTS.forceEventTypes.navigateToURL);
    urlEvent.setParams(params);
    urlEvent.fire();
  },

  navigateToSobject: function (recordId, options) {
    if (!recordId) {
      return;
    }
    var defaultOptions = {};
    var params = Object.assign({ recordId: recordId }, defaultOptions, options);
    var navEvt = $A.get(this.BASE_CONSTANTS.forceEventTypes.navigateToSObject);
    navEvt.setParams(params);
    navEvt.fire();
  },
  navigate: function (cmp, params) {
    var navigation = cmp.find('navigation');
    if (Array.isArray(navigation)) {
      return;
    }
    return navigation.navigate(params);
  },

  emitEvent: function (cmp, eventType, params) {
    var event = cmp.getEvent(eventType);
    event.setParams(params);
    event.fire();
  },

  emitApplicationEvent: function (type, value) {
    var event = this.getApplicationEvent();
    var params = {
      type: type,
      value: value
    };
    event.setParams(params);
    event.fire();
  },

  getApplicationEvent: function () {
    return $A.get(this.BASE_CONSTANTS.appEventName);
  },

  windowData: function (cmp, data) {
    var cmpId = cmp.getGlobalId();
    if (data) {
      window[cmpId] = data;
    }
    return window[cmpId];
  },

  clearWindowData: function (cmp) {
    var cmpId = cmp.getGlobalId();
    delete window[cmpId];
  },

  normalizeRichText: function (text) {
    var result = text
      .replace(/<br\/?>/gi, '')
      .replace(/style="[^\"]*"/gi, '')
      .replace(/<\/?span[^>]*?>/gi, '')
      .replace(/<h\d[^>]*?>(.*)?<\/h\d>/gi, '<p><b>$1</b></p>')
      .replace(/<\/?img[^>]*?>/gi, '')
      .replace(/<table[^>]*?>.*?<\/table>/gi, '')
      .replace(/<a[^>]*href="(?!(\/\/|https?)).*?".*?>.*?<\/a>/gi, '');
    console.log({
      text: text,
      result: result
    });
    return result;
  },
  utils: {
    closest: function (element, matchSelector) {
      var self = this;
      if (!(element instanceof Element)) {
        return null;
      }
      if (!Element.prototype.closest) {
        Element.prototype.closest = function (/**@type {String} */ selector) {
          var el = this;
          do {
            if (self.matches(el, selector)) {
              return el;
            }
            // @ts-ignore
            el = el.parentElement || el.parentNode;
          } while (el !== null && el.nodeType === 1);
          return null;
        };
      }
      return element.closest(matchSelector);
    },
    matches: function (element, matchSelector) {
      if (!(element instanceof Element)) {
        return false;
      }
      if (!Element.prototype.matches) {
        Element.prototype.matches =
          Element.prototype['matchesSelector'] ||
          Element.prototype['mozMatchesSelector'] ||
          Element.prototype['msMatchesSelector'] ||
          Element.prototype['oMatchesSelector'] ||
          Element.prototype['webkitMatchesSelector'] ||
          function (selector) {
            var doc = this.document || this.ownerDocument;
            var matches = doc.querySelectorAll(selector);
            var i = matches.length;
            while (--i >= 0 && matches.item(i) !== this) {
              /*  */
            }
            return i > -1;
          };
      }
      return element.matches(matchSelector);
    }
  },
  unProxyData: function (data) {
    return JSON.parse(JSON.stringify(data));
  },
  buildHtmlServerError: function (err) {
    var that = this;
    var errors = that.buildServerErrorsArray(err);
    if (!errors) {
      return 'Unknown Error';
    }
    return errors.join('<br/>');
  },
  buildServerErrorsArray: function (err) {
    var that = this;
    var errors = [];
    if (Array.isArray(err)) {
      errors = err.map(function (item) {
        return item.message;
      });
    } else if (typeof err === 'object') {
      if (err.responseObj) {
        if (typeof err.responseObj === 'string') {
          errors = [err.responseObj];
        } else {
          errors = errors.concat(that.buildServerErrorsArray(err.responseObj));
        }
      } else if (err.message) {
        errors = [err.message];
      } else {
        errors = [JSON.stringify(err)];
      }
    } else {
      errors = [err];
    }
    return errors;
  },
  convertCmpsToArray: function (cmps) {
    if (Array.isArray(cmps)) {
      return cmps;
    }
    if (cmps) {
      return [cmps];
    }
    return [];
  },
  buildCmpDefinition: function (name) {
    /**@type {import('BaseComponent').CmpDefinition} */
    var definition = {
      name: 'c:' + name,
      className: 'c' + name
    };
    return definition;
  },
  buildAuraModalParams: function (modalName) {
    var promisesAndResolvers = ['create', 'close'].reduce(
      function (acc, name) {
        var promise = new Promise(function (resolve) {
          acc.resolvers[name] = resolve;
        });
        acc.promises[name] = promise;

        return acc;
      },
      { resolvers: {}, promises: {} }
    );

    var params = Object.assign(
      {
        modalName: modalName,
        cssClass: '',
        modalData: {},
        callbacks: {},
        resolvers: {},
        promises: {}
      },
      promisesAndResolvers
    );
    return params;
  }
});