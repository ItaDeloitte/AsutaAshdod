/**@type {import("ChatItem").Helper} */
({
  init: function(cmp) {
    this.labels(cmp, this.getCustomLabels(cmp));
  },
  destroy: function(cmp) {},
  render: function(cmp) {
    var isRendered = this.isRendered(cmp);
    if (isRendered) {
      return;
    }
    this.isRendered(cmp, true);
    this.fetchMessagesLog(cmp);
  },

  getCustomLabels: function() {
    return {
      CloseChatTab: $A.get('$Label.c.Chat_CloseChatTab'),
      TypeMessage: $A.get('$Label.c.Chat_TypeMessage')
    };
  },

  chat: function(cmp, value) {
    return this.attribute(cmp, 'chat', value);
  },
  messages: function(cmp, value) {
    return this.attribute(cmp, 'messages', value);
  },

  isSending: function(cmp, value) {
    return this.property(cmp, '_isSending', value);
  },

  newMessageText: function(cmp, value) {
    return this.attribute(cmp, 'newMessageText', value);
  },

  conversationKitCmp: function(cmp) {
    return cmp.find('conversationKit');
  },

  omniApiCmp: function(cmp) {
    return cmp.find('omniApi');
  },

  utilityBarCmp: function(cmp) {
    return cmp.find('utilityBar');
  },

  chatScrollerCmp: function(cmp) {
    return cmp.find('chatScroller');
  },

  fetchMessagesLog: function(cmp) {
    var that = this;
    var chat = that.chat(cmp);
    var conversationKitCmp = this.conversationKitCmp(cmp);
    conversationKitCmp
      .getChatLog({
        recordId: chat.work.workItemId
      })
      .then(
        $A.getCallback(function(/**@type {Aura.ConversationLog}*/ log) {
          that.messages(cmp, log.messages);
          that.scrollChatToBottom(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(that.unProxyData(err));
        })
      );
  },
  messageHandler: function(cmp, message) {
    var chat = this.chat(cmp);
    if (chat.work.workItemId !== message.recordId) {
      return;
    }
    var messages = this.messages(cmp);
    messages.push(message);
    this.messages(cmp, messages);
    this.scrollChatToBottom(cmp);
  },
  sendMessageHandler: function(cmp) {
    var that = this;
    var newMessage = that.newMessageText(cmp);
    if (!newMessage) {
      return;
    }

    var isSending = that.isSending(cmp);
    if (isSending) {
      return;
    }

    var chat = that.chat(cmp);
    var conversationKitCmp = that.conversationKitCmp(cmp);
    that.isSending(cmp, true);

    conversationKitCmp
      .sendMessage({
        recordId: chat.work.workItemId,
        message: { text: newMessage }
      })
      .then(
        $A.getCallback(function(res) {
          console.log(that.unProxyData(res));
          that.newMessageText(cmp, '');
          that.isSending(cmp, false);
          that.scrollChatToBottom(cmp);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          that.isSending(cmp, false);
          console.log(that.unProxyData(err));
        })
      );
  },

  scrollChatToBottom: function(cmp) {
    var that = this;
    setTimeout(function() {
      var chatScrollerCmp = that.chatScrollerCmp(cmp);
      if (!chatScrollerCmp) {
        return;
      }
      chatScrollerCmp.scrollTo('bottom');
    });
  },
  endChat: function(cmp) {
    var that = this;
    var chat = that.chat(cmp);
    var conversationKitCmp = this.conversationKitCmp(cmp);
    // console.log(that.unProxyData(chat));
    that.emitEvent(cmp, 'onclosechattab', { value: { work: chat.work } });

    // conversationKitCmp
    //   .endChat({ recordId: chat.work.workItemId })
    //   .then(
    //     $A.getCallback(function(res) {
    //       console.log(res);
    //     })
    //   )
    //   .catch(
    //     $A.getCallback(function(err) {
    //       console.log(err);
    //     })
    //   );
  },

  request: function(cmp, params) {
    var that = this;
    var globalServiceCmp = that.globalServiceCmp(cmp);
    var all = globalServiceCmp.getAll();
    var services = all.services;
    var executeService = services.executeService;

    return executeService.execute('LC_CustomChatController', params);
  }
});