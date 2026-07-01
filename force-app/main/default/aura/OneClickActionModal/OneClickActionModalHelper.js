/**@type {import("OneClickActionModal").Helper} */
({
  init: function(cmp) {},
  destroy: function(cmp) {},
  render: function(cmp) {},
  emitActionClicked: function(cmp, action) {
    this.emitEvent(cmp, 'actionClicked', { value: action });
  }
});