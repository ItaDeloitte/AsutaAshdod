/**@type {import("Alert").Helper} */
({
  init: function(cmp) {},
  emitClose: function(cmp) {
    this.emitEvent(cmp, 'closed');
  }
});