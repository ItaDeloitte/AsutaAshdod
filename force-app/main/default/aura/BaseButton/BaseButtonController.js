//@ts-check
/**@type {import("BaseButton").Controller} */
({
  onInit: function(cmp, event, helper) {
    helper.init(cmp);
  },
  onFocus: function(cmp, event, helper) {
    return helper.findButton(cmp).focus();
  },
  click: function(cmp, event, helper) {
    helper.emitEvent(cmp, 'onclick', { value: event });
  },
  focus: function(cmp, event, helper) {
    helper.emitEvent(cmp, 'onfocus', { value: event });
  },
  blur: function(cmp, event, helper) {
    helper.emitEvent(cmp, 'onblur', { value: event });
  }
});