// import env from '@salesforce/label/c.environment';

const env = 'development';

const isCommunity = /\/s\//.test(window.location.href);
const sldsResourcePrefix = isCommunity
  ? window.location.pathname.match(/(.*)\/s\//i)[1]
  : window.location.origin;
const sldsIconsPath = `${sldsResourcePrefix}/_slds/icons`;

// const RESOURCE_URL = APP_URL.match(/.*\/resource/i)[0];
const RESOURCE_URL = '';

const isEdgeUA = /\bEdge\/.(\d+)\b/.test(navigator.userAgent);
const inIframe = window.top !== window.self;
const isIframeInEdge = isEdgeUA && inIframe;

const newerIEUA = /\bTrident\/[567]\b|\bMSIE (?:9|10)\.0\b/;
const webkitUA = /\bAppleWebKit\/(\d+)\b/;
const olderEdgeUA = /\bEdge\/12\.(\d+)\b/;
const isIE =
  newerIEUA.test(navigator.userAgent) ||
  (navigator.userAgent.match(olderEdgeUA) || [])[1] < 10547 ||
  (navigator.userAgent.match(webkitUA) || [])[1] < 537;

const supportsSvg = !isIE && !isIframeInEdge;

export const appConfig = {
  env: env,
  isDevelopment: env === 'dev' || env === 'development',
  isCommunity,
  isEdgeUA,
  inIframe,
  isIframeInEdge,
  supportsSvg,
  sldsResourcePrefix,
  sldsIconsPath,
  sldsIconSprites: {
    utility: `${sldsIconsPath}/utility-sprite/svg/symbols.svg`
  },
  resourceUrl: RESOURCE_URL,
  defaultImages: {}
};