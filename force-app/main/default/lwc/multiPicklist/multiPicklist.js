import { LightningElement, api, track } from 'lwc';
import { idGeneratorService } from 'c/idGeneratorService';
import { ClassSet, utils } from 'c/utils';
import { labels } from './labels';

export default class MultiPicklist extends LightningElement {
  @api width = 100;
  @api variant = '';
  @api label = '';
  @api name = '';
  @api dropdownLength = 5;
  @api required = false;
  @api placeholder = labels.Placeholder;
  @api selectAllLabel = labels.SelectAll;
  @api selectAllDisabled = false;
  @api isOrderedOptionsPicklist = false;
  @api disabled = false;
  @api singleSelect = false;
  @api labelHidden = false;

  @track listOfOrder = [];
  @track _value = [];
  @track _options = [];
  isOpen = false;
  selectedPills = [];
  rendered = false;
  dynamicId = idGeneratorService.guid();
  error = '';
  customError = '';

  connectedCallback() {}

  disconnectedCallback() {}

  renderedCallback() {}

  @api
  get options() {
    return this._options;
  }
  set options(options) {
    this.rendered = false;
    this.parseOptions(options);
    this.parseValue(this._value);
  }

  @api
  get value() {
    return this.getSelectedValues();
  }
  set value(value) {
    this._value = value || [];
    this.parseValue(value);
  }

  get labels() {
    return labels;
  }

  get labelStyle() {
    return this.variant === 'label-hidden'
      ? ' slds-hide'
      : ' slds-form-element__label ';
  }

  get dropdownOuterStyle() {
    return (
      'slds-dropdown slds-dropdown_fluid multipicklist-dropdown slds-dropdown_length-' +
      this.dropdownLength
    );
  }

  get mainDivClass() {
    return new ClassSet(
      'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click'
    )
      .add({
        'slds-is-open': this.isOpen,
        'slds-has-error': this.hasError
      })
      .toString();
  }
  get valueText() {
    if (this.value.length === 0) {
      return '';
    }
    if (this.singleSelect) {
      return this.options.find(option => option.value === this.value?.at(0))?.label
    }
    if (this.isAllSelected) {
      return labels.AllSelected;
    }
    return utils.formatTemplateTextWithNamedParams(labels.SelectedNOptions, {
      current: this.value.length,
      all: this.options.length
    });
  }

  get hasError() {
    return !!this.error;
  }

  get hasCustomError() {
    return !!this.customError;
  }

  get isAllSelected() {
    return this.value.length === this.options.length;
  }

  @api
  checkValidity() {
    if (this.hasCustomError) {
      return false;
    }
    if (!this.required) {
      return true;
    }
    return this.value.length > 0;
  }

  @api
  reportValidity() {
    const isValid = this.checkValidity();
    if (!isValid) {
      this.error = this.hasCustomError
        ? this.customError
        : labels.ThisFieldIsRequired;
    } else {
      this.error = '';
    }
    return isValid;
  }

  @api
  showHelpMessageIfInvalid() {
    this.reportValidity();
  }

  @api
  focus() {
    // if (this._connected) {
    //   this.inputElement.focus();
    // }
  }

  @api
  blur() {
    // if (this._connected) {
    //   this.inputElement.blur();
    // }
  }

  parseValue(value) {
    if (!value || !this._options || this._options.length < 1) {
      return;
    }
    const valueSet = new Set(value);
    this._options = this._options.map(function (option) {
      if (valueSet.has(option.value)) {
        option.selected = true;
      }
      return option;
    });
    this.selectedPills = this.getPillArray();
  }

  /**
   *
   * @param {any[]} options
   */
  parseOptions(options) {
    if (Array.isArray(options)) {
      this._options = JSON.parse(JSON.stringify(options)).map((option, i) => {
        option.key = i;
        return option;
      });
    }
  }
  //private called by getter of 'value'
  getSelectedValues() {
    var values = [];
    //if no options set yet or invalid, just return value
    if (this._options.length < 1) {
      return this._value;
    }
    this._options.forEach(function (option) {
      if (option.selected === true) {
        values.push(option.value);
      }
    });
    return values;
  }

  openDropdown() {
    this.isOpen = true;
  }
  closeDropdown() {
    this.isOpen = false;
  }

  /**@param {*} event */
  inputKeyDownHandler(event) {
    const { code } = event;
    if (code === 'Enter' || code === 'Space') {
      event.preventDefault();
      this.toggleDropdown();
    }
  }

  /**@param {*} event */
  inputKeyUpHandler(event) {}

  inputClickHandler() {
    this.toggleDropdown();
  }

  toggleDropdown() {
    if (this.disabled) {
      return;
    }
    if (!this.isOpen) {
      this.openDropdown();
      window.addEventListener('click', this.handleClose);
    } else {
      this.closeDropdown();
      window.removeEventListener('click', this.handleClose);
    }
  }

  handleClose = (event) => {
    const { detail } = event;
    if (typeof detail === 'object' && detail.multiSelectId === this.dynamicId) {
      return;
    }
    if (this.isOpen) {
      this.closeDropdown();
      window.removeEventListener('click', this.handleClose);
    }
  };

  /**
   *
   * @param {*} event
   */
  formElementClickHandler(event) {
    event.preventDefault();
    event.stopPropagation();
    this.dispatchEvent(
      new CustomEvent('click', {
        detail: {
          multiSelectId: this.dynamicId
        },
        bubbles: true,
        composed: true,
        cancelable: true
      })
    );
  }

  handlePillRemove(event) {
    event.preventDefault();
    event.stopPropagation();

    const name = event.detail.item.name;

    this._options.forEach(function (element) {
      if (element.value === name) {
        element.selected = false;
      }
    });
    this.selectedPills = this.getPillArray();
    this.despatchChangeEvent();
  }

  handleSelectedClick(event) {
    event.preventDefault();
    event.stopPropagation();

    const { value, selected } = event.detail;

    this._options.forEach((option) => {
      if (this.singleSelect) {
        option.selected = false;
      }
      if (option.value === value) {
        option.selected = selected === true ? false : true;
        if (this.isOrderedOptionsPicklist) {
          if (selected !== true) {
            this.listOfOrder.push(option)
            this.listOfOrder = this.listOfOrder.slice()
          } else {
            const index = this.listOfOrder.findIndex(elem => elem.value === option.value)
            if (index !== -1) {
              this.listOfOrder.splice(index, 1);
            }
          }
        }
      }
    });
    this.selectedPills = this.getPillArray();
    this.despatchChangeEvent();
    this.reportValidity();
  }

  allSelectClickHandler() {
    const selectedValue = !this.isAllSelected;

    this._options.forEach((option) => {
      option.selected = selectedValue;
    });

    this.selectedPills = this.getPillArray();
    this.despatchChangeEvent();
    this.reportValidity();
  }

  despatchChangeEvent() {
    const value = this.isOrderedOptionsPicklist ? this.listOfOrder.map(item => item.value) : this.getSelectedValues();
    this.dispatchEvent(
      new CustomEvent('change', {
        detail: {
          value: value
        }
      })
    );
  }

  getPillArray() {
    var pills = [];
    this._options.forEach(function (element) {
      var interator = 0;
      if (element.selected) {
        pills.push({
          label: element.label,
          name: element.value,
          key: interator++
        });
      }
    });
    return pills;
  }
}