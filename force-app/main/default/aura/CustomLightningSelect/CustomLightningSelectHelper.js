/**@type {import("CustomLightningSelect").Helper} */
({
  init: function(cmp) {},
  destroy: function(cmp) {},
  render: function(cmp) {},

  selectCmp: function(cmp) {
    return cmp.find('select');
  },

  showHelpMessageIfInvalid: function(cmp) {
    var selectCmp = this.selectCmp(cmp);
    selectCmp.showHelpMessageIfInvalid();
  },

  emitChange: function(cmp) {
    this.emitEvent(cmp, 'onchange');
  }
});