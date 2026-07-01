/**@type {import("BaseModal").Helper} */
({
  init: function(cmp) {},
  /* Get/Set */
  backdropClose: function(cmp) {
    return this.attribute(cmp, 'backdropClose');
  },

  focusInputCmp: function(cmp) {
    return cmp.find('focusInput');
  },
  /* End Get/Set */

  onOpenChange: function(cmp, isOpen) {
    var paddingWidth = window.innerWidth - document.body.clientWidth;
    document.body.style.paddingRight = isOpen ? paddingWidth + 'px' : null;
    document.body.classList.toggle('is-modal-open', isOpen);
    if (isOpen) {
      this.focusInput(cmp);
    }
  },
  emitClose: function(cmp) {
    var event = cmp.getEvent('onclose');
    event.fire();
  },
  focusInput: function(cmp) {
    var focusInputCmp = this.focusInputCmp(cmp);
    if (focusInputCmp) {
      var inputEl = focusInputCmp.getElement();
      setTimeout(function() {
        inputEl.focus();
      });
    }
  },
  backdropClick: function(cmp) {
    var backdropClose = this.backdropClose(cmp);
    if (backdropClose) {
      this.emitClose(cmp);
    }
  }
});