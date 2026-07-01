/**@type {import("MultiSelect").Helper} */
({
  init: function(cmp) {},
  destroy: function(cmp) {
    this.destroySelect(cmp);
  },
  render: function(cmp) {},

  multiSelectCmp: function(cmp) {
    return cmp.find('multiSelect');
  },
  $multiSelectEl: function(cmp) {
    return $(this.multiSelectCmp(cmp).getElement());
  },
  isCreated: function(cmp, value) {
    return this.attribute(cmp, 'isCreated', value);
  },
  value: function(cmp, value) {
    return this.attribute(cmp, 'value', value);
  },
  width: function(cmp, value) {
    return this.attribute(cmp, 'width', value);
  },
  placeholder: function(cmp, value) {
    return this.attribute(cmp, 'placeholder', value);
  },
  required: function(cmp, value) {
    return this.attribute(cmp, 'required', value);
  },
  isTouched: function(cmp, value) {
    return this.attribute(cmp, 'isTouched', value);
  },
  validity: function(cmp, value) {
    return this.attribute(cmp, 'validity', value);
  },
  options: function(cmp, value) {
    return this.attribute(cmp, 'options', value);
  },
  selectAll: function(cmp, value) {
    return this.attribute(cmp, 'selectAll', value);
  },
  single: function(cmp, value) {
    return this.attribute(cmp, 'single', value);
  },
  multiple: function(cmp, value) {
    return this.attribute(cmp, 'multiple', value);
  },
  hideOptgroupCheckboxes: function(cmp, value) {
    return this.attribute(cmp, 'hideOptgroupCheckboxes', value);
  },
  multipleWidth: function(cmp, value) {
    return this.attribute(cmp, 'multipleWidth', value);
  },
  dropWidth: function(cmp, value) {
    return this.attribute(cmp, 'dropWidth', value);
  },
  maxHeight: function(cmp, value) {
    return this.attribute(cmp, 'maxHeight', value);
  },
  position: function(cmp, value) {
    return this.attribute(cmp, 'position', value);
  },
  displayValues: function(cmp, value) {
    return this.attribute(cmp, 'displayValues', value);
  },
  displayTitle: function(cmp, value) {
    return this.attribute(cmp, 'displayTitle', value);
  },
  displayDelimiter: function(cmp, value) {
    return this.attribute(cmp, 'displayDelimiter', value);
  },
  minimumCountSelected: function(cmp, value) {
    return this.attribute(cmp, 'minimumCountSelected', value);
  },
  ellipsis: function(cmp, value) {
    return this.attribute(cmp, 'ellipsis', value);
  },
  isOpen: function(cmp, value) {
    return this.attribute(cmp, 'isOpen', value);
  },
  keepOpen: function(cmp, value) {
    return this.attribute(cmp, 'keepOpen', value);
  },
  openOnHover: function(cmp, value) {
    return this.attribute(cmp, 'openOnHover', value);
  },
  container: function(cmp, value) {
    return this.attribute(cmp, 'container', value);
  },
  filter: function(cmp, value) {
    return this.attribute(cmp, 'filter', value);
  },
  filterGroup: function(cmp, value) {
    return this.attribute(cmp, 'filterGroup', value);
  },
  filterPlaceholder: function(cmp, value) {
    return this.attribute(cmp, 'filterPlaceholder', value);
  },
  filterAcceptOnEnter: function(cmp, value) {
    return this.attribute(cmp, 'filterAcceptOnEnter', value);
  },
  animate: function(cmp, value) {
    return this.attribute(cmp, 'animate', value);
  },
  formatFns: function(cmp, value) {
    return this.attribute(cmp, 'formatFns', value);
  },
  selectAllLabel: function(cmp, value) {
    return this.attribute(cmp, 'selectAllLabel', value);
  },
  allSelectedLabel: function(cmp, value) {
    return this.attribute(cmp, 'allSelectedLabel', value);
  },
  noMatchesFoundLabel: function(cmp, value) {
    return this.attribute(cmp, 'noMatchesFoundLabel', value);
  },
  disabled: function(cmp, value) {
    return this.attribute(cmp, 'disabled', value);
  },
  isOpened: function(cmp, value) {
    return this.attribute(cmp, 'isOpened', value);
  },

  initSelect: function(cmp) {
    var $selectEl = this.$multiSelectEl(cmp);
    var configOptions = this.buildConfigOptions(cmp);
    $selectEl.multipleSelect(configOptions);
    var value = this.value(cmp);
    this.setSelects(cmp, value);
  },
  destroySelect: function(cmp) {
    var $selectEl = this.$multiSelectEl(cmp);
    $selectEl.multipleSelect('destroy');
    this.isCreated(cmp, false);
  },
  buildConfigOptions: function(cmp) {
    var formatFns = this.formatFns(cmp);
    var selectAllLabel = this.selectAllLabel(cmp);
    var allSelectedLabel = this.allSelectedLabel(cmp);
    var noMatchesFoundLabel = this.noMatchesFoundLabel(cmp);

    /**@type {import('MultiSelect').BuildLabelFormatFn} */
    function buildLabelFormatFn(label) {
      if (!label) {
        return;
      }
      return function() {
        return label;
      };
    }

    var options = {
      width: this.width(cmp),
      placeholder: this.placeholder(cmp),
      selectAll: this.selectAll(cmp),
      single: this.single(cmp),
      multiple: this.multiple(cmp),
      hideOptgroupCheckboxes: this.hideOptgroupCheckboxes(cmp),
      multipleWidth: this.multipleWidth(cmp),
      dropWidth: this.dropWidth(cmp),
      maxHeight: this.maxHeight(cmp),
      position: this.position(cmp),
      displayValues: this.displayValues(cmp),
      displayTitle: this.displayTitle(cmp),
      displayDelimiter: this.displayDelimiter(cmp),
      minimumCountSelected: this.minimumCountSelected(cmp),
      ellipsis: this.ellipsis(cmp),
      isOpen: this.isOpen(cmp),
      keepOpen: this.keepOpen(cmp),
      openOnHover: this.openOnHover(cmp),
      // container:this.container(cmp),
      filter: this.filter(cmp),
      filterGroup: this.filterGroup(cmp),
      filterPlaceholder: this.filterPlaceholder(cmp),
      filterAcceptOnEnter: this.filterAcceptOnEnter(cmp),
      animate: this.animate(cmp),
      textTemplate: formatFns.textTemplate,
      labelTemplate: formatFns.labelTemplate,
      styler: formatFns.styler,
      formatSelectAll: buildLabelFormatFn(selectAllLabel),
      formatAllSelected: buildLabelFormatFn(allSelectedLabel),
      formatCountSelected: formatFns.formatCountSelected,
      formatNoMatchesFound: buildLabelFormatFn(noMatchesFoundLabel),
      onOpen: this.openHandler.bind(this, cmp),
      onClose: this.closeHandler.bind(this, cmp),
      onCheckAll: this.checkAllHandler.bind(this, cmp),
      onUncheckAll: this.uncheckAllHandler.bind(this, cmp),
      onFocus: this.focusHandler.bind(this, cmp),
      onBlur: this.blurHandler.bind(this, cmp),
      onOptgroupClick: this.optgroupClickHandler.bind(this, cmp),
      onClick: this.clickHandler.bind(this, cmp),
      onFilter: this.filterHandler.bind(this, cmp),
      onAfterCreate: this.afterCreateHandler.bind(this, cmp)
    };
    return options;
  },
  getSelects: function(cmp, type) {
    return this.callSelectMethod(cmp, 'getSelects', type);
  },
  setSelects: function(cmp, values) {
    return this.callSelectMethod(cmp, 'setSelects', values);
  },
  enable: function(cmp) {
    return this.callSelectMethod(cmp, 'enable');
  },
  disable: function(cmp) {
    return this.callSelectMethod(cmp, 'disable');
  },
  open: function(cmp) {
    return this.callSelectMethod(cmp, 'open');
  },
  close: function(cmp) {
    return this.callSelectMethod(cmp, 'close');
  },
  focus: function(cmp) {
    return this.callSelectMethod(cmp, 'focus');
  },
  blur: function(cmp) {
    return this.callSelectMethod(cmp, 'blur');
  },
  checkAll: function(cmp) {
    return this.callSelectMethod(cmp, 'checkAll');
  },
  uncheckAll: function(cmp) {
    return this.callSelectMethod(cmp, 'uncheckAll');
  },
  refreshSelect: function(cmp) {
    setTimeout(this.callSelectMethod.bind(this, cmp, 'refresh'));
  },
  callSelectMethod: function(cmp, methodName, params) {
    var isCreated = this.isCreated(cmp);
    if (!isCreated) {
      return;
    }
    var $selectEl = this.$multiSelectEl(cmp);
    if (!$selectEl) {
      return;
    }
    return $selectEl.multipleSelect(methodName, params);
  },

  openHandler: function(cmp) {
    this.isOpened(cmp, true);
    this.emitEvent(cmp, 'onopen');
  },
  closeHandler: function(cmp) {
    this.isOpened(cmp, false);
    this.isTouched(cmp, true);
    this.validate(cmp);
    this.emitEvent(cmp, 'onclose');
  },
  checkAllHandler: function(cmp) {
    this.valueChangeHandler(cmp);
  },
  uncheckAllHandler: function(cmp) {
    this.valueChangeHandler(cmp);
  },
  focusHandler: function(cmp) {
    this.emitEvent(cmp, 'onfocus');
  },
  blurHandler: function(cmp) {
    this.isTouched(cmp, true);
    this.validate(cmp);
    this.emitEvent(cmp, 'onblur');
  },
  optgroupClickHandler: function(cmp, view) {
    this.valueChangeHandler(cmp);
  },
  clickHandler: function(cmp, view) {
    this.valueChangeHandler(cmp);
  },
  filterHandler: function(cmp, text) {},
  afterCreateHandler: function(cmp) {
    this.isCreated(cmp, true);
    this.emitEvent(cmp, 'oncreate');
  },
  valueChangeHandler: function(cmp) {
    var value = this.getSelects(cmp);
    this.value(cmp, value);
    this.validate(cmp);
    this.emitEvent(cmp, 'onchange', { value: value });
  },
  reset: function(cmp) {
    this.setSelects(cmp, []);
    this.isTouched(cmp, false);
  },
  validate: function(cmp) {
    var validity = {
      valid: true,
      valueMissing: false
    };
    var value = this.value(cmp);

    var required = this.required(cmp);
    if (required && value.length === 0) {
      validity.valueMissing = true;
      validity.valid = false;
    }
    this.validity(cmp, validity);
    return validity;
  },
  setValue: function(cmp, value) {
    this.value(cmp, value);
    this.setSelects(cmp, value);
    this.validate(cmp);
  },

  changeDisabledHandler: function(cmp) {
    var disabled = this.disabled(cmp);
    if (disabled) {
      this.disable(cmp);
    } else {
      this.enable(cmp);
    }
  },
  rebuild: function(cmp) {
    this.destroySelect(cmp);
    this.initSelect(cmp);
  }
});