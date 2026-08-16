/**@type {import("BaseAutocomplete").Controller} */
({
  onInit: function(cmp, event, helper) {
    helper.init(cmp);
  },
  onRender: function(cmp, event, helper) {
    helper.prepareInput(cmp);
  },
  onDestroy: function(cmp, event, helper) {
    helper.destroy(cmp);
  },
  onKeyup: function(cmp, event, helper) {
    helper.keyup(cmp, event);
  },
  onFocusInput: function(cmp, event, helper) {
    helper.focusInput(cmp);
  },
  onBlurInput: function(cmp, event, helper) {
    helper.blurInput(cmp);
  },
  onClose: function(cmp, event, helper) {
    helper.isListOpen(cmp, false);
  },
  onChangeValue: function(cmp, event, helper) {
    helper.changeSearchTerm(cmp);
  },
  onSelectOption: function(cmp, event, helper) {
    /**@type {HTMLElement} */
    var target = event.currentTarget;

    if (!target) {
      return;
    }
    event.stopPropagation();
    var value = target.dataset.value;
    helper.selectOption(cmp, value);
  },
  onLinkClick: function(cmp, event, helper) {
    event.stopPropagation();
  },
  onClear: function(cmp, event, helper) {
    helper.clearValue(cmp);
  },
  onScriptsLoaded: function(cmp, event, helper) {
    helper.resolveScriptLoad(cmp, '$');
  },
  onShowHelpMessageIfInvalid: function(cmp, event, helper) {
    helper.isTouched(cmp, true);
    helper.validate(cmp);
  },
  onCheckValidity: function(cmp, event, helper) {
    var validity = helper.validate(cmp);
    return validity.valid;
  },
  onSetCustomValidity: function(cmp, event, helper) {
    var params = event.getParams();
    var message = params.arguments.message;
    helper.customValidityMessage(cmp, message);
  },
  onSetCustomMessage: function (cmp, event, helper) {
    var params = event.getParams();
    var message = params.arguments.message;
    helper.setCustomMessage(cmp, message)
  },
  onResetCustomMessage: function (cmp, event, helper) {
    helper.resetCustomMessage(cmp)
  },
  onTriggerSearch: function(cmp, event, helper) {
    helper.triggerSearch(cmp);
  },
  onReset: function(cmp, event, helper) {
    var args = event.getParam('arguments');
    var emitChange = args.emitChange;
    helper.reset(cmp, emitChange);
  },
  onSetOption: function(cmp, event, helper) {
    var args = event.getParam('arguments');
    var option = args.option;
    helper.setOption(cmp, option);
  },
  onChangeDisabled: function(cmp, event, helper) {
    helper.changeDisableHandler(cmp);
  },
  onCreate: function(cmp, event, helper) {
    helper.emitCreate(cmp);
  }
});