/**@type {import("Chat").Controller} */
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
  // onSelectStatus: function(cmp, event, helper) {
  //   var value = event.getParam('value');
  //   helper.selectStatusHandler(cmp, value);
  // },
  // onSendMessage: function(cmp, event, helper) {
  //   helper.messageSendHandler(cmp);
  // },
  onWorkAccepted: function(cmp, event, helper) {
    var params = event.getParams();
    helper.workAcceptedHandler(cmp, params);
  },
  onTest: function(cmp, event, helper) {
    helper.test(cmp, cmp.workParams);
  },

  onConversationNewMessage: function(cmp, event, helper) {
    var params = event.getParams();
    helper.messageHandler(cmp, params);
  },

  onConversationChatEnded: function(cmp, event, helper) {
    var params = event.getParams();
    helper.conversationChatEndedHandler(cmp, params.recordId);
  },
  onWorkClosed: function(cmp, event, helper) {
    var params = event.getParams();
    helper.workClosedHandler(cmp, params);
  },
  tabSelectHandler: function(cmp, event, helper) {
    var params = event.getParams();
    helper.tabSelectHandler(cmp, params);
  },
  onCloseChatTab: function(cmp, event, helper) {
    var params = event.getParams();
    var work = params.value.work;
    helper.closeChatTabHandler(cmp, work);
  },
  errorCloseHandler: function(cmp, event, helper) {
    helper.errorCloseHandler(cmp);
  }
});