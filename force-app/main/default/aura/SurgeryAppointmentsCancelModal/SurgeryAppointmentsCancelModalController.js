/**@type {import("SurgeryAppointmentsCancelModal").Controller} */
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
    console.log('onTableRowAction');
    /**@type {import('SurgeryAppointmentsCancelModal').TableRowActionEventParams} */
    var params = event.getParams();
    var action = params.action;
    var row = params.row;
    switch (action.name) {
      case 'cancel': {
        return helper.cancelAppointment(cmp, row);
      }
    }
  },
  onClose: function(cmp, event, helper) {
    helper.close(cmp);
  }
});