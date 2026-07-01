/**@type {import("PatientDetailsModal").Controller} */
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
    onNext: function(cmp, event, helper) {
      helper.nextStep(cmp);
    },
    onPrev: function(cmp, event, helper) {
      helper.prevStep(cmp);
    },
    onSubmit: function(cmp, event, helper) {
      helper.submit(cmp);
    }
})