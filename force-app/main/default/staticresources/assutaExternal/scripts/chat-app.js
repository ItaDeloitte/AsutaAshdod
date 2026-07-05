//@ts-check
(function() {
  // @ts-ignore
  var chatSettings = window.chatSettings;

  function ChatUtils() {}

  ChatUtils.prototype.getRandomHash = function() {
    return Math.random()
      .toString(16)
      .slice(2);
  };

  ChatUtils.prototype.loadStylesheet = function(url) {
    var linkEl = document.createElement('link');

    linkEl.type = 'text/css';
    linkEl.rel = 'stylesheet';
    linkEl.href = url + '?' + this.getRandomHash();

    document.head.appendChild(linkEl);
  };

  ChatUtils.prototype.loadScript = function(url, cb) {
    var scriptEl = document.createElement('script');
    scriptEl.type = 'text/javascript';
    scriptEl.src = url + '?' + this.getRandomHash();

    document.body.appendChild(scriptEl);
  };

  ChatUtils.prototype.inIframe = function() {
    return /chat-iframe/.test(location.href);
  };

  /* CHAT APP */
  function ChatApp(settings) {
    this.settings = settings;
    this.isSidebarOpen = false;
    this.resourceUrl = this.settings.host + '/resource/assutaExternal';
    this.chatUtils = new ChatUtils();
  }

  ChatApp.prototype.start = function() {
    var that = this;
    var useIframe = this.settings.useIframe;
    var inIframe = this.chatUtils.inIframe();

    var delay = inIframe ? 100 : 3000;

    this.loadStyles();
    this.loadScripts();
    if (this.settings.sidebar) {
      this.initSidebar();
    }
    this.initEvents();

    setTimeout(function() {
      if (useIframe && !inIframe) {
        that.initIframe();
      } else {
        that.initESW();
      }
      that.chatSidebarEl.style.display = '';
    }, delay);
  };

  ChatApp.prototype.initSidebar = function() {
    var that = this;
    var chatSidebarEl = document.createElement('div');
    chatSidebarEl.id = 'emb-chat-sidebar';
    chatSidebarEl.classList.add('emb-chat-sidebar');
    chatSidebarEl.style.display = 'none';
    chatSidebarEl.innerHTML =
      '<div class="emb-chat-sidebar__inner">' +
      '<div class="emb-chat-sidebar__header">' +
      '</div>' +
      '<div data-emb-chat-el="sidebar-body" class="emb-chat-sidebar__body"></div>' +
      '</div>' +
      '<button data-emb-chat-el="sidebar-toggle-btn" class="emb-chat-sidebar__toggle-btn"></button>' +
      '</div>';
    document.body.appendChild(chatSidebarEl);
    this.chatSidebarEl = chatSidebarEl;

    this.toggleSidebarBtnEl = document.querySelector(
      '[data-emb-chat-el="sidebar-toggle-btn"]'
    );
    this.chatSidebarBody = document.querySelector(
      '[data-emb-chat-el="sidebar-body"]'
    );

    this.toggleSidebarBtnEl.addEventListener('click', function(event) {
      that.chatSidebarEl.classList.toggle('is-open');
    });
  };

  ChatApp.prototype.loadStyles = function() {
    var externalStyles = [this.resourceUrl + '/styles/chat-common.css'];

    if (this.settings.sidebar) {
	  if(this.settings.sysCode=='doc_advisor'){
		  externalStyles.push(this.resourceUrl + '/styles/chat-sidebar-da.css');
	  }else{
		  externalStyles.push(this.resourceUrl + '/styles/chat-sidebar.css');
	  }
      
    }

    for (var i = 0; i < externalStyles.length; i++) {
      this.chatUtils.loadStylesheet(externalStyles[i]);
    }
  };

  ChatApp.prototype.loadScripts = function() {};

  ChatApp.prototype.initEvents = function() {
    var that = this;
    var inIframe = that.chatUtils.inIframe();

    if (this.settings.isAgent) {
      document.body.addEventListener('click', function(event) {
        /**
         * @type {*}
         */
        var target = event.target;
        if (!target.closest) {
          return;
        }

        var $contactUsBtn = target.closest(
          '.embeddedServiceHelpButton .helpButtonEnabled.uiButton'
        );
        if (!$contactUsBtn) {
          return;
        }
        var $message = $contactUsBtn.querySelector('.message');

        if (!$message) {
          return;
        }
        if ($message.textContent === that.settings.labels.contactUs) {
          if (!inIframe) {
            window.location.href = chatSettings.contactUsRedirectUrl;
            return;
          }
          window.parent.postMessage('chatNavigateToContactUs', '*');
        }
      });
    }
  };

  ChatApp.prototype.initIframe = function() {
    var iframeEl = document.createElement('iframe');
    iframeEl.className = 'emb-chat-sidebar__chat-iframe';
    iframeEl.src =
      this.resourceUrl +
      '/pages/chat-iframe.html?settings=' +
      this.settings.settingsScript +
      '&sidebar=' +
      this.settings.sidebar;

    this.chatSidebarBody.appendChild(iframeEl);

    window.addEventListener('message', function(event) {
      if (event.data === 'chatNavigateToContactUs') {
        window.location.href = chatSettings.contactUsRedirectUrl;
      }
    });
  };

  ChatApp.prototype.initESW = function() {
    var that = this;
    var config = {
      targetElement: this.chatSidebarEl ? this.chatSidebarBody : document.body,
      preInitCallback: function(embedded_svc) {
        embedded_svc.addEventHandler('onAgentMessage', function(event) {
          that.scrollMessageAreaToBottom();
        });
        embedded_svc.addEventHandler('onAgentRichMessage', function(event) {
          that.scrollMessageAreaToBottom();
        });
      }
    };

    this.settings.initEsvFn(config);
  };

  ChatApp.prototype.scrollMessageAreaToBottom = function() {
    var scrollDelay = 50;
    setTimeout(function() {
      var messageAreaEl = document.querySelector(
        '.embeddedServiceSidebar .messageArea'
      );
      if (messageAreaEl) {
        messageAreaEl.scrollTo(0, messageAreaEl.scrollHeight);
      }
    }, scrollDelay);
  };

  if (!chatSettings) {
    console.error('Chat settings not found');
    return;
  }

  var chatApp = new ChatApp(chatSettings);
  chatApp.start();
})();
