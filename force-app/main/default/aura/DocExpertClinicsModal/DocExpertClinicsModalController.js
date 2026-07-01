/**@type {import("DocExpertClinicsModal").Controller} */
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
    /**@type {import('DocExpertClinicsModal').TableRowActionEventParams} */
    var params = event.getParams();
    var action = params.action;
    var row = params.row;
    switch (action.name) {
      case 'schedule': {
        return helper.schedule(cmp, row);
      }
    }
  }
});