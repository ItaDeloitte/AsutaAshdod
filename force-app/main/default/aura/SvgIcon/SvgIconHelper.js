//@ts-check
/**@type {import("SvgIcon").Helper} */
({
  init: function(cmp) {},
  CONSTANTS: {
    namespaces: {
      svg: 'http://www.w3.org/2000/svg',
      xlink: 'http://www.w3.org/1999/xlink'
    },
    svgClassName: 'slds-icon'
  },

  src: function(cmp, value) {
    return this.attribute(cmp, 'src', value);
  },
  prevSrc: function(cmp, value) {
    return this.attribute(cmp, 'prevSrc', value);
  },
  type: function(cmp, value) {
    return this.attribute(cmp, 'type', value);
  },

  container: function(cmp) {
    return cmp.find('container');
  },

  destroy: function(cmp) {},

  renderIcon: function(cmp) {
    var src = this.src(cmp);
    var container = this.container(cmp);
    /** @type {HTMLElement} */
    var containerEl = container.getElement();
    var svgEl = containerEl.querySelector('svg');
    if (svgEl) {
      return this.updateSvgIcon(svgEl, src);
    }
    svgEl = this.buildSvgIcon(src);
    containerEl.appendChild(svgEl);
  },

  buildSvgIcon: function(iconSrc) {
    var namespaces = this.CONSTANTS.namespaces;
    /**@type {Object} */
    var svgEl = document.createElementNS(namespaces.svg, 'svg');
    var useEl = document.createElementNS(namespaces.svg, 'use');
    useEl.setAttributeNS(namespaces.xlink, 'xlink:href', iconSrc);
    svgEl.setAttribute('class', this.CONSTANTS.svgClassName);
    svgEl.appendChild(useEl);
    return svgEl;
  },

  updateSvgIcon: function(svgEl, iconSrc) {
    var namespaces = this.CONSTANTS.namespaces;
    var useEl = svgEl.querySelector('use');
    if (useEl) {
      useEl.setAttributeNS(namespaces.xlink, 'xlink:href', iconSrc);
    }
  }
});