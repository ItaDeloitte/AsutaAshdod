//@ts-check
({
  onInit: function (cmp, event, helper) {
    helper.init(cmp);
  },
  onDestroy: function (cmp, event, helper) {
    helper.destroy(cmp);
  },
  onRender: function (cmp, event, helper) {
    helper.render(cmp);
  },
  onCancel: function (cmp, event, helper) {
    helper.cancel(cmp);
  },
  onSubmit: function (cmp, event, helper) {
    helper.submit(cmp);
  },
  onEditFieldChange: function (cmp, event, helper) {
    helper.editFieldChangeHandler(cmp, event);
  }
})