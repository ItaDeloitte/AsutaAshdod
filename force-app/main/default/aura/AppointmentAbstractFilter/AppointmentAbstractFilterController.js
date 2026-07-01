({
  onChangeInput: function(cmp, event, helper) {
    var params = event.getParams();
    helper.emitFilterChanged(cmp, params.value);
  }
});