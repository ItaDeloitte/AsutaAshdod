(function() {
  var searchParams = location.search.slice(
    location.search.indexOf('?') === 0 ? 1 : 0
  );

  var parsedSearchParams = searchParams.split('&').reduce((acc, item) => {
    var parsedItem = item.split('=');
    acc[encodeURIComponent(parsedItem[0])] = encodeURIComponent(parsedItem[1]);
    return acc;
  }, {});

  var settingScript = parsedSearchParams.settings;
  var sidebar = parsedSearchParams.sidebar === 'true';

  if (!settingScript) {
    return;
  }

  appendScript('../scripts/' + settingScript + '?v1')
    .then(function() {
      window.chatSettings.sidebar = sidebar;
      return appendScript('../scripts/chat-app.js?v1');
    })
    .catch((err) => {
      console.error(err);
    });

  function appendScript(src) {
    return new window.Promise(function(resolve, reject) {
      var scriptEl = document.createElement('script');
      scriptEl.src = src;
      scriptEl.onload = resolve;
      scriptEl.onerror = reject;
      document.body.appendChild(scriptEl);
    });
  }
})();
