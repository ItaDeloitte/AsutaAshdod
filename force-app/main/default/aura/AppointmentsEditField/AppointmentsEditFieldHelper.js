/**@type {import("AppointmentsEditField").Helper} */
({
  init: function(cmp) {},
  destroy: function(cmp) {},
  render: function(cmp) {},

  name: function(cmp, value) {
    return this.attribute(cmp, 'name', value);
  },
  isDisabled: function(cmp, value) {
    return this.attribute(cmp, 'isDisabled', value);
  },
  isEditable: function(cmp, value) {
    return this.attribute(cmp, 'isEditable', value);
  },
  editClickHandler: function(cmp) {
    var isEditable = this.isEditable(cmp);
    if (isEditable) {
      this.emitEdit(cmp);
    }
  },
  emitEdit: function(cmp) {
    var name = this.name(cmp);
    this.emitEvent(cmp, 'onedit', { value: name });
  }
});