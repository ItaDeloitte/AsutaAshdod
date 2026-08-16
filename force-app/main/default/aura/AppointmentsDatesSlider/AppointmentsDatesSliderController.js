/**@type {import("AppointmentsDatesSlider").Controller} */
({
  onInit: function(cmp, event, helper) {
    helper.onScriptReady(cmp, 'swiper').then(
      $A.getCallback(function() {
        helper.init(cmp);
      })
    );
  },
  onDestroy: function(cmp, event, helper) {
    helper.destroy(cmp);
  },
  onRender: function(cmp, event, helper) {
    helper.render(cmp);
  },
  onSwiperLoaded: function(cmp, event, helper) {
    helper.resolveScriptLoad(cmp, 'swiper');
  },
  onUpdateHeight: function(cmp, event, helper) {
    helper.updateSwiperHeight(cmp);
  }
});