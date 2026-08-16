var linkEl = document.createElement('link');

linkEl.rel = 'stylesheet';
linkEl.href =
  'https://ongoingsup-myassuta.cs87.force.com/AssutaExternalResources/resource/assutaExternal/styles/chat-common.css?' +
  Math.random()
    .toString(16)
    .slice(2);

document.head.appendChild(linkEl);
