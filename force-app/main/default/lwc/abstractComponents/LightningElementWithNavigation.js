//@ts-check
import { LightningElement, wire } from 'lwc';
// @ts-ignore
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';

/**
 * @extends LightningElement
 */
export class LightningElementWithNavigation extends NavigationMixin(
  LightningElement
) {
  @wire(CurrentPageReference) pageRef;

  connectedCallback() {}

  disconnectedCallback() {}

  /**
   * @returns {LightningElement}
   */
  get elementRef() {
    return /**@type {any}*/ (this);
  }
}