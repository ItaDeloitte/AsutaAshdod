/**@type {import("BaseAutocomplete").Helper} */
({
  init: function(cmp) {
    var self = this;
    this.checkInitValue(cmp);
    self.attachWindowClickEvent(cmp);
    // this.onScriptReady(cmp, '$').then(function(scriptName) {
    //   self.attachWindowClickEvent(cmp);
    // });
  },
  CONSTANTS: {
    searchDelay: 300
  },
  /*  */
  term: function(cmp, value) {
    return this.attribute(cmp, 'searchTerm', value);
  },
  keyupTimeoutId: function(cmp, id) {
    return this.property(cmp, '_keyupTimeoutId', id);
  },
  isForceClearTerm: function(cmp, value) {
    return this.attribute(cmp, 'isForceClearTerm', value);
  },
  isPlainAutoComplete: function(cmp, value) {
    return this.attribute(cmp, 'isPlainAutoComplete', value);
  },
  isDisabled: function(cmp, value) {
    return this.attribute(cmp, 'isDisabled', value);
  },
  results: function(cmp, options) {
    return this.attribute(cmp, 'searchResults', options);
  },
  value: function(cmp, value) {
    return this.attribute(cmp, 'value', value);
  },
  selectedOption: function(cmp, value) {
    return this.attribute(cmp, 'selectedOption', value);
  },
  isListOpen: function(cmp, value) {
    return this.attribute(cmp, 'isListOpen', value);
  },
  handlerAttr: function(cmp) {
    var cmpId = cmp.getGlobalId();
    return '[data-handler="' + cmpId + '"]';
    // return '[data-handler]';
  },
  isInited: function(cmp, value) {
    return this.attribute(cmp, 'isInited', value);
  },
  isFocused: function(cmp, value) {
    return this.attribute(cmp, 'isFocused', value);
  },
  isTouched: function(cmp, value) {
    return this.attribute(cmp, 'isTouched', value);
  },
  required: function(cmp, value) {
    return this.attribute(cmp, 'required', value);
  },
  validity: function(cmp, value) {
    return this.attribute(cmp, 'validity', value);
  },
  customMessageVisible: function(cmp, value) {
    return this.attribute(cmp, 'customMessageVisible', value);
  },
  customMessage: function(cmp, value) {
    return this.attribute(cmp, 'customMessage', value);
  },
  customValidityMessage: function(cmp, value) {
    return this.attribute(cmp, 'customValidityMessage', value);
  },
  listenerFn: function(cmp, value) {
    return this.property(cmp, '_listenerFn', value);
  },
  /*  */
  inputCmp: function(cmp) {
    return cmp.find('input');
  },
  keyup: function(cmp, event) {
    var self = this;
    var term = event.target.value;
    var currentTerm = this.term(cmp);
    if (currentTerm === term) {
      //TODO:check
      return;
    }
    var isPlainAutoComplete = this.isPlainAutoComplete(cmp);

    var delay = this.CONSTANTS.searchDelay;
    this.term(cmp, term);
    this.clearKeyupTimeout(cmp);

    if (isPlainAutoComplete) {
      this.value(cmp, term);
      this.validate(cmp);
      this.isFocused(cmp, true);
      this.emitChange(cmp);
    }

    var timeoutId = window.setTimeout(
      $A.getCallback(function() {
        self.emitSearch(cmp, term);
      }),
      delay
    );
    this.keyupTimeoutId(cmp, timeoutId);
  },
  checkInitValue: function(cmp) {
    var value;
    // var isDisabled = this.isDisabled(cmp);
    // if (isDisabled) {
    //   this.isInited(cmp, true);
    //   return;
    // }
    var isPlainAutoComplete = this.isPlainAutoComplete(cmp);
    if (isPlainAutoComplete) {
      value = this.value(cmp);
      this.term(cmp, value);
      this.isInited(cmp, true);
      this.triggerSearch(cmp);
      return;
    }

    var selectedOption = this.selectedOption(cmp);
    value = this.value(cmp);

    if (selectedOption) {
      this.value(cmp, selectedOption.value);
      this.term(cmp, selectedOption.label);
      this.isInited(cmp, true);
      this.triggerSearch(cmp);
      return;
    } else if (value) {
      this.emitInitSearch(cmp, value);
    } else {
      this.isInited(cmp, true);
      this.triggerSearch(cmp);
    }
  },
  selectOption: function(cmp, value) {
    var isPlainAutoComplete = this.isPlainAutoComplete(cmp);
    var prevValue = this.value(cmp);
    var option = this.findOption(cmp, value);
    if (option) {
      this.selectedOption(cmp, option);
      this.value(cmp, value);
      this.term(cmp, option.label);
      this.isListOpen(cmp, false);
    } else {
      this.selectedOption(cmp, null);
      this.value(cmp, '');
    }
    if (isPlainAutoComplete || prevValue !== value) {
      this.emitChange(cmp);
    }
    this.validate(cmp);
  },
  findOption: function(cmp, value) {
    var searchResults = this.results(cmp);
    return searchResults.find(function(item) {
      return item.value === value;
    });
  },
  focusInput: function(cmp) {
    var isInited = this.isInited(cmp);
    var value = this.value(cmp);
    var isPlainAutoComplete = this.isPlainAutoComplete(cmp);
    if (!isPlainAutoComplete && (!isInited || value)) {
      return;
    }
    this.isFocused(cmp, true);
    this.isListOpen(cmp, true);
  },
  blurInput: function(cmp) {
    this.isFocused(cmp, false);
    this.isTouched(cmp, true);
    this.customMessageVisible(cmp, false);
    this.customMessage(cmp, '');
  },
  emitChange: function(cmp) {
    var value = this.value(cmp);
    var option = this.selectedOption(cmp);
    var params = {
      value: value,
      option: option
    };
    this.emitEvent(cmp, 'onchange', {
      value: params
    });
  },
  emitSearch: function(cmp, term) {
    this.isLoading(cmp, true);
    var params = {
      done: $A.getCallback(this.doneSearchCallback.bind(this, cmp)),
      term: term
    };
    this.emitEvent(cmp, 'onsearch', { value: params });
  },
  emitInitSearch: function(cmp, value) {
    var params = {
      done: $A.getCallback(this.doneInitCallback.bind(this, cmp)),
      value: value
    };
    this.emitEvent(cmp, 'oninitsearch', { value: params });
  },
  doneInitCallback: function(cmp, option, err) {
    if (err) {
      console.log(err);
      return;
    }
    this.selectedOption(cmp, option);
    if (option) {
      this.term(cmp, option.label);
    }
    this.isInited(cmp, true);
    this.emitSearch(cmp, option ? option.label : '');
  },
  doneSearchCallback: function(cmp, results, err) {
    this.isLoading(cmp, false);
    if (err) {
      console.log(err);
      return;
    }
    var isFocused = this.isFocused(cmp);
    this.results(cmp, results);
    if (isFocused) {
      this.isListOpen(cmp, true);
    }
  },
  attachWindowClickEvent: function(cmp) {
    var listenerFn = $A.getCallback(this.closeListenerFn.bind(this, cmp));
    window.document.body.addEventListener('click', listenerFn);
    this.listenerFn(cmp, listenerFn);
  },
  closeListenerFn: function(cmp, event) {
    var isListOpen = this.isListOpen(cmp);
    if (!isListOpen) {
      return;
    }
    var dataHandlerAttr = this.handlerAttr(cmp);
    var prevTerm = this.term(cmp);
    var isPlainAutoComplete = this.isPlainAutoComplete(cmp);
    var target = event.target;
    if (!this.utils.closest(target, dataHandlerAttr)) {
      this.isListOpen(cmp, false);
      if (!isPlainAutoComplete) {
        var selectedOption = this.selectedOption(cmp);
        if (selectedOption) {
          this.term(cmp, selectedOption.label);
        } else {
          this.term(cmp, '');
          if (prevTerm) {
            this.emitSearch(cmp, '');
          }
        }
      }
    }
  },
  changeSearchTerm: function(cmp) {
    var value = this.value(cmp);
    this.term(cmp, value);
  },
  destroy: function(cmp) {
    this.clearKeyupTimeout(cmp);
    this.clearEvents(cmp);
  },
  clearKeyupTimeout: function(cmp) {
    var keyupTimeoutId = this.keyupTimeoutId(cmp);
    window.clearTimeout(keyupTimeoutId);
  },
  clearEvents: function(cmp) {
    var listenerFn = this.listenerFn(cmp);
    window.document.body.removeEventListener('click', listenerFn);
  },
  prepareInput: function(cmp) {
    var inputCmp = this.inputCmp(cmp);
    if (!inputCmp || !cmp.isValid()) {
      return;
    }
    var inputEl = inputCmp.getElement();
    inputEl.setAttribute('autocomplete', 'off');
  },
  clearValue: function(cmp) {
    this.selectOption(cmp, null);
    this.term(cmp, '');
    var inputCmp = this.inputCmp(cmp);
    if (inputCmp) {
      var inputEl = inputCmp.getElement();
      inputEl.focus();
    }
    this.emitSearch(cmp, '');
  },
  validate: function(cmp) {
    var customValidityMessage = this.customValidityMessage(cmp);
    var validity = {
      valueMissing: false,
      customMessage: customValidityMessage,
      valid: true
    };

    var value = this.value(cmp);

    var required = this.required(cmp);
    if (required && !value) {
      validity.valueMissing = true;
      validity.valid = false;
    }
    if (customValidityMessage) {
      validity.valid = false;
    }
    this.validity(cmp, validity);
    return validity;
  },
  setCustomMessage: function(cmp, message) {
    this.customMessageVisible(cmp, true);
    this.customMessage(cmp, message);
  },
  resetCustomMessage: function(cmp) {
    this.customMessageVisible(cmp, false);
    this.customMessage(cmp, '');
  },
  reset: function(cmp, emitChange) {
    this.selectedOption(cmp, null);
    this.term(cmp, '');
    this.value(cmp, '');
    this.isTouched(cmp, false);
    if (emitChange) {
      this.emitChange(cmp);
    }
  },
  setOption: function(cmp, option) {
    var prevValue = this.value(cmp);
    var prevTerm = this.term(cmp);
    var term = option ? option.label : '';
    var value = option ? option.value : '';
    this.selectedOption(cmp, option);
    this.term(cmp, term);
    this.value(cmp, value);
    if (prevTerm !== term || prevValue !== value) {
      this.emitSearch(cmp, term);
    }
  },
  changeDisableHandler: function(cmp) {
    var isDisabled = this.isDisabled(cmp);
    if (isDisabled) {
      return;
    }
    var term = this.term(cmp);
    this.emitSearch(cmp, term);
  },
  emitCreate: function(cmp) {
    this.emitEvent(cmp, 'oncreate');
  },
  triggerSearch: function(cmp) {
    var term = this.term(cmp);
    this.emitSearch(cmp, term);
  }
});