/**@type {import("BaseRelatedAutocomplete").Helper} */
({
  init: function(cmp) {},
  destroy: function(cmp) {},
  render: function(cmp) {},

  value: function(cmp, value) {
    return this.attribute(cmp, 'value', value);
  },

  emitChange: function(cmp) {
    var value = this.value(cmp);
    this.emitEvent(cmp, 'onchange', { value: value });
  }
});