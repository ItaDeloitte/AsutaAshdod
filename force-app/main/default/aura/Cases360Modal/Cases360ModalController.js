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
  onTableRowAction: function(cmp, event, helper) {
    var params = event.getParams();
    var row = params.row;
    return helper.linkAppointment(cmp, row);
  }
})