/**@type {import("ConfirmModal").Helper} */
({
  init: function() {},

  isOpen: function(cmp, value) {
    return this.attribute(cmp, 'isOpen', value);
  },

  emitClose: function(cmp, value) {
    var event = cmp.getEvent('onclose');
    event.setParam('value', value);
    event.fire();
    this.isOpen(cmp, false);
  }
});