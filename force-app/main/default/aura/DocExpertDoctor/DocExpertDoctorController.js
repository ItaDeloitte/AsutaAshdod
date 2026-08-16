/**@type {import("DocExpertDoctor").Controller} */
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
  onPictureError: function(cmp, event, helper) {
    helper.pictureErrorHandler(cmp);
  },
  onActionClick: function(cmp, event, helper) {
    var sourceCmp = event.getSource();
    /**@type {import('DocExpertBase').DoctorAction} */
    var action = helper.attribute(sourceCmp, 'name');
    helper.doctorActionHandler(cmp, action);
  },
  onRecommendClick: function(cmp, event, helper) {
    helper.doctorActionHandler(cmp, 'recommend');
  },
  onChangeRecommendedDoctors: function(cmp, event, helper) {
    helper.config(cmp);
  },
  onHideInfo: function(cmp, event, helper) {
    helper.currentInfo(cmp, '');
  },
  onShowInfo: function(cmp, event, helper) {
    /**@type {HTMLElement} */
    var target = event.currentTarget;
    var infoType =
      /** @type {import('DocExpertDoctor').DoctorInfo}*/ (target.dataset.info);
    helper.showInfo(cmp, infoType);
  }
});