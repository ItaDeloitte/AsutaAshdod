/**
 * Created by daniilvinnik on 28.09.2022.
 */

({
     onInit: function(cmp, event, helper) {
          helper.init(cmp);
     },
     onRefresh: function(cmp, event, helper) {
          helper.fetchConfig(cmp);
     },
     onShowLinkToCaseActionModal: function(cmp,event, helper) {
          helper.showLinkToCaseActionModal(cmp)
     },
     onSendOTP: function(cmp, event, helper) {
          helper.sendOtp(cmp);
     },
     onShowDisabilityModal: function(cmp, event, helper) {
          helper.showDisabilityModal(cmp);
     },
     onUploadFilesToClinic: function(cmp, event, helper) {
          helper.uploadFilesToClinic(cmp);
     },
     onConverClick: function(cmp, event, helper) {
          helper.convertAppointment(cmp);
     },
     onShowIVFModal: function(cmp, event, helper) {
          helper.showIVFModal(cmp);
          helper.isPaymentButtonEnabled(cmp, false);
     },
     onShowSendQuestionnaireLinkModal: function (cmp, event, helper) {
          helper.showSendQuestionnaireLinkModal(cmp);
     },
     onShowForcedAppointment: function(cmp, event, helper) {
          helper.showForcedAppointmentScreen(cmp);
     },
});