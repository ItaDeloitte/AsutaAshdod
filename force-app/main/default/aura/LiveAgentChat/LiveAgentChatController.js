/**@type {import("LiveAgentChat").Controller} */
({
  onInit: function(cmp, event, helper) {
    helper.init(cmp);
  },
  onDestroy: function(cmp, event, helper) {
    helper.destroy(cmp);
  },
  onStart: function(cmp, event, helper) {
    helper.startChat(cmp);
  },
  onFieldChange: function(cmp, event, helper) {
    var fieldCmp = event.getSource();
    helper.fieldChangeHandler(cmp, fieldCmp);
  },
  onChangeRecordType: function(cmp, event, helper) {
    var target = event.target;
    var value = target.value;
    var editData = helper.editData(cmp);
    editData.recordType = value;
    helper.editData(cmp, editData);
    helper.recordTypeChangeHandler(cmp);
  },
  onNextStep: function(cmp, event, helper) {
    helper.nextStep(cmp);
  }
});