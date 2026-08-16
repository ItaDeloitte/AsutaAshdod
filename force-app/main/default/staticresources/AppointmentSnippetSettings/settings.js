var initESW = function(gslbBaseURL) {
  embedded_svc.settings.displayHelpButton = true; //Or false
  embedded_svc.settings.allowGuestUsers = true;
  embedded_svc.settings.language = ""; //For example, enter 'en' or 'en-US'

  embedded_svc.settings.defaultMinimizedText = "Chat"; //(Defaults to Chat with an Expert)
  //embedded_svc.settings.disabledMinimizedText = '...'; //(Defaults to Agent Offline)

  //embedded_svc.settings.loadingText = ''; //(Defaults to Loading)
  //embedded_svc.settings.storageDomain = 'yourdomain.com'; //(Sets the domain for your deployment so that visitors can navigate subdomains during a chat session)

  // Settings for Chat
  //embedded_svc.settings.directToButtonRouting = function(prechatFormData) {
  // Dynamically changes the button ID based on what the visitor enters in the pre-chat form.
  // Returns a valid button ID.
  //};

  //Sets the auto-population of pre-chat form fields
  embedded_svc.settings.prepopulatedPrechatFields = {
    Appointment_Id_From_bot__c: getAppointmentId()
  };

  embedded_svc.snippetSettingsFile.extraPrechatFormDetails = [
    {
      label: "Appointment Id From bot",
      transcriptFields: ["Appointment_Id_From_bot__c"],
      value: getAppointmentId(),
      displayToAgent: true
    }
  ];

  //embedded_svc.settings.fallbackRouting = []; //An array of button IDs, user IDs, or userId_buttonId
  //embedded_svc.settings.offlineSupportMinimizedText = '...'; //(Defaults to Contact Us)

  embedded_svc.settings.enabledFeatures = ["LiveAgent"];
  embedded_svc.settings.entryFeature = "LiveAgent";

  embedded_svc.init(
    "https://assuta--dev.my.salesforce.com",
    "https://dev-myassutadev.cs87.force.com/",
    gslbBaseURL,
    "00D8E0000000ot9",
    "test_continue_bot",
    {
      baseLiveAgentContentURL:
        "https://c.la1-c2cs-lo2.salesforceliveagent.com/content",
      deploymentId: "5728E00000000a5",
      buttonId: "5738E00000000o2",
      baseLiveAgentURL: "https://d.la1-c2cs-lo2.salesforceliveagent.com/chat",
      eswLiveAgentDevName:
        "EmbeddedServiceLiveAgent_Parent04I8E000000Cc8jUAC_16e3bcabf8d",
      isOfflineSupportEnabled: false
    }
  );
};

function getAppointmentId() {
  const urlParams = new URLSearchParams(window.location.search);
  return urlParams.get("id");
}
if (!window.location.href.includes("?id=test")) {
  window.location.href = window.location.href + "?id=test";
}

if (!window.embedded_svc) {
  var s = document.createElement("script");

  s.setAttribute(
    "src",
    "https://assuta--dev.my.salesforce.com/embeddedservice/5.0/esw.min.js"
  );
  s.onload = function() {
    initESW(null);
  };
  document.body.appendChild(s);
} else {
  initESW("https://service.force.com");
}
