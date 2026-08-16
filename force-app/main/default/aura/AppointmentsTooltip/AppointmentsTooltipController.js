/**@type {import("AppointmentsTooltip").Controller} */
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
  onTogglerClick: function(cmp, event, helper) {
    helper.toggle(cmp);
  },
  onTogglerHover: function(cmp, event, helper) {
    /**@type {HTMLElement} */
    var target = event.currentTarget;
    // helper.show(cmp);
  },
  onTogglerOut: function(cmp, event, helper) {
    // console.log('toggler out');
  },
  onHide: function(cmp, event, helper) {
    helper.hide(cmp);
  }
});