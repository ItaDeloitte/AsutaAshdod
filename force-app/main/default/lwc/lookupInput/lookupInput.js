import { LightningElement, track, api } from 'lwc';
import { idGeneratorService } from 'c/idGeneratorService';
import { labels } from './labels';

const MINIMAL_SEARCH_TERM_LENGTH = 2;
const SEARCH_DELAY = 300; // Wait 300 ms after user stops typing then, peform search

export default class LookupInput extends LightningElement {
  dynamicId = idGeneratorService.guid();
  labels = labels;
  @api name;
  @api label;
  @api pluralLabel;
  @api selection;
  @api placeholder = '';
  @api isMultiEntry = false;
  @api errors = [];
  @api scrollAfterNItems = 5;
  @api customKey;
  @api showIcon = false;
  @api initSearch = false;
  @api minSearchTermLength = MINIMAL_SEARCH_TERM_LENGTH; // Min number of chars required to search
  @api required = false;
  @api noResultsLabel = labels.NoResults;
  @api isReadonly = false;
  @api maxMultiSelections;
  @api help;
  @api openSearch = false;

  @track searchTerm = '';
  @track searchResults = [];
  @track hasFocus = false;
  @track loading = false;
  @track isOpen = false;

  cleanSearchTerm;
  blurTimeout;
  searchThrottlingTimeout;

  connectedCallback() {
    this.attachDocumentListener();
    if (this.isMultiEntry && !Array.isArray(this.selection)) {
      this.selection = [];
    }
    const minSearchTermLength = parseInt(this.minSearchTermLength, 10);
    this.minSearchTermLength = isNaN(minSearchTermLength)
      ? MINIMAL_SEARCH_TERM_LENGTH
      : minSearchTermLength;
    if (!this.openSearch) {
      this.initialSearch();
    }
  }

  disconnectedCallback() {
    this.clearDocumentListener();
  }

  documentClickListener = (event) => {
    const { detail } = event;
    if (typeof detail === 'object' && detail.id === this.dynamicId) {
      return;
    }
    if (this.isOpen) {
      this.isOpen = false;
    }
  };

  attachDocumentListener() {
    document.addEventListener('click', this.documentClickListener);
  }

  clearDocumentListener() {
    document.removeEventListener('click', this.documentClickListener);
  }

  formElementClickHandler(event) {
    event.preventDefault();
    event.stopPropagation();
    this.dispatchEvent(
      new CustomEvent('click', {
        detail: {
          id: this.dynamicId
        },
        bubbles: true,
        composed: true,
        cancelable: true
      })
    );
  }

  get inputEl() {
    return this.template.querySelector('input');
  }

  // EXPOSED FUNCTIONS

  @api
  setNoResultsLabel(label){
    this.noResultsLabel = label ? label : labels.NoResults
  }

  @api
  setSearchResults(results) {
    // Reset the spinner
    this.loading = false;

    this.searchResults = results.map((result) => {
      // Clone and complete search result if icon is missing
      if (typeof result.icon === 'undefined') {
        const { id, sObjectType, title, subtitle } = result;
        return {
          id,
          sObjectType,
          icon: 'standard:default',
          title,
          subtitle
        };
      }
      return result;
    });
  }

  @api
  getSelection() {
    return this.selection;
  }

  @api
  getkey() {
    return this.customKey;
  }

  @api
  showHelpMessageIfInvalid() {
    this.reportValidity();
  }

  @api
  checkValidity() {
    if (!this.required) {
      return true;
    }
    if (this.isMultiEntry) {
      return Array.isArray(this.selection) && this.selection.length > 0;
    }
    return this.selection && this.selection.id;
  }

  @api
  reportValidity() {
    const isValid = this.checkValidity();
    if (!isValid) {
      const errMessage = this.isMultiEntry
        ? labels.MultiFieldRequired
        : labels.FieldRequired;
      const error = this.buildError(errMessage);

      this.errors = [error];
    } else {
      this.errors = [];
    }
    return isValid;
  }

  @api
  setCustomValidity(message) {
    const error = this.buildError(message);
    this.errors = [...this.errors, error];
  }

  @api resetErrors() {
    this.errors = [];
  }

  @api setErrors(errors) {
    this.errors = [...errors];
  }

  @api focus() {
    this.focusInput();
  }

  @api focusInput() {
    const inputEl = this.inputEl;
    if (inputEl) {
      inputEl.focus();
    }
  }

  @api triggerSearch() {
    this.updateSearchTerm(this.searchTerm, true);
  }

  // INTERNAL FUNCTIONS

  updateSearchTerm(newSearchTerm, force) {
    this.searchTerm = newSearchTerm;

    // Compare clean new search term with current one and abort if identical
    const newCleanSearchTerm = newSearchTerm
      .trim()
      .replace(/\*/g, '')
      .toLowerCase();
    if (this.cleanSearchTerm === newCleanSearchTerm && !force) {
      return;
    }

    // Save clean search term
    this.cleanSearchTerm = newCleanSearchTerm;

    // Ignore search terms that are too small
    if (newCleanSearchTerm.length < this.minSearchTermLength) {
      this.searchResults = [];
      return;
    }

    // Apply search throttling (prevents search if user is still typing)
    if (this.searchThrottlingTimeout) {
      clearTimeout(this.searchThrottlingTimeout);
    }
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    this.searchThrottlingTimeout = setTimeout(() => {
      // Send search event if search term is long enougth
      if (this.cleanSearchTerm.length >= this.minSearchTermLength) {
        // Display spinner until results are returned
        this.loading = true;
        let selectedIds = [];

        if (this.isMultiEntry) {
          selectedIds = this.selection.map((element) => element.id);
        } else if (this.selection) {
          selectedIds.push(this.selection.id);
        }

        const searchEvent = new CustomEvent('search', {
          detail: {
            searchTerm: this.cleanSearchTerm,
            selectedIds: selectedIds
          }
        });
        this.dispatchEvent(searchEvent);
      }
      this.searchThrottlingTimeout = null;
    }, SEARCH_DELAY);
  }

  initialSearch() {
    // eslint-disable-next-line @lwc/lwc/no-async-operation
    setTimeout(() => {
      if (this.isMultiEntry) {
        this.updateSearchTerm(this.searchTerm, true);
      } else if (!this.hasSelection()) {
        this.updateSearchTerm(this.searchTerm, true);
      }
    }, 50);
  }

  isSelectionAllowed() {
    if (this.isMultiEntry) {
      return true;
    }
    return !this.hasSelection();
  }

  hasResults() {
    return this.searchResults.length > 0;
  }

  hasSelection() {
    if (this.isMultiEntry) {
      return this.selection.length > 0;
    }
    return !!this.selection;
  }

  // EVENT HANDLING

  handleInput(event) {
    // Prevent action if selection is not allowed
    if (!this.isSelectionAllowed()) {
      return;
    }
    this.updateSearchTerm(event.target.value);
  }

  handleResultClick(event) {
    this.isOpen = false;
    const recordId = event.currentTarget.dataset.recordid;

    // Save selection
    let selectedItem = this.searchResults.filter(
      (result) => result.id === recordId
    );
    if (selectedItem.length === 0) {
      return;
    }
    selectedItem = selectedItem[0];
    if (this.isMultiEntry) {
      if (
        this.maxMultiSelections > 0 &&
        this.selection.length < this.maxMultiSelections
      ) {
        this.selection = [...this.selection, selectedItem];
      }
    } else {
      this.selection = selectedItem;
    }

    // Reset search
    this.searchTerm = '';
    this.searchResults = [];
    this.resetErrors();

    // Notify parent components that selection has changed
    this.dispatchEvent(new CustomEvent('selectionchange'));
    if (this.isMultiEntry) {
      this.updateSearchTerm(this.searchTerm, true);
    }
  }

  handleComboboxClick() {
    // Hide combobox immediatly
    if (this.blurTimeout) {
      window.clearTimeout(this.blurTimeout);
    }
    this.hasFocus = false;
  }

  handleFocus() {
    // Prevent action if selection is not allowed
    if (!this.isSelectionAllowed()) {
      return;
    }
    this.hasFocus = true;
    this.isOpen = true;
    if (this.openSearch) {
      this.searchResults = [];
      this.triggerSearch();
    }
    this.dispatchEvent(new CustomEvent('lookupfocus'));
  }

  handleBlur() {
    // Prevent action if selection is not allowed

    if (!this.isSelectionAllowed()) {
      return;
    }
    this.hasFocus = false;
    this.dispatchEvent(new CustomEvent('lookupblur'));
  }

  handleRemoveSelectedItem(event) {
    const recordId = event.currentTarget.name;
    this.selection = this.selection.filter((item) => item.id !== recordId);
    // Notify parent components that selection has changed
    this.dispatchEvent(new CustomEvent('selectionchange'));
    if (this.isMultiEntry) {
      this.updateSearchTerm(this.searchTerm, true);
    }
  }

  handleClearSelection() {
    if (this.isMultiEntry) {
      this.selection = [];
    } else {
      this.selection = null;
    }

    // Notify parent components that selection has changed
    this.dispatchEvent(new CustomEvent('selectionchange'));
    this.updateSearchTerm('', true);
    this.focusInput();
  }

  // STYLE EXPRESSIONS

  get getContainerClass() {
    let css = 'slds-combobox_container slds-has-inline-listbox ';
    if (this.hasFocus && this.hasResults()) {
      css += 'slds-has-input-focus ';
    }
    if (this.errors.length > 0) {
      css += 'has-custom-error';
    }
    return css;
  }

  get getDropdownClass() {
    let css =
      'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ';
    if (
      this.isOpen
      // &&
      // this.cleanSearchTerm &&
      // this.cleanSearchTerm.length >= this.minSearchTermLength
    ) {
      css += 'slds-is-open';
    }
    return css;
  }

  get getInputClass() {
    let css =
      'slds-input slds-combobox__input has-custom-height ' +
      (this.errors.length === 0 ? '' : 'has-custom-error ');
    if (!this.isMultiEntry) {
      css +=
        'slds-combobox__input-value ' +
        (this.hasSelection() ? 'has-custom-border' : '');
    }
    return css;
  }

  get getComboboxClass() {
    let css = 'slds-combobox__form-element slds-input-has-icon ';
    if (this.isMultiEntry) {
      css += 'slds-input-has-icon_right';
    } else {
      css +=
        this.hasSelection() && this.showIcon
          ? 'slds-input-has-icon_left-right'
          : 'slds-input-has-icon_right';
    }
    return css;
  }

  get getSearchIconClass() {
    let css = 'slds-input__icon slds-input__icon_right ';
    if (!this.isMultiEntry) {
      css += this.hasSelection() ? 'slds-hide' : '';
    }
    return css;
  }

  get getClearSelectionButtonClass() {
    return (
      'slds-button slds-button_icon slds-input__icon slds-input__icon_right ' +
      (this.hasSelection() ? '' : 'slds-hide')
    );
  }

  get getSelectIconName() {
    if (this.hasSelection()) {
      const icon = this.isMultiEntry
        ? this.selection[0].icon
        : this.selection.icon;
      return icon || 'standard:default';
    }
    return 'standard:default';
  }

  get getSelectIconClass() {
    return (
      'slds-combobox__input-entity-icon ' +
      (this.hasSelection() ? '' : 'slds-hide')
    );
  }

  get formElementClass() {
    return `slds-form-element ${this.showIcon ? 'has-icon' : ''}`;
  }

  get getInputValue() {
    if (this.isMultiEntry) {
      return this.searchTerm;
    }
    return this.hasSelection() ? this.selection.title : this.searchTerm;
  }

  get getInputTitle() {
    if (this.isMultiEntry) {
      return '';
    }

    return this.hasSelection() ? this.selection.title : '';
  }

  get getListboxClass() {
    return (
      'slds-listbox slds-listbox_vertical slds-dropdown slds-dropdown_fluid ' +
      (this.scrollAfterNItems
        ? 'slds-dropdown_length-with-icon-' + this.scrollAfterNItems
        : '')
    );
  }

  get isInputReadonly() {
    if (this.isReadonly) {
      return true;
    }
    if (this.isMultiEntry) {
      return false;
    }
    return this.hasSelection();
  }

  get isInputDisabled() {
    if (this.isMultiEntry) {
      return (
        this.maxMultiSelections > 0 &&
        this.selection.length === this.maxMultiSelections
      );
    }
    return false;
  }

  get isExpanded() {
    return this.hasResults();
  }

  get isMultiResultsVisible() {
    return this.isMultiEntry && this.hasSelection();
  }

  /**
   *
   * @param {string} message
   */
  buildError(message) {
    return { key: idGeneratorService.guid(), message: message };
  }
}