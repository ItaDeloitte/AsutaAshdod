/**@type {import("Case360LinkButton").Helper} */
({
  init: function(cmp) {},
  destroy: function(cmp) {},
  render: function(cmp) {},

  overlayLibCmp: function(cmp) {
    return cmp.find('overlayLib');
  },

  showModal: function(cmp) {
    var that = this;
    var recordId = that.recordId(cmp);
    var overlayLibCmp = that.overlayLibCmp(cmp);
    var cmpName = 'Case360LinkModal';
    var cmpDefinition = that.buildCmpDefinition(cmpName);
    that.isLoading(cmp, true);
    $A.createComponent(
      cmpDefinition.name,
      {
        recordId: recordId
      },
      function(preparedCmp, status) {
        if (status === 'SUCCESS') {
          overlayLibCmp
            .showCustomModal({
              body: preparedCmp,
              cssClass: cmpDefinition.className + ' modal',
              showCloseButton: true,
              closeCallback: function() {}
            })
            .then(
              $A.getCallback(function() {
                that.isLoading(cmp, false);
              })
            );
        } else {
          console.log(status);
          that.isLoading(cmp, false);
        }
      }
    );
  }
});