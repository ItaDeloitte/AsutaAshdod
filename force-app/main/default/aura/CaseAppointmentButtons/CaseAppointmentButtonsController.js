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
  onConverClick: function(cmp, event, helper) {
    helper.convertAppointment(cmp);
  },
  onLinkClick: function(cmp, event, helper) {
    helper.showCasesModal(cmp);
  },
  onShowCase360CloseModal: function(cmp, event, helper) {
    helper.showCase360CloseModal(cmp);
  },
  onShowContactDoctorModal: function(cmp, event, helper) {
    helper.showContactDoctorModal(cmp);
  },
  onSendOTP: function(cmp, event, helper) {
    helper.sendOtp(cmp);
  },
  onShowDisabilityModal: function(cmp, event, helper) {
    helper.showDisabilityModal(cmp);
  },
  onRefresh: function(cmp, event, helper) {
    helper.fetchConfig(cmp);
  },
  onShowIVFModal: function(cmp, event, helper) {
    helper.showIVFModal(cmp);
    helper.isPaymentButtonEnabled(cmp, false);
  },
  onUploadFilesToClinic: function(cmp, event, helper) {
    helper.uploadFilesToClinic(cmp);
  },
  onShowForcedAppointment: function(cmp, event, helper) {
    helper.showForcedAppointmentScreen(cmp);
  },
  onShowLinkToCaseActionModal: function (cmp, event, helper) {
    helper.showLinkToCaseActionModal(cmp);
  },
  onShowSendQuestionnaireLinkModal: function (cmp, event, helper) {
    helper.showSendQuestionnaireLinkModal(cmp);
  }
});