import { LightningElement, api } from 'lwc';
import { ClassSet } from 'c/utils';

export default class MultiSelectItem extends LightningElement {
  @api key = '';
  @api value = '';
  @api label = '';
  @api selected = false;
  @api isOrdered = false;
  @api listOfOrder = []
  
  @api optionStyle;
  @api icon;

  connectedCallback() {}

  disconnectedCallback() {}

  get index() {
    const index = this.listOfOrder?.findIndex(option => option.value === this.value)
    return index === -1 ? '' : `${index+1}  |`
  }

  get listItemStyle() {
    return new ClassSet(
      'slds-media  slds-listbox__option_plain slds-media_small slds-listbox__option'
    )
      .add({
        'slds-is-selected': this.selected
      })
      .toString();
  }

  selectHandler(event) {
    // Prevents the anchor element from navigating to a URL.
    event.preventDefault();
    event.stopPropagation();
    const selectedEvent = new CustomEvent('selected', {
      detail: {
        label: this.label,
        value: this.value,
        selected: this.selected,
        shift: event.shiftKey
      }
    });
    this.dispatchEvent(selectedEvent);
  }
}