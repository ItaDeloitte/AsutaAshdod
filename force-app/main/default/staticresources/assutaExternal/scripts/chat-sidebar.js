//@ts-check
(function() {
  // @ts-ignore
  var chatSettings = {
    sidebar: true,
    host: 'https://ongoingsup-myassuta.cs87.force.com/AssutaExternalResources'
  };

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

  /* CHAT APP */
  function ChatApp(settings) {
    this.settings = settings;
    this.isSidebarOpen = false;
    this.resourceUrl = this.settings.host + '/resource/assutaExternal';
    this.chatUtils = new ChatUtils();
  }

  ChatApp.prototype.start = function() {
    this.loadStyles();
    this.loadScripts();
    if (this.settings.sidebar) {
      this.initSidebar();
    }

    this.initESW();
  };

  ChatApp.prototype.initSidebar = function() {
    var that = this;
    var chatSidebarEl = document.createElement('div');
    chatSidebarEl.id = 'emb-chat-sidebar';
    chatSidebarEl.classList.add('emb-chat-sidebar');
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
      externalStyles.push(this.resourceUrl + '/styles/chat-sidebar.css');
    }

    for (var i = 0; i < externalStyles.length; i++) {
      this.chatUtils.loadStylesheet(externalStyles[i]);
    }
  };

  ChatApp.prototype.loadScripts = function() {};

  ChatApp.prototype.initEvents = function() {
    var that = this;
  };

  ChatApp.prototype.initESW = function() {
    var that = this;
    // @ts-ignore
    var embedded_svc = window.embedded_svc;
    var initESW = function(gslbBaseURL) {
      embedded_svc.settings.targetElement = this.settings.sidebar
        ? that.chatSidebarBody
        : document.body;
      embedded_svc.settings.displayHelpButton = true; //Or false
      embedded_svc.settings.language = 'iw'; //For example, enter 'en' or 'en-US'

      embedded_svc.settings.defaultMinimizedText = "צ'אט עם נציג"; //(Defaults to Chat with an Expert)
      embedded_svc.settings.disabledMinimizedText = 'צור קשר'; //(Defaults to Agent Offline)
      embedded_svc.settings.offlineSupportMinimizedText = 'צור קשר'; //(Defaults to Contact Us)
      embedded_svc.settings.loadingText = 'טוען...'; //(Defaults to Loading)

      //embedded_svc.settings.loadingText = ''; //(Defaults to Loading)
      //embedded_svc.settings.storageDomain = 'yourdomain.com'; //(Sets the domain for your deployment so that visitors can navigate subdomains during a chat session)

      // Settings for Chat
      //embedded_svc.settings.directToButtonRouting = function(prechatFormData) {
      // Dynamically changes the button ID based on what the visitor enters in the pre-chat form.
      // Returns a valid button ID.
      //};
      //embedded_svc.settings.prepopulatedPrechatFields = {}; //Sets the auto-population of pre-chat form fields
      //embedded_svc.settings.fallbackRouting = []; //An array of button IDs, user IDs, or userId_buttonId
      //embedded_svc.settings.offlineSupportMinimizedText = '...'; //(Defaults to Contact Us)

      embedded_svc.settings.enabledFeatures = ['LiveAgent'];
      embedded_svc.settings.entryFeature = 'LiveAgent';

      embedded_svc.init(
        'https://assuta--qa.my.salesforce.com',
        'https://qa-assuta.cs87.force.com',
        gslbBaseURL,
        '00D8E000000EA90',
        'test_to_deletes',
        {
          baseLiveAgentContentURL:
            'https://c.la1-c1cs-lo3.salesforceliveagent.com/content',
          deploymentId: '5724J0000008eG6',
          buttonId: '5734J0000008fox',
          baseLiveAgentURL:
            'https://d.la1-c1cs-lo3.salesforceliveagent.com/chat',
          eswLiveAgentDevName: 'test_to_deletes',
          isOfflineSupportEnabled: false
        }
      );
    };

    // @ts-ignore
    if (!window.embedded_svc) {
      var s = document.createElement('script');
      s.setAttribute(
        'src',
        'https://assuta.my.salesforce.com/embeddedservice/5.0/esw.min.js'
      );
      s.onload = function() {
        initESW(null);
      };
      document.body.appendChild(s);
    } else {
      initESW('https://service.force.com');
    }
  };

  var chatApp = new ChatApp(chatSettings);

  chatApp.start();
})();
