/**@type {import("MultiSelect").Controller} */
({
  onInit: function(cmp, event, helper) {
    helper.init(cmp);
  },
  onDestroy: function(cmp, event, helper) {
    helper.destroy(cmp);
  },
  onRender: function(cmp, event, helper) {
    helper.render(cmp);
  },
  onScriptsLoaded: function(cmp, event, helper) {
    helper.initSelect(cmp);
  },
  onChangeOptions: function(cmp, event, helper) {
    helper.refreshSelect(cmp);
  },
  onReset: function(cmp, event, helper) {},
  onRefresh: function(cmp, event, helper) {
    helper.refreshSelect(cmp);
  },
  onShowHelpMessageIfInvalid: function(cmp, event, helper) {
    helper.isTouched(cmp, true);
    return helper.validate(cmp);
  },
  onCheckValidity: function(cmp, event, helper) {
    var validity = helper.validate(cmp);
    return validity.valid;
  },
  onSetValue: function(cmp, event, helper) {
    var args = event.getParam('arguments');
    var value = args.value;
    helper.setValue(cmp, value);
  },
  onGetValue: function(cmp, event, helper) {
    return helper.getSelects(cmp);
  },
  onFocus: function(cmp, event, helper) {
    helper.focus(cmp);
  },
  onBlur: function(cmp, event, helper) {
    helper.blur(cmp);
  },
  onCheckAll: function(cmp, event, helper) {
    helper.checkAll(cmp);
  },
  onUncheckAll: function(cmp, event, helper) {
    helper.uncheckAll(cmp);
  },
  onEnable: function(cmp, event, helper) {
    helper.enable(cmp);
  },
  onDisable: function(cmp, event, helper) {
    helper.disable(cmp);
  },
  onOpen: function(cmp, event, helper) {
    helper.open(cmp);
  },
  onClose: function(cmp, event, helper) {
    helper.close(cmp);
  },
  onRebuild: function(cmp, event, helper) {
    helper.rebuild(cmp);
  },
  onChangeDisabled: function(cmp, event, helper) {
    helper.changeDisabledHandler(cmp);
  }
});