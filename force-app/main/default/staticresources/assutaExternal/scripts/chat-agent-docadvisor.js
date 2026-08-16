(function() {
  var enLabels = {
    contactUs: 'Contact Us'
  };
  var iwLabels = {
    contactUs: 'צור קשר'
  };

  var labels = iwLabels;
  window.chatSettings = {
    sidebar: false,
    isAgent: true,
    labels: labels,
    sysCode:'doc_advisor',
    host: 'https://myassuta.secure.force.com',
    contactUsRedirectUrl: 'https://www.assuta.co.il/contact_us',
    initEsvFn: function(config) {
      var targetElement = config.targetElement;
      var preInitCallback = config.preInitCallback || function() {};

      var initESW = function(gslbBaseURL) {
        // @ts-ignore
        var embedded_svc = window.embedded_svc;
        embedded_svc.settings.targetElement = targetElement;
        embedded_svc.settings.displayHelpButton = true; //Or false
        embedded_svc.settings.language = 'iw'; //For example, enter 'en' or 'en-US'

        embedded_svc.settings.defaultMinimizedText = "צ'אט עם נציג"; //(Defaults to Chat with an Expert)
        embedded_svc.settings.disabledMinimizedText = 'צור קשר'; //(Defaults to Agent Offline)
        embedded_svc.settings.offlineSupportMinimizedText = labels.contactUs; //(Defaults to Contact Us)
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

        preInitCallback(embedded_svc);

        embedded_svc.init(
          'https://assuta.my.salesforce.com',
          'https://assuta.force.com',
          gslbBaseURL,
          '00D4J000000D53o',
          'AssutaBot_Demo',
          {
            baseLiveAgentContentURL:
              'https://c.la1-c2-lo2.salesforceliveagent.com/content',
            deploymentId: '5724J0000008eap',
            buttonId: '5734J0000008hkH',
            baseLiveAgentURL:
              'https://d.la1-c2-lo2.salesforceliveagent.com/chat',
            eswLiveAgentDevName:
              'EmbeddedServiceLiveAgent_Parent04I4J0000008ORhUAM_16a7378faa0',
            isOfflineSupportEnabled: true
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
    }
  };
})();
