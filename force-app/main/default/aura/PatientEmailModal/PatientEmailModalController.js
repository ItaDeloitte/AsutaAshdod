/**@type {import("PatientEmailModal").Controller} */
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
    onCancel: function(cmp, event, helper) {
      helper.cancelHandler(cmp);
    },
    onSubmit: function(cmp, event, helper) {
      helper.submit(cmp);
    }
})