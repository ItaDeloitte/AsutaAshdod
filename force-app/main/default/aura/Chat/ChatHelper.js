/**@type {import("Chat").Helper} */
({
  init: function(cmp) {
    this.labels(cmp, this.getCustomLabels(cmp));
  },
  destroy: function(cmp) {
    this.isRendered(cmp, false);
    var styleSheet = this.styleSheet(cmp);
    if (styleSheet) {
      styleSheet.detach();
    }
  },
  render: function(cmp) {
    var isRendered = this.isRendered(cmp);
    if (isRendered) {
      return;
    }
    // console.log('RENDER');
    this.isRendered(cmp, true);
    this.config(cmp);
  },

  error: function(cmp, value) {
    return this.attribute(cmp, 'error', value);
  },

  chatsList: function(cmp, value) {
    return this.attribute(cmp, 'chatsList', value);
  },
  utilityLabel: function(cmp, value) {
    return this.attribute(cmp, 'utilityLabel', value);
  },
  utilityId: function(cmp, value) {
    return this.property(cmp, '_utilityId', value);
  },

  selectedTab: function(cmp, value) {
    return this.attribute(cmp, 'selectedTab', value);
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

  getCustomLabels: function() {
    return {
      DevChat: $A.get('$Label.c.DevChat'),
      ImposibleToCloseActiveChatError: $A.get(
        '$Label.c.Chat_ImposibleToCloseActiveChatError'
      )
    };
  },

  getChatWrapperCmp: function(cmp) {
    return cmp.find('chatWrapper');
  },

  styleSheet: function(cmp, value) {
    return this.property(cmp, '_styleSheet', value);
  },

  config: function(cmp) {
    var that = this;
    this.attachInjection(cmp);

    this.configUtilityId(cmp);

    var globalService = this.globalServiceCmp(cmp);
    var all = globalService.getAll();
    var services = all.services;
    var jssService = services.jssService;
    globalService.callWithLwcContext(
      $A.getCallback(function(lwcContext) {
        jssService.getJss(lwcContext).catch(function() {});
      })
    );

    // that.fetchOpenedWorks(cmp);
  },

  attachInjection: function(cmp) {
    var iframeEl = document.createElement('iframe');
    iframeEl.style.display = 'none';
    iframeEl.id = 'injection-iframe';
    var src = $A.get('$Resource.app') + '/iframes/injection-iframe/index.html';
    iframeEl.src = src;
    document.body.appendChild(iframeEl);
  },

  fetchOpenedWorks: function(cmp) {
    var that = this;
    var omniCmp = that.omniApiCmp(cmp);
    setTimeout(function() {
      omniCmp
        .getAgentWorks()
        .then(function(res) {
          var works = res.works;
          // console.log('AGENT WORKS', that.unProxyData(works));
          works.forEach(function(work) {
            var foundWork = that.findWorkByWorkItemId(cmp, work.workitemId);
            if (!foundWork) {
              that.workAcceptedHandler(cmp, work);
            }
          });
          // console.log('getAgentWorks', that.unProxyData(res));
        })
        .catch(function(err) {
          console.log(err);
        });
    }, 10000);
  },

  configUtilityId: function(cmp) {
    var that = this;
    var utilityBarCmp = this.utilityBarCmp(cmp);
    var utilityLabel = that.utilityLabel(cmp);

    utilityBarCmp
      .getAllUtilityInfo()
      .then(function(allData) {
        return allData.find(function(item) {
          return item.utilityLabel === utilityLabel;
        });
      })
      .then(function(chatUtility) {
        if (!chatUtility) {
          return null;
        }
        var utilityId = chatUtility.id;
        that.utilityId(cmp, utilityId);
        utilityBarCmp.onUtilityClick({
          utilityId: utilityId,
          eventHandler: that.utilityClickHandler.bind(that, cmp)
        });
      })
      .catch(function(err) {
        console.log(err);
      });
  },

  test: function(cmp, data) {},
  workAcceptedHandler: function(cmp, work) {
    var that = this;
    // console.log('workAcceptedHandler', that.unProxyData(work));
    var chatsList = that.chatsList(cmp);
    var chat = that.findWorkByWorkItemId(cmp, work.workItemId);
    if (chat) {
      return;
    }
    that
      .fetchMessagesLog(cmp, work.workItemId)
      .then(
        $A.getCallback(function() {
          return that.fetchDescribe(cmp, work.workItemId);
        })
      )
      .then(
        $A.getCallback(function(describe) {
          /**@type {import('Chat').Chat} */
          var chat = that.findWorkByWorkItemId(cmp, work.workItemId);
          if (chat) {
            return;
          }
          chat = {
            describe: describe,
            work: work
          };
          chatsList.push(chat);
          that.chatsList(cmp, chatsList);
          if (chatsList.length === 1) {
            that.selectedTab(cmp, chat.work.workItemId);
          }
        })
      )
      .catch(
        $A.getCallback(function(err) {
          console.log(err);
        })
      );
  },

  fetchMessagesLog: function(cmp, workItem) {
    var that = this;
    var conversationKitCmp = that.conversationKitCmp(cmp);
    return conversationKitCmp.getChatLog({
      recordId: workItem
    });
  },

  conversationChatEndedHandler: function(cmp, workItemId) {
    // console.log('conversationChatEndedHandler', this.unProxyData(dd));

    this.removeWorkFromList(cmp, workItemId);
  },

  messageHandler: function(cmp, message) {
    var that = this;
    var worksList = that.chatsList(cmp);
    var selectedTab = that.selectedTab(cmp);

    var targetWorkItem = worksList.find(function(item) {
      return item.work.workItemId === message.recordId;
    });

    if (!targetWorkItem) {
      return;
    }

    if (targetWorkItem.work.workItemId !== selectedTab) {
      targetWorkItem.hasNewMessages = true;
      that.chatsList(cmp, worksList);
      that.updateTabsHighlight(cmp);
    }

    that.getUtilityInfo(cmp).then(function(utilityInfo) {
      if (utilityInfo && !utilityInfo.utilityVisible) {
        that.setUtilityHighlight(cmp, true);
      }
    });
  },

  fetchDescribe: function(cmp, workitemId) {
    var that = this;
    var params = {
      actionName: 'getWorkitemDescribe',
      workitemId: workitemId
    };
    return that.request(cmp, params);
  },

  request: function(cmp, params) {
    var that = this;
    var globalServiceCmp = that.globalServiceCmp(cmp);
    var all = globalServiceCmp.getAll();
    var services = all.services;
    var executeService = services.executeService;

    return executeService.execute('LC_CustomChatController', params);
  },
  setUtilityHighlight: function(cmp, isHighlight) {
    var that = this;
    var utilityId = that.utilityId(cmp);
    var utilityBarCmp = that.utilityBarCmp(cmp);
    utilityBarCmp
      .setUtilityHighlighted({
        utilityId: utilityId,
        highlighted: isHighlight
      })
      .catch(function(err) {
        console.log(err);
      });
  },

  utilityClickHandler: function(cmp) {
    this.setUtilityHighlight(cmp, false);
  },

  getUtilityInfo: function(cmp) {
    var that = this;
    var utilityId = that.utilityId(cmp);
    var utilityBarCmp = that.utilityBarCmp(cmp);
    return utilityBarCmp.getUtilityInfo({
      utilityId: utilityId
    });
  },

  tabSelectHandler: function(cmp, params) {
    var that = this;
    var id = params.id;
    this.selectedTab(cmp, id);
    var worksList = that.chatsList(cmp);
    var chat = that.findWorkByWorkItemId(cmp, id);
    if (chat.hasNewMessages) {
      chat.hasNewMessages = false;
      that.chatsList(cmp, worksList);
      that.updateTabsHighlight(cmp);
    }
  },

  updateTabsHighlight: function(cmp) {
    var that = this;
    var chatWrapperEl = that.getChatWrapperCmp(cmp).getElement();
    var worksList = that.chatsList(cmp);
    var styleSheet = that.styleSheet(cmp);

    if (styleSheet) {
      chatWrapperEl.classList.remove(styleSheet.classes.devChat);
      styleSheet.detach();
    }

    var jss = window['lightningJss'].jss;

    var chatsWithNewMessages = worksList.filter(function(item) {
      return item.hasNewMessages;
    });

    var highlightStyles = {
      color: 'rgb(22, 50, 92)',
      backgroundColor: 'rgb(255, 183, 93)'
    };

    var tabStyles = chatsWithNewMessages.reduce(function(acc, item) {
      acc[
        '& li[data-tab-value="' + item.work.workItemId + '"]'
      ] = highlightStyles;
      return acc;
    }, {});

    styleSheet = jss.createStyleSheet(
      {
        devChat: tabStyles
      },
      { link: false }
    );
    styleSheet.attach();
    that.styleSheet(cmp, styleSheet);
    chatWrapperEl.classList.add(styleSheet.classes.devChat);
  },

  findWorkByWorkItemId: function(cmp, id) {
    var that = this;
    var worksList = that.chatsList(cmp);
    return worksList.find(function(item) {
      return item.work.workItemId === id;
    });
  },
  workClosedHandler: function(cmp, params) {
    var workItemId = params.workItemId;
    var workId = params.workId;
    this.removeWorkFromList(cmp, workItemId);
  },
  closeChatTabHandler: function(cmp, work) {
    var that = this;
    var labels = that.labels(cmp);
    var params = {
      actionName: 'checkCloseAbility',
      workitemId: work.workItemId
    };

    that
      .request(cmp, params)
      .then(
        $A.getCallback(function(isAllowClose) {
          if (!isAllowClose) {
            that.error(cmp, labels.ImposibleToCloseActiveChatError);

            return;
          }
          that.removeWorkFromList(cmp, work.workItemId);
        })
      )
      .catch(
        $A.getCallback(function(err) {
          var globalServiceCmp = that.globalServiceCmp(cmp);
          var services = globalServiceCmp.getAll().services;
          var toastService = services.toastService;
          var errorsService = services.errorsService;

          var errMessage = errorsService.buildServerErrorsString(err);

          globalServiceCmp.callWithLwcContext(
            $A.getCallback(function(lwc) {
              toastService.error(lwc, { message: errMessage });
            })
          );
        })
      );
  },
  removeWorkFromList: function(cmp, workItemId) {
    var worksList = this.chatsList(cmp);
    worksList = worksList.filter(function(item) {
      return item.work.workItemId !== workItemId;
    });
    this.chatsList(cmp, worksList);
  },
  errorCloseHandler: function(cmp) {
    this.error(cmp, '');
  }
});