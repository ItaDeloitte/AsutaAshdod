/**@type {import("ActionModalInner").Helper} */
({
  init: function(cmp) {},

  uiScrollerWrapperCmp: function(cmp) {
    return cmp.find('bodyScroller');
  },

  scrollBody: function(cmp) {
    var bodyScrollerCmp = this.uiScrollerWrapperCmp(cmp);
    if (bodyScrollerCmp) {
      bodyScrollerCmp.scrollTo('top');
    }
  }
});