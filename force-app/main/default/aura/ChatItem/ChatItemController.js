/**@type {import("ChatItem").Controller} */
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
  onConversationNewMessage: function(cmp, event, helper) {
    var params = event.getParams();
    console.log('onConversationNewMessage');
    console.log(helper.unProxyData(params));
    helper.messageHandler(cmp, params);
  },
  onConversationAgentSend: function(cmp, event, helper) {
    var params = event.getParams();
    console.log('onConversationAgentSend');
    console.log(helper.unProxyData(params));
    helper.messageHandler(cmp, params);
  },
  onKeyup: function(cmp, event, helper) {
    if (event.keyCode === 13) {
      event.preventDefault();
      helper.sendMessageHandler(cmp);
    }
  },
  onEndChat: function(cmp, event, helper) {
    helper.endChat(cmp);
  }
});