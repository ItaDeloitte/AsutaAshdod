/**@type {import("Tippy").Helper} */
({
  init: function(cmp) {},
  destroy: function(cmp) {},
  render: function(cmp) {},

  tippy: function(cmp, value) {
    return this.property(cmp, '_tippy', value);
  },
  triggerBtnCmp: function(cmp) {
    return cmp.find('triggerBtn');
  },
  triggerBtnElement: function(cmp) {
    var triggerBtnCmp = this.triggerBtnCmp(cmp);
    return triggerBtnCmp.getElement();
  },
  config: function(cmp) {
    /**@type {import('../../../../../typings/tippy').Tippy} */
    var tippy = window['tippy'];
    console.log(tippy);
    var buttonElement = this.triggerBtnElement(cmp);
    console.log(buttonElement);
    /**@type {import('../../../../../typings/tippy').Instance} */
    var tippyInstance = tippy(buttonElement, {
      content: 'content'
    });
    this.tippy(cmp, tippyInstance);
  }
});