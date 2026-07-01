/**@type {import("AppointmentsTooltip").Helper} */
({
  init: function(cmp) {},
  destroy: function(cmp) {
    this.clearGlobalClickListener(cmp);
  },
  render: function(cmp) {},

  overlayLibCmp: function(cmp) {
    return cmp.find('overlay');
  },

  isVisible: function(cmp, value) {
    return this.attribute(cmp, 'isVisible', value);
  },

  globalClickListenerFn: function(cmp, value) {
    return this.property(cmp, '_globalClickListenerFn', value);
  },

  handlerAttr: function(cmp) {
    var cmpId = cmp.getGlobalId();
    return '[data-handler="' + cmpId + '"]';
  },

  toggle: function(cmp) {
    var isVisible = this.isVisible(cmp);
    if (isVisible) {
      this.hide(cmp);
    } else {
      this.show(cmp);
    }
  },
  show: function(cmp) {
    this.isVisible(cmp, true);
    this.attachGlobalClickListener(cmp);
  },
  hide: function(cmp) {
    this.isVisible(cmp, false);
    this.clearGlobalClickListener(cmp);
  },
  attachGlobalClickListener: function(cmp) {
    var self = this;
    var handlerAttr = this.handlerAttr(cmp);
    var listenerFn = $A.getCallback(function(event) {
      var target = event.target;
      if (!self.utils.closest(target, handlerAttr)) {
        self.hide(cmp);
      }
    });
    window.document.body.addEventListener('click', listenerFn);
    this.globalClickListenerFn(cmp, listenerFn);
  },
  clearGlobalClickListener: function(cmp) {
    var listenerFn = this.globalClickListenerFn(cmp);
    if (listenerFn) {
      window.document.body.removeEventListener('click', listenerFn);
    }
  }
});