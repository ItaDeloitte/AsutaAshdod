/**@type {import("AvayaCommunicatorController").Controller} */
({
  onInit: function(cmp, event, helper) {
    helper.init(cmp);
  },
  handleAvayaEvent: function(cmp, event, helper) {
     helper.AvayaEvent(cmp, event);
  }
});